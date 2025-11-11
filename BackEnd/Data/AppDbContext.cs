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
                // ConsultationFee is a decimal; explicitly set precision and scale so values
                // aren't silently truncated by SQL Server and to satisfy EF Core model validation.
                entity.Property(e => e.ConsultationFee).HasPrecision(18, 2);
            });
        }
    }
}
