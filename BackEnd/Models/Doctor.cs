namespace MedicalManagement.API.Models
{
    public class Doctor
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Specialty { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Bio { get; set; }
        // For simplicity store availability as a free-form string. Can be changed to schedule model later.
        public string? Availability { get; set; }
    }
}
