using CampusFacility.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace CampusFacility.Api.Controllers
{
    [ApiController]
    [Route("api/technicians")]
    public class TechniciansController : ControllerBase
    {
        private readonly TechnicianService _technicianService;

        public TechniciansController(TechnicianService technicianService)
        {
            _technicianService = technicianService;
        }

        [HttpGet]
        [Authorize(Roles = "MANAGER")]
        public async Task<IActionResult> GetAllTechnicians()
        {
            var technicians = await _technicianService.GetAllTechniciansAsync();
            return Ok(technicians);
        }

        [HttpGet("my-tasks")]
        [Authorize(Roles = "TECHNICIAN")]
        public async Task<IActionResult> GetMyTasks()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int userId)) return Unauthorized();

            var tasks = await _technicianService.GetMyTasksAsync(userId);
            return Ok(tasks);
        }
    }
}
