using System;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace MedicalManagement.API.Models
{
    public class DoctorRating
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? Id { get; set; }

        [BsonElement("doctorId")]
        public string DoctorId { get; set; } = string.Empty;

        [BsonElement("userId")]
        public string? UserId { get; set; }

        [BsonElement("score")]
        public decimal Score { get; set; }

        [BsonElement("comment")]
        public string? Comment { get; set; }

        [BsonElement("createdAt")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
