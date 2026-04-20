using System.Net;
using System.Net.Http.Headers;
using System.Text.Json;
using MedicalManagement.API.Models;

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

            using var form = new MultipartFormDataContent();
            await using var stream = image.OpenReadStream();
            using var streamContent = new StreamContent(stream);
            streamContent.Headers.ContentType = new MediaTypeHeaderValue(image.ContentType ?? "application/octet-stream");
            form.Add(streamContent, "file", image.FileName ?? "upload.jpg");

            using var response = await client.PostAsync("predict", form, cancellationToken);
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

            var aiResponse = JsonSerializer.Deserialize<AiResponse>(
                responseBody,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
            );

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

            return new AiServiceResult
            {
                IsSuccess = true,
                StatusCode = (int)HttpStatusCode.OK,
                Data = aiResponse
            };
        }
        catch (TaskCanceledException ex) when (!cancellationToken.IsCancellationRequested)
        {
            _logger.LogError(ex, "AI image request timed out.");
            return new AiServiceResult
            {
                IsSuccess = false,
                StatusCode = StatusCodes.Status504GatewayTimeout,
                ErrorMessage = "AI service timed out."
            };
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "HTTP error while calling AI service for image prediction.");
            return new AiServiceResult
            {
                IsSuccess = false,
                StatusCode = StatusCodes.Status502BadGateway,
                ErrorMessage = "Could not reach AI service."
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error while calling AI service for image prediction.");
            return new AiServiceResult
            {
                IsSuccess = false,
                StatusCode = StatusCodes.Status500InternalServerError,
                ErrorMessage = "Unexpected error while processing AI image request."
            };
        }
    }
}
