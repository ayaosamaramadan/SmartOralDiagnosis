using System.ComponentModel.DataAnnotations;

namespace MedicalManagement.API.DTOs
{
    public class CaseSimilarityRequest
    {
        public string? Diagnosis { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public string? Symptoms { get; set; }
        public string? Notes { get; set; }

        [Range(1, 10)]
        public int TopK { get; set; } = 3;

        // Accept 0-1 or 0-100. Default is 70%.
        public double SimilarityThreshold { get; set; } = 70;

        public string? ExcludeRecordId { get; set; }
        public string? DoctorId { get; set; }
    }

    public class SimilarCaseDto
    {
        public string CaseId { get; set; } = string.Empty;
        public double Similarity { get; set; }
        public string? Diagnosis { get; set; }
        public string? ThumbnailUrl { get; set; }
    }

    public class CaseSimilarityResponse
    {
        public string? QueryDiagnosis { get; set; }
        public double BestMatchSimilarity { get; set; }
        public int SimilarCasesCount { get; set; }
        public int SameDiagnosisCount { get; set; }
        public int TotalCasesConsidered { get; set; }
        public List<SimilarCaseDto> TopCases { get; set; } = new();
    }
}
