"use client";
import { useState, useCallback, useEffect } from "react";
import toast from "react-hot-toast";
import Image from "next/image";
import { CheckCircle, AlertCircle, RotateCcw } from "lucide-react";
import UploadImage from "./UploadImage";
import CameraCapture from "./CameraCapture";
import { aiService } from "../services/api";

interface AnalysisResult {
    confidence: number;
    diagnosis: string;
    severity: "low" | "medium" | "high";
    recommendations: string[];
    areas: Array<{
        x: number;
        y: number;
        width: number;
        height: number;
        type: string;
    }>;
}

export default function ScanComponent() {
    const [capturedImage, setCapturedImage] = useState<string | null>(null);
    const [isAnalyzing, setIsAnalyzing] = useState(false);
    const [analysisResult, setAnalysisResult] = useState<AnalysisResult | null>(null);
    const [shouldAutoAnalyze, setShouldAutoAnalyze] = useState(false);

    const parseAnalysisResponse = useCallback((resp: any): AnalysisResult => {
        const coerceSeverity = (value: any): AnalysisResult["severity"] => {
            if (typeof value !== "string") return "low";
            const normalized = value.toLowerCase();
            if (normalized === "medium" || normalized === "high") return normalized as AnalysisResult["severity"];
            return "low";
        };

        // AI service may return confidence either as fraction (0.0-1.0) or percent (0-100).
        const rawConfidence = typeof resp?.confidence === "number"
            ? resp.confidence
            : typeof resp?.probability === "number"
            ? resp.probability
            : 0;

        // Normalize to percent (0-100) — if value looks like fraction, scale it.
        const confidence = rawConfidence <= 1 ? Math.round(rawConfidence * 100) : Math.round(rawConfidence);

        return {
            confidence,
            diagnosis: resp?.diagnosis ?? resp?.label ?? JSON.stringify(resp ?? {}),
            severity: coerceSeverity(resp?.severity ?? resp?.risk),
            recommendations: Array.isArray(resp?.recommendations)
                ? resp.recommendations
                : Array.isArray(resp?.suggestions)
                ? resp.suggestions
                : [],
            areas: Array.isArray(resp?.areas)
                ? resp.areas
                : Array.isArray(resp?.bboxes)
                ? resp.bboxes
                : []
        };
    }, []);

    const analyzeImage = useCallback(async () => {
        if (!capturedImage) return;
        setIsAnalyzing(true);
        setAnalysisResult(null);

        try {
            const resp = await aiService.predictFromDataUrl(capturedImage);
            const parsed = parseAnalysisResponse(resp);
            setAnalysisResult(parsed);
            toast.success("Analysis complete");
        } catch (err) {
            console.error("AI analyze error:", err);
            setAnalysisResult(null);
            toast.error("Analysis failed. Please try again.");
        } finally {
            setIsAnalyzing(false);
        }
    }, [capturedImage, parseAnalysisResponse]);

    useEffect(() => {
        if (capturedImage && shouldAutoAnalyze) {
            analyzeImage();
            setShouldAutoAnalyze(false);
        }
    }, [capturedImage, shouldAutoAnalyze, analyzeImage]);

    const resetScan = useCallback(() => {
        setCapturedImage(null);
        setAnalysisResult(null);
        setIsAnalyzing(false);
        setShouldAutoAnalyze(false);
    }, []);

    const handleCameraCapture = useCallback((imageData: string) => {
        setCapturedImage(imageData);
        setShouldAutoAnalyze(true);
    }, []);

    const handleUploadCapture = useCallback((imageData: string) => {
        setCapturedImage(imageData);
        setShouldAutoAnalyze(false);
        setIsAnalyzing(true);
        setAnalysisResult(null);
    }, []);

    const handleUploadAnalysisResult = useCallback((payload: any | null, error?: Error) => {
        if (!payload || error) {
            setIsAnalyzing(false);
            return;
        }

        const parsed = parseAnalysisResponse(payload);
        setAnalysisResult(parsed);
        setIsAnalyzing(false);
        toast.success("Analysis complete");
    }, [parseAnalysisResponse]);

    const getSeverityColor = (severity: string) => {
        switch (severity) {
            case "low":
                return "text-green-700 dark:text-green-400 bg-green-100 dark:bg-green-900/30";
            case "medium":
                return "text-yellow-700 dark:text-yellow-400 bg-yellow-100 dark:bg-yellow-900/30";
            case "high":
                return "text-red-700 dark:text-red-400 bg-red-100 dark:bg-red-900/30";
            default:
                return "text-gray-700 dark:text-gray-400 bg-gray-100 dark:bg-gray-900/30";
        }
    };

    return (
        <>
            <div className="mt-[-8px]">
                <div className="w-full min-h-screen flex flex-col">
                    <div className="max-w-4xl mx-auto p-6 space-y-20 flex flex-col">
                        <div className="text-center">
                            <h1 className="text-3xl font-bold text-black dark:text-white">
                                Smart Oral Diagnosis
                            </h1>
                            <p className="text-gray-600 dark:text-gray-300">
                                Take a photo or upload an image for AI-powered dental analysis
                            </p>
                        </div>

                        <div className="flex-1 flex flex-col justify-center">
                            {!capturedImage && (
                                <div className="grid md:grid-cols-2 gap-2 h-full">
                                    <CameraCapture onImageCapture={handleCameraCapture} />
                                    <UploadImage
                                        onImageCapture={handleUploadCapture}
                                        onAnalysisResult={handleUploadAnalysisResult}
                                    />
                                </div>
                            )}

                            {capturedImage && (
                                <div className="rounded-lg p-6 border border-gray-300 dark:border-gray-700 h-full flex flex-col bg-gray-50 dark:bg-transparent">
                                    <div className="flex justify-between items-center mb-4">
                                        <h2 className="text-xl font-semibold text-black dark:text-white">Analysis</h2>
                                        <button
                                            onClick={resetScan}
                                            className="p-2 text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
                                            title="Start Over"
                                        >
                                            <RotateCcw className="h-5 w-5" />
                                        </button>
                                    </div>

                                    <div className="grid md:grid-cols-2 gap-6 flex-1">
                                        <div className="relative w-full h-full flex items-center justify-center">
                                            <Image
                                                src={capturedImage}
                                                alt="Captured dental image"
                                                width={400}
                                                height={300}
                                                className="w-full h-auto max-h-[60vh] rounded-lg border border-gray-300 dark:border-gray-600 object-contain"
                                            />
                                        </div>

                                        <div className="space-y-4 flex flex-col justify-center">
                                            {!analysisResult && !isAnalyzing && (
                                                <button
                                                    onClick={analyzeImage}
                                                    className="w-full px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
                                                >
                                                    Analyze Image
                                                </button>
                                            )}

                                            {isAnalyzing && (
                                                <div className="text-center py-8">
                                                    <div className="animate-spin h-8 w-8 border-4 border-blue-600 border-t-transparent rounded-full mx-auto mb-4"></div>
                                                    <p className="text-gray-600 dark:text-gray-300">Analyzing your image...</p>
                                                </div>
                                            )}

                                            {analysisResult && (
                                                <div className="space-y-4">
                                                    <div className="flex items-center space-x-2">
                                                        <CheckCircle className="h-5 w-5 text-green-400" />
                                                        <span className="font-medium text-black dark:text-white">Analysis Complete</span>
                                                    </div>

                                                    <div className="bg-gray-50 dark:bg-transparent rounded-lg p-4 border border-gray-300 dark:border-gray-700">
                                                        <h3 className="font-medium mb-2 text-black dark:text-white">Diagnosis</h3>
                                                        <p className="text-lg font-semibold text-black dark:text-white mb-2">
                                                            {analysisResult.diagnosis}
                                                        </p>
                                                        <div className="flex items-center space-x-2">
                                                            <span className={`px-2 py-1 rounded text-sm font-medium ${getSeverityColor(analysisResult.severity)}`}>
                                                                {analysisResult.severity.toUpperCase()} RISK
                                                            </span>
                                                            <span className="text-sm text-gray-500 dark:text-gray-400">
                                                                {analysisResult.confidence}% confidence
                                                            </span>
                                                        </div>
                                                    </div>

                                                    <div className="bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-700 rounded-lg p-4">
                                                        <h3 className="font-medium mb-2 flex items-center text-blue-600 dark:text-blue-300">
                                                            <AlertCircle className="h-4 w-4 mr-2 text-blue-500 dark:text-blue-400" />
                                                            Recommendations
                                                        </h3>
                                                        <ul className="space-y-1">
                                                            {analysisResult.recommendations.map((rec, index) => (
                                                                <li key={index} className="text-sm text-gray-700 dark:text-gray-300">
                                                                    • {rec}
                                                                </li>
                                                            ))}
                                                        </ul>
                                                    </div>
                                                    <button
                                                        onClick={resetScan}
                                                        className="w-full px-6 py-2 bg-gray-200 dark:bg-gray-600 text-gray-800 dark:text-white rounded-lg hover:bg-gray-300 dark:hover:bg-gray-700 transition-colors"
                                                    >
                                                        Scan Another Image
                                                    </button>
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
}