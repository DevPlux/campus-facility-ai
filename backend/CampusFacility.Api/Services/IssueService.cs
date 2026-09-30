using CampusFacility.Api.Data;
using CampusFacility.Api.DTOs.Issues;
using CampusFacility.Api.Enums;
using CampusFacility.Api.Models;
using CampusFacility.Api.Services.Agents;
using Microsoft.EntityFrameworkCore;

namespace CampusFacility.Api.Services
{
    public class IssueService
    {
        private readonly AppDbContext _context;
        private readonly ISupabaseStorageService _storageService;
        private readonly IssueAnalysisAgent _aiAgent;

        public IssueService(AppDbContext context, ISupabaseStorageService storageService, IssueAnalysisAgent aiAgent)
        {
            _context = context;
            _storageService = storageService;
            _aiAgent = aiAgent;
        }

        public async Task<IssueDto?> CreateIssueAsync(int reporterId, CreateIssueRequestDto request)
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var issue = new Issue
                {
                    ReporterId = reporterId,
                    Title = request.Title.Trim(),
                    Description = request.Description.Trim(),
                    Location = request.Location.Trim(),
                    Status = IssueStatus.OPEN,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Issues.Add(issue);
                await _context.SaveChangesAsync();

                var publicUrl = await _storageService.UploadIssueImageAsync(request.Image, issue.Id);
                if (string.IsNullOrEmpty(publicUrl))
                    throw new Exception("Supabase upload returned empty URL.");

                _context.IssueImages.Add(new IssueImage
                {
                    IssueId = issue.Id,
                    ImageUrl = publicUrl,
                    ImageType = ImageType.BEFORE,
                    UploadedAt = DateTime.UtcNow
                });
                await _context.SaveChangesAsync();

                var analysis = await _aiAgent.AnalyzeAsync(issue.Title, issue.Description, issue.Location);
                if (analysis != null)
                {
                    if (Enum.TryParse<IssueCategory>(analysis.Category, true, out var cat)) issue.Category = cat;
                    if (Enum.TryParse<Priority>(analysis.Priority, true, out var prio)) issue.Priority = prio;
                    
                    issue.RequiredSkill = analysis.RequiredSkill;
                    issue.AiSummary = analysis.Summary;
                    issue.Status = IssueStatus.ANALYZED;
                    await _context.SaveChangesAsync();

                    if (!string.IsNullOrEmpty(issue.RequiredSkill))
                    {
                        var tech = await _context.Technicians
                            .Where(t => t.IsAvailable && (t.Skill.ToLower() == issue.RequiredSkill.ToLower() || issue.RequiredSkill.ToLower().Contains(t.Skill.ToLower())))
                            .FirstOrDefaultAsync();

                        if (tech != null)
                        {
                            var assignment = new Assignment
                            {
                                IssueId = issue.Id,
                                TechnicianId = tech.Id,
                                CreatedAt = DateTime.UtcNow,
                                Status = "PENDING_APPROVAL",
                                AiReason = $"AI recommended skill '{issue.RequiredSkill}' which matches technician."
                            };
                            _context.Assignments.Add(assignment);
                            issue.Status = IssueStatus.PENDING_APPROVAL;
                            await _context.SaveChangesAsync();
                        }
                        else
                        {
                            issue.Status = IssueStatus.WAITING_FOR_TECHNICIAN;
                            await _context.SaveChangesAsync();
                        }
                    }
                }
                
                await transaction.CommitAsync();

                return new IssueDto
                {
                    Id = issue.Id,
                    Title = issue.Title,
                    Description = issue.Description,
                    Location = issue.Location,
                    Category = issue.Category?.ToString().ToUpperInvariant(),
                    Priority = issue.Priority?.ToString().ToUpperInvariant(),
                    RequiredSkill = issue.RequiredSkill,
                    AiSummary = issue.AiSummary,
                    Status = issue.Status.ToString().ToUpperInvariant(),
                    BeforeImageUrl = publicUrl,
                    CreatedAt = issue.CreatedAt
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }

        public async Task<List<IssueDto>> GetMyIssuesAsync(int reporterId)
        {
            var issues = await _context.Issues
                .Include(i => i.Images)
                .Where(i => i.ReporterId == reporterId)
                .OrderByDescending(i => i.CreatedAt)
                .ToListAsync();

            return issues.Select(i => new IssueDto
            {
                Id = i.Id,
                Title = i.Title,
                Description = i.Description,
                Location = i.Location,
                Category = i.Category?.ToString().ToUpperInvariant(),
                Priority = i.Priority?.ToString().ToUpperInvariant(),
                RequiredSkill = i.RequiredSkill,
                AiSummary = i.AiSummary,
                Status = i.Status.ToString().ToUpperInvariant(),
                BeforeImageUrl = i.Images.FirstOrDefault(img => img.ImageType == ImageType.BEFORE)?.ImageUrl,
                AfterImageUrl = i.Images.FirstOrDefault(img => img.ImageType == ImageType.AFTER)?.ImageUrl,
                CreatedAt = i.CreatedAt
            }).ToList();
        }

        public async Task<List<ManagerIssueListDto>> GetAllIssuesAsync(string? status, string? category, string? priority)
        {
            var query = _context.Issues
                .Include(i => i.Reporter)
                .Include(i => i.Images)
                .Include(i => i.Assignments)
                    .ThenInclude(a => a.Technician)
                        .ThenInclude(t => t.User)
                .AsQueryable();

            if (!string.IsNullOrEmpty(status) && Enum.TryParse<IssueStatus>(status, true, out var parsedStatus))
                query = query.Where(i => i.Status == parsedStatus);

            if (!string.IsNullOrEmpty(category) && Enum.TryParse<IssueCategory>(category, true, out var parsedCategory))
                query = query.Where(i => i.Category == parsedCategory);

            if (!string.IsNullOrEmpty(priority) && Enum.TryParse<Priority>(priority, true, out var parsedPriority))
                query = query.Where(i => i.Priority == parsedPriority);

            var issues = await query.OrderByDescending(i => i.CreatedAt).ToListAsync();

            return issues.Select(i =>
            {
                var currentAssignment = i.Assignments.OrderByDescending(a => a.CreatedAt).FirstOrDefault();
                return new ManagerIssueListDto
                {
                    Id = i.Id,
                    Title = i.Title,
                    Description = i.Description,
                    Location = i.Location,
                    Status = i.Status.ToString().ToUpperInvariant(),
                    Category = i.Category?.ToString().ToUpperInvariant(),
                    Priority = i.Priority?.ToString().ToUpperInvariant(),
                    RequiredSkill = i.RequiredSkill,
                    AiSummary = i.AiSummary,
                    ReporterName = i.Reporter?.Name ?? "Unknown",
                    BeforeImageUrl = i.Images.FirstOrDefault(img => img.ImageType == ImageType.BEFORE)?.ImageUrl,
                    AfterImageUrl = i.Images.FirstOrDefault(img => img.ImageType == ImageType.AFTER)?.ImageUrl,
                    CreatedAt = i.CreatedAt,
                    TechnicianName = currentAssignment?.Technician?.User?.Name,
                    AssignmentStatus = currentAssignment?.Status,
                    AssignmentId = currentAssignment?.Id,
                    RecommendationReason = currentAssignment?.AiReason,
                    
                };
            }).ToList();
        }

        public async Task<IssueDetailDto?> GetIssueByIdAsync(int id, int userId, string role)
        {
            var query = _context.Issues
                .Include(i => i.Reporter)
                .Include(i => i.Images)
                .Include(i => i.Assignments)
                    .ThenInclude(a => a.Technician)
                        .ThenInclude(t => t.User)
                .Include(i => i.StatusHistory)
                .Where(i => i.Id == id);

            if (role == "REPORTER")
                query = query.Where(i => i.ReporterId == userId);
            else if (role == "TECHNICIAN")
                query = query.Where(i => i.Assignments.Any(a => a.Technician.UserId == userId));

            var issue = await query.FirstOrDefaultAsync();
            if (issue == null) return null;

            var currentAssignment = issue.Assignments.OrderByDescending(a => a.CreatedAt).FirstOrDefault();

            return new IssueDetailDto
            {
                Id = issue.Id,
                Title = issue.Title,
                Description = issue.Description,
                Location = issue.Location,
                Status = issue.Status.ToString().ToUpperInvariant(),
                Category = issue.Category?.ToString().ToUpperInvariant(),
                Priority = issue.Priority?.ToString().ToUpperInvariant(),
                RequiredSkill = issue.RequiredSkill,
                AiSummary = issue.AiSummary,
                ReporterId = issue.ReporterId,
                ReporterName = issue.Reporter?.Name ?? "Unknown",
                ReporterEmail = issue.Reporter?.Email ?? "Unknown",
                CreatedAt = issue.CreatedAt,
                BeforeImageUrl = issue.Images.FirstOrDefault(img => img.ImageType == ImageType.BEFORE)?.ImageUrl,
                AfterImageUrl = issue.Images.FirstOrDefault(img => img.ImageType == ImageType.AFTER)?.ImageUrl,
                TechnicianId = currentAssignment?.TechnicianId,
                TechnicianName = currentAssignment?.Technician?.User?.Name,
                TechnicianSkill = currentAssignment?.Technician?.Skill,
                TechnicianIsAvailable = currentAssignment?.Technician?.IsAvailable,
                AssignmentId = currentAssignment?.Id,
                AssignmentStatus = currentAssignment?.Status,
                RecommendationReason = currentAssignment?.AiReason,

                AssignmentCreatedAt = currentAssignment?.CreatedAt,
                ApprovedAt = currentAssignment?.ApprovedAt,
                ApprovedBy = currentAssignment?.ApprovedBy
            };
        }
    }
}






