using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace MedicalManagement.API.Models
{
    public class Appointment
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("patientId")]
        public string PatientId { get; set; } = string.Empty;

        [BsonElement("doctorId")]
        public string DoctorId { get; set; } = string.Empty;

        [BsonElement("appointmentDate")]
        public DateTime AppointmentDate { get; set; }

        [BsonElement("duration")]
        public int Duration { get; set; } = 30; // Minutes

        [BsonElement("status")]
        public string Status { get; set; } = "Scheduled"; // Scheduled, Completed, Cancelled, No-Show

        [BsonElement("type")]
        public string Type { get; set; } = string.Empty; // Consultation, Follow-up, Emergency

        [BsonElement("reason")]
        public string Reason { get; set; } = string.Empty;

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties (not stored in DB)
        [BsonIgnore]
        public Patient? Patient { get; set; }

        [BsonIgnore]
        public Doctor? Doctor { get; set; }
    }

    public class MedicalRecord
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string Id { get; set; } = ObjectId.GenerateNewId().ToString();

        [BsonElement("patientId")]
        public string PatientId { get; set; } = string.Empty;

        [BsonElement("doctorId")]
        public string DoctorId { get; set; } = string.Empty;

        [BsonElement("appointmentId")]
        public string? AppointmentId { get; set; }

        [BsonElement("visitDate")]
        public DateTime VisitDate { get; set; }

        [BsonElement("diagnosis")]
        public string Diagnosis { get; set; } = string.Empty;

        [BsonElement("symptoms")]
        public List<string> Symptoms { get; set; } = new();

        [BsonElement("treatment")]
        public string Treatment { get; set; } = string.Empty;

        [BsonElement("prescriptions")]
        public List<Prescription> Prescriptions { get; set; } = new();

        [BsonElement("labResults")]
        public List<LabResult> LabResults { get; set; } = new();

        [BsonElement("vitalSigns")]
        public VitalSigns VitalSigns { get; set; } = new();

        [BsonElement("notes")]
        public string Notes { get; set; } = string.Empty;

        [BsonElement("followUpDate")]
        public DateTime? FollowUpDate { get; set; }

        [BsonElement("attachments")]
        public List<string> Attachments { get; set; } = new(); // File paths/URLs

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [BsonElement("updatedAt")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties (not stored in DB)
        [BsonIgnore]
        public Patient? Patient { get; set; }

        [BsonIgnore]
        public Doctor? Doctor { get; set; }
    }

    public class Prescription
    {
        [BsonElement("medicationName")]
        public string MedicationName { get; set; } = string.Empty;

        [BsonElement("dosage")]
        public string Dosage { get; set; } = string.Empty;

        [BsonElement("frequency")]
        public string Frequency { get; set; } = string.Empty;

        [BsonElement("duration")]
        public string Duration { get; set; } = string.Empty;

        [BsonElement("instructions")]
        public string Instructions { get; set; } = string.Empty;
    }

    public class LabResult
    {
        [BsonElement("testName")]
        public string TestName { get; set; } = string.Empty;

        [BsonElement("result")]
        public string Result { get; set; } = string.Empty;

        [BsonElement("referenceRange")]
        public string ReferenceRange { get; set; } = string.Empty;

        [BsonElement("unit")]
        public string Unit { get; set; } = string.Empty;

        [BsonElement("testDate")]
        public DateTime TestDate { get; set; }
    }

    public class VitalSigns
    {
        [BsonElement("temperature")]
        public double? Temperature { get; set; } // Celsius

        [BsonElement("bloodPressure")]
        public string BloodPressure { get; set; } = string.Empty; // e.g., "120/80"

        [BsonElement("heartRate")]
        public int? HeartRate { get; set; } // BPM

        [BsonElement("respiratoryRate")]
        public int? RespiratoryRate { get; set; } // Per minute

        [BsonElement("oxygenSaturation")]
        public double? OxygenSaturation { get; set; } // Percentage

        [BsonElement("weight")]
        public double? Weight { get; set; } // Kg

        [BsonElement("height")]
        public double? Height { get; set; } // Cm
    }
}
