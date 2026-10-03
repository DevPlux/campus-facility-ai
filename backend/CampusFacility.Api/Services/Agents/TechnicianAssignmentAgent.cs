using System.Net;
using System.Text;
using System.Text.Json;
using CampusFacility.Api.DTOs.Agents;

namespace CampusFacility.Api.Services.Agents
{
    public class TechnicianAssignmentAgent
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<TechnicianAssignmentAgent> _logger;

        private const int MaxAttempts = 3;

        public TechnicianAssignmentAgent(
            HttpClient httpClient,
            IConfiguration configuration,
            ILogger<TechnicianAssignmentAgent> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<TechnicianAssignmentResult?> RecommendAsync(
            int issueId,
            string title,
            string description,
            string location,
            string? category,
            string? priority,
            string requiredSkill,
            List<TechnicianCandidate> candidates)
        {
            if (candidates.Count == 0)
                return null;

            var apiKey = _configuration["Gemini:ApiKey"];

            if (string.IsNullOrWhiteSpace(apiKey))
                throw new InvalidOperationException(
                    "Gemini API key is not configured.");

            var model =
                _configuration["Gemini:Model"]
                ?? "gemini-1.5-flash";

            var url =
                $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";

            var candidateJson = JsonSerializer.Serialize(candidates);

            var prompt = $@"
                You are a Technician Assignment Agent for a campus
                facility issue management system.

                Your responsibility is ONLY to recommend one technician
                from the supplied candidate list.

                ISSUE:
                Issue ID: {issueId}
                Title: {title}
                Description: {description}
                Location: {location}
                Category: {category}
                Priority: {priority}
                Required Skill: {requiredSkill}

                ELIGIBLE TECHNICIANS:
                {candidateJson}

                RULES:
                1. Select ONLY a technician from ELIGIBLE TECHNICIANS.
                2. Never invent a technician ID.
                3. The technician must have a suitable skill.
                4. The technician must be available.
                5. Return only valid JSON.
                6. Do not include markdown or JSON code fences.

                Required JSON format:

                {{
                ""issueId"": {issueId},
                ""technicianId"": 0,
                ""reason"": ""Short explanation for the recommendation""
                }}
                ";

            var requestBody = new
            {
                contents = new[]
                {
                    new
                    {
                        parts = new[]
                        {
                            new { text = prompt }
                        }
                    }
                },
                generationConfig = new
                {
                    responseMimeType = "application/json"
                }
            };

            var requestJson = JsonSerializer.Serialize(requestBody);

            for (var attempt = 1; attempt <= MaxAttempts; attempt++)
            {
                using var request = new HttpRequestMessage(
                    HttpMethod.Post,
                    url);

                request.Content = new StringContent(
                    requestJson,
                    Encoding.UTF8,
                    "application/json");

                try
                {
                    using var response =
                        await _httpClient.SendAsync(request);

                    if (!response.IsSuccessStatusCode)
                    {
                        var errorBody =
                            await response.Content.ReadAsStringAsync();

                        _logger.LogWarning(
                            "TechnicianAssignmentAgent Gemini attempt {Attempt} failed. Status: {Status}. Response: {Response}",
                            attempt,
                            response.StatusCode,
                            errorBody);

                        if (IsRetryable(response.StatusCode) &&
                            attempt < MaxAttempts)
                        {
                            await Task.Delay(
                                TimeSpan.FromSeconds(attempt * 2));

                            continue;
                        }

                        throw new HttpRequestException(
                            $"Gemini technician assignment failed with status {(int)response.StatusCode}.");
                    }

                    var responseJson =
                        await response.Content.ReadAsStringAsync();

                    using var document =
                        JsonDocument.Parse(responseJson);

                    var root = document.RootElement;

                    if (!root.TryGetProperty(
                            "candidates",
                            out var geminiCandidates) ||
                        geminiCandidates.GetArrayLength() == 0)
                    {
                        throw new InvalidOperationException(
                            "Gemini returned no candidates.");
                    }

                    var text = geminiCandidates[0]
                        .GetProperty("content")
                        .GetProperty("parts")[0]
                        .GetProperty("text")
                        .GetString();

                    if (string.IsNullOrWhiteSpace(text))
                    {
                        throw new InvalidOperationException(
                            "Gemini returned an empty technician recommendation.");
                    }

                    text = CleanJson(text);

                    var result =
                        JsonSerializer.Deserialize<TechnicianAssignmentResult>(
                            text,
                            new JsonSerializerOptions
                            {
                                PropertyNameCaseInsensitive = true
                            });

                    if (result == null)
                    {
                        throw new InvalidOperationException(
                            "Unable to parse technician recommendation.");
                    }

                    // Structured-output validation
                    if (result.IssueId != issueId)
                    {
                        throw new InvalidOperationException(
                            "Agent returned an invalid issue ID.");
                    }

                    if (result.TechnicianId <= 0)
                    {
                        throw new InvalidOperationException(
                            "Agent returned an invalid technician ID.");
                    }

                    if (string.IsNullOrWhiteSpace(result.Reason))
                    {
                        throw new InvalidOperationException(
                            "Agent returned no recommendation reason.");
                    }

                    return result;
                }
                catch (HttpRequestException ex)
                    when (attempt < MaxAttempts)
                {
                    _logger.LogWarning(
                        ex,
                        "TechnicianAssignmentAgent request failed on attempt {Attempt}. Retrying...",
                        attempt);

                    await Task.Delay(
                        TimeSpan.FromSeconds(attempt * 2));
                }
            }

            throw new InvalidOperationException(
                "TechnicianAssignmentAgent failed after all retry attempts.");
        }

        private static bool IsRetryable(HttpStatusCode statusCode)
        {
            return statusCode ==
                       HttpStatusCode.TooManyRequests ||
                   statusCode ==
                       HttpStatusCode.BadGateway ||
                   statusCode ==
                       HttpStatusCode.ServiceUnavailable ||
                   statusCode ==
                       HttpStatusCode.GatewayTimeout;
        }

        private static string CleanJson(string text)
        {
            return text
                .Replace("```json", "")
                .Replace("```", "")
                .Trim();
        }
    }
}