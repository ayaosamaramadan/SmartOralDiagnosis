using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using MedicalManagement.API.Models;
using Microsoft.AspNetCore.Http;

namespace MedicalManagement.API.Services;

public class AiServiceResult
{
    public bool IsSuccess { get; init; }
    public int StatusCode { get; init; }
    public AiResponse? Data { get; init; }
    public string? ErrorMessage { get; init; }
}

public class AiService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<AiService> _logger;

    public AiService(IHttpClientFactory httpClientFactory, ILogger<AiService> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public Task<AiServiceResult> PredictAsync(AiRequest request, CancellationToken cancellationToken = default)
    {
        _logger.LogWarning("Text-based AI prediction is not supported by the deployed image model.");

        return Task.FromResult(new AiServiceResult
        {
            IsSuccess = false,
            StatusCode = StatusCodes.Status400BadRequest,
            ErrorMessage = "Text input is not supported by this AI model. Upload an image file using form field 'file' or 'image'."
        });
    }

    public async Task<AiServiceResult> PredictFromImageAsync(IFormFile image, CancellationToken cancellationToken = default)
    {
        try
        {
            var client = _httpClientFactory.CreateClient("AiService");

            await using var stream = image.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory, cancellationToken);
            var imageBytes = memory.ToArray();

            MultipartFormDataContent BuildForm()
            {
                var form = new MultipartFormDataContent();
                var fileContent = new ByteArrayContent(imageBytes);
                fileContent.Headers.ContentType = new MediaTypeHeaderValue(image.ContentType ?? "application/octet-stream");
                form.Add(fileContent, "file", image.FileName ?? "upload.jpg");

                var imageContent = new ByteArrayContent(imageBytes);
                imageContent.Headers.ContentType = new MediaTypeHeaderValue(image.ContentType ?? "application/octet-stream");
                form.Add(imageContent, "image", image.FileName ?? "upload.jpg");

                return form;
            }

            async Task<AiServiceResult?> PostAndParseAsync(HttpClient httpClient, string requestUri)
            {
                using var form = BuildForm();
                using var response = await httpClient.PostAsync(requestUri, form, cancellationToken);
                var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("AI service returned non-success status {StatusCode}: {Body}", (int)response.StatusCode, responseBody);
                    return new AiServiceResult
                    {
                        IsSuccess = false,
                        StatusCode = (int)response.StatusCode,
                        ErrorMessage = string.IsNullOrWhiteSpace(responseBody) ? "AI service returned an error." : responseBody
                    };
                }

                var aiResponse = JsonSerializer.Deserialize<AiResponse>(responseBody, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                if (aiResponse == null)
                {
                    _logger.LogError("AI service response could not be deserialized. Body: {Body}", responseBody);
                    return new AiServiceResult
                    {
                        IsSuccess = false,
                        StatusCode = (int)HttpStatusCode.BadGateway,
                        ErrorMessage = "Invalid AI service response."
                    };
                }

                return new AiServiceResult { IsSuccess = true, StatusCode = (int)HttpStatusCode.OK, Data = aiResponse };
            }

            // Try primary configured AI service
            try
            {
                var primary = await PostAndParseAsync(client, "predict");
                if (primary != null && primary.IsSuccess) return primary;
            }
            catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
            {
                _logger.LogWarning(ex, "AI image request to configured AI service timed out, will try fallback.");
            }
            catch (HttpRequestException ex)
            {
                _logger.LogWarning(ex, "HTTP error calling configured AI service, will try fallback.");
            }

            // Fallback candidates. Keep loopback only for local development so
            // hosted deployments cannot accidentally degrade to localhost.
            var hostedEnvironment = IsHostedEnvironment();
            var candidates = hostedEnvironment
                ? new[]
                {
                    Environment.GetEnvironmentVariable("AI_SERVICE_BASEURL"),
                    Environment.GetEnvironmentVariable("AI_SERVICE_BASE_URL"),
                    Environment.GetEnvironmentVariable("AI_BASEURL"),
                    Environment.GetEnvironmentVariable("AI_BASE_URL"),
                    Environment.GetEnvironmentVariable("NEXT_PUBLIC_AI_URL")
                }
                : new[]
                {
                    Environment.GetEnvironmentVariable("AI_SERVICE_LOCAL_BASEURL"),
                    Environment.GetEnvironmentVariable("AI_SERVICE_FALLBACK_URL"),
                    Environment.GetEnvironmentVariable("AI_SERVICE_BASEURL_LOCAL"),
                    Environment.GetEnvironmentVariable("NEXT_PUBLIC_AI_URL"),
                    "http://localhost:8000"
                };

            foreach (var candidate in candidates)
            {
                var baseUrl = NormalizeBaseUrl(candidate);
                if (string.IsNullOrWhiteSpace(baseUrl)) continue;

                try
                {
                    using var fallbackClient = new HttpClient { BaseAddress = new Uri(baseUrl), Timeout = client.Timeout };
                    var fallback = await PostAndParseAsync(fallbackClient, "predict");
                    if (fallback != null && fallback.IsSuccess)
                    {
                        _logger.LogInformation("AI image prediction succeeded using fallback AI at {BaseUrl}", baseUrl);
                        return fallback;
                    }
                    else if (fallback != null)
                    {
                        _logger.LogWarning("Fallback AI service at {BaseUrl} returned {StatusCode}", baseUrl, fallback.StatusCode);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error while calling fallback AI service at {Candidate}", candidate);
                }
            }

            return new AiServiceResult
            {
                IsSuccess = false,
                StatusCode = StatusCodes.Status502BadGateway,
                ErrorMessage = "AI service returned an error and no fallback could be reached."
            };
        }
        catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
        {
            _logger.LogError(ex, "AI image request timed out.");
            return new AiServiceResult { IsSuccess = false, StatusCode = StatusCodes.Status504GatewayTimeout, ErrorMessage = "AI service timed out." };
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error while calling AI service for image prediction.");
            return new AiServiceResult { IsSuccess = false, StatusCode = StatusCodes.Status502BadGateway, ErrorMessage = "Could not reach AI service." };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error while calling AI service for image prediction.");
            return new AiServiceResult { IsSuccess = false, StatusCode = StatusCodes.Status500InternalServerError, ErrorMessage = "Unexpected error while processing AI image request." };
        }
    }

    private static string? NormalizeBaseUrl(string? rawValue)
    {
        if (string.IsNullOrWhiteSpace(rawValue)) return null;
        var candidate = rawValue.Trim().TrimEnd('/');
        if (!candidate.StartsWith("http://", StringComparison.OrdinalIgnoreCase) && !candidate.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            candidate = $"http://{candidate}";
        }

        if (!Uri.TryCreate(candidate, UriKind.Absolute, out var uri)) return null;

        var absolute = uri.AbsoluteUri.TrimEnd('/');
        if (absolute.EndsWith("/api/ai/predict", StringComparison.OrdinalIgnoreCase))
        {
            absolute = absolute.Substring(0, absolute.Length - "/api/ai/predict".Length);
        }
        else if (absolute.EndsWith("/predict", StringComparison.OrdinalIgnoreCase))
        {
            absolute = absolute.Substring(0, absolute.Length - "/predict".Length);
        }

        return absolute.EndsWith('/') ? absolute : absolute + "/";
    }

    private static bool IsHostedEnvironment()
    {
        return !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("PORT"))
            || !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("RAILWAY_STATIC_URL"))
            || !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("RAILWAY_URL"));
    }
}
