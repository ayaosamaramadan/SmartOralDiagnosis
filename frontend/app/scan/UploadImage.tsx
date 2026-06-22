"use client";

import { useRef, useCallback, useState } from "react";
import { Upload } from "lucide-react";
import toast from "react-hot-toast";
import { aiService } from "../../services/api";
import { Oralsdata, diagnosisRecommendations, defaultRecommendations } from "data/Data";

interface UploadImageProps {
  onImageCapture: (imageData: string) => void;
  onAnalysisResult?: (result: any | null, error?: Error) => void;
}

export default function UploadImage({ onImageCapture, onAnalysisResult }: UploadImageProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const openFileDialog = useCallback(() => {
    fileInputRef.current?.click();
  }, []);

  const [diseaseName, setDiseaseName] = useState<string | null>(null);
  const [confidence, setConfidence] = useState<number | null>(null);
  const [loading, setLoading] = useState(false);
  const [errorText, setErrorText] = useState<string | null>(null);
  const [lastFile, setLastFile] = useState<File | null>(null);

  const handleFile = useCallback(async (file: File) => {
    if (!file || !file.type.startsWith("image/")) return;
    setLoading(true);
    setErrorText(null);
    setLastFile(file);

    // show immediately in UI
    const reader = new FileReader();
    reader.onload = (e) => {
      onImageCapture(e.target?.result as string);
    };
    reader.readAsDataURL(file);
    

    // send to backend AI
    try {
      const resp = await aiService.predictFromFile(file);
      // prefer explicit prediction field if present
      const name = resp.prediction ?? resp.disease_category ?? resp.diseaseCategory ?? resp.diagnosis ?? resp.label ?? resp.result ?? null;
      if (name) {
        setDiseaseName(String(name));
      } else {
        setDiseaseName(null);
      }

      // normalize confidence (0-1) or percent (0-100) to percent
      const rawConfidence = typeof resp?.confidence === 'number' ? resp.confidence : typeof resp?.probability === 'number' ? resp.probability : null;
      if (typeof rawConfidence === 'number') {
        const normalized = rawConfidence <= 1 ? Math.round(rawConfidence * 100) : Math.round(rawConfidence);
        setConfidence(Math.min(100, Math.max(0, normalized)));
      } else {
        setConfidence(null);
      }
      onAnalysisResult?.(resp ?? null, undefined);
    } catch (err: any) {
      console.error("Upload AI error:", err);
      setDiseaseName(null);
      setConfidence(null);
      const errMsg = err?.message ? String(err.message) : String(err ?? "Unknown error");
      setErrorText(errMsg);
      toast.error(errMsg.length > 180 ? `${errMsg.slice(0, 177)}...` : errMsg);
      const normalizedErr = err instanceof Error ? err : new Error(String(errMsg));
      onAnalysisResult?.(null, normalizedErr);
    } finally {
      setLoading(false);
    }
  }, [onImageCapture, onAnalysisResult]);

  const handleFileUpload = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) handleFile(file);
  }, [handleFile]);

  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
  }, []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    const files = e.dataTransfer.files;
    if (files[0]) handleFile(files[0]);
  }, [handleFile]);

  const normalizeKey = (value?: string) =>
    (value ?? "")
      .toString()
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]/g, "");

  const findDiseaseByCode = (code?: string) => {
    if (!code) return undefined;
    const normalized = code.trim().toLowerCase();
    return Oralsdata.find((d) => d.shortTitle.toLowerCase() === normalized);
  };

  const findDiseaseByName = (name?: string) => {
    if (!name) return undefined;
    const normalized = normalizeKey(name);
    return Oralsdata.find((d) => normalizeKey(d.title) === normalized);
  };

  const resolveRecommendationsForName = (name?: string) => {
    if (!name) return defaultRecommendations;
    const match = findDiseaseByCode(name) ?? findDiseaseByName(name);
    const resolvedCode = match
      ? match.shortTitle.toUpperCase()
      : typeof name === "string" && /^[a-z]{2,3}$/i.test(name.trim())
      ? name.trim().toUpperCase()
      : undefined;
    const codeSpecific = resolvedCode ? diagnosisRecommendations[resolvedCode] ?? [] : [];
    return codeSpecific.length ? codeSpecific : defaultRecommendations;
  };

  return (
    <div 
      className="bg-gray-50 dark:bg-gray-900 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 p-8 text-center hover:border-blue-400 transition-colors cursor-pointer"
      onDragOver={handleDragOver}
      onDrop={handleDrop}
      onClick={openFileDialog}
    >
      <Upload className="mx-auto h-12 w-12 text-gray-500 dark:text-gray-400 mb-4" />
      <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">Upload Image</h3>
      <p className="text-gray-600 dark:text-gray-400 mb-4">Drag and drop or click to select</p>
      <input
        title="Upload Image"
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileUpload}
        className="hidden"
      />
      <button
        className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-60"
        onClick={(e) => {
          e.stopPropagation();
          openFileDialog();
        }}
        disabled={loading}
      > 
        {loading ? "Analyzing..." : "Choose File"}
      </button>

      {(diseaseName || confidence !== null) && (
        <div className="mt-4">
          {diseaseName && (
            <>
              <p className="text-sm text-gray-700 dark:text-gray-300">Prediction:</p>
              <p className="font-semibold text-lg text-black dark:text-white">{diseaseName}</p>
            </>
          )}
          {confidence !== null && (
            <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">{confidence}% confidence</p>
          )}
          <div className="mt-3">
            <div className="bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-700 rounded-lg p-3">
              <p className="text-sm font-semibold text-blue-600 dark:text-blue-300">Recommendations</p>
              <ul className="mt-2 space-y-1 list-disc list-inside text-gray-700 dark:text-gray-300">
                {resolveRecommendationsForName(diseaseName ?? undefined).map((rec) => (
                  <li key={`upload-rec-${rec}`}>{rec}</li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      )}
      {errorText && (
        <div className="mt-2 text-sm text-red-600 dark:text-red-400">
          <p>Error: {errorText}</p>
          {lastFile && (
            <div className="mt-2">
              <button
                onClick={() => handleFile(lastFile)}
                className="px-4 py-1 bg-yellow-500 text-white rounded"
              >
                Retry
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}