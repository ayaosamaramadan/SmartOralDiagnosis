import { NextResponse } from "next/server";

const normalizePredictUrl = (value: string) => {
  const trimmed = value.trim().replace(/\/+$/, "");
  if (!trimmed) {
    return "https://web-production-4e3e5.up.railway.app/predict";
  }

  return trimmed.endsWith("/predict") ? trimmed : `${trimmed}/predict`;
};

const AI_PREDICT_URL = normalizePredictUrl(
  process.env.NEXT_PUBLIC_AI_URL ?? process.env.AI_SERVICE_URL ?? ""
);

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

    const upstreamForm = new FormData();
    upstreamForm.append("file", file, file.name || "upload.jpg");

    const upstreamResponse = await fetch(AI_PREDICT_URL, {
      method: "POST",
      body: upstreamForm,
    });

    const responseText = await upstreamResponse.text();
    const contentType = upstreamResponse.headers.get("content-type") || "application/json";

    if (!upstreamResponse.ok || !contentType.includes("application/json")) {
      return new Response(responseText, {
        status: upstreamResponse.status,
        headers: {
          "content-type": contentType,
        },
      });
    }

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
  } catch (error: any) {
    return NextResponse.json(
      { message: error?.message || "Unexpected AI proxy error" },
      { status: 500 }
    );
  }
}