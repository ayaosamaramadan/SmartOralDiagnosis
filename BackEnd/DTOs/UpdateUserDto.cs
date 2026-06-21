namespace MedicalManagement.API.DTOs
{
    public class UpdateUserDto
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Photo { get; set; }
        public string? Location { get; set; }
        public string? DateOfBirth { get; set; }
    }
}
