import { NextResponse } from "next/server";

const DEFAULT_AI_PREDICT_URL = "https://web-production-4e3e5.up.railway.app/predict";
const GEMINI_API_ROOT = "https://generativelanguage.googleapis.com/v1";
const DEFAULT_GEMINI_MODEL = "gemini-2.0-flash";
const FALLBACK_GEMINI_MODELS = ["gemini-2.0-flash-lite", DEFAULT_GEMINI_MODEL];
const DIAGNOSIS_LABELS = {
  CaS: "CaS",
  CoS: "Commissural Stomatitis",
  Gum: "Gingival Condition",
  MC: "Mucocele",
  OC: "Oral Cancer",
  OLP: "Oral Lichen Planus",
  OT: "Other",
} as const;

type DiagnosisCode = keyof typeof DIAGNOSIS_LABELS;

const normalizePredictUrl = (value: string) => {
  const trimmed = value.trim().replace(/\/+$/, "");
  if (!trimmed) {
    return DEFAULT_AI_PREDICT_URL;
  }

  if (/\/predict$/i.test(trimmed) || /\/api\/ai\/predict$/i.test(trimmed)) {
    return trimmed;
  }

  return `${trimmed}/predict`;
};

const parsePredictUrlList = (value?: string) => {
  if (!value || typeof value !== "string") return [];

  return value
    .split(",")
    .map((item) => item.trim())
    .filter((item) => item.length > 0)
    .map(normalizePredictUrl);
};

const AI_PREDICT_URLS = Array.from(
  new Set([
    ...parsePredictUrlList(process.env.AI_PREDICT_URL),
    ...parsePredictUrlList(process.env.AI_URL),
    ...parsePredictUrlList(process.env.NEXT_PUBLIC_AI_URL),
    DEFAULT_AI_PREDICT_URL,
  ])
);

const shouldRetryUpstream = (status: number) => status === 429 || status >= 500;

const normalizeGeminiModelName = (value?: string | null) =>
  String(value || DEFAULT_GEMINI_MODEL).replace(/^models\//i, "").trim();

const isGeminiModelError = (message: string) =>
  /model|does not exist|not found|not supported.*generatecontent|invalid argument/i.test(message);

const clampConfidence = (value: unknown) => {
  const numeric = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(numeric)) return null;

  if (numeric >= 0 && numeric <= 1) {
    return Math.round(numeric * 100);
  }

  return Math.round(Math.min(Math.max(numeric, 0), 100));
};

const extractJsonObject = (value: string) => {
  const trimmed = value.trim();
  if (!trimmed) return null;

  const fencedMatch = trimmed.match(/```(?:json)?\s*([\s\S]*?)\s*```/i);
  if (fencedMatch?.[1]) {
    return fencedMatch[1].trim();
  }

  const start = trimmed.indexOf("{");
  const end = trimmed.lastIndexOf("}");
  if (start >= 0 && end > start) {
    return trimmed.slice(start, end + 1);
  }

  return trimmed;
};

const normalizeDiagnosisCode = (value: unknown): DiagnosisCode | null => {
  if (typeof value !== "string") return null;

  const normalized = value.trim();
  if (!normalized) return null;

  const compact = normalized.replace(/[\s_-]+/g, "").toUpperCase();
  const directMap: Record<string, DiagnosisCode> = {
    CAS: "CaS",
    CANKERSORES: "CaS",
    APHTHOUSULCER: "CaS",
    APHTHOUSULCERS: "CaS",
    COS: "CoS",
    COMMISSURALSTOMATITIS: "CoS",
    GUM: "Gum",
    GINGIVALCONDITION: "Gum",
    GINGIVITIS: "Gum",
    MC: "MC",
    MUCOCELE: "MC",
    OC: "OC",
    ORALCANCER: "OC",
    OLP: "OLP",
    ORALLICHENPLANUS: "OLP",
    OT: "OT",
    OTHER: "OT",
  };

  return directMap[compact] ?? null;
};

const extractDetailMessage = (detail: any): string | null => {
  if (typeof detail === "string" && detail.trim().length > 0) {
    return detail.trim();
  }

  if (Array.isArray(detail)) {
    for (const entry of detail) {
      const extracted = extractDetailMessage(entry);
      if (extracted) return extracted;
    }
    return null;
  }

  if (detail && typeof detail === "object") {
    if (typeof detail.message === "string" && detail.message.trim().length > 0) {
      return detail.message.trim();
    }
    if (typeof detail.msg === "string" && detail.msg.trim().length > 0) {
      return detail.msg.trim();
    }
  }

  return null;
};

const normalizeUpstreamError = (responseText: string, contentType: string) => {
  const fallback = responseText?.trim() || "AI service returned an error.";
  if (!contentType.includes("application/json")) {
    return { message: fallback };
  }

  try {
    const parsed = JSON.parse(responseText);
    if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) {
      return { message: fallback };
    }

    const detail = extractDetailMessage((parsed as any).detail);
    const message =
      (typeof (parsed as any).message === "string" && (parsed as any).message.trim()) ||
      (typeof (parsed as any).error === "string" && (parsed as any).error.trim()) ||
      (typeof (parsed as any).title === "string" && (parsed as any).title.trim()) ||
      detail ||
      fallback;

    return {
      ...(parsed as Record<string, unknown>),
      message,
      ...(detail && detail !== message ? { detail } : {}),
    };
  } catch {
    return { message: fallback };
  }
};

const normalizeAiResponse = (payload: any) => {
  if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
    return payload;
  }

  const diseaseCategory =
    typeof payload.disease_category === "string" && payload.disease_category.trim().length > 0
      ? payload.disease_category.trim()
      : typeof payload.diagnosis === "string" && payload.diagnosis.trim().length > 0
        ? payload.diagnosis.trim()
        : typeof payload.label === "string" && payload.label.trim().length > 0
          ? payload.label.trim()
          : typeof payload.result === "string" && payload.result.trim().length > 0
            ? payload.result.trim()
            : null;

  const confidence =
    typeof payload.confidence === "number"
      ? payload.confidence
      : typeof payload.probability === "number"
        ? payload.probability
        : null;

  return {
    ...payload,
    disease_category: diseaseCategory,
    diagnosis: typeof payload.diagnosis === "string" && payload.diagnosis.trim().length > 0
      ? payload.diagnosis.trim()
      : diseaseCategory,
    confidence,
  };
};

const listGenerateContentModels = async (geminiKey: string) => {
  const listUrl = `${GEMINI_API_ROOT}/models?key=${encodeURIComponent(geminiKey)}`;
  const response = await fetch(listUrl, {
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) {
    return [];
  }

  let data: any = null;
  try {
    data = await response.json();
  } catch {
    return [];
  }

  const models = Array.isArray(data?.models) ? data.models : [];
  return models
    .filter(
      (entry: any) =>
        typeof entry?.name === "string" &&
        Array.isArray(entry?.supportedGenerationMethods) &&
        entry.supportedGenerationMethods.includes("generateContent")
    )
    .map((entry: any) => normalizeGeminiModelName(entry.name))
    .filter((name: string) => name.length > 0);
};

const callGeminiDiagnosis = async (file: File, modelName: string, geminiKey: string) => {
  const imageBase64 = Buffer.from(await file.arrayBuffer()).toString("base64");
  const normalizedModelName = normalizeGeminiModelName(modelName);
  const url = `${GEMINI_API_ROOT}/models/${normalizedModelName}:generateContent?key=${encodeURIComponent(geminiKey)}`;
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      contents: [
        {
          role: "user",
          parts: [
            {
              text:
                "Classify this oral lesion image for SmartOralDiagnosis. Choose exactly one code from: CaS, CoS, Gum, MC, OC, OLP, OT. " +
                "Return only a JSON object with keys code, diagnosis, confidence, and reason. " +
                "Use OT if the image is unclear or does not match the known classes.",
            },
            {
              inlineData: {
                mimeType: file.type || "image/jpeg",
                data: imageBase64,
              },
            },
          ],
        },
      ],
      generationConfig: {
        temperature: 0.1,
      },
    }),
  });

  let data: any = null;
  try {
    data = await response.json();
  } catch {
    data = null;
  }

  return { response, data, modelName: normalizedModelName };
};

const parseGeminiDiagnosis = (payload: any) => {
  const parts = Array.isArray(payload?.candidates?.[0]?.content?.parts)
    ? payload.candidates[0].content.parts
    : [];
  const text = parts
    .map((part: any) => (typeof part?.text === "string" ? part.text : ""))
    .join("\n")
    .trim();

  if (!text) {
    return null;
  }

  const jsonText = extractJsonObject(text);
  let parsed: Record<string, unknown> | null = null;
  if (jsonText) {
    try {
      parsed = JSON.parse(jsonText);
    } catch {
      parsed = null;
    }
  }

  const code =
    normalizeDiagnosisCode(parsed?.code) ||
    normalizeDiagnosisCode(parsed?.diagnosisCode) ||
    normalizeDiagnosisCode(parsed?.label) ||
    normalizeDiagnosisCode(parsed?.diagnosis) ||
    normalizeDiagnosisCode(text);

  if (!code) {
    return null;
  }

  const diagnosis = DIAGNOSIS_LABELS[code];
  return normalizeAiResponse({
    source: "gemini-fallback",
    disease_category: diagnosis,
    diagnosis,
    diagnosisCode: code,
    label: code,
    code,
    confidence: clampConfidence(parsed?.confidence),
    reason: typeof parsed?.reason === "string" ? parsed.reason.trim() : undefined,
  });
};

const classifyWithGeminiFallback = async (file: File) => {
  const geminiKey = process.env.GEMINI_API_KEY?.trim();
  if (!geminiKey) {
    return null;
  }

  const configuredModel = normalizeGeminiModelName(process.env.GEMINI_MODEL);
  const initialCandidates = [configuredModel, ...FALLBACK_GEMINI_MODELS].filter(
    (name, index, arr) => name.length > 0 && arr.indexOf(name) === index
  );

  let availableModels: string[] = [];
  let { response, data, modelName } = await callGeminiDiagnosis(file, initialCandidates[0], geminiKey);

  if (!response.ok) {
    const errorMessage = data?.error?.message || data?.message || "";
    if (isGeminiModelError(errorMessage)) {
      availableModels = await listGenerateContentModels(geminiKey);
      const retryCandidates = [...initialCandidates.slice(1), ...availableModels].filter(
        (name, index, arr) => name.length > 0 && arr.indexOf(name) === index && name !== modelName
      );

      for (const candidate of retryCandidates) {
        ({ response, data, modelName } = await callGeminiDiagnosis(file, candidate, geminiKey));
        if (response.ok) {
          break;
        }

        const retryError = data?.error?.message || data?.message || "";
        if (!isGeminiModelError(retryError)) {
          break;
        }
      }
    }
  }

  if (!response.ok) {
    const errorMessage = data?.error?.message || data?.message || "Gemini image fallback failed.";
    throw new Error(errorMessage);
  }

  const diagnosis = parseGeminiDiagnosis(data);
  if (!diagnosis) {
    throw new Error("Gemini fallback returned an unrecognized diagnosis.");
  }

  return {
    ...diagnosis,
    sourceModel: modelName,
  };
};

export const runtime = "nodejs";

export async function POST(req: Request) {
  try {
    const formData = await req.formData();
    const file = formData.get("file") ?? formData.get("image");

    if (!(file instanceof File)) {
      return NextResponse.json(
        { message: "Image file is required in form field 'file' or 'image'." },
        { status: 400 }
      );
    }

    let lastFailure:
      | {
          status: number;
          contentType: string;
          responseText: string;
          upstreamUrl: string;
        }
      | null = null;

    for (let index = 0; index < AI_PREDICT_URLS.length; index += 1) {
      const upstreamUrl = AI_PREDICT_URLS[index];
      const isLastUrl = index === AI_PREDICT_URLS.length - 1;

      const upstreamForm = new FormData();
      upstreamForm.append("file", file, file.name || "upload.jpg");
      upstreamForm.append("image", file, file.name || "upload.jpg");

      const upstreamResponse = await fetch(upstreamUrl, {
        method: "POST",
        body: upstreamForm,
      });

      const responseText = await upstreamResponse.text();
      const contentType = upstreamResponse.headers.get("content-type") || "application/json";

      if (upstreamResponse.ok && contentType.includes("application/json")) {
        try {
          const payload = JSON.parse(responseText);
          return NextResponse.json(normalizeAiResponse(payload), { status: upstreamResponse.status });
        } catch {
          return new Response(responseText, {
            status: upstreamResponse.status,
            headers: {
              "content-type": contentType,
            },
          });
        }
      }

      if (upstreamResponse.ok) {
        return new Response(responseText, {
          status: upstreamResponse.status,
          headers: {
            "content-type": contentType,
          },
        });
      }

      lastFailure = {
        status: upstreamResponse.status,
        contentType,
        responseText,
        upstreamUrl,
      };

      if (!shouldRetryUpstream(upstreamResponse.status) || isLastUrl) {
        break;
      }
    }

    try {
      const geminiFallback = await classifyWithGeminiFallback(file);
      if (geminiFallback) {
        return NextResponse.json(geminiFallback, { status: 200 });
      }
    } catch (fallbackError: any) {
      if (lastFailure) {
        const normalizedError = normalizeUpstreamError(lastFailure.responseText, lastFailure.contentType);
        const rawMessage =
          typeof normalizedError.message === "string" && normalizedError.message.trim().length > 0
            ? normalizedError.message.trim()
            : "AI service returned an error.";
        const message =
          /internal server error/i.test(rawMessage)
            ? `AI service is currently unavailable (${lastFailure.upstreamUrl}).`
            : rawMessage;

        return NextResponse.json(
          {
            ...normalizedError,
            message,
            upstreamStatus: lastFailure.status,
            upstreamUrl: lastFailure.upstreamUrl,
            fallbackError: fallbackError?.message || "Gemini fallback failed.",
          },
          { status: lastFailure.status }
        );
      }

      return NextResponse.json(
        { message: fallbackError?.message || "Gemini fallback failed." },
        { status: 500 }
      );
    }

    if (lastFailure) {
      const normalizedError = normalizeUpstreamError(lastFailure.responseText, lastFailure.contentType);
      const rawMessage =
        typeof normalizedError.message === "string" && normalizedError.message.trim().length > 0
          ? normalizedError.message.trim()
          : "AI service returned an error.";
      const message =
        /internal server error/i.test(rawMessage)
          ? `AI service is currently unavailable (${lastFailure.upstreamUrl}).`
          : rawMessage;

      return NextResponse.json(
        {
          ...normalizedError,
          message,
          upstreamStatus: lastFailure.status,
          upstreamUrl: lastFailure.upstreamUrl,
        },
        { status: lastFailure.status }
      );
    }

    return NextResponse.json(
      { message: "No AI upstream URL is configured." },
      { status: 500 }
    );
  } catch (error: any) {
    return NextResponse.json(
      { message: error?.message || "Unexpected AI proxy error" },
      { status: 500 }
    );
  }
}
