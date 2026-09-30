using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace CampusFacility.Api.Controllers
{
    [ApiController]
    [Route("api/health")]
    public class HealthController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetHealth()
        {
            return Ok(new { status = "ok" });
        }
    }
}
