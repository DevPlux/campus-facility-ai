using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace CampusFacility.Api.DTOs.Assignments
{
    public class CompleteAssignmentRequestDto
    {
        [Required]
        public required string CompletionNote { get; set; }

        [Required]
        public required IFormFile Image { get; set; }
    }
}
