using MedicalManagement.API.Models;
using MedicalManagement.API.Configuration;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace MedicalManagement.API.Services
{
    public interface IAppointmentService
    {
        Task<List<AppointmentDto>> GetAllAppointmentsAsync();
        Task<AppointmentDto?> GetAppointmentByIdAsync(string id);
        Task<AppointmentDto?> CreateAppointmentAsync(CreateAppointmentRequest request);
        Task<AppointmentDto?> UpdateAppointmentAsync(string id, Appointment appointment);
        Task<bool> DeleteAppointmentAsync(string id);
        Task<List<AppointmentDto>> GetAppointmentsByPatientIdAsync(string patientId);
        Task<List<AppointmentDto>> GetAppointmentsByDoctorIdAsync(string doctorId);
        Task<List<AppointmentDto>> GetAppointmentsByDateAsync(DateTime date);
    }

    public class AppointmentService : IAppointmentService
    {
        private readonly IMongoCollection<Appointment> _appointments;
        private readonly IMongoCollection<Patient> _patients;
        private readonly IMongoCollection<Doctor> _doctors;

        public AppointmentService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _appointments = database.GetCollection<Appointment>("appointments");
            _patients = database.GetCollection<Patient>("patients");
            _doctors = database.GetCollection<Doctor>("doctors");
        }

        public async Task<List<AppointmentDto>> GetAllAppointmentsAsync()
        {
            var appointments = await _appointments.Find(_ => true).ToListAsync();
            return await MapToDtosAsync(appointments);
        }

        public async Task<AppointmentDto?> GetAppointmentByIdAsync(string id)
        {
            var appointment = await _appointments.Find(a => a.Id == id).FirstOrDefaultAsync();
            if (appointment == null) return null;

            var appointmentDtos = await MapToDtosAsync(new List<Appointment> { appointment });
            return appointmentDtos.FirstOrDefault();
        }

        public async Task<AppointmentDto?> CreateAppointmentAsync(CreateAppointmentRequest request)
        {
            var appointment = new Appointment
            {
                PatientId = request.PatientId,
                DoctorId = request.DoctorId,
                AppointmentDate = request.AppointmentDate,
                Duration = request.Duration,
                Type = request.Type,
                Reason = request.Reason,
                Status = "Scheduled"
            };

            await _appointments.InsertOneAsync(appointment);

            var appointmentDtos = await MapToDtosAsync(new List<Appointment> { appointment });
            return appointmentDtos.FirstOrDefault();
        }

        public async Task<AppointmentDto?> UpdateAppointmentAsync(string id, Appointment appointment)
        {
            appointment.Id = id;
            appointment.UpdatedAt = DateTime.UtcNow;

            var result = await _appointments.ReplaceOneAsync(a => a.Id == id, appointment);
            if (result.ModifiedCount > 0)
            {
                var appointmentDtos = await MapToDtosAsync(new List<Appointment> { appointment });
                return appointmentDtos.FirstOrDefault();
            }
            return null;
        }

        public async Task<bool> DeleteAppointmentAsync(string id)
        {
            var result = await _appointments.DeleteOneAsync(a => a.Id == id);
            return result.DeletedCount > 0;
        }

        public async Task<List<AppointmentDto>> GetAppointmentsByPatientIdAsync(string patientId)
        {
            var appointments = await _appointments.Find(a => a.PatientId == patientId).ToListAsync();
            return await MapToDtosAsync(appointments);
        }

        public async Task<List<AppointmentDto>> GetAppointmentsByDoctorIdAsync(string doctorId)
        {
            var appointments = await _appointments.Find(a => a.DoctorId == doctorId).ToListAsync();
            return await MapToDtosAsync(appointments);
        }

        public async Task<List<AppointmentDto>> GetAppointmentsByDateAsync(DateTime date)
        {
            var startDate = date.Date;
            var endDate = startDate.AddDays(1);

            var appointments = await _appointments.Find(a =>
                a.AppointmentDate >= startDate && a.AppointmentDate < endDate).ToListAsync();
            return await MapToDtosAsync(appointments);
        }

        private async Task<List<AppointmentDto>> MapToDtosAsync(List<Appointment> appointments)
        {
            var appointmentDtos = new List<AppointmentDto>();

            foreach (var appointment in appointments)
            {
                var patient = await _patients.Find(p => p.Id == appointment.PatientId).FirstOrDefaultAsync();
                var doctor = await _doctors.Find(d => d.Id == appointment.DoctorId).FirstOrDefaultAsync();

                appointmentDtos.Add(new AppointmentDto
                {
                    Id = appointment.Id,
                    PatientId = appointment.PatientId,
                    DoctorId = appointment.DoctorId,
                    AppointmentDate = appointment.AppointmentDate,
                    Duration = appointment.Duration,
                    Status = appointment.Status,
                    Type = appointment.Type,
                    Reason = appointment.Reason,
                    Notes = appointment.Notes,
                    PatientName = patient != null ? $"{patient.FirstName} {patient.LastName}" : "Unknown",
                    DoctorName = doctor != null ? $"Dr. {doctor.FirstName} {doctor.LastName}" : "Unknown"
                });
            }

            return appointmentDtos;
        }
    }
}
