using CampusFacility.Api.DTOs.Issues;
using CampusFacility.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Linq;
using System.IO;

namespace CampusFacility.Api.Controllers
{
    [ApiController]
    [Route("api/issues")]
    public class IssuesController : ControllerBase
    {
        private readonly IssueService _issueService;

        public IssuesController(IssueService issueService)
        {
            _issueService = issueService;
        }

        [HttpPost]
        [Authorize(Roles = "REPORTER")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> CreateIssue([FromForm] CreateIssueRequestDto request)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int reporterId))
            {
                return Unauthorized();
            }

            if (request.Image == null || request.Image.Length == 0)
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Image is required." } });
            }

            if (request.Image.Length > 5 * 1024 * 1024)
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Image size cannot exceed 5 MB." } });
            }

            var allowedContentTypes = new[]
                {
                    "image/jpeg",
                    "image/png",
                    "image/heic",
                    "image/heif"
                };

                var allowedExtensions = new[]
                {
                    ".jpg",
                    ".jpeg",
                    ".png",
                    ".heic",
                    ".heif"
                };
            
            var extension = Path.GetExtension(request.Image.FileName).ToLowerInvariant();

            if (!allowedContentTypes.Contains(request.Image.ContentType.ToLowerInvariant()) || 
                !allowedExtensions.Contains(extension))
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Only JPG, PNG, HEIC and HEIF images are allowed." } });
            }

            var issueDto = await _issueService.CreateIssueAsync(reporterId, request);
            return Created($"/api/issues/{issueDto!.Id}", issueDto);
        }

        [HttpGet("my")]
        [Authorize(Roles = "REPORTER")]
        public async Task<IActionResult> GetMyIssues()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int reporterId))
            {
                return Unauthorized();
            }

            var issues = await _issueService.GetMyIssuesAsync(reporterId);
            return Ok(issues);
        }

        [HttpGet]
        [Authorize(Roles = "MANAGER")]
        public async Task<IActionResult> GetAllIssues([FromQuery] string? status, [FromQuery] string? category, [FromQuery] string? priority)
        {
            var issues = await _issueService.GetAllIssuesAsync(status, category, priority);
            return Ok(issues);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "MANAGER,REPORTER,TECHNICIAN")]
        public async Task<IActionResult> GetIssueById(int id)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var roleClaim = User.FindFirstValue(ClaimTypes.Role);
            if (!int.TryParse(userIdClaim, out int userId) || string.IsNullOrEmpty(roleClaim)) return Unauthorized();

            var issue = await _issueService.GetIssueByIdAsync(id, userId, roleClaim);
            return Ok(issue);
        }
    }
}
