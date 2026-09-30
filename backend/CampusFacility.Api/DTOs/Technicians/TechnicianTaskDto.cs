using System;

namespace CampusFacility.Api.DTOs.Technicians
{
    public class TechnicianTaskDto
    {
        public int AssignmentId { get; set; }
        public int IssueId { get; set; }
        public required string Title { get; set; }
        public required string Description { get; set; }
        public required string Location { get; set; }
        public string? Category { get; set; }
        public string? Priority { get; set; }
        public string? RequiredSkill { get; set; }
        public string? AiSummary { get; set; }
        public required string IssueStatus { get; set; }
        public required string AssignmentStatus { get; set; }
        public string? RecommendationReason { get; set; }
        public string? BeforeImageUrl { get; set; }
        public string? AfterImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ApprovedAt { get; set; }
    }
}
