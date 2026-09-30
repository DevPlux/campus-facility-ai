using CampusFacility.Api.Data;
using CampusFacility.Api.DTOs.Technicians;
using CampusFacility.Api.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CampusFacility.Api.Services
{
    public class TechnicianService
    {
        private readonly AppDbContext _context;

        public TechnicianService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<TechnicianDto>> GetAllTechniciansAsync()
        {
            var technicians = await _context.Technicians
                .Include(t => t.User)
                .OrderBy(t => t.User.Name)
                .AsNoTracking()
                .ToListAsync();

            return technicians.Select(t => new TechnicianDto
            {
                Id = t.Id,
                UserId = t.UserId,
                Name = t.User.Name,
                Email = t.User.Email,
                Skill = t.Skill,
                IsAvailable = t.IsAvailable
            }).ToList();
        }

        public async Task<List<TechnicianTaskDto>> GetMyTasksAsync(int userId)
        {
            var technician = await _context.Technicians
                .FirstOrDefaultAsync(t => t.UserId == userId);

            if (technician == null)
            {
                throw new Exception("Technician record not found for the current user.");
            }

            var allowedStatuses = new[] { "ASSIGNED", "IN_PROGRESS", "COMPLETED" };

            var assignments = await _context.Assignments
                .Include(a => a.Issue)
                .ThenInclude(i => i.Images)
                .Where(a => a.TechnicianId == technician.Id && allowedStatuses.Contains(a.Status))
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();

            return assignments.Select(a => new TechnicianTaskDto
            {
                AssignmentId = a.Id,
                IssueId = a.IssueId,
                Title = a.Issue.Title,
                Description = a.Issue.Description,
                Location = a.Issue.Location,
                Category = a.Issue.Category?.ToString().ToUpperInvariant(),
                Priority = a.Issue.Priority?.ToString().ToUpperInvariant(),
                RequiredSkill = a.Issue.RequiredSkill,
                AiSummary = a.Issue.AiSummary,
                IssueStatus = a.Issue.Status.ToString().ToUpperInvariant(),
                AssignmentStatus = a.Status,
                RecommendationReason = a.AiReason,
                BeforeImageUrl = a.Issue.Images.FirstOrDefault(img => img.ImageType == ImageType.BEFORE)?.ImageUrl,
                AfterImageUrl = a.Issue.Images.FirstOrDefault(img => img.ImageType == ImageType.AFTER)?.ImageUrl,
                CreatedAt = a.CreatedAt,
                ApprovedAt = a.ApprovedAt
            }).ToList();
        }
    }
}
