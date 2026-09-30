using CampusFacility.Api.Enums;

namespace CampusFacility.Api.Models
{
    public class User
    {
        public int Id { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public required string PasswordHash { get; set; }
        public Role Role { get; set; }

        public ICollection<Issue> ReportedIssues { get; set; } = new List<Issue>();
        public Technician? Technician { get; set; }
    }
}
