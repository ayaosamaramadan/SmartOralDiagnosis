using MedicalManagement.API.Models;
using MedicalManagement.API.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace MedicalManagement.API.Services
{
    public interface IDoctorService
    {
        Task<List<DoctorDto>> GetAllDoctorsAsync();
        Task<DoctorDto?> GetDoctorByIdAsync(string id);
        Task<DoctorDto?> CreateDoctorAsync(Doctor doctor);
        Task<DoctorDto?> UpdateDoctorAsync(string id, Doctor doctor);
        Task<bool> DeleteDoctorAsync(string id);
        Task<List<DoctorDto>> GetDoctorsBySpecializationAsync(string specialization);
    }

    public class DoctorService : IDoctorService
    {
        private readonly IMongoCollection<Doctor> _doctors;
        private readonly IMongoCollection<Patient> _patients;

        public DoctorService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _doctors = database.GetCollection<Doctor>("doctors");
            _patients = database.GetCollection<Patient>("patients");
        }

        public async Task<List<DoctorDto>> GetAllDoctorsAsync()
        {
            var doctors = await _doctors.Find(_ => true).ToListAsync();
            var doctorDtos = new List<DoctorDto>();

            foreach (var doctor in doctors)
            {
                var patientCount = await _patients.CountDocumentsAsync(p => p.AssignedDoctorId == doctor.Id);
                doctorDtos.Add(MapToDto(doctor, (int)patientCount));
            }

            return doctorDtos;
        }

        public async Task<DoctorDto?> GetDoctorByIdAsync(string id)
        {
            var doctor = await _doctors.Find(d => d.Id == id).FirstOrDefaultAsync();
            if (doctor == null) return null;

            var patientCount = await _patients.CountDocumentsAsync(p => p.AssignedDoctorId == id);
            return MapToDto(doctor, (int)patientCount);
        }

        public async Task<DoctorDto?> CreateDoctorAsync(Doctor doctor)
        {
            doctor.Role = "doctor";
            await _doctors.InsertOneAsync(doctor);
            return MapToDto(doctor, 0);
        }

        public async Task<DoctorDto?> UpdateDoctorAsync(string id, Doctor doctor)
        {
            doctor.Id = id;
            doctor.UpdatedAt = DateTime.UtcNow;

            var result = await _doctors.ReplaceOneAsync(d => d.Id == id, doctor);
            if (result.ModifiedCount > 0)
            {
                var patientCount = await _patients.CountDocumentsAsync(p => p.AssignedDoctorId == id);
                return MapToDto(doctor, (int)patientCount);
            }
            return null;
        }

        public async Task<bool> DeleteDoctorAsync(string id)
        {
            var result = await _doctors.DeleteOneAsync(d => d.Id == id);
            return result.DeletedCount > 0;
        }

        public async Task<List<DoctorDto>> GetDoctorsBySpecializationAsync(string specialization)
        {
            var doctors = await _doctors.Find(d => d.Specialization == specialization).ToListAsync();
            var doctorDtos = new List<DoctorDto>();

            foreach (var doctor in doctors)
            {
                var patientCount = await _patients.CountDocumentsAsync(p => p.AssignedDoctorId == doctor.Id);
                doctorDtos.Add(MapToDto(doctor, (int)patientCount));
            }

            return doctorDtos;
        }

        private static DoctorDto MapToDto(Doctor doctor, int patientCount)
        {
            return new DoctorDto
            {
                Id = doctor.Id,
                Email = doctor.Email,
                FirstName = doctor.FirstName,
                LastName = doctor.LastName,
                PhoneNumber = doctor.PhoneNumber,
                Role = doctor.Role,
                IsActive = doctor.IsActive,
                CreatedAt = doctor.CreatedAt,
                LicenseNumber = doctor.LicenseNumber,
                Specialization = doctor.Specialization,
                Department = doctor.Department,
                Qualifications = doctor.Qualifications,
                Experience = doctor.Experience,
                Schedule = doctor.Schedule,
                ConsultationFee = doctor.ConsultationFee,
                PatientCount = patientCount
            };
        }
    }
}
