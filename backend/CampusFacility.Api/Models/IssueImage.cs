using CampusFacility.Api.Enums;

namespace CampusFacility.Api.Models
{
    public class IssueImage
    {
        public int Id { get; set; }
        public int IssueId { get; set; }
        public required string ImageUrl { get; set; }
        public ImageType ImageType { get; set; }
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        public Issue Issue { get; set; } = null!;
    }
}
