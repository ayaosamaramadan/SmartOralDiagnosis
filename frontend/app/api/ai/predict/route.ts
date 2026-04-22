import { NextResponse } from "next/server";

const DEFAULT_AI_PREDICT_URL = "https://web-production-4e3e5.up.railway.app/predict";

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
    ...parsePredictUrlList(process.env.NEXT_PUBLIC_AI_URL),
    DEFAULT_AI_PREDICT_URL,
  ])
);

const shouldRetryUpstream = (status: number) => status === 429 || status >= 500;

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

    if (lastFailure) {
      const normalizedError = normalizeUpstreamError(lastFailure.responseText, lastFailure.contentType);
      return NextResponse.json(
        {
          ...normalizedError,
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