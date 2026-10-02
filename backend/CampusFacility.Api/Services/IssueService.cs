using CampusFacility.Api.Data;
using CampusFacility.Api.DTOs.Agents;
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

        // Agent 1 - Issue Analysis
        private readonly IssueAnalysisAgent _aiAgent;

        // Agent 2 - Technician Assignment
        private readonly TechnicianAssignmentAgent _assignmentAgent;


        public IssueService(
            AppDbContext context,
            ISupabaseStorageService storageService,
            IssueAnalysisAgent aiAgent,
            TechnicianAssignmentAgent assignmentAgent)
        {
            _context = context;
            _storageService = storageService;
            _aiAgent = aiAgent;
            _assignmentAgent = assignmentAgent;
        }


        // ============================================================
        // CREATE ISSUE
        // ============================================================

        public async Task<IssueDto?> CreateIssueAsync(
            int reporterId,
            CreateIssueRequestDto request)
        {
            await using var transaction =
                await _context.Database.BeginTransactionAsync();

            try
            {
                // ====================================================
                // 1. CREATE ISSUE
                // ====================================================

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


                // ====================================================
                // 2. UPLOAD BEFORE IMAGE
                // ====================================================

                var publicUrl =
                    await _storageService.UploadIssueImageAsync(
                        request.Image,
                        issue.Id);

                if (string.IsNullOrEmpty(publicUrl))
                {
                    throw new Exception(
                        "Supabase upload returned empty URL.");
                }

                _context.IssueImages.Add(
                    new IssueImage
                    {
                        IssueId = issue.Id,
                        ImageUrl = publicUrl,
                        ImageType = ImageType.BEFORE,
                        UploadedAt = DateTime.UtcNow
                    });

                await _context.SaveChangesAsync();


                // ====================================================
                // 3. AGENT 1 - ISSUE ANALYSIS
                // ====================================================

                var analysis =
                    await _aiAgent.AnalyzeAsync(
                        issue.Title,
                        issue.Description,
                        issue.Location);

                if (analysis != null)
                {
                    if (Enum.TryParse<IssueCategory>(
                            analysis.Category,
                            true,
                            out var cat))
                    {
                        issue.Category = cat;
                    }

                    if (Enum.TryParse<Priority>(
                            analysis.Priority,
                            true,
                            out var prio))
                    {
                        issue.Priority = prio;
                    }

                    issue.RequiredSkill =
                        analysis.RequiredSkill;

                    issue.AiSummary =
                        analysis.Summary;

                    issue.Status =
                        IssueStatus.ANALYZED;

                    await _context.SaveChangesAsync();


                    // =================================================
                    // 4. AGENT 2 - TECHNICIAN ASSIGNMENT
                    // =================================================

                    if (!string.IsNullOrEmpty(
                            issue.RequiredSkill))
                    {
                        // ---------------------------------------------
                        // Step 4.1
                        // Backend retrieves available technicians.
                        //
                        // Agent 2 does NOT have direct database access.
                        // ---------------------------------------------

                        var availableTechnicians =
                            await _context.Technicians
                                .Include(t => t.User)
                                .Where(t =>
                                    t.IsAvailable &&
                                    !_context.Assignments.Any(a =>
                                        a.TechnicianId == t.Id &&
                                        (
                                            a.Status == "ASSIGNED" ||
                                            a.Status == "IN_PROGRESS"
                                        )))
                                .ToListAsync();


                        // ---------------------------------------------
                        // Step 4.2
                        // Deterministically filter candidates by skill.
                        //
                        // Only safe/eligible technicians are supplied
                        // to Agent 2.
                        // ---------------------------------------------

                        var eligibleTechnicians =
                            availableTechnicians
                                .Where(t =>
                                    t.Skill.Equals(
                                        issue.RequiredSkill,
                                        StringComparison
                                            .OrdinalIgnoreCase)
                                    ||
                                    issue.RequiredSkill.Contains(
                                        t.Skill,
                                        StringComparison
                                            .OrdinalIgnoreCase))
                                .ToList();


                        // ---------------------------------------------
                        // Step 4.3
                        // No technician currently satisfies the
                        // required skill and availability conditions.
                        // ---------------------------------------------

                        if (eligibleTechnicians.Count == 0)
                        {
                            issue.Status =
                                IssueStatus
                                    .WAITING_FOR_TECHNICIAN;

                            await _context.SaveChangesAsync();
                        }
                        else
                        {
                            // -----------------------------------------
                            // Step 4.4
                            // Build controlled Agent 2 input.
                            // -----------------------------------------

                            var candidates =
                                eligibleTechnicians
                                    .Select(t =>
                                        new TechnicianCandidate
                                        {
                                            TechnicianId = t.Id,

                                            Name =
                                                t.User?.Name
                                                ?? "Unknown",

                                            Skill = t.Skill,

                                            IsAvailable =
                                                t.IsAvailable
                                        })
                                    .ToList();


                            // -----------------------------------------
                            // Step 4.5
                            // Agent 2 asks Gemini to recommend ONE
                            // technician from the supplied candidates.
                            // -----------------------------------------

                            var recommendation =
                                await _assignmentAgent
                                    .RecommendAsync(
                                        issue.Id,
                                        issue.Title,
                                        issue.Description,
                                        issue.Location,

                                        issue.Category
                                            ?.ToString(),

                                        issue.Priority
                                            ?.ToString(),

                                        issue.RequiredSkill,

                                        candidates);


                            if (recommendation == null)
                            {
                                issue.Status =
                                    IssueStatus
                                        .WAITING_FOR_TECHNICIAN;

                                await _context
                                    .SaveChangesAsync();
                            }
                            else
                            {
                                // =====================================
                                // 5. DETERMINISTIC VALIDATION
                                // =====================================
                                //
                                // Never trust the AI recommendation
                                // without backend validation.
                                // =====================================


                                // -------------------------------------
                                // Validate that Agent 2 selected a
                                // technician from the candidate list.
                                // -------------------------------------

                                var selectedTechnician =
                                    eligibleTechnicians
                                        .FirstOrDefault(t =>
                                            t.Id ==
                                            recommendation
                                                .TechnicianId);

                                if (selectedTechnician == null)
                                {
                                    throw new
                                        InvalidOperationException(
                                            "Assignment Agent selected a technician outside the eligible candidate list.");
                                }


                                // -------------------------------------
                                // Re-check technician availability.
                                // -------------------------------------

                                if (!selectedTechnician.IsAvailable)
                                {
                                    issue.Status =
                                        IssueStatus
                                            .WAITING_FOR_TECHNICIAN;

                                    await _context
                                        .SaveChangesAsync();
                                }
                                else
                                {
                                    // ---------------------------------
                                    // Re-check skill compatibility.
                                    // ---------------------------------

                                    var skillMatches =
                                        selectedTechnician.Skill
                                            .Equals(
                                                issue.RequiredSkill,
                                                StringComparison
                                                    .OrdinalIgnoreCase)
                                        ||
                                        issue.RequiredSkill
                                            .Contains(
                                                selectedTechnician
                                                    .Skill,

                                                StringComparison
                                                    .OrdinalIgnoreCase);

                                    if (!skillMatches)
                                    {
                                        throw new
                                            InvalidOperationException(
                                                "Assignment Agent selected a technician with an incompatible skill.");
                                    }


                                    // ---------------------------------
                                    // Re-check active assignments.
                                    //
                                    // This protects the workflow even
                                    // if IsAvailable is stale.
                                    // ---------------------------------

                                    var hasActiveAssignment =
                                        await _context.Assignments
                                            .AnyAsync(a =>
                                                a.TechnicianId ==
                                                    selectedTechnician.Id
                                                &&
                                                (
                                                    a.Status ==
                                                        "ASSIGNED"
                                                    ||
                                                    a.Status ==
                                                        "IN_PROGRESS"
                                                ));

                                    if (hasActiveAssignment)
                                    {
                                        issue.Status =
                                            IssueStatus
                                                .WAITING_FOR_TECHNICIAN;

                                        await _context
                                            .SaveChangesAsync();
                                    }
                                    else
                                    {
                                        // =============================
                                        // 6. HUMAN-IN-THE-LOOP
                                        // =============================
                                        //
                                        // Agent 2 recommends only.
                                        //
                                        // Manager must approve before
                                        // the assignment becomes final.
                                        // =============================

                                        var assignment =
                                            new Assignment
                                            {
                                                IssueId =
                                                    issue.Id,

                                                TechnicianId =
                                                    selectedTechnician
                                                        .Id,

                                                CreatedAt =
                                                    DateTime.UtcNow,

                                                Status =
                                                    "PENDING_APPROVAL",

                                                AiReason =
                                                    recommendation
                                                        .Reason
                                            };

                                        _context.Assignments.Add(
                                            assignment);

                                        issue.Status =
                                            IssueStatus
                                                .PENDING_APPROVAL;

                                        await _context
                                            .SaveChangesAsync();
                                    }
                                }
                            }
                        }
                    }
                }


                // ====================================================
                // 7. COMMIT TRANSACTION
                // ====================================================

                await transaction.CommitAsync();


                // ====================================================
                // 8. RETURN CREATED ISSUE
                // ====================================================

                return new IssueDto
                {
                    Id = issue.Id,
                    Title = issue.Title,
                    Description = issue.Description,
                    Location = issue.Location,

                    Category =
                        issue.Category
                            ?.ToString()
                            .ToUpperInvariant(),

                    Priority =
                        issue.Priority
                            ?.ToString()
                            .ToUpperInvariant(),

                    RequiredSkill =
                        issue.RequiredSkill,

                    AiSummary =
                        issue.AiSummary,

                    Status =
                        issue.Status
                            .ToString()
                            .ToUpperInvariant(),

                    BeforeImageUrl =
                        publicUrl,

                    CreatedAt =
                        issue.CreatedAt
                };
            }
            catch
            {
                await transaction.RollbackAsync();
                throw;
            }
        }


        // ============================================================
        // GET REPORTER'S ISSUES
        // ============================================================

        public async Task<List<IssueDto>>
            GetMyIssuesAsync(int reporterId)
        {
            var issues =
                await _context.Issues
                    .Include(i => i.Images)
                    .Where(i =>
                        i.ReporterId == reporterId)
                    .OrderByDescending(i =>
                        i.CreatedAt)
                    .ToListAsync();

            return issues
                .Select(i => new IssueDto
                {
                    Id = i.Id,
                    Title = i.Title,
                    Description = i.Description,
                    Location = i.Location,

                    Category =
                        i.Category
                            ?.ToString()
                            .ToUpperInvariant(),

                    Priority =
                        i.Priority
                            ?.ToString()
                            .ToUpperInvariant(),

                    RequiredSkill =
                        i.RequiredSkill,

                    AiSummary =
                        i.AiSummary,

                    Status =
                        i.Status
                            .ToString()
                            .ToUpperInvariant(),

                    BeforeImageUrl =
                        i.Images
                            .FirstOrDefault(img =>
                                img.ImageType ==
                                ImageType.BEFORE)
                            ?.ImageUrl,

                    AfterImageUrl =
                        i.Images
                            .FirstOrDefault(img =>
                                img.ImageType ==
                                ImageType.AFTER)
                            ?.ImageUrl,

                    CreatedAt =
                        i.CreatedAt
                })
                .ToList();
        }


        // ============================================================
        // GET ALL ISSUES - MANAGER
        // ============================================================

        public async Task<List<ManagerIssueListDto>>
            GetAllIssuesAsync(
                string? status,
                string? category,
                string? priority)
        {
            var query =
                _context.Issues

                    .Include(i => i.Reporter)

                    .Include(i => i.Images)

                    .Include(i => i.Assignments)
                        .ThenInclude(a =>
                            a.Technician)
                            .ThenInclude(t =>
                                t.User)

                    .AsQueryable();


            // Status filter
            if (!string.IsNullOrEmpty(status)
                &&
                Enum.TryParse<IssueStatus>(
                    status,
                    true,
                    out var parsedStatus))
            {
                query =
                    query.Where(i =>
                        i.Status == parsedStatus);
            }


            // Category filter
            if (!string.IsNullOrEmpty(category)
                &&
                Enum.TryParse<IssueCategory>(
                    category,
                    true,
                    out var parsedCategory))
            {
                query =
                    query.Where(i =>
                        i.Category == parsedCategory);
            }


            // Priority filter
            if (!string.IsNullOrEmpty(priority)
                &&
                Enum.TryParse<Priority>(
                    priority,
                    true,
                    out var parsedPriority))
            {
                query =
                    query.Where(i =>
                        i.Priority == parsedPriority);
            }


            var issues =
                await query
                    .OrderByDescending(i =>
                        i.CreatedAt)
                    .ToListAsync();


            return issues
                .Select(i =>
                {
                    var currentAssignment =
                        i.Assignments
                            .OrderByDescending(a =>
                                a.CreatedAt)
                            .FirstOrDefault();


                    return new ManagerIssueListDto
                    {
                        Id = i.Id,
                        Title = i.Title,
                        Description = i.Description,
                        Location = i.Location,

                        Status =
                            i.Status
                                .ToString()
                                .ToUpperInvariant(),

                        Category =
                            i.Category
                                ?.ToString()
                                .ToUpperInvariant(),

                        Priority =
                            i.Priority
                                ?.ToString()
                                .ToUpperInvariant(),

                        RequiredSkill =
                            i.RequiredSkill,

                        AiSummary =
                            i.AiSummary,

                        ReporterName =
                            i.Reporter?.Name
                            ?? "Unknown",

                        BeforeImageUrl =
                            i.Images
                                .FirstOrDefault(img =>
                                    img.ImageType ==
                                    ImageType.BEFORE)
                                ?.ImageUrl,

                        AfterImageUrl =
                            i.Images
                                .FirstOrDefault(img =>
                                    img.ImageType ==
                                    ImageType.AFTER)
                                ?.ImageUrl,

                        CreatedAt =
                            i.CreatedAt,

                        TechnicianName =
                            currentAssignment
                                ?.Technician
                                ?.User
                                ?.Name,

                        AssignmentStatus =
                            currentAssignment
                                ?.Status,

                        AssignmentId =
                            currentAssignment
                                ?.Id,

                        RecommendationReason =
                            currentAssignment
                                ?.AiReason
                    };
                })
                .ToList();
        }


        // ============================================================
        // GET ISSUE DETAILS
        // ============================================================

        public async Task<IssueDetailDto?>
            GetIssueByIdAsync(
                int id,
                int userId,
                string role)
        {
            var query =
                _context.Issues

                    .Include(i =>
                        i.Reporter)

                    .Include(i =>
                        i.Images)

                    .Include(i =>
                        i.Assignments)
                        .ThenInclude(a =>
                            a.Technician)
                            .ThenInclude(t =>
                                t.User)

                    .Include(i =>
                        i.StatusHistory)

                    .Where(i =>
                        i.Id == id);


            // Reporter can only view their own issue.
            if (role == "REPORTER")
            {
                query =
                    query.Where(i =>
                        i.ReporterId == userId);
            }

            // Technician can only view issues
            // assigned to them.
            else if (role == "TECHNICIAN")
            {
                query =
                    query.Where(i =>
                        i.Assignments.Any(a =>
                            a.Technician.UserId ==
                            userId));
            }


            var issue =
                await query.FirstOrDefaultAsync();

            if (issue == null)
            {
                return null;
            }


            var currentAssignment =
                issue.Assignments
                    .OrderByDescending(a =>
                        a.CreatedAt)
                    .FirstOrDefault();


            return new IssueDetailDto
            {
                Id = issue.Id,
                Title = issue.Title,
                Description = issue.Description,
                Location = issue.Location,

                Status =
                    issue.Status
                        .ToString()
                        .ToUpperInvariant(),

                Category =
                    issue.Category
                        ?.ToString()
                        .ToUpperInvariant(),

                Priority =
                    issue.Priority
                        ?.ToString()
                        .ToUpperInvariant(),

                RequiredSkill =
                    issue.RequiredSkill,

                AiSummary =
                    issue.AiSummary,

                ReporterId =
                    issue.ReporterId,

                ReporterName =
                    issue.Reporter?.Name
                    ?? "Unknown",

                ReporterEmail =
                    issue.Reporter?.Email
                    ?? "Unknown",

                CreatedAt =
                    issue.CreatedAt,

                BeforeImageUrl =
                    issue.Images
                        .FirstOrDefault(img =>
                            img.ImageType ==
                            ImageType.BEFORE)
                        ?.ImageUrl,

                AfterImageUrl =
                    issue.Images
                        .FirstOrDefault(img =>
                            img.ImageType ==
                            ImageType.AFTER)
                        ?.ImageUrl,

                TechnicianId =
                    currentAssignment
                        ?.TechnicianId,

                TechnicianName =
                    currentAssignment
                        ?.Technician
                        ?.User
                        ?.Name,

                TechnicianSkill =
                    currentAssignment
                        ?.Technician
                        ?.Skill,

                TechnicianIsAvailable =
                    currentAssignment
                        ?.Technician
                        ?.IsAvailable,

                AssignmentId =
                    currentAssignment
                        ?.Id,

                AssignmentStatus =
                    currentAssignment
                        ?.Status,

                RecommendationReason =
                    currentAssignment
                        ?.AiReason,

                AssignmentCreatedAt =
                    currentAssignment
                        ?.CreatedAt,

                ApprovedAt =
                    currentAssignment
                        ?.ApprovedAt,

                ApprovedBy =
                    currentAssignment
                        ?.ApprovedBy
            };
        }
    }
}