using CampusFacility.Api.Enums;
using Microsoft.Extensions.Configuration;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Net.Http;
using System.Threading.Tasks;
using System;

namespace CampusFacility.Api.Services.Agents
{
    public class IssueAnalysisResult
    {
        [JsonPropertyName("category")]
        public string? Category { get; set; }

        [JsonPropertyName("priority")]
        public string? Priority { get; set; }

        [JsonPropertyName("requiredSkill")]
        public string? RequiredSkill { get; set; }

        [JsonPropertyName("summary")]
        public string? Summary { get; set; }
    }

    public class IssueAnalysisAgent
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _config;

        public IssueAnalysisAgent(HttpClient httpClient, IConfiguration config)
        {
            _httpClient = httpClient;
            _config = config;
        }

        public async Task<IssueAnalysisResult?> AnalyzeAsync(string title, string description, string location)
        {
            var apiKey = _config["Gemini:ApiKey"];
            var model = _config["Gemini:Model"] ?? "gemini-1.5-flash";

            if (string.IsNullOrEmpty(apiKey) || apiKey == "YOUR_GEMINI_API_KEY")
            {
                throw new InvalidOperationException("Gemini API key is missing or not configured correctly.");
            }

            var allowedCategories = string.Join(", ", Enum.GetNames<IssueCategory>());
            var allowedPriorities = string.Join(", ", Enum.GetNames<Priority>());

            var promptText = $@"
Analyze the following maintenance issue and return a JSON object with strictly these fields:
- category: One of [{allowedCategories}]
- priority: One of [{allowedPriorities}]
- requiredSkill: MUST be exactly one of [PLUMBING, ELECTRICAL, HVAC, IT, CARPENTRY, GENERAL]
- summary: A brief 1-sentence summary of the issue

Issue Title: {title}
Description: {description}
Location: {location}
";

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[] { new { text = promptText } }
                    }
                },
                generationConfig = new
                {
                    responseMimeType = "application/json"
                }
            };

            var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
            
            var response = await _httpClient.PostAsJsonAsync(url, payload);
            
            if (!response.IsSuccessStatusCode)
            {
                var errorBody = await response.Content.ReadAsStringAsync();
                throw new Exception($"Gemini API call failed with status {response.StatusCode}: {errorBody}");
            }

            var responseDoc = await JsonDocument.ParseAsync(await response.Content.ReadAsStreamAsync());
            var text = responseDoc.RootElement
                .GetProperty("candidates")[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text").GetString();

            if (string.IsNullOrWhiteSpace(text))
            {
                throw new Exception("Empty content received from Gemini.");
            }

            return JsonSerializer.Deserialize<IssueAnalysisResult>(text, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        }
    }
}


