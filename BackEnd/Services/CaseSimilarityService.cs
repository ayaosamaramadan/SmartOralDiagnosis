using System.Text;
using System.Text.Json;
using MedicalManagement.API.Data;
using MedicalManagement.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace MedicalManagement.API.Services
{
    public class CaseSimilarityService
    {
        private readonly AppDbContext _db;

        private static readonly HashSet<string> StopWords = new(StringComparer.OrdinalIgnoreCase)
        {
            "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "he", "in", "is", "it",
            "its", "of", "on", "that", "the", "to", "was", "were", "will", "with", "without"
        };

        public CaseSimilarityService(AppDbContext db)
        {
            _db = db;
        }

        public async Task<CaseSimilarityResponse> FindSimilarCasesAsync(CaseSimilarityRequest request, CancellationToken cancellationToken = default)
        {
            var threshold = NormalizeThreshold(request.SimilarityThreshold);
            var topK = Math.Clamp(request.TopK, 1, 10);

            var queryText = BuildQueryText(request);
            var queryTokens = Tokenize(queryText);
            var normalizedDiagnosis = NormalizeDiagnosis(request.Diagnosis);

            var recordsQuery = _db.MedicalRecords.AsNoTracking().AsQueryable();
            if (!string.IsNullOrWhiteSpace(request.DoctorId))
            {
                recordsQuery = recordsQuery.Where(r => r.DoctorId == request.DoctorId);
            }

            if (!string.IsNullOrWhiteSpace(request.ExcludeRecordId))
            {
                recordsQuery = recordsQuery.Where(r => r.Id != request.ExcludeRecordId);
            }

            var records = await recordsQuery.ToListAsync(cancellationToken);

            var scored = new List<(double score, string recordId, string? diagnosis, string? thumbnail)>();
            foreach (var record in records)
            {
                var recordText = BuildRecordText(record);
                var recordTokens = Tokenize(recordText);
                var textScore = queryTokens.Count == 0 && recordTokens.Count == 0
                    ? 0
                    : JaccardSimilarity(queryTokens, recordTokens);

                var diagnosisScore = 0.0;
                if (!string.IsNullOrWhiteSpace(normalizedDiagnosis) && !string.IsNullOrWhiteSpace(record.Diagnosis))
                {
                    var recordDiagnosis = NormalizeDiagnosis(record.Diagnosis);
                    if (!string.IsNullOrWhiteSpace(recordDiagnosis) && string.Equals(normalizedDiagnosis, recordDiagnosis, StringComparison.OrdinalIgnoreCase))
                    {
                        diagnosisScore = 1.0;
                    }
                }

                var score = normalizedDiagnosis == null
                    ? textScore
                    : (0.7 * textScore) + (0.3 * diagnosisScore);

                scored.Add((score, record.Id, record.Diagnosis, TryExtractThumbnail(record.AttachmentsJson)));
            }

            var ordered = scored.OrderByDescending(s => s.score).ToList();
            var top = ordered.Take(topK)
                .Select(s => new SimilarCaseDto
                {
                    CaseId = s.recordId,
                    Similarity = Math.Round(s.score * 100, 2),
                    Diagnosis = s.diagnosis,
                    ThumbnailUrl = s.thumbnail
                })
                .ToList();

            var similarCount = ordered.Count(s => s.score >= threshold);
            var sameDiagnosisCount = 0;
            if (!string.IsNullOrWhiteSpace(normalizedDiagnosis))
            {
                sameDiagnosisCount = ordered.Count(s => s.score >= threshold &&
                    !string.IsNullOrWhiteSpace(s.diagnosis) &&
                    string.Equals(normalizedDiagnosis, NormalizeDiagnosis(s.diagnosis), StringComparison.OrdinalIgnoreCase));
            }

            var best = ordered.FirstOrDefault();

            return new CaseSimilarityResponse
            {
                QueryDiagnosis = request.Diagnosis,
                BestMatchSimilarity = Math.Round(best.score * 100, 2),
                SimilarCasesCount = similarCount,
                SameDiagnosisCount = sameDiagnosisCount,
                TotalCasesConsidered = records.Count,
                TopCases = top
            };
        }

        private static string BuildQueryText(CaseSimilarityRequest request)
        {
            var sb = new StringBuilder();
            AppendIfNotEmpty(sb, request.Title);
            AppendIfNotEmpty(sb, request.Description);
            AppendIfNotEmpty(sb, request.Symptoms);
            AppendIfNotEmpty(sb, request.Notes);
            AppendIfNotEmpty(sb, request.Diagnosis);
            return sb.ToString();
        }

        private static string BuildRecordText(Models.MedicalRecord record)
        {
            var sb = new StringBuilder();
            AppendIfNotEmpty(sb, record.Title);
            AppendIfNotEmpty(sb, record.Description);
            AppendIfNotEmpty(sb, record.Diagnosis);
            AppendIfNotEmpty(sb, record.Treatment);
            return sb.ToString();
        }

        private static void AppendIfNotEmpty(StringBuilder sb, string? value)
        {
            if (!string.IsNullOrWhiteSpace(value))
            {
                if (sb.Length > 0) sb.Append(' ');
                sb.Append(value);
            }
        }

        private static HashSet<string> Tokenize(string text)
        {
            var tokens = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrWhiteSpace(text)) return tokens;

            var normalized = new StringBuilder(text.Length);
            foreach (var ch in text)
            {
                if (char.IsLetterOrDigit(ch))
                {
                    normalized.Append(char.ToLowerInvariant(ch));
                }
                else
                {
                    normalized.Append(' ');
                }
            }

            foreach (var token in normalized.ToString().Split(' ', StringSplitOptions.RemoveEmptyEntries))
            {
                if (token.Length < 2) continue;
                if (StopWords.Contains(token)) continue;
                tokens.Add(token);
            }

            return tokens;
        }

        private static double JaccardSimilarity(HashSet<string> a, HashSet<string> b)
        {
            if (a.Count == 0 && b.Count == 0) return 1.0;
            if (a.Count == 0 || b.Count == 0) return 0.0;

            var intersection = 0;
            var smaller = a.Count <= b.Count ? a : b;
            var larger = a.Count <= b.Count ? b : a;
            foreach (var token in smaller)
            {
                if (larger.Contains(token)) intersection++;
            }

            var union = a.Count + b.Count - intersection;
            return union == 0 ? 0 : (double)intersection / union;
        }

        private static string? NormalizeDiagnosis(string? diagnosis)
        {
            if (string.IsNullOrWhiteSpace(diagnosis)) return null;
            var trimmed = diagnosis.Trim();
            var parts = trimmed.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            return string.Join(' ', parts).ToLowerInvariant();
        }

        private static double NormalizeThreshold(double threshold)
        {
            if (threshold > 1.0) threshold /= 100.0;
            return Math.Clamp(threshold, 0, 1);
        }

        private static string? TryExtractThumbnail(string? attachmentsJson)
        {
            if (string.IsNullOrWhiteSpace(attachmentsJson)) return null;

            try
            {
                using var doc = JsonDocument.Parse(attachmentsJson);
                if (doc.RootElement.ValueKind != JsonValueKind.Array) return null;

                foreach (var element in doc.RootElement.EnumerateArray())
                {
                    if (element.ValueKind != JsonValueKind.Object) continue;
                    var thumb = TryGetStringProperty(element, "thumbnailUrl") ??
                                TryGetStringProperty(element, "filePath") ??
                                TryGetStringProperty(element, "url");
                    if (!string.IsNullOrWhiteSpace(thumb)) return thumb;
                }
            }
            catch
            {
                return null;
            }

            return null;
        }

        private static string? TryGetStringProperty(JsonElement element, string name)
        {
            foreach (var prop in element.EnumerateObject())
            {
                if (string.Equals(prop.Name, name, StringComparison.OrdinalIgnoreCase))
                {
                    if (prop.Value.ValueKind == JsonValueKind.String)
                    {
                        return prop.Value.GetString();
                    }
                }
            }

            return null;
        }
    }
}
