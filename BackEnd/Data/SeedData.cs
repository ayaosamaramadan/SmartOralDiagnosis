using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using MedicalManagement.API.Models;
using BCrypt.Net;

namespace MedicalManagement.API.Data
{
    public static class SeedData
    {
        public static async Task EnsureSeedDataAsync(IServiceProvider services)
        {
            using var scope = services.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

            if (!db.Users.Any(u => u.Email == "doctor@example.com"))
            {
                var doctor = new User
                {
                    Email = "doctor@example.com",
                    FirstName = "John",
                    LastName = "Doe",
                    Role = UserRole.Doctor,
                    Specialization = "General Dentistry",
                    LicenseNumber = "LIC12345",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    ConsultationFee = 50
                };
                doctor.PasswordHash = BCrypt.Net.BCrypt.HashPassword("password123");
                db.Users.Add(doctor);
            }

            if (!db.Users.Any(u => u.Email == "patient@example.com"))
            {
                var patient = new User
                {
                    Email = "patient@example.com",
                    FirstName = "Jane",
                    LastName = "Smith",
                    Role = UserRole.Patient,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                patient.PasswordHash = BCrypt.Net.BCrypt.HashPassword("password123");
                db.Users.Add(patient);
            }

            await db.SaveChangesAsync();
            // Seed a sample appointment if none exists
            var doctorUser = db.Users.FirstOrDefault(u => u.Email == "doctor@example.com");
            var patientUser = db.Users.FirstOrDefault(u => u.Email == "patient@example.com");

            if (doctorUser != null && patientUser != null && !db.Appointments.Any())
            {
                var appointment = new Appointment
                {
                    PatientId = patientUser.Id,
                    DoctorId = doctorUser.Id,
                    AppointmentDate = DateTime.UtcNow.AddDays(3),
                    Duration = 30,
                    Type = AppointmentType.Consultation,
                    Status = AppointmentStatus.Scheduled,
                    Reason = "Routine check-up",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.Appointments.Add(appointment);
                await db.SaveChangesAsync();

                // Seed a sample medical record for that appointment
                var record = new MedicalRecord
                {
                    PatientId = patientUser.Id,
                    DoctorId = doctorUser.Id,
                    AppointmentId = appointment.Id,
                    Title = "Initial Consultation",
                    Description = "General oral examination, no acute findings.",
                    Diagnosis = "Healthy",
                    Treatment = "No treatment required",
                    RecordDate = DateTime.UtcNow,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                db.MedicalRecords.Add(record);
                await db.SaveChangesAsync();
            }
        }
    }
}

