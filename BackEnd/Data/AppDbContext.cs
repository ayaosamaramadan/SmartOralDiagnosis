using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; } = null!;
    public DbSet<Appointment> Appointments { get; set; } = null!;
    public DbSet<MedicalRecord> MedicalRecords { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Email).IsRequired().HasMaxLength(200);
                entity.Property(e => e.FirstName).HasMaxLength(100);
                entity.Property(e => e.LastName).HasMaxLength(100);
                entity.Property(e => e.PhoneNumber).HasMaxLength(25);
                entity.Property(e => e.LicenseNumber).HasMaxLength(100);
                entity.Property(e => e.Specialization).HasMaxLength(200);
<<<<<<< HEAD
                // ConsultationFee is decimal; explicitly set precision to avoid truncation warnings
=======
                // Ensure decimal precision is specified to avoid silent truncation when using SQL Server
                // and to make EF Core model validation happy.
>>>>>>> 25ab0a39111395522e5e762ea9c793e76dd660ac
                entity.Property(e => e.ConsultationFee).HasPrecision(18, 2);
            });
        }
    }
}
