using System.ComponentModel.DataAnnotations;

namespace MedicalManagement.API.Models
{
    public enum UserRole
    {
        Patient,
        Doctor,
        Admin
    }

    public class User
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        [Required]
        [MaxLength(200)]
        public string Email { get; set; } = string.Empty;

        [MaxLength(100)]
        public string FirstName { get; set; } = string.Empty;

        [MaxLength(100)]
        public string LastName { get; set; } = string.Empty;

        [MaxLength(25)]
        public string? PhoneNumber { get; set; }

        public UserRole Role { get; set; } = UserRole.Patient;

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // For auth
        public string PasswordHash { get; set; } = string.Empty;

        // Patient-specific
        public string? DateOfBirth { get; set; }
        public string? AddressJson { get; set; }
        public string? EmergencyContactJson { get; set; }
        public string? MedicalHistoryJson { get; set; }
        public string? AssignedDoctorId { get; set; }

        // Doctor-specific
        public string? Specialization { get; set; }
        public string? LicenseNumber { get; set; }
        public string? Department { get; set; }
        public int? Experience { get; set; }
        // Availability stored as JSON array of DoctorAvailability
        public string? AvailabilityJson { get; set; }
        public decimal? ConsultationFee { get; set; }
    }
}
