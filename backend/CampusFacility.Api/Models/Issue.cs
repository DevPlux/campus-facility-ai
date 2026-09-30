using CampusFacility.Api.Enums;

namespace CampusFacility.Api.Models
{
    public class Issue
    {
        public int Id { get; set; }
        public int ReporterId { get; set; }
        public required string Title { get; set; }
        public required string Description { get; set; }
        public required string Location { get; set; }
        public IssueCategory? Category { get; set; }
        public Priority? Priority { get; set; }
        public string? RequiredSkill { get; set; }
        public string? AiSummary { get; set; }
        public IssueStatus Status { get; set; } = IssueStatus.OPEN;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public User Reporter { get; set; } = null!;
        public ICollection<IssueImage> Images { get; set; } = new List<IssueImage>();
        public ICollection<IssueStatusHistory> StatusHistory { get; set; } = new List<IssueStatusHistory>();
        public ICollection<AgentRun> AgentRuns { get; set; } = new List<AgentRun>();
        public ICollection<Assignment> Assignments { get; set; } = new List<Assignment>();
    }
}
