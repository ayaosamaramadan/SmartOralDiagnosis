using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net;
using MedicalManagement.API.Data;
using MedicalManagement.API.Models;
using MedicalManagement.API.Services;
using MongoDB.Driver;
using Microsoft.Extensions.Logging;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly JwtService _jwt;
        private readonly MongoDbService _mongo;
        private readonly ILogger<AuthController> _logger;

        // Constructor accepts MongoDbService via DI
        public AuthController(AppDbContext db, JwtService jwt, MongoDbService mongo, ILogger<AuthController> logger)
        {
            _db = db;
            _jwt = jwt;
            _mongo = mongo;
            _logger = logger;
        }

        [HttpPost("register")]
        [Microsoft.AspNetCore.Authorization.AllowAnonymous]
        public async Task<IActionResult> Register([FromBody] MedicalManagement.API.DTOs.RegisterRequest req)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var exists = await _db.Users.AnyAsync(u => u.Email == req.Email);
            if (exists) return BadRequest(new { message = "Email already registered" });

            var user = new User
            {
                Email = req.Email,
                FirstName = req.FirstName,
                LastName = req.LastName,
                PhoneNumber = req.PhoneNumber,
                DateOfBirth = req.DateOfBirth,
                Role = Enum.TryParse<UserRole>(req.Role, true, out var r) ? r : UserRole.Patient,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            var pwdHash = BCrypt.Net.BCrypt.HashPassword(req.Password);
            user.PasswordHash = pwdHash;

            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            try
            {
                var coll = _mongo.GetCollection<MongoDB.Bson.BsonDocument>("users");
                var doc = new MongoDB.Bson.BsonDocument
                {
                    { "_id", user.Id },
                    { "firstname", user.FirstName ?? string.Empty },
                    { "lastname", user.LastName ?? string.Empty },
                    { "birthday", user.DateOfBirth ?? string.Empty },
                    { "email", user.Email },
                    { "pass", user.PasswordHash },
                    { "phone", user.PhoneNumber ?? string.Empty },
                    { "photo", user.Photo ?? string.Empty },
                    {"location", user.Location ?? string.Empty }
                };
                // Include role so clients that read from Mongo can see the user's role
                try
                {
                    doc.Add("role", user.Role.ToString());
                }
                catch { /* ignore if role cannot be added for any reason */ }
                await coll.InsertOneAsync(doc);
                _logger?.LogInformation("Inserted user {Email} into MongoDB 'users' collection.", user.Email);
            }
            catch (Exception ex)
            {
                // Use structured logging so errors are visible in application logs
                _logger?.LogWarning(ex, "Failed to write user {Email} to MongoDB.", user.Email);
            }

            var token = _jwt.GenerateToken(user);
            return Ok(new { token, user });
        }

        [HttpPost("login")]
        [Microsoft.AspNetCore.Authorization.AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] MedicalManagement.API.DTOs.LoginRequest req)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            User? user = null;

            // Try MongoDB first (if available) as the source of truth for auth
            try
            {
                var coll = _mongo.GetCollection<MongoDB.Bson.BsonDocument>("users");
                var filter = Builders<MongoDB.Bson.BsonDocument>.Filter.Eq("email", req.Email);
                var mongoDoc = await coll.Find(filter).FirstOrDefaultAsync();
                if (mongoDoc != null)
                {
                    // Map minimal Mongo document back into User model for authentication checks
                    user = new User
                    {
                        Id = mongoDoc.GetValue("_id").AsString,
                        Email = mongoDoc.GetValue("email").AsString,
                        FirstName = mongoDoc.Contains("firstname") ? mongoDoc.GetValue("firstname").AsString : string.Empty,
                        LastName = mongoDoc.Contains("lastname") ? mongoDoc.GetValue("lastname").AsString : string.Empty,
                        Photo = mongoDoc.Contains("photo") ? mongoDoc.GetValue("photo").AsString : null,
                        PasswordHash = mongoDoc.Contains("pass") ? mongoDoc.GetValue("pass").AsString : string.Empty,
                        PhoneNumber = mongoDoc.Contains("phone") ? mongoDoc.GetValue("phone").AsString : null,
                        DateOfBirth = mongoDoc.Contains("birthday") ? mongoDoc.GetValue("birthday").AsString : null,
                    };

                    // Map role from Mongo document if present
                    try
                    {
                        if (mongoDoc.Contains("role"))
                        {
                            var roleStr = mongoDoc.GetValue("role").AsString;
                            if (!string.IsNullOrWhiteSpace(roleStr) && Enum.TryParse<UserRole>(roleStr, true, out var parsedRole))
                            {
                                user.Role = parsedRole;
                            }
                        }
                        else if (mongoDoc.Contains("roles"))
                        {
                            // roles may be an array - try to take the first string entry
                            var rolesVal = mongoDoc.GetValue("roles");
                            if (rolesVal.IsBsonArray && rolesVal.AsBsonArray.Count > 0)
                            {
                                var first = rolesVal.AsBsonArray[0];
                                var roleStr = first.AsString;
                                if (!string.IsNullOrWhiteSpace(roleStr) && Enum.TryParse<UserRole>(roleStr, true, out var parsedRole2))
                                {
                                    user.Role = parsedRole2;
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger?.LogDebug(ex, "Failed to parse role from Mongo document for {Email}", req.Email);
                    }
                    _logger?.LogInformation("Found user {Email} in MongoDB for login.", req.Email);
                }
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "MongoDB lookup failed during login for {Email} - falling back to SQL.", req.Email);
            }

            // Fallback to SQL if not found in Mongo
            if (user == null)
            {
                user = await _db.Users.FirstOrDefaultAsync(u => u.Email == req.Email);
            }

            if (user == null) return Unauthorized(new { message = "Invalid credentials" });

            var ok = BCrypt.Net.BCrypt.Verify(req.Password, user.PasswordHash);
            if (!ok) return Unauthorized(new { message = "Invalid credentials" });

            // If user came from Mongo but not SQL, sync back into SQL for consistency
            try
            {
                var existsInSql = await _db.Users.AnyAsync(u => u.Id == user.Id);
                if (!existsInSql)
                {
                    _db.Users.Add(user);
                    await _db.SaveChangesAsync();
                    _logger?.LogInformation("Synchronized user {Email} from MongoDB into SQL database.", user.Email);
                }
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "Failed to synchronize user {Email} into SQL after Mongo login.", user.Email);
            }

            var token = _jwt.GenerateToken(user);
            return Ok(new { token, user });
        }
    }
}
