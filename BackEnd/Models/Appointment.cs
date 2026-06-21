using System.ComponentModel.DataAnnotations;

namespace MedicalManagement.API.Models
{
    public enum AppointmentType
    {
        Consultation,
        FollowUp,
        Emergency,
        Routine
    }

    public enum AppointmentStatus
    {
        Scheduled,
        Confirmed,
        InProgress,
        Completed,
        Cancelled,
        NoShow
    }

    public class Appointment
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        public string PatientId { get; set; } = string.Empty;

        [Required]
        public string DoctorId { get; set; } = string.Empty;

        public DateTime AppointmentDate { get; set; }
        public int? Duration { get; set; }
        public AppointmentType Type { get; set; } = AppointmentType.Consultation;
        public AppointmentStatus Status { get; set; } = AppointmentStatus.Scheduled;
        public string? Reason { get; set; }
        public string? Notes { get; set; }
        public string? Diagnosis { get; set; }
        // Prescription stored as JSON array
        public string? PrescriptionJson { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
