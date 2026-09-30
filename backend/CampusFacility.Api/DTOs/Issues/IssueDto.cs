namespace CampusFacility.Api.DTOs.Issues
{
    public class IssueDto
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
    }
}
