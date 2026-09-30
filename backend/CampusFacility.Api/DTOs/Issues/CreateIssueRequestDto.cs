using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace CampusFacility.Api.DTOs.Issues
{
    public class CreateIssueRequestDto
    {
        [Required]
        [MaxLength(200)]
        public required string Title { get; set; }

        [Required]
        [MaxLength(2000)]
        public required string Description { get; set; }

        [Required]
        [MaxLength(200)]
        public required string Location { get; set; }

        [Required]
        public required IFormFile Image { get; set; }
    }
}
