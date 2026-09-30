using CampusFacility.Api.Data;
using CampusFacility.Api.DTOs.Assignments;
using CampusFacility.Api.Enums;
using CampusFacility.Api.Models;
using Microsoft.EntityFrameworkCore;
using System;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace CampusFacility.Api.Services
{
    public class AssignmentService
    {
        private readonly AppDbContext _context;
        private readonly ISupabaseStorageService _storageService;

        public AssignmentService(AppDbContext context, ISupabaseStorageService storageService)
        {
            _context = context;
            _storageService = storageService;
        }

        public async Task<bool> ApproveAssignmentAsync(int assignmentId, int managerId)
        {
            var assignment = await _context.Assignments
                .Include(a => a.Issue)
                .Include(a => a.Technician)
                .FirstOrDefaultAsync(a => a.Id == assignmentId && a.Status == "PENDING_APPROVAL");

            if (assignment == null) throw new Exception("Assignment not found or not in pending status.");
            if (assignment.Issue.Status != IssueStatus.PENDING_APPROVAL) throw new Exception("Issue is not in pending approval status.");
            if (!assignment.Technician.IsAvailable || assignment.Technician.Skill != assignment.Issue.RequiredSkill) throw new Exception("Technician is no longer available or skill mismatch.");

            var activeAssignments = await _context.Assignments.AnyAsync(a => a.TechnicianId == assignment.TechnicianId && (a.Status == "ASSIGNED" || a.Status == "IN_PROGRESS"));
            if (activeAssignments) throw new Exception("Technician already has an active assignment.");

            assignment.Status = "ASSIGNED";
            assignment.ApprovedBy = managerId;
            assignment.ApprovedAt = DateTime.UtcNow;
            assignment.Technician.IsAvailable = false;

            _context.IssueStatusHistory.Add(new IssueStatusHistory
            {
                IssueId = assignment.IssueId,
                OldStatus = assignment.Issue.Status,
                NewStatus = IssueStatus.ASSIGNED,
                ChangedBy = managerId,
                ChangedAt = DateTime.UtcNow
            });
            assignment.Issue.Status = IssueStatus.ASSIGNED;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> RejectAssignmentAsync(int assignmentId, int managerId)
        {
            var assignment = await _context.Assignments.Include(a => a.Issue).FirstOrDefaultAsync(a => a.Id == assignmentId && a.Status == "PENDING_APPROVAL");
            if (assignment == null) throw new Exception("Assignment not found.");

            assignment.Status = "REJECTED";
            _context.IssueStatusHistory.Add(new IssueStatusHistory
            {
                IssueId = assignment.IssueId,
                OldStatus = assignment.Issue.Status,
                NewStatus = IssueStatus.ANALYZED,
                ChangedBy = managerId,
                ChangedAt = DateTime.UtcNow
            });
            assignment.Issue.Status = IssueStatus.ANALYZED;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> StartAssignmentAsync(int assignmentId, int userId)
        {
            var assignment = await _context.Assignments.Include(a => a.Issue).Include(a => a.Technician).FirstOrDefaultAsync(a => a.Id == assignmentId);
            if (assignment == null) throw new KeyNotFoundException("Assignment not found.");
            if (assignment.Technician.UserId != userId) throw new UnauthorizedAccessException("This assignment does not belong to the logged-in technician.");
            if (assignment.Status != "ASSIGNED" || assignment.Issue.Status != IssueStatus.ASSIGNED) throw new InvalidOperationException("Assignment is not in ASSIGNED state.");

            assignment.Status = "IN_PROGRESS";
            _context.IssueStatusHistory.Add(new IssueStatusHistory
            {
                IssueId = assignment.IssueId,
                OldStatus = assignment.Issue.Status,
                NewStatus = IssueStatus.IN_PROGRESS,
                ChangedBy = userId,
                ChangedAt = DateTime.UtcNow
            });
            assignment.Issue.Status = IssueStatus.IN_PROGRESS;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CompleteAssignmentAsync(int assignmentId, int userId, CompleteAssignmentRequestDto request)
        {
            var assignment = await _context.Assignments.Include(a => a.Issue).Include(a => a.Technician).FirstOrDefaultAsync(a => a.Id == assignmentId);
            if (assignment == null) throw new KeyNotFoundException("Assignment not found.");
            if (assignment.Technician.UserId != userId) throw new UnauthorizedAccessException("This assignment does not belong to the logged-in technician.");
            if (assignment.Status != "IN_PROGRESS" || assignment.Issue.Status != IssueStatus.IN_PROGRESS) throw new InvalidOperationException("Assignment is not in IN_PROGRESS state.");

            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var publicUrl = await _storageService.UploadIssueImageAsync(request.Image, assignment.IssueId, "after");
                if (string.IsNullOrEmpty(publicUrl)) throw new Exception("Supabase upload returned empty URL.");

                _context.IssueImages.Add(new IssueImage
                {
                    IssueId = assignment.IssueId,
                    ImageUrl = publicUrl,
                    ImageType = ImageType.AFTER,
                    UploadedAt = DateTime.UtcNow
                });

                assignment.CompletionNote = request.CompletionNote;
                assignment.Status = "COMPLETED";
                
                _context.IssueStatusHistory.Add(new IssueStatusHistory
                {
                    IssueId = assignment.IssueId,
                    OldStatus = assignment.Issue.Status,
                    NewStatus = IssueStatus.COMPLETED,
                    ChangedBy = userId,
                    ChangedAt = DateTime.UtcNow
                });

                assignment.Issue.Status = IssueStatus.COMPLETED;
                assignment.Technician.IsAvailable = true;

                await _context.SaveChangesAsync();

                var waitingIssue = await _context.Issues
                    .Where(i => i.Status == IssueStatus.WAITING_FOR_TECHNICIAN 
                           && i.RequiredSkill != null 
                           && (i.RequiredSkill.ToLower() == assignment.Technician.Skill.ToLower() || i.RequiredSkill.ToLower().Contains(assignment.Technician.Skill.ToLower())))
                    .OrderBy(i => i.CreatedAt)
                    .FirstOrDefaultAsync();

                if (waitingIssue != null)
                {
                    var newAssignment = new Assignment
                    {
                        IssueId = waitingIssue.Id,
                        TechnicianId = assignment.TechnicianId,
                        CreatedAt = DateTime.UtcNow,
                        Status = "PENDING_APPROVAL",
                        AiReason = $"Automated Queue: AI recommended skill '{waitingIssue.RequiredSkill}' which matches technician."
                    };
                    _context.Assignments.Add(newAssignment);
                    waitingIssue.Status = IssueStatus.PENDING_APPROVAL;
                    await _context.SaveChangesAsync();
                }

                await transaction.CommitAsync();
                return true;
            }
            catch
            {
                try { await transaction.RollbackAsync(); } catch { }
                throw;
            }
        }
    }
}
