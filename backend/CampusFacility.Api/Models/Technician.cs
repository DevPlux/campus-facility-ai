namespace CampusFacility.Api.Models
{
    public class Technician
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public required string Skill { get; set; }
        public bool IsAvailable { get; set; } = true;

        public User User { get; set; } = null!;
        public ICollection<Assignment> Assignments { get; set; } = new List<Assignment>();
    }
}
