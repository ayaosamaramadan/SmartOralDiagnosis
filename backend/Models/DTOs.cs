namespace MedicalManagement.API.Models
{
    public class LoginRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }

    public class RegisterRequest
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }

    public class AuthResponse
    {
        public string Token { get; set; } = string.Empty;
        public UserDto User { get; set; } = new();
    }

    public class UserDto
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class PatientDto : UserDto
    {
        
        public string Gender { get; set; } = string.Empty;
        public Address Address { get; set; } = new();
        public EmergencyContact EmergencyContact { get; set; } = new();
        public string BloodType { get; set; } = string.Empty;
        public List<string> Allergies { get; set; } = new();
        public List<string> MedicalHistory { get; set; } = new();
        public string? AssignedDoctorId { get; set; }
    }

    public class DoctorDto : UserDto
    {
        public string LicenseNumber { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public string Department { get; set; } = string.Empty;
        public List<string> Qualifications { get; set; } = new();
        public int Experience { get; set; }
        public Schedule Schedule { get; set; } = new();
        public decimal ConsultationFee { get; set; }
        public int PatientCount { get; set; }
    }

    public class AdminDto : UserDto
    {
        public List<string> Permissions { get; set; } = new();
        public string Department { get; set; } = string.Empty;
    }

    public class AppointmentDto
    {
        public string Id { get; set; } = string.Empty;
        public string PatientId { get; set; } = string.Empty;
        public string DoctorId { get; set; } = string.Empty;
        public DateTime AppointmentDate { get; set; }
        public int Duration { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Type { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
        public string PatientName { get; set; } = string.Empty;
        public string DoctorName { get; set; } = string.Empty;
    }

    public class CreateAppointmentRequest
    {
        public string PatientId { get; set; } = string.Empty;
        public string DoctorId { get; set; } = string.Empty;
        public DateTime AppointmentDate { get; set; }
        public int Duration { get; set; } = 30;
        public string Type { get; set; } = string.Empty;
        public string Reason { get; set; } = string.Empty;
    }

    public class MedicalRecordDto
    {
        public string Id { get; set; } = string.Empty;
        public string PatientId { get; set; } = string.Empty;
        public string DoctorId { get; set; } = string.Empty;
        public string? AppointmentId { get; set; }
        public DateTime VisitDate { get; set; }
        public string Diagnosis { get; set; } = string.Empty;
        public List<string> Symptoms { get; set; } = new();
        public string Treatment { get; set; } = string.Empty;
        public List<Prescription> Prescriptions { get; set; } = new();
        public List<LabResult> LabResults { get; set; } = new();
        public VitalSigns VitalSigns { get; set; } = new();
        public string Notes { get; set; } = string.Empty;
        public DateTime? FollowUpDate { get; set; }
        public string PatientName { get; set; } = string.Empty;
        public string DoctorName { get; set; } = string.Empty;
    }
}
