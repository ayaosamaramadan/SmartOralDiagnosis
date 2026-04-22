import { NextResponse } from "next/server";

const DEFAULT_BACKEND_PREDICT_URL = "https://oralbackend-production.up.railway.app/api/ai/predict";
const DEFAULT_DIRECT_AI_PREDICT_URL = "https://web-production-4e3e5.up.railway.app/predict";
const LOCAL_BACKEND_PREDICT_URL = "http://localhost:4000/api/ai/predict";
const LOCAL_DIRECT_AI_PREDICT_URL = "http://localhost:8000/predict";

type UpstreamAttempt = {
  upstreamUrl: string;
  status: number;
  message: string;
};

const isLoopbackUrl = (value: string) =>
  /^https?:\/\/(?:localhost|127(?:\.\d{1,3}){3}|0\.0\.0\.0)(?::\d+)?(?:\/|$)/i.test(value);

const allowLoopback =
  process.env.NODE_ENV === "development" ||
  String(process.env.ALLOW_LOOPBACK_AI || "").toLowerCase() === "true";

const normalizeAbsoluteUrl = (value: string) => {
  const trimmed = value.trim().replace(/\/+$/, "");

  if (!trimmed) return "";
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  if (trimmed.startsWith("//")) return `https:${trimmed}`;
  if (trimmed.startsWith("/")) return trimmed;

  const isLocalHost =
    /^localhost(?::\d+)?(?:\/|$)/i.test(trimmed) ||
    /^127(?:\.\d{1,3}){3}(?::\d+)?(?:\/|$)/.test(trimmed) ||
    /^0\.0\.0\.0(?::\d+)?(?:\/|$)/.test(trimmed);

  return `${isLocalHost ? "http" : "https"}://${trimmed}`;
};

const normalizeBackendPredictUrl = (value: string) => {
  const normalized = normalizeAbsoluteUrl(value);
  if (!normalized) {
    return DEFAULT_BACKEND_PREDICT_URL;
  }

  if (/\/api\/ai\/predict$/i.test(normalized)) {
    return normalized;
  }

  if (/\/api$/i.test(normalized)) {
    return `${normalized}/ai/predict`;
  }

  return `${normalized}/api/ai/predict`;
};

const normalizeDirectPredictUrl = (value: string) => {
  const normalized = normalizeAbsoluteUrl(value);
  if (!normalized) {
    return DEFAULT_DIRECT_AI_PREDICT_URL;
  }

  if (/\/predict$/i.test(normalized) || /\/api\/ai\/predict$/i.test(normalized)) {
    return normalized;
  }

  return `${normalized}/predict`;
};

const parseUrlList = (value: string | undefined, normalizer: (value: string) => string) => {
  if (!value || typeof value !== "string") return [];

  return value
    .split(",")
    .map((item) => item.trim())
    .filter((item) => item.length > 0)
    .map(normalizer);
};

const BACKEND_PREDICT_URLS = Array.from(
  new Set([
    ...(process.env.NODE_ENV !== "production" ? [LOCAL_BACKEND_PREDICT_URL] : []),
    ...parseUrlList(process.env.AI_PROXY_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.BACKEND_PREDICT_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.API_PREDICT_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.API_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.BACKEND_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.NEXT_PUBLIC_BACKEND_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.NEXT_BACKEND_SERVER, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.NEXT_PUBLIC_API_URL, normalizeBackendPredictUrl),
    ...parseUrlList(process.env.NEXT_PUBLIC_BACK_URL, normalizeBackendPredictUrl),
    DEFAULT_BACKEND_PREDICT_URL,
  ])
).filter((url) => allowLoopback || !isLoopbackUrl(url));

const DIRECT_AI_PREDICT_URLS = Array.from(
  new Set([
    ...(process.env.NODE_ENV !== "production" ? [LOCAL_DIRECT_AI_PREDICT_URL] : []),
    ...parseUrlList(process.env.AI_PREDICT_URL, normalizeDirectPredictUrl),
    ...parseUrlList(process.env.AI_URL, normalizeDirectPredictUrl),
    ...parseUrlList(process.env.AI_SERVICE_BASEURL, normalizeDirectPredictUrl),
    ...parseUrlList(process.env.AI_SERVICE_BASE_URL, normalizeDirectPredictUrl),
    ...parseUrlList(process.env.NEXT_PUBLIC_AI_URL, normalizeDirectPredictUrl),
    DEFAULT_DIRECT_AI_PREDICT_URL,
  ])
).filter((url) => allowLoopback || !isLoopbackUrl(url));

const AI_PREDICT_URLS = Array.from(new Set([...BACKEND_PREDICT_URLS, ...DIRECT_AI_PREDICT_URLS]));

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
    diagnosis:
      typeof payload.diagnosis === "string" && payload.diagnosis.trim().length > 0
        ? payload.diagnosis.trim()
        : diseaseCategory,
    confidence,
  };
};

const summarizeAttempts = (attempts: UpstreamAttempt[]) =>
  attempts.map((attempt) => ({
    upstreamUrl: attempt.upstreamUrl,
    status: attempt.status,
    message: attempt.message,
  }));

const buildFailureResponse = (attempts: UpstreamAttempt[]) => {
  const lastAttempt = attempts[attempts.length - 1];
  const backendFailure = attempts.find((attempt) => /\/api\/ai\/predict$/i.test(attempt.upstreamUrl));
  const directAiFailure = attempts.find(
    (attempt) =>
      /web-production-4e3e5\.up\.railway\.app/i.test(attempt.upstreamUrl) ||
      (/\/predict$/i.test(attempt.upstreamUrl) && !/\/api\/ai\/predict$/i.test(attempt.upstreamUrl))
  );

  let message = lastAttempt?.message || "AI service is currently unavailable.";
  if (
    backendFailure &&
    /localhost|127\.0\.0\.1|0\.0\.0\.0|connection refused/i.test(backendFailure.message) &&
    directAiFailure &&
    /internal server error/i.test(directAiFailure.message)
  ) {
    message =
      "The backend AI proxy is pointing to an invalid local AI service, and the Railway AI service is also failing.";
  } else if (backendFailure && directAiFailure) {
    message = "Both the backend AI proxy and the Railway AI service are unavailable right now.";
  } else if (directAiFailure && /internal server error/i.test(directAiFailure.message)) {
    message = "The Railway AI service is currently unavailable.";
  }

  return NextResponse.json(
    {
      message,
      attempts: summarizeAttempts(attempts),
      upstreamStatus: lastAttempt?.status || 503,
      upstreamUrl: lastAttempt?.upstreamUrl || null,
    },
    { status: 503 }
  );
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

    const attempts: UpstreamAttempt[] = [];

    for (const upstreamUrl of AI_PREDICT_URLS) {
      const upstreamForm = new FormData();
      upstreamForm.append("file", file, file.name || "upload.jpg");
      upstreamForm.append("image", file, file.name || "upload.jpg");

      try {
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

        const normalizedError = normalizeUpstreamError(responseText, contentType);
        attempts.push({
          upstreamUrl,
          status: upstreamResponse.status,
          message:
            typeof normalizedError.message === "string" && normalizedError.message.trim().length > 0
              ? normalizedError.message.trim()
              : responseText.trim() || `Request failed with status ${upstreamResponse.status}`,
        });
      } catch (error: any) {
        attempts.push({
          upstreamUrl,
          status: 502,
          message: error?.message || "Could not reach AI upstream.",
        });
      }
    }

    if (attempts.length > 0) {
      return buildFailureResponse(attempts);
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
