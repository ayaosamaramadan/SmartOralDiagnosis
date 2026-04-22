using System.Text.Json;
using System.Text.Json.Serialization;

namespace MedicalManagement.API.Models;

public class AiResponse
{
    public string? Prediction { get; set; }

    public double? Confidence { get; set; }

    // Keep any additional fields returned by the external AI API.
    [JsonExtensionData]
    public Dictionary<string, JsonElement>? AdditionalData { get; set; }
}
