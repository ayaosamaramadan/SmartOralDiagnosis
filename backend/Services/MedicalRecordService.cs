using MedicalManagement.API.Models;
using MedicalManagement.API.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace MedicalManagement.API.Services
{
    public interface IMedicalRecordService
    {
        Task<List<MedicalRecordDto>> GetAllMedicalRecordsAsync();
        Task<MedicalRecordDto?> GetMedicalRecordByIdAsync(string id);
        Task<MedicalRecordDto?> CreateMedicalRecordAsync(MedicalRecord record);
        Task<MedicalRecordDto?> UpdateMedicalRecordAsync(string id, MedicalRecord record);
        Task<bool> DeleteMedicalRecordAsync(string id);
        Task<List<MedicalRecordDto>> GetMedicalRecordsByPatientIdAsync(string patientId);
        Task<List<MedicalRecordDto>> GetMedicalRecordsByDoctorIdAsync(string doctorId);
    }

    public class MedicalRecordService : IMedicalRecordService
    {
        private readonly IMongoCollection<MedicalRecord> _medicalRecords;
        private readonly IMongoCollection<Patient> _patients;
        private readonly IMongoCollection<Doctor> _doctors;

        public MedicalRecordService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _medicalRecords = database.GetCollection<MedicalRecord>("medicalRecords");
            _patients = database.GetCollection<Patient>("patients");
            _doctors = database.GetCollection<Doctor>("doctors");
        }

        public async Task<List<MedicalRecordDto>> GetAllMedicalRecordsAsync()
        {
            var records = await _medicalRecords.Find(_ => true).ToListAsync();
            return await MapToDtosAsync(records);
        }

        public async Task<MedicalRecordDto?> GetMedicalRecordByIdAsync(string id)
        {
            var record = await _medicalRecords.Find(r => r.Id == id).FirstOrDefaultAsync();
            if (record == null) return null;

            var recordDtos = await MapToDtosAsync(new List<MedicalRecord> { record });
            return recordDtos.FirstOrDefault();
        }

        public async Task<MedicalRecordDto?> CreateMedicalRecordAsync(MedicalRecord record)
        {
            await _medicalRecords.InsertOneAsync(record);

            var recordDtos = await MapToDtosAsync(new List<MedicalRecord> { record });
            return recordDtos.FirstOrDefault();
        }

        public async Task<MedicalRecordDto?> UpdateMedicalRecordAsync(string id, MedicalRecord record)
        {
            record.Id = id;
            record.UpdatedAt = DateTime.UtcNow;

            var result = await _medicalRecords.ReplaceOneAsync(r => r.Id == id, record);
            if (result.ModifiedCount > 0)
            {
                var recordDtos = await MapToDtosAsync(new List<MedicalRecord> { record });
                return recordDtos.FirstOrDefault();
            }
            return null;
        }

        public async Task<bool> DeleteMedicalRecordAsync(string id)
        {
            var result = await _medicalRecords.DeleteOneAsync(r => r.Id == id);
            return result.DeletedCount > 0;
        }

        public async Task<List<MedicalRecordDto>> GetMedicalRecordsByPatientIdAsync(string patientId)
        {
            var records = await _medicalRecords.Find(r => r.PatientId == patientId).ToListAsync();
            return await MapToDtosAsync(records);
        }

        public async Task<List<MedicalRecordDto>> GetMedicalRecordsByDoctorIdAsync(string doctorId)
        {
            var records = await _medicalRecords.Find(r => r.DoctorId == doctorId).ToListAsync();
            return await MapToDtosAsync(records);
        }

        private async Task<List<MedicalRecordDto>> MapToDtosAsync(List<MedicalRecord> records)
        {
            var recordDtos = new List<MedicalRecordDto>();

            foreach (var record in records)
            {
                var patient = await _patients.Find(p => p.Id == record.PatientId).FirstOrDefaultAsync();
                var doctor = await _doctors.Find(d => d.Id == record.DoctorId).FirstOrDefaultAsync();

                recordDtos.Add(new MedicalRecordDto
                {
                    Id = record.Id,
                    PatientId = record.PatientId,
                    DoctorId = record.DoctorId,
                    AppointmentId = record.AppointmentId,
                    VisitDate = record.VisitDate,
                    Diagnosis = record.Diagnosis,
                    Symptoms = record.Symptoms,
                    Treatment = record.Treatment,
                    Prescriptions = record.Prescriptions,
                    LabResults = record.LabResults,
                    VitalSigns = record.VitalSigns,
                    Notes = record.Notes,
                    FollowUpDate = record.FollowUpDate,
                    PatientName = patient != null ? $"{patient.FirstName} {patient.LastName}" : "Unknown",
                    DoctorName = doctor != null ? $"Dr. {doctor.FirstName} {doctor.LastName}" : "Unknown"
                });
            }

            return recordDtos;
        }
    }

    public interface IAdminService
    {
        Task<Dictionary<string, object>> GetDashboardStatsAsync();
        Task<List<UserDto>> GetAllUsersAsync();
        Task<bool> DeactivateUserAsync(string userId);
        Task<bool> ActivateUserAsync(string userId);
    }

    public class AdminService : IAdminService
    {
        private readonly IMongoCollection<User> _users;
        private readonly IMongoCollection<Patient> _patients;
        private readonly IMongoCollection<Doctor> _doctors;
        private readonly IMongoCollection<Appointment> _appointments;
        private readonly IMongoCollection<MedicalRecord> _medicalRecords;

        public AdminService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _users = database.GetCollection<User>("users");
            _patients = database.GetCollection<Patient>("patients");
            _doctors = database.GetCollection<Doctor>("doctors");
            _appointments = database.GetCollection<Appointment>("appointments");
            _medicalRecords = database.GetCollection<MedicalRecord>("medicalRecords");
        }

        public async Task<Dictionary<string, object>> GetDashboardStatsAsync()
        {
            var totalPatients = await _patients.CountDocumentsAsync(_ => true);
            var totalDoctors = await _doctors.CountDocumentsAsync(_ => true);
            var totalAppointments = await _appointments.CountDocumentsAsync(_ => true);
            var totalRecords = await _medicalRecords.CountDocumentsAsync(_ => true);

            var today = DateTime.UtcNow.Date;
            var todayAppointments = await _appointments.CountDocumentsAsync(a =>
                a.AppointmentDate >= today && a.AppointmentDate < today.AddDays(1));

            return new Dictionary<string, object>
            {
                { "totalPatients", totalPatients },
                { "totalDoctors", totalDoctors },
                { "totalAppointments", totalAppointments },
                { "totalMedicalRecords", totalRecords },
                { "todayAppointments", todayAppointments }
            };
        }

        public async Task<List<UserDto>> GetAllUsersAsync()
        {
            var users = await _users.Find(_ => true).ToListAsync();
            return users.Select(user => new UserDto
            {
                Id = user.Id,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                PhoneNumber = user.PhoneNumber,
                Role = user.Role,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt
            }).ToList();
        }

        public async Task<bool> DeactivateUserAsync(string userId)
        {
            var update = Builders<User>.Update.Set(u => u.IsActive, false).Set(u => u.UpdatedAt, DateTime.UtcNow);
            var result = await _users.UpdateOneAsync(u => u.Id == userId, update);
            return result.ModifiedCount > 0;
        }

        public async Task<bool> ActivateUserAsync(string userId)
        {
            var update = Builders<User>.Update.Set(u => u.IsActive, true).Set(u => u.UpdatedAt, DateTime.UtcNow);
            var result = await _users.UpdateOneAsync(u => u.Id == userId, update);
            return result.ModifiedCount > 0;
        }
    }
}
