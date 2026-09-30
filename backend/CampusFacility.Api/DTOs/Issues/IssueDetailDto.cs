using System;

namespace CampusFacility.Api.DTOs.Issues
{
    public class IssueDetailDto
    {
        public int Id { get; set; }
        public required string Title { get; set; }
        public required string Description { get; set; }
        public required string Location { get; set; }
        public string? Category { get; set; }
        public string? Priority { get; set; }
        public string? RequiredSkill { get; set; }
        public string? AiSummary { get; set; }
        public required string Status { get; set; }
        public string? BeforeImageUrl { get; set; }
        public string? AfterImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }

        public int ReporterId { get; set; }
        public required string ReporterName { get; set; }
        public required string ReporterEmail { get; set; }

        public int? AssignmentId { get; set; }
        public string? AssignmentStatus { get; set; }
        public string? RecommendationReason { get; set; }
        public DateTime? AssignmentCreatedAt { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public int? ApprovedBy { get; set; }

        public int? TechnicianId { get; set; }
        public string? TechnicianName { get; set; }
        public string? TechnicianSkill { get; set; }
        public bool? TechnicianIsAvailable { get; set; }

        public string? CompletionNote { get; set; }
    }
}
