const rawBaseUrl = (process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000").replace(/\/+$/, "");
const API_BASE_URL = rawBaseUrl.endsWith("/api") ? rawBaseUrl : `${rawBaseUrl}/api`;

type RequestMethod = "GET" | "POST";

async function request<T>(path: string, method: RequestMethod, body?: unknown): Promise<T> {
  const url = `${API_BASE_URL}${path.startsWith("/") ? path : `/${path}`}`;

  const response = await fetch(url, {
    method,
    headers: {
      "Content-Type": "application/json",
    },
    credentials: "include",
    ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
  });

  const text = await response.text();
  let parsed: any = null;

  if (text) {
    try {
      parsed = JSON.parse(text);
    } catch {
      parsed = text;
    }
  }

  if (!response.ok) {
    const errorMessage =
      (parsed && typeof parsed === "object" && (parsed.message || parsed.error)) ||
      response.statusText ||
      "Request failed";
    throw new Error(String(errorMessage));
  }

  return parsed as T;
}

export function getRequest<T>(path: string): Promise<T> {
  return request<T>(path, "GET");
}

export function postRequest<T>(path: string, data: unknown): Promise<T> {
  return request<T>(path, "POST", data);
}

export function getTest(): Promise<{ message: string }> {
  return getRequest<{ message: string }>("/test");
}

export function postData(data: unknown): Promise<{ message: string; data: unknown }> {
  return postRequest<{ message: string; data: unknown }>("/test", data);
}

export { API_BASE_URL };
