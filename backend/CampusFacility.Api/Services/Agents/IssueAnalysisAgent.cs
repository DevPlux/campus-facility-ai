using CampusFacility.Api.Enums;
using Microsoft.Extensions.Configuration;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

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

        private const int MaxAttempts = 3;

        public IssueAnalysisAgent(
            HttpClient httpClient,
            IConfiguration config)
        {
            _httpClient = httpClient;
            _config = config;
        }

        public async Task<IssueAnalysisResult?> AnalyzeAsync(
            string title,
            string description,
            string location)
        {
            var apiKey = _config["Gemini:ApiKey"];
            var model =
                _config["Gemini:Model"] ?? "gemini-1.5-flash";

            if (string.IsNullOrWhiteSpace(apiKey) ||
                apiKey == "YOUR_GEMINI_API_KEY")
            {
                throw new InvalidOperationException(
                    "Gemini API key is missing or not configured correctly.");
            }

            var allowedCategories =
                string.Join(", ", Enum.GetNames<IssueCategory>());

            var allowedPriorities =
                string.Join(", ", Enum.GetNames<Priority>());

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
                        parts = new[]
                        {
                            new
                            {
                                text = promptText
                            }
                        }
                    }
                },

                generationConfig = new
                {
                    responseMimeType = "application/json"
                }
            };

            var url =
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

            HttpResponseMessage? response = null;

            // ---------------------------------------------------------
            // Gemini request with retry handling
            // ---------------------------------------------------------
            for (int attempt = 1; attempt <= MaxAttempts; attempt++)
            {
                response = await _httpClient.PostAsJsonAsync(
                    url,
                    payload
                );

                if (response.IsSuccessStatusCode)
                {
                    break;
                }

                var errorBody =
                    await response.Content.ReadAsStringAsync();

                var shouldRetry =
                    response.StatusCode ==
                        HttpStatusCode.ServiceUnavailable ||
                    response.StatusCode ==
                        HttpStatusCode.TooManyRequests ||
                    response.StatusCode ==
                        HttpStatusCode.BadGateway ||
                    response.StatusCode ==
                        HttpStatusCode.GatewayTimeout;

                if (!shouldRetry)
                {
                    throw new Exception(
                        $"Gemini API call failed with status " +
                        $"{response.StatusCode}: {errorBody}"
                    );
                }

                // Final attempt failed
                if (attempt == MaxAttempts)
                {
                    throw new Exception(
                        $"Gemini API unavailable after " +
                        $"{MaxAttempts} attempts. " +
                        $"Last status: {response.StatusCode}. " +
                        $"{errorBody}"
                    );
                }

                // Increasing delay:
                // attempt 1 -> 2 seconds
                // attempt 2 -> 4 seconds
                var delaySeconds = attempt * 2;

                await Task.Delay(
                    TimeSpan.FromSeconds(delaySeconds)
                );
            }

            if (response == null)
            {
                throw new Exception(
                    "No response received from Gemini API."
                );
            }

            // ---------------------------------------------------------
            // Read Gemini JSON response
            // ---------------------------------------------------------
            using var responseDoc =
                await JsonDocument.ParseAsync(
                    await response.Content.ReadAsStreamAsync()
                );

            var root = responseDoc.RootElement;

            if (!root.TryGetProperty(
                    "candidates",
                    out var candidates) ||
                candidates.GetArrayLength() == 0)
            {
                throw new Exception(
                    "Gemini returned no candidates."
                );
            }

            var text = candidates[0]
                .GetProperty("content")
                .GetProperty("parts")[0]
                .GetProperty("text")
                .GetString();

            if (string.IsNullOrWhiteSpace(text))
            {
                throw new Exception(
                    "Empty content received from Gemini."
                );
            }

            // ---------------------------------------------------------
            // Deserialize structured AI result
            // ---------------------------------------------------------
            var result =
                JsonSerializer.Deserialize<IssueAnalysisResult>(
                    text,
                    new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    }
                );

            if (result == null)
            {
                throw new Exception(
                    "Unable to deserialize Gemini analysis."
                );
            }

            // ---------------------------------------------------------
            // Basic structured-output validation
            // ---------------------------------------------------------
            if (string.IsNullOrWhiteSpace(result.Category) ||
                string.IsNullOrWhiteSpace(result.Priority) ||
                string.IsNullOrWhiteSpace(result.RequiredSkill) ||
                string.IsNullOrWhiteSpace(result.Summary))
            {
                throw new Exception(
                    "Gemini returned an incomplete analysis."
                );
            }

            return result;
        }
    }
}