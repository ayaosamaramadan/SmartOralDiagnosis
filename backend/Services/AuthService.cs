using MedicalManagement.API.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using MedicalManagement.API.Configuration;

namespace MedicalManagement.API.Services
{
    public interface IAuthService
    {
        Task<AuthResponse?> LoginAsync(LoginRequest request);
        Task<AuthResponse?> RegisterAsync(RegisterRequest request);
        Task<User?> GetUserByIdAsync(string userId);
        string GenerateJwtToken(User user);
    }

    public class AuthService : IAuthService
    {
        private readonly IMongoCollection<User> _users;
        private readonly IConfiguration _configuration;

        public AuthService(IMongoClient mongoClient, IOptions<MongoDbSettings> mongoDbSettings, IConfiguration configuration)
        {
            var database = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
            _users = database.GetCollection<User>("users");
            _configuration = configuration;
        }

        public async Task<AuthResponse?> LoginAsync(LoginRequest request)
        {
            try
            {
                // Make role comparison case-insensitive and handle null values
                var user = await _users.Find(u =>
                    u.Email != null && u.Email.ToLower() == request.Email.ToLower() &&
                    u.Role != null && u.Role.ToLower() == request.Role.ToLower())
                    .FirstOrDefaultAsync();

                if (user == null)
                {
                    Console.WriteLine($"User not found for email: {request.Email}, role: {request.Role}");
                    return null;
                }

                if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                {
                    Console.WriteLine("Password verification failed");
                    return null;
                }

                var token = GenerateJwtToken(user);
                var userDto = new UserDto
                {
                    Id = user.Id,
                    Email = user.Email,
                    FirstName = user.FirstName,
                    LastName = user.LastName,
                    PhoneNumber = user.PhoneNumber,
                    Role = user.Role,
                    IsActive = user.IsActive,
                    CreatedAt = user.CreatedAt
                };

                return new AuthResponse
                {
                    Token = token,
                    User = userDto
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Login error: {ex.Message}");
                return null;
            }
        }

        public async Task<AuthResponse?> RegisterAsync(RegisterRequest request)
        {
            try
            {
                // Check if user already exists
                var existingUser = await _users.Find(u => u.Email == request.Email).FirstOrDefaultAsync();
                if (existingUser != null)
                {
                    Console.WriteLine($"User already exists with email: {request.Email}");
                    return null;
                }

                // Create new user with proper role formatting
                var newUser = new User
                {
                    Email = request.Email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                    FirstName = request.FirstName,
                    LastName = request.LastName,
                    PhoneNumber = request.PhoneNumber,
                    Role = request.Role.ToLower() switch
                    {
                        "doctor" => "Doctor",
                        "patient" => "Patient",
                        "admin" => "Admin",
                        _ => request.Role
                    },
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                await _users.InsertOneAsync(newUser);
                Console.WriteLine($"User registered successfully: {newUser.Email} as {newUser.Role}");

                var token = GenerateJwtToken(newUser);
                var userDto = new UserDto
                {
                    Id = newUser.Id,
                    Email = newUser.Email,
                    FirstName = newUser.FirstName,
                    LastName = newUser.LastName,
                    PhoneNumber = newUser.PhoneNumber,
                    Role = newUser.Role,
                    IsActive = newUser.IsActive,
                    CreatedAt = newUser.CreatedAt
                };

                return new AuthResponse
                {
                    Token = token,
                    User = userDto
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Registration error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                return null;
            }
        }

        public async Task<User?> GetUserByIdAsync(string userId)
        {
            return await _users.Find(u => u.Id == userId).FirstOrDefaultAsync();
        }

        public string GenerateJwtToken(User user)
        {
            try
            {
                var jwtSettings = _configuration.GetSection("JwtSettings");
                var secretKey = jwtSettings["SecretKey"];

                if (string.IsNullOrEmpty(secretKey))
                {
                    throw new InvalidOperationException("JWT SecretKey is not configured");
                }

                var key = Encoding.ASCII.GetBytes(secretKey);
                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(new[]
                    {
                        new Claim(ClaimTypes.NameIdentifier, user.Id ?? string.Empty),
                        new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
                        new Claim(ClaimTypes.Role, user.Role ?? string.Empty),
                        new Claim(ClaimTypes.Name, $"{user.FirstName} {user.LastName}")
                    }),
                    Expires = DateTime.UtcNow.AddHours(double.Parse(jwtSettings["ExpirationInHours"] ?? "24")),
                    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
                };

                var tokenHandler = new JwtSecurityTokenHandler();
                var token = tokenHandler.CreateToken(tokenDescriptor);
                return tokenHandler.WriteToken(token);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"JWT Generation error: {ex.Message}");
                throw;
            }
        }
    }
}
