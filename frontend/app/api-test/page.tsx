"use client";

import { useState } from "react";
import { getTest, postData } from "../../services/apiClient";

type ApiResult = {
  message?: string;
  data?: unknown;
};

export default function ApiTestPage() {
  const [result, setResult] = useState<ApiResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const callGet = async () => {
    setLoading(true);
    setError("");
    try {
      const response = await getTest();
      setResult(response);
    } catch (err: any) {
      setError(err?.message || "Failed to call GET /api/test");
      setResult(null);
    } finally {
      setLoading(false);
    }
  };

  const callPost = async () => {
    setLoading(true);
    setError("");
    try {
      const response = await postData({ source: "api-test-page", sentAt: new Date().toISOString() });
      setResult(response);
    } catch (err: any) {
      setError(err?.message || "Failed to call POST /api/test");
      setResult(null);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="mx-auto max-w-2xl p-6">
      <h1 className="mb-4 text-2xl font-semibold">API Connection Test</h1>

      <div className="mb-4 flex gap-3">
        <button
          type="button"
          onClick={callGet}
          disabled={loading}
          className="rounded bg-blue-600 px-4 py-2 text-white disabled:opacity-50"
        >
          {loading ? "Loading..." : "Call GET /api/test"}
        </button>

        <button
          type="button"
          onClick={callPost}
          disabled={loading}
          className="rounded bg-emerald-600 px-4 py-2 text-white disabled:opacity-50"
        >
          {loading ? "Loading..." : "Call POST /api/test"}
        </button>
      </div>

      {error && <p className="mb-3 rounded bg-red-100 p-3 text-red-700">{error}</p>}

      {result && (
        <pre className="overflow-x-auto rounded bg-slate-100 p-4 text-sm">
          {JSON.stringify(result, null, 2)}
        </pre>
      )}
    </main>
  );
}
