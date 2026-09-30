namespace CampusFacility.Api.DTOs.Auth
{
    public class LoginResponseDto
    {
        public required string Token { get; set; }
        public required AuthUserDto User { get; set; }
    }
}
