import { NextResponse } from "next/server";
// Avoid using filesystem APIs in Next app routes (Edge/runtime incompatibilities)

type ChatRole = "user" | "assistant";

type ChatMessage = {
  role: ChatRole;
  content: string;
};

const SYSTEM_PROMPT =
  "You are SmartOralDiagnosis assistant. Help users with oral-health information in clear language. Do not claim certainty for diagnosis and advise seeing a licensed dentist for urgent or severe symptoms.";

const GEMINI_API_ROOT = "https://generativelanguage.googleapis.com/v1";
const DEFAULT_MODEL = "gemini-2.0-flash";
const FALLBACK_MODELS = ["gemini-2.0-flash-lite", DEFAULT_MODEL];

function normalizeModelName(modelName: string) {
  return modelName.replace(/^models\//i, "").trim();
}

function isModelError(errorMessage: string) {
  return /model|does not exist|not found|is not a valid|not supported.*generatecontent/i.test(errorMessage);
}

async function listGenerateContentModels(geminiKey: string) {
  const listUrl = `${GEMINI_API_ROOT}/models?key=${encodeURIComponent(geminiKey)}`;
  const listRes = await fetch(listUrl, {
    headers: { "Content-Type": "application/json" },
  });

  if (!listRes.ok) {
    return [];
  }

  let listData: any = null;
  try {
    listData = await listRes.json();
  } catch {
    return [];
  }

  const allModels = Array.isArray(listData?.models) ? listData.models : [];
  return allModels
    .filter(
      (m: any) =>
        typeof m?.name === "string" &&
        Array.isArray(m?.supportedGenerationMethods) &&
        m.supportedGenerationMethods.includes("generateContent")
    )
    .map((m: any) => normalizeModelName(m.name))
    .filter((name: string) => name.length > 0);
}

// Read env directly from process.env. Avoid reading .env files at runtime
// because Next's app routes may run in restricted runtimes where `fs`
// is unavailable (causes compilation/runtime errors and HTML error pages).

export async function POST(req: Request) {
  try {
    const apiKey = process.env.GEMINI_API_KEY;
    const configuredModel = normalizeModelName(process.env.GEMINI_MODEL || DEFAULT_MODEL);

    if (!apiKey) {
      return NextResponse.json(
        { message: "Missing GEMINI_API_KEY on server (set it in frontend/.env.local or root .env)" },
        { status: 500 }
      );
    }

    const geminiKey = apiKey;

    let body: any;
    try {
      body = await req.json();
    } catch (ex: any) {
      console.error("/api/chatbot - failed to parse JSON body:", ex?.message || ex);
      return NextResponse.json({ message: "Invalid JSON body" }, { status: 400 });
    }

    const messages = Array.isArray(body?.messages) ? body.messages : [];

    const sanitizedMessages: ChatMessage[] = messages
      .filter((m: any) => m && typeof m.content === "string" && m.content.trim().length > 0)
      .map((m: any) => ({
        role: m.role === "assistant" ? "assistant" : "user",
        content: m.content.trim(),
      }));

    if (sanitizedMessages.length === 0) {
      return NextResponse.json(
        { message: "At least one message is required" },
        { status: 400 }
      );
    }

    const callGemini = async (modelName: string) => {
      const normalizedModelName = normalizeModelName(modelName);
      const url = `${GEMINI_API_ROOT}/models/${normalizedModelName}:generateContent?key=${encodeURIComponent(geminiKey)}`;
      const res = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              role: "user",
              parts: [{ text: SYSTEM_PROMPT }],
            },
            ...sanitizedMessages.map((m) => ({
              role: m.role === "assistant" ? "model" : "user",
              parts: [{ text: m.content }],
            })),
          ],
          generationConfig: {
            temperature: 0.4,
          },
        }),
      });

      let d: any = null;
      try {
        d = await res.json();
      } catch {
        d = null;
      }
      return { res, d, modelName: normalizedModelName };
    };

    const initialCandidates = [configuredModel, ...FALLBACK_MODELS].filter(
      (name, index, arr) => name.length > 0 && arr.indexOf(name) === index
    );

    let availableModels: string[] = [];
    let { res, d, modelName } = await callGemini(initialCandidates[0]);

    if (!res.ok) {
      const errMsg = d?.error?.message || d?.message || "";
      if (isModelError(errMsg)) {
        availableModels = await listGenerateContentModels(geminiKey);

        const retryCandidates = [...initialCandidates.slice(1), ...availableModels]
          .map(normalizeModelName)
          .filter(
            (name, index, arr) =>
              name.length > 0 && arr.indexOf(name) === index && name !== modelName
          );

        for (const candidate of retryCandidates) {
          console.warn(`/api/chatbot: model '${modelName}' failed, retrying with '${candidate}':`, errMsg);
          ({ res, d, modelName } = await callGemini(candidate));
          if (res.ok) {
            break;
          }

          const nextErrMsg = d?.error?.message || d?.message || "";
          if (!isModelError(nextErrMsg)) {
            break;
          }
        }
      }
    }

    if (!res.ok) {
      const errorMessage = d?.error?.message || d?.message || "Gemini request failed";

      if (isModelError(errorMessage) && availableModels.length > 0) {
        const suggestedModels = availableModels.slice(0, 5).join(", ");
        return NextResponse.json(
          { message: `${errorMessage} Try one of: ${suggestedModels}` },
          { status: res.status }
        );
      }

      return NextResponse.json({ message: errorMessage }, { status: res.status });
    }

    const reply = d?.candidates?.[0]?.content?.parts?.find((p: any) => typeof p?.text === "string")?.text;
    if (typeof reply !== "string" || reply.trim().length === 0) {
      return NextResponse.json({ message: "Gemini returned an empty response" }, { status: 502 });
    }

    return NextResponse.json({ reply: reply.trim() });
  } catch (error: any) {
    console.error("/api/chatbot unexpected error:", error);
    return NextResponse.json(
      { message: error?.message || "Unexpected server error" },
      { status: 500 }
    );
  }
}
