using CampusFacility.Api.DTOs.Auth;
using CampusFacility.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CampusFacility.Api.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;

        public AuthController(AuthService authService)
        {
            _authService = authService;
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            var response = await _authService.LoginAsync(request);

            if (response == null)
            {
                return Unauthorized(new
                {
                    success = false,
                    message = "Invalid email or password.",
                    errors = Array.Empty<string>()
                });
            }

            return Ok(response);
        }

        [Authorize]
        [HttpGet("test-auth")]
        public IActionResult TestAuth()
        {
            return Ok(new { message = "Authenticated" });
        }

        [Authorize(Roles = "MANAGER")]
        [HttpGet("test-manager")]
        public IActionResult TestManager()
        {
            return Ok(new { message = "Manager Access Granted" });
        }

        [Authorize(Roles = "REPORTER")]
        [HttpGet("test-reporter")]
        public IActionResult TestReporter()
        {
            return Ok(new { message = "Reporter Access Granted" });
        }

        [Authorize(Roles = "TECHNICIAN")]
        [HttpGet("test-technician")]
        public IActionResult TestTechnician()
        {
            return Ok(new { message = "Technician Access Granted" });
        }
    }
}
