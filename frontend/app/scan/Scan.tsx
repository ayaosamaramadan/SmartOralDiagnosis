"use client";
import { useState, useCallback, useEffect } from "react";
import toast from "react-hot-toast";
import Image from "next/image";
import { CheckCircle, RotateCcw } from "lucide-react";
import { OralType } from "types/oralTypes";
import UploadImage from "../scan/UploadImage";
import CameraCapture from "./CameraCapture";
import { Oralsdata } from "data/Data";
import Reco from "./Reco";
import { useAppDispatch, useAppSelector } from "../../store/hooks";
import { analyzeFromDataUrl, setAnalysisResult, resetScan as resetScanAction } from "../../store/slices/scanSlice";

const normalizeKey = (value?: string) =>
    (value ?? "")
        .toString()
        .trim()
        .toLowerCase()
        .replace(/[^a-z0-9]/g, "");

const findDiseaseByCode = (code?: string): OralType | undefined => {
    if (!code) return undefined;
    const normalized = code.trim().toLowerCase();
    return Oralsdata.find((disease) => disease.shortTitle.toLowerCase() === normalized);
};

const findDiseaseByName = (name?: string): OralType | undefined => {
    if (!name) return undefined;
    const normalized = normalizeKey(name);
    return Oralsdata.find((disease) => normalizeKey(disease.title) === normalized);
};

const matchDiseaseCandidates = (candidates: Iterable<string>, fallbackLabel?: string) => {
    const candidateList = Array.from(
        new Set(
            Array.from(candidates)
                .map((value) => value?.toString().trim())
                .filter((value): value is string => Boolean(value))
        )
    );

    if (fallbackLabel) candidateList.push(fallbackLabel);

    for (const candidate of candidateList) {
        const match = findDiseaseByCode(candidate);
        if (match) return { matchedDisease: match, diagnosisCode: match.shortTitle };
    }

    for (const candidate of candidateList) {
        const match = findDiseaseByName(candidate);
        if (match) return { matchedDisease: match, diagnosisCode: match.shortTitle };
    }

    const fallbackCode = candidateList.find((value) => /^[a-z]{2,3}$/i.test(value ?? ""));
    return { matchedDisease: undefined, diagnosisCode: fallbackCode?.toUpperCase() };
};

const normalizeRecommendations = (items: any[]): string[] =>
    items
        .flatMap((item) => {
            if (typeof item === "string") return [item];
            if (Array.isArray(item?.dots)) return item.dots;
            const collected: string[] = [];
            if (typeof item?.type === "string") collected.push(item.type);
            if (typeof item?.title === "string") collected.push(item.title);
            if (typeof item?.desc === "string") collected.push(item.desc);
            if (typeof item?.text === "string") collected.push(item.text);
            return collected.length ? collected : [JSON.stringify(item)];
        })
        .filter((item) => Boolean(item && item.trim?.()))
        .map((item) => item.trim());


interface AnalysisResult {
    confidence: number;
    diagnosis: string;
    diagnosisCode?: string;
    matchedDisease?: OralType;
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
    const dispatch = useAppDispatch();
    const { analysisResult, isAnalyzing } = useAppSelector((state: any) => state.scan);
    const [capturedImage, setCapturedImage] = useState<string | null>(null);
    // const [analysisResult, setAnalysisResult] = useState<AnalysisResult | null>(null);
    const [shouldAutoAnalyze, setShouldAutoAnalyze] = useState(false);

    const parseAnalysisResponse = useCallback((resp: any): AnalysisResult => {
        const coerceSeverity = (value: any): AnalysisResult["severity"] => {
            if (typeof value !== "string") return "low";
            const normalized = value.toLowerCase();
            if (normalized === "medium" || normalized === "high") return normalized as AnalysisResult["severity"];
            return "low";
        };

        const candidateStrings = new Set<string>();
        const pushCandidate = (value?: string) => {
            if (typeof value === "string" && value.trim().length > 0) {
                candidateStrings.add(value.trim());
            }
        };

        pushCandidate(resp?.disease_category);
        pushCandidate(resp?.diseaseCategory);
        pushCandidate(resp?.code);
        pushCandidate(resp?.diagnosisCode);
        pushCandidate(resp?.shortTitle);

        let resolvedDiagnosis = "";
        if (typeof resp?.disease_category === "string") {
            resolvedDiagnosis = resp.disease_category;
            pushCandidate(resp.disease_category);
        } else if (typeof resp?.diseaseCategory === "string") {
            resolvedDiagnosis = resp.diseaseCategory;
            pushCandidate(resp.diseaseCategory);
        } else if (typeof resp?.diagnosis === "string") {
            resolvedDiagnosis = resp.diagnosis;
            pushCandidate(resp.diagnosis);
        } else if (resp?.diagnosis && typeof resp.diagnosis === "object") {
            if (typeof resp.diagnosis.code === "string") pushCandidate(resp.diagnosis.code);
            if (typeof resp.diagnosis.shortTitle === "string") pushCandidate(resp.diagnosis.shortTitle);
            const objectLabel = resp.diagnosis.label ?? resp.diagnosis.name ?? resp.diagnosis.title;
            if (typeof objectLabel === "string") {
                resolvedDiagnosis = objectLabel;
                pushCandidate(objectLabel);
            } else {
                resolvedDiagnosis = JSON.stringify(resp.diagnosis);
            }
        } else if (typeof resp?.label === "string") {
            resolvedDiagnosis = resp.label;
            pushCandidate(resp.label);
        } else if (typeof resp?.result === "string") {
            resolvedDiagnosis = resp.result;
            pushCandidate(resp.result);
        } else {
            resolvedDiagnosis = JSON.stringify(resp ?? {});
        }

        // AI service may return confidence either as fraction (0.0-1.0) or percent (0-100).
        const rawConfidence = typeof resp?.confidence === "number"
            ? resp.confidence
            : typeof resp?.probability === "number"
                ? resp.probability
                : 0;

        // Normalize to percent (0-100) — if value looks like fraction, scale it.
        const normalizedConfidence = rawConfidence <= 1 ? Math.round(rawConfidence * 100) : Math.round(rawConfidence);
        const confidence = Math.min(100, Math.max(0, normalizedConfidence));

        const normRecommendations = Array.isArray(resp?.recommendations)
            ? normalizeRecommendations(resp.recommendations)
            : Array.isArray(resp?.suggestions)
                ? normalizeRecommendations(resp.suggestions)
                : [];

        const normAreas = Array.isArray(resp?.areas)
            ? resp.areas
            : Array.isArray(resp?.bboxes)
                ? resp.bboxes
                : [];

        const { matchedDisease, diagnosisCode } = matchDiseaseCandidates(candidateStrings, resolvedDiagnosis);
        const readableDiagnosis = matchedDisease?.title ?? resolvedDiagnosis;

        return {
            confidence,
            diagnosis: readableDiagnosis,
            diagnosisCode,
            matchedDisease,
            severity: coerceSeverity(resp?.severity ?? resp?.risk),
            recommendations: normRecommendations,
            areas: normAreas
        };
    }, []);

    const analyzeImage = useCallback(async () => {
        if (!capturedImage) return;
        // dispatch thunk that handles network + parsing
        try {
            const action = await dispatch(analyzeFromDataUrl(capturedImage));
            // thunk sets state; show toast on success
            if (analyzeFromDataUrl.fulfilled.match(action)) {
               console.log('Analysis successful:', action.payload);
            } else {
                const err = (action.payload as any) || 'Analysis failed';
                toast.error(String(err));
            }
        } catch (err) {
            console.error('AI analyze error:', err);
            toast.error('Analysis failed. Please try again.');
        }
    }, [capturedImage, dispatch]);

    useEffect(() => {
        if (capturedImage && shouldAutoAnalyze) {
            analyzeImage();
            setShouldAutoAnalyze(false);
        }
    }, [capturedImage, shouldAutoAnalyze, analyzeImage]);

    const resetScan = useCallback(() => {
        setCapturedImage(null);
        dispatch(resetScanAction());
        setShouldAutoAnalyze(false);
    }, [dispatch]);

    const handleCameraCapture = useCallback((imageData: string) => {
        setCapturedImage(imageData);
        setShouldAutoAnalyze(true);
    }, []);

    const handleUploadCapture = useCallback((imageData: string) => {
        setCapturedImage(imageData);
        setShouldAutoAnalyze(false);
        dispatch(setAnalysisResult(null));
    }, [dispatch]);

    const handleUploadAnalysisResult = useCallback((payload: any | null, error?: Error) => {
        if (!payload || error) {
            // clear analyzing flag if any
            return;
        }

        // backend response may be already user-friendly; try to parse locally
        try {
            const parsed = parseAnalysisResponse(payload);
            dispatch(setAnalysisResult(parsed));
            toast.success('Analysis complete');
        } catch (err) {
            console.error('Upload parse error:', err);
            toast.error('Could not parse analysis result');
        }
    }, [dispatch, parseAnalysisResponse]);

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
                                                        <div className="text-sm text-gray-600 dark:text-gray-400 mt-2">
                                                            {analysisResult.matchedDisease ? (
                                                                <>
                                                                    Matches dataset entry
                                                                    <span className="font-semibold"> {analysisResult.matchedDisease.title}</span>
                                                                    {analysisResult.matchedDisease.shortTitle && (
                                                                        <span> ({analysisResult.matchedDisease.shortTitle})</span>
                                                                    )}
                                                                </>
                                                            ) : analysisResult.diagnosisCode ? (
                                                                <>No dataset entry found for code {analysisResult.diagnosisCode}.</>
                                                            ) : (
                                                                <>Diagnosis code not provided by AI.</>
                                                            )}
                                                        </div>
                                                    </div>

                                                    <Reco />
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