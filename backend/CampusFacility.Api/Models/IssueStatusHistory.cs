using CampusFacility.Api.Enums;

namespace CampusFacility.Api.Models
{
    public class IssueStatusHistory
    {
        public int Id { get; set; }
        public int IssueId { get; set; }
        public IssueStatus OldStatus { get; set; }
        public IssueStatus NewStatus { get; set; }
        public int ChangedBy { get; set; }
        public DateTime ChangedAt { get; set; } = DateTime.UtcNow;

        public Issue Issue { get; set; } = null!;
        public User ChangedByUser { get; set; } = null!;
    }
}
