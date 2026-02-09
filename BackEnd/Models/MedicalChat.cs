using System.ComponentModel.DataAnnotations;
using System.Collections.Generic;

namespace MedicalManagement.API.Models
{
    public class MedicalChat
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string PatientId { get; set; } = string.Empty;

        [Required]
        public string DoctorId { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? LastMessageAt { get; set; }

        public ICollection<MedicalMessage> Messages { get; set; } = new List<MedicalMessage>();
    }
}
