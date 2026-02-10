using System.Net.Http.Headers;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AIController : ControllerBase
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly ILogger<AIController> _logger;

        public AIController(IHttpClientFactory httpFactory, ILogger<AIController> logger)
        {
            _httpFactory = httpFactory;
            _logger = logger;
        }

        [AllowAnonymous]
        [HttpPost("predict")]
        public async Task<IActionResult> Predict([FromForm] IFormFile image)
        {
            if (image == null || image.Length == 0) return BadRequest(new { message = "No image file provided" });

            try
            {
                var client = _httpFactory.CreateClient("AIService");
               var target = client.BaseAddress != null ? new Uri(client.BaseAddress, "predict") : new Uri((Request.Headers.ContainsKey("X-AI-Endpoint") ? Request.Headers["X-AI-Endpoint"].ToString() : Environment.GetEnvironmentVariable("NEXT_BACKEND_SERVER") + "/predict")!);

                using var content = new MultipartFormDataContent();
                using var stream = image.OpenReadStream();
                var streamContent = new StreamContent(stream);
                streamContent.Headers.ContentType = new MediaTypeHeaderValue(image.ContentType ?? "application/octet-stream");
                content.Add(streamContent, "image", image.FileName ?? "upload.jpg");

                var response = await client.PostAsync(target, content);
                var respText = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger?.LogWarning("AI service returned {Status}: {Body}", response.StatusCode, respText);
                    return StatusCode((int)response.StatusCode, new { message = "AI service error", detail = respText });
                }

                // Return whatever the AI service returned (assumed JSON)
                return Content(respText, "application/json");
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Error forwarding image to AI service");
                return StatusCode(500, new { message = "Internal server error", detail = ex.Message });
            }
        }
    }
}