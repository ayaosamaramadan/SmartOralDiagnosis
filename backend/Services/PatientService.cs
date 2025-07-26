using MedicalManagement.API.Models;
using MedicalManagement.API.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace MedicalManagement.API.Services
{
    public interface IPatientService
    {
        Task<List<PatientDto>> GetAllPatientsAsync();
        Task<PatientDto?> GetPatientByIdAsync(string id);
        Task<PatientDto?> CreatePatientAsync(Patient patient);
        Task<PatientDto?> UpdatePatientAsync(string id, Patient patient);
        Task<bool> DeletePatientAsync(string id);
        Task<List<PatientDto>> GetPatientsByDoctorIdAsync(string doctorId);
    }

    public class PatientService : IPatientService
    {
        private readonly IMongoCollection<Patient> _patients;
        private readonly IMongoCollection<Doctor> _doctors;

        public PatientService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _patients = database.GetCollection<Patient>("patients");
            _doctors = database.GetCollection<Doctor>("doctors");
        }

        public async Task<List<PatientDto>> GetAllPatientsAsync()
        {
            var patients = await _patients.Find(_ => true).ToListAsync();
            return patients.Select(MapToDto).ToList();
        }

        public async Task<PatientDto?> GetPatientByIdAsync(string id)
        {
            var patient = await _patients.Find(p => p.Id == id).FirstOrDefaultAsync();
            return patient != null ? MapToDto(patient) : null;
        }

        public async Task<PatientDto?> CreatePatientAsync(Patient patient)
        {
            patient.Role = "patient";
            await _patients.InsertOneAsync(patient);
            return MapToDto(patient);
        }

        public async Task<PatientDto?> UpdatePatientAsync(string id, Patient patient)
        {
            patient.Id = id;
            patient.UpdatedAt = DateTime.UtcNow;

            var result = await _patients.ReplaceOneAsync(p => p.Id == id, patient);
            return result.ModifiedCount > 0 ? MapToDto(patient) : null;
        }

        public async Task<bool> DeletePatientAsync(string id)
        {
            var result = await _patients.DeleteOneAsync(p => p.Id == id);
            return result.DeletedCount > 0;
        }

        public async Task<List<PatientDto>> GetPatientsByDoctorIdAsync(string doctorId)
        {
            var patients = await _patients.Find(p => p.AssignedDoctorId == doctorId).ToListAsync();
            return patients.Select(MapToDto).ToList();
        }

        private static PatientDto MapToDto(Patient patient)
        {
            return new PatientDto
            {
                Id = patient.Id,
                Email = patient.Email,
                FirstName = patient.FirstName,
                LastName = patient.LastName,
                PhoneNumber = patient.PhoneNumber,
                Role = patient.Role,
                IsActive = patient.IsActive,
                CreatedAt = patient.CreatedAt,
                DateOfBirth = patient.DateOfBirth,
                Gender = patient.Gender,
                Address = patient.Address,
                EmergencyContact = patient.EmergencyContact,
                BloodType = patient.BloodType,
                Allergies = patient.Allergies,
                MedicalHistory = patient.MedicalHistory,
                AssignedDoctorId = patient.AssignedDoctorId
            };
        }
    }
}
