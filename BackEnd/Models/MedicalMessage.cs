using System.ComponentModel.DataAnnotations;

namespace MedicalManagement.API.Models
{
    public class MedicalMessage
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string ChatId { get; set; } = string.Empty;

        [Required]
        public string SenderId { get; set; } = string.Empty;

        public UserRole SenderRole { get; set; } = UserRole.Patient;

        [Required]
        [MaxLength(4000)]
        public string Content { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public MedicalChat? Chat { get; set; }
    }
}
