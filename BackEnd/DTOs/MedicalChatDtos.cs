using System.ComponentModel.DataAnnotations;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.DTOs
{
    public class CreateMedicalChatRequest
    {
        public string? PatientId { get; set; }
        public string? DoctorId { get; set; }
    }

    public class MedicalChatResponse
    {
        public string Id { get; set; } = string.Empty;
        public string PatientId { get; set; } = string.Empty;
        public string DoctorId { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? LastMessageAt { get; set; }
    }

    public class CreateMedicalMessageRequest
    {
        [Required]
        [MaxLength(4000)]
        public string Content { get; set; } = string.Empty;
    }

    public class MedicalMessageResponse
    {
        public string Id { get; set; } = string.Empty;
        public string ChatId { get; set; } = string.Empty;
        public string SenderId { get; set; } = string.Empty;
        public UserRole SenderRole { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }
}
