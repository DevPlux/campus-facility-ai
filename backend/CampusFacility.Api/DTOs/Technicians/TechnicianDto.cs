namespace CampusFacility.Api.DTOs.Technicians
{
    public class TechnicianDto
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public required string Name { get; set; }
        public required string Email { get; set; }
        public required string Skill { get; set; }
        public bool IsAvailable { get; set; }
    }
}
