using System;
using System.Collections.Generic;
using System.IO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using MedicalManagement.API.Models;
using MongoDB.Driver;

namespace MedicalManagement.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UploadsController : ControllerBase
    {
        private readonly IWebHostEnvironment _env;
        private readonly MongoDbService _mongo;
        private readonly ILogger<UploadsController> _logger;
        private const long MaxProfilePhotoBytes = 5 * 1024 * 1024; // 5MB safety limit
        private static readonly HashSet<string> AllowedPhotoMimeTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/gif"
        };

        public UploadsController(IWebHostEnvironment env, MongoDbService mongo, ILogger<UploadsController> logger)
        {
            _env = env;
            _mongo = mongo;
            _logger = logger;
        }

        [HttpPost]
        [RequestSizeLimit(10_000_000)] // limit ~10MB
        public async Task<IActionResult> Upload([FromForm] IFormFile file)
        {
            if (file == null || file.Length == 0) return BadRequest("No file uploaded");

            var uploads = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "uploads");
            if (!Directory.Exists(uploads)) Directory.CreateDirectory(uploads);

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
            var filePath = Path.Combine(uploads, fileName);

            using var stream = System.IO.File.Create(filePath);
            await file.CopyToAsync(stream);

            var publicPath = $"/uploads/{fileName}";
            return Ok(new { fileName, filePath = publicPath });
        }

        [HttpPost("profile-photo")]
        [Authorize]
        [RequestSizeLimit(MaxProfilePhotoBytes)]
        public async Task<IActionResult> UploadProfilePhoto([FromForm] IFormFile file, [FromForm] string? userId = null)
        {
            if (file == null || file.Length == 0) return BadRequest("No file uploaded");
            if (file.Length > MaxProfilePhotoBytes)
            {
                return BadRequest("File is too large. Maximum allowed size is 5MB.");
            }

            if (!AllowedPhotoMimeTypes.Contains(file.ContentType))
            {
                return BadRequest("Unsupported file type. Please upload a JPG, PNG, WEBP, or GIF image.");
            }

            await using var memoryStream = new MemoryStream();
            await file.CopyToAsync(memoryStream);
            var photoBytes = memoryStream.ToArray();

            // create a BSON document to store in MongoDB (store binary as base64 string to avoid relying on a typed model)
            var id = MongoDB.Bson.ObjectId.GenerateNewId().ToString();
            var bson = new MongoDB.Bson.BsonDocument
            {
                { "_id", id },
                { "userId", userId ?? string.Empty },
                { "fileName", Path.GetFileName(file.FileName) },
                { "contentType", file.ContentType ?? "application/octet-stream" },
                { "length", photoBytes.LongLength },
                { "data", Convert.ToBase64String(photoBytes) },
                { "uploadedAt", DateTime.UtcNow }
            };

            try
            {
                var collection = _mongo.GetCollection<MongoDB.Bson.BsonDocument>("profile_photos");
                await collection.InsertOneAsync(bson);
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex, "MongoDB is not configured for profile photo uploads.");
                return StatusCode(503, "Profile photo storage is temporarily unavailable.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to upload profile photo to MongoDB.");
                return StatusCode(500, "Failed to store profile photo.");
            }

            var baseUrl = $"{Request.Scheme}://{Request.Host}";
            var photoUrl = $"{baseUrl}/api/uploads/profile-photo/{id}";
            return Ok(new { photoId = id, photoUrl });
        }

        [HttpGet("profile-photo/{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetProfilePhoto(string id)
        {
            MongoDB.Bson.BsonDocument? document;

            try
            {
                var collection = _mongo.GetCollection<MongoDB.Bson.BsonDocument>("profile_photos");
                var filter = Builders<MongoDB.Bson.BsonDocument>.Filter.Eq("_id", id);
                document = await collection.Find(filter).FirstOrDefaultAsync();
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogWarning(ex, "MongoDB is not configured for profile photo retrieval.");
                return NotFound();
            }

            if (document == null)
            {
                return NotFound();
            }

            try
            {
                var base64 = document.Contains("data") ? document.GetValue("data").AsString : null;
                var contentType = document.Contains("contentType") ? document.GetValue("contentType").AsString : "application/octet-stream";
                var fileName = document.Contains("fileName") ? document.GetValue("fileName").AsString : "file";

                if (string.IsNullOrEmpty(base64)) return NotFound();
                var bytes = Convert.FromBase64String(base64);
                return File(bytes, contentType, fileName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to read profile photo document from MongoDB.");
                return StatusCode(500, "Failed to read profile photo.");
            }
        }
    }
}