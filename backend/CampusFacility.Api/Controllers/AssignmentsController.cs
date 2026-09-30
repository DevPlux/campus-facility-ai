using CampusFacility.Api.DTOs.Assignments;
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
    [Route("api/assignments")]
    public class AssignmentsController : ControllerBase
    {
        private readonly AssignmentService _assignmentService;

        public AssignmentsController(AssignmentService assignmentService)
        {
            _assignmentService = assignmentService;
        }

        [HttpPost("{id}/approve")]
        [Authorize(Roles = "MANAGER")]
        public async Task<IActionResult> ApproveAssignment(int id)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int managerId)) return Unauthorized();

            await _assignmentService.ApproveAssignmentAsync(id, managerId);
            return Ok(new { success = true, message = "Assignment approved successfully." });
        }

        [HttpPost("{id}/reject")]
        [Authorize(Roles = "MANAGER")]
        public async Task<IActionResult> RejectAssignment(int id)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int managerId)) return Unauthorized();

            await _assignmentService.RejectAssignmentAsync(id, managerId);
            return Ok(new { success = true, message = "Assignment rejected successfully." });
        }

        [HttpPatch("{id}/start")]
        [Authorize(Roles = "TECHNICIAN")]
        public async Task<IActionResult> StartAssignment(int id)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int userId)) return Unauthorized();

            await _assignmentService.StartAssignmentAsync(id, userId);
            return Ok(new { success = true, message = "Assignment started successfully." });
        }

        [HttpPatch("{id}/complete")]
        [Authorize(Roles = "TECHNICIAN")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> CompleteAssignment(int id, [FromForm] CompleteAssignmentRequestDto request)
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdClaim, out int userId)) return Unauthorized();

            if (request.Image == null || request.Image.Length == 0)
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Image is required." } });
            }

            if (request.Image.Length > 5 * 1024 * 1024)
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Image size cannot exceed 5 MB." } });
            }

            var allowedContentTypes = new[] { "image/jpeg", "image/png" };
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(request.Image.FileName).ToLowerInvariant();

            if (!allowedContentTypes.Contains(request.Image.ContentType.ToLowerInvariant()) || 
                !allowedExtensions.Contains(extension))
            {
                return BadRequest(new { success = false, message = "Invalid image file.", errors = new[] { "Only JPG and PNG images are allowed." } });
            }

            await _assignmentService.CompleteAssignmentAsync(id, userId, request);
            return Ok(new { success = true, message = "Assignment completed successfully." });
        }
    }
}
