namespace CampusFacility.Api.DTOs.Agents
{
    public class TechnicianAssignmentResult
    {
        public int IssueId { get; set; }
        public int TechnicianId { get; set; }
        public string Reason { get; set; } = string.Empty;
    }

    public class TechnicianCandidate
    {
        public int TechnicianId { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Skill { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
    }
}