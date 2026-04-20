"use client";

import { useRef, useCallback, useState } from "react";
import { Upload } from "lucide-react";
import toast from "react-hot-toast";
import { aiService } from "../../services/api";

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
      // resp may contain diagnosis or label
      const name = resp.disease_category ?? resp.diseaseCategory ?? resp.diagnosis ?? resp.label ?? resp.result ?? null;
      if (name) {
        setDiseaseName(String(name));
      } else {
        setDiseaseName(null);
      }
      onAnalysisResult?.(resp ?? null, undefined);
    } catch (err: any) {
      console.error("Upload AI error:", err);
      setDiseaseName(null);
      const errMsg = err?.message ? String(err.message) : String(err ?? "Unknown error");
      setErrorText(errMsg);
      toast.error("Could not analyze uploaded image.");
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

      {diseaseName && (
        <div className="mt-4">
          <p className="text-sm text-gray-700 dark:text-gray-300">Predicted disease:</p>
          <p className="font-semibold text-lg text-black dark:text-white">{diseaseName}</p>
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