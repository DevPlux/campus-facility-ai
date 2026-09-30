using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System.Net.Http.Headers;

namespace CampusFacility.Api.Services
{
    public interface ISupabaseStorageService
    {
        Task<string?> UploadIssueImageAsync(IFormFile file, int issueId, string folderName = "before");
        Task<bool> DeleteImageAsync(string path);
    }

    public class SupabaseStorageService : ISupabaseStorageService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;

        public SupabaseStorageService(HttpClient httpClient, IConfiguration configuration)
        {
            _httpClient = httpClient;
            _configuration = configuration;
        }

        public async Task<string?> UploadIssueImageAsync(IFormFile file, int issueId, string folderName = "before")
        {
            var url = _configuration["Supabase:Url"]?.TrimEnd('/');
            var key = _configuration["Supabase:ServiceRoleKey"];
            var bucket = _configuration["Supabase:StorageBucket"] ?? "issue-images";

            if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(key))
            {
                throw new InvalidOperationException("Supabase storage configuration is missing.");
            }

            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var guid = Guid.NewGuid();
            var path = $"issues/{issueId}/{folderName.ToLowerInvariant()}/{guid}{extension}";

            using var requestMessage = new HttpRequestMessage(HttpMethod.Post, $"{url}/storage/v1/object/{bucket}/{path}");
            requestMessage.Headers.Authorization = new AuthenticationHeaderValue("Bearer", key);
            requestMessage.Headers.Add("apikey", key);

            var streamContent = new StreamContent(file.OpenReadStream());
            streamContent.Headers.ContentType = new MediaTypeHeaderValue(file.ContentType);
            requestMessage.Content = streamContent;

            var response = await _httpClient.SendAsync(requestMessage);
            if (!response.IsSuccessStatusCode)
            {
                var errorMsg = await response.Content.ReadAsStringAsync();
                throw new Exception($"Failed to upload to Supabase Storage: {response.StatusCode} - {errorMsg}");
            }

            return $"{url}/storage/v1/object/public/{bucket}/{path}";
        }

        public async Task<bool> DeleteImageAsync(string path)
        {
            var url = _configuration["Supabase:Url"]?.TrimEnd('/');
            var key = _configuration["Supabase:ServiceRoleKey"];
            var bucket = _configuration["Supabase:StorageBucket"] ?? "issue-images";

            if (string.IsNullOrEmpty(url) || string.IsNullOrEmpty(key)) return false;

            // path should be the relative path inside the bucket, e.g. "issues/15/before/..."
            using var requestMessage = new HttpRequestMessage(HttpMethod.Delete, $"{url}/storage/v1/object/{bucket}/{path}");
            requestMessage.Headers.Authorization = new AuthenticationHeaderValue("Bearer", key);
            requestMessage.Headers.Add("apikey", key);

            var response = await _httpClient.SendAsync(requestMessage);
            return response.IsSuccessStatusCode;
        }
    }
}




