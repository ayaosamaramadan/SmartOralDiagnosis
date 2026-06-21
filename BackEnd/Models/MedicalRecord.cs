using System.ComponentModel.DataAnnotations;

namespace MedicalManagement.API.Models
{
    public class MedicalRecord
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string PatientId { get; set; } = string.Empty;

        [Required]
        public string DoctorId { get; set; } = string.Empty;

        public string? AppointmentId { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string? Diagnosis { get; set; }
        public string? Treatment { get; set; }
        // Prescription/tests/attachments stored as JSON for simplicity
        public string? PrescriptionJson { get; set; }
        public string? TestsJson { get; set; }
        public string? AttachmentsJson { get; set; }

        public DateTime RecordDate { get; set; } = DateTime.UtcNow;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
