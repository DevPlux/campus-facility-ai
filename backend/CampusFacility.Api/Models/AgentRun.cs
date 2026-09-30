using CampusFacility.Api.Enums;

namespace CampusFacility.Api.Models
{
    public class AgentRun
    {
        public int Id { get; set; }
        public int IssueId { get; set; }
        public AgentType AgentType { get; set; }
        public AgentRunStatus Status { get; set; }
        public string? OutputJson { get; set; }
        public string? ErrorMessage { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? CompletedAt { get; set; }

        public Issue Issue { get; set; } = null!;
    }
}
