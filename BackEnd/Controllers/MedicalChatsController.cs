using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MedicalManagement.API.Data;
using MedicalManagement.API.DTOs;
using MedicalManagement.API.Models;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/medical-chats")]
    [Authorize]
    public class MedicalChatsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public MedicalChatsController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<MedicalChatResponse>>> GetMyChats()
        {
            var (userId, role) = GetCurrentUser();
            if (string.IsNullOrWhiteSpace(userId) || role == null) return Unauthorized();
            if (!IsPatientOrDoctor(role.Value)) return Forbid();

            IQueryable<MedicalChat> query = role == UserRole.Patient
                ? _db.MedicalChats.AsNoTracking().Where(c => c.PatientId == userId)
                : _db.MedicalChats.AsNoTracking().Where(c => c.DoctorId == userId);

            var chats = await query
                .OrderByDescending(c => c.LastMessageAt ?? c.UpdatedAt)
                .ToListAsync();

            return Ok(chats.Select(MapChat));
        }

        [HttpGet("{chatId}")]
        public async Task<ActionResult<MedicalChatResponse>> GetChat(string chatId)
        {
            var (userId, role) = GetCurrentUser();
            if (string.IsNullOrWhiteSpace(userId) || role == null) return Unauthorized();
            if (!IsPatientOrDoctor(role.Value)) return Forbid();

            var chat = await _db.MedicalChats.AsNoTracking().FirstOrDefaultAsync(c => c.Id == chatId);
            if (chat == null) return NotFound();
            if (!IsParticipant(chat, userId)) return Forbid();

            return Ok(MapChat(chat));
        }

        [HttpPost]
        public async Task<ActionResult<MedicalChatResponse>> CreateChat([FromBody] CreateMedicalChatRequest request)
        {
            var (userId, role) = GetCurrentUser();
            if (string.IsNullOrWhiteSpace(userId) || role == null) return Unauthorized();
            if (!IsPatientOrDoctor(role.Value)) return Forbid();

            var patientId = request.PatientId?.Trim();
            var doctorId = request.DoctorId?.Trim();

            if (role == UserRole.Patient)
            {
                if (string.IsNullOrWhiteSpace(patientId)) patientId = userId;
                if (!string.Equals(patientId, userId, StringComparison.Ordinal)) return Forbid();
                if (string.IsNullOrWhiteSpace(doctorId)) return BadRequest(new { message = "doctorId is required" });
            }
            else
            {
                if (string.IsNullOrWhiteSpace(doctorId)) doctorId = userId;
                if (!string.Equals(doctorId, userId, StringComparison.Ordinal)) return Forbid();
                if (string.IsNullOrWhiteSpace(patientId)) return BadRequest(new { message = "patientId is required" });
            }

            if (string.Equals(patientId, doctorId, StringComparison.Ordinal))
            {
                return BadRequest(new { message = "patientId and doctorId must be different" });
            }

            var patientExists = await _db.Users.AsNoTracking().AnyAsync(u => u.Id == patientId && u.Role == UserRole.Patient);
            if (!patientExists) return NotFound(new { message = "Patient not found" });

            var doctorExists = await _db.Users.AsNoTracking().AnyAsync(u => u.Id == doctorId && u.Role == UserRole.Doctor);
            if (!doctorExists) return NotFound(new { message = "Doctor not found" });

            var existing = await _db.MedicalChats.FirstOrDefaultAsync(c => c.PatientId == patientId && c.DoctorId == doctorId);
            if (existing != null)
            {
                return Ok(MapChat(existing));
            }

            var now = DateTime.UtcNow;
            var chat = new MedicalChat
            {
                PatientId = patientId,
                DoctorId = doctorId,
                CreatedAt = now,
                UpdatedAt = now
            };

            _db.MedicalChats.Add(chat);
            await _db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetChat), new { chatId = chat.Id }, MapChat(chat));
        }

        [HttpGet("{chatId}/messages")]
        public async Task<ActionResult<IEnumerable<MedicalMessageResponse>>> GetMessages(string chatId, int limit = 100)
        {
            var (userId, role) = GetCurrentUser();
            if (string.IsNullOrWhiteSpace(userId) || role == null) return Unauthorized();
            if (!IsPatientOrDoctor(role.Value)) return Forbid();

            var chat = await _db.MedicalChats.AsNoTracking().FirstOrDefaultAsync(c => c.Id == chatId);
            if (chat == null) return NotFound();
            if (!IsParticipant(chat, userId)) return Forbid();

            var safeLimit = Math.Clamp(limit, 1, 500);
            var messages = await _db.MedicalMessages.AsNoTracking()
                .Where(m => m.ChatId == chatId)
                .OrderBy(m => m.CreatedAt)
                .Take(safeLimit)
                .ToListAsync();

            return Ok(messages.Select(MapMessage));
        }

        [HttpPost("{chatId}/messages")]
        public async Task<ActionResult<MedicalMessageResponse>> PostMessage(string chatId, [FromBody] CreateMedicalMessageRequest request)
        {
            var (userId, role) = GetCurrentUser();
            if (string.IsNullOrWhiteSpace(userId) || role == null) return Unauthorized();
            if (!IsPatientOrDoctor(role.Value)) return Forbid();
            if (string.IsNullOrWhiteSpace(request.Content))
            {
                return BadRequest(new { message = "content is required" });
            }

            var chat = await _db.MedicalChats.FirstOrDefaultAsync(c => c.Id == chatId);
            if (chat == null) return NotFound();
            if (!IsParticipant(chat, userId)) return Forbid();

            var now = DateTime.UtcNow;
            var message = new MedicalMessage
            {
                ChatId = chat.Id,
                SenderId = userId,
                SenderRole = role.Value,
                Content = request.Content.Trim(),
                CreatedAt = now
            };

            _db.MedicalMessages.Add(message);
            chat.LastMessageAt = now;
            chat.UpdatedAt = now;

            await _db.SaveChangesAsync();

            return Ok(MapMessage(message));
        }

        private static MedicalChatResponse MapChat(MedicalChat chat)
        {
            return new MedicalChatResponse
            {
                Id = chat.Id,
                PatientId = chat.PatientId,
                DoctorId = chat.DoctorId,
                CreatedAt = chat.CreatedAt,
                UpdatedAt = chat.UpdatedAt,
                LastMessageAt = chat.LastMessageAt
            };
        }

        private static MedicalMessageResponse MapMessage(MedicalMessage message)
        {
            return new MedicalMessageResponse
            {
                Id = message.Id,
                ChatId = message.ChatId,
                SenderId = message.SenderId,
                SenderRole = message.SenderRole,
                Content = message.Content,
                CreatedAt = message.CreatedAt
            };
        }

        private (string? userId, UserRole? role) GetCurrentUser()
        {
            var userId = User.FindFirst("sub")?.Value;
            var roleClaim = User.FindFirst("role")?.Value;
            if (Enum.TryParse<UserRole>(roleClaim, true, out var parsedRole))
            {
                return (userId, parsedRole);
            }

            return (userId, null);
        }

        private static bool IsPatientOrDoctor(UserRole role)
        {
            return role == UserRole.Patient || role == UserRole.Doctor;
        }

        private static bool IsParticipant(MedicalChat chat, string userId)
        {
            return string.Equals(chat.PatientId, userId, StringComparison.Ordinal) ||
                   string.Equals(chat.DoctorId, userId, StringComparison.Ordinal);
        }
    }
}
