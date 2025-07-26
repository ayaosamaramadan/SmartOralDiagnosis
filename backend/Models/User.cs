using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace MedicalManagement.API.Models
{
    public class User
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("email")]
        public string Email { get; set; } = string.Empty;

        [BsonElement("passwordHash")]
        public string PasswordHash { get; set; } = string.Empty;

        [BsonElement("firstName")]
        public string FirstName { get; set; } = string.Empty;

        [BsonElement("lastName")]
        public string LastName { get; set; } = string.Empty;

        [BsonElement("phoneNumber")]
        public string PhoneNumber { get; set; } = string.Empty;

        [BsonElement("role")]
        public string Role { get; set; } = string.Empty; // "patient", "doctor", "admin"

        [BsonElement("isActive")]
        public bool IsActive { get; set; } = true;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }

    public class Patient : User
    {
        [BsonElement("gender")]
        public string Gender { get; set; } = string.Empty;

        [BsonElement("address")]
        public Address Address { get; set; } = new();

        [BsonElement("emergencyContact")]
        public EmergencyContact EmergencyContact { get; set; } = new();

        [BsonElement("bloodType")]
        public string BloodType { get; set; } = string.Empty;

        [BsonElement("allergies")]
        public List<string> Allergies { get; set; } = new();

        [BsonElement("medicalHistory")]
        public List<string> MedicalHistory { get; set; } = new();

        [BsonElement("assignedDoctorId")]
        public string? AssignedDoctorId { get; set; }
    }

    public class Doctor : User
    {
        [BsonElement("licenseNumber")]
        public string LicenseNumber { get; set; } = string.Empty;

        [BsonElement("specialization")]
        public string Specialization { get; set; } = string.Empty;

        [BsonElement("department")]
        public string Department { get; set; } = string.Empty;

        [BsonElement("qualifications")]
        public List<string> Qualifications { get; set; } = new();

        [BsonElement("experience")]
        public int Experience { get; set; } // Years of experience

        [BsonElement("schedule")]
        public Schedule Schedule { get; set; } = new();

        [BsonElement("consultationFee")]
        public decimal ConsultationFee { get; set; }

        [BsonElement("patientIds")]
        public List<string> PatientIds { get; set; } = new();
    }

    public class Admin : User
    {
        [BsonElement("permissions")]
        public List<string> Permissions { get; set; } = new();

        [BsonElement("department")]
        public string Department { get; set; } = string.Empty;
    }

    public class Address
    {
        [BsonElement("street")]
        public string Street { get; set; } = string.Empty;

        [BsonElement("city")]
        public string City { get; set; } = string.Empty;

        [BsonElement("state")]
        public string State { get; set; } = string.Empty;

        [BsonElement("zipCode")]
        public string ZipCode { get; set; } = string.Empty;

        [BsonElement("country")]
        public string Country { get; set; } = string.Empty;
    }

    public class EmergencyContact
    {
        [BsonElement("name")]
        public string Name { get; set; } = string.Empty;

        [BsonElement("relationship")]
        public string Relationship { get; set; } = string.Empty;

        [BsonElement("phoneNumber")]
        public string PhoneNumber { get; set; } = string.Empty;
    }

    public class Schedule
    {
        [BsonElement("workingDays")]
        public List<string> WorkingDays { get; set; } = new(); // ["Monday", "Tuesday", ...]

        [BsonElement("startTime")]
        public TimeSpan StartTime { get; set; }

        [BsonElement("endTime")]
        public TimeSpan EndTime { get; set; }

        [BsonElement("timeSlotDuration")]
        public int TimeSlotDuration { get; set; } = 30; // Minutes
    }
}
