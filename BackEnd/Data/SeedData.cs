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
        }
    }
}
