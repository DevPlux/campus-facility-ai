namespace CampusFacility.Api.Models
{
    public class Assignment
    {
        public int Id { get; set; }
        public int IssueId { get; set; }
        public int TechnicianId { get; set; }
        public required string Status { get; set; }
        public string? AiReason { get; set; }
        public string? CompletionNote { get; set; }
        public int? ApprovedBy { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public Issue Issue { get; set; } = null!;
        public Technician Technician { get; set; } = null!;
        public User? ApprovedByUser { get; set; }
    }
}
