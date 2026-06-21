import { Oralsdata, diagnosisRecommendations, defaultRecommendations } from "data/Data";
import { AlertCircle } from "lucide-react";
import { OralType } from "../../types/oralTypes";
import { useAppSelector } from "../../store/hooks";




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


const Reco = () => {
    const { analysisResult } = useAppSelector((state: any) => state.scan);

    if (!analysisResult) {
        return (
            <div className="bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-700 rounded-lg p-4">
                <h3 className="font-medium mb-2 flex items-center text-blue-600 dark:text-blue-300">
                    <AlertCircle className="h-4 w-4 mr-2 text-blue-500 dark:text-blue-400" />
                    Recommendations
                </h3>
                <div>
                    <p className="text-sm font-semibold text-blue-600 dark:text-blue-300">General Care Tips</p>
                    <ul className="mt-2 space-y-1 list-disc list-inside text-gray-700 dark:text-gray-300">
                        {defaultRecommendations.map((tip) => (
                            <li key={`default-${tip}`}>{tip}</li>
                        ))}
                    </ul>
                </div>
            </div>
        );
    }
       
    return (<>
        <div className="bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-700 rounded-lg p-4">
            <h3 className="font-medium mb-2 flex items-center text-blue-600 dark:text-blue-300">
                <AlertCircle className="h-4 w-4 mr-2 text-blue-500 dark:text-blue-400" />
                Recommendations
            </h3>
            {(() => {
                const datasetListRaw = Array.isArray(analysisResult.matchedDisease?.symptoms?.list)
                    ? analysisResult.matchedDisease?.symptoms?.list
                    : [];
                const datasetList = normalizeRecommendations(datasetListRaw);
                const resolvedCode = (analysisResult.matchedDisease?.shortTitle ?? analysisResult.diagnosisCode ?? "").toUpperCase();
                const codeSpecific = resolvedCode
                    ? diagnosisRecommendations[resolvedCode] ?? []
                    : [];
                const quickTipsLabel = analysisResult.matchedDisease
                    ? `${analysisResult.matchedDisease.title} Quick Tips`
                    : resolvedCode
                        ? `${resolvedCode} Quick Tips`
                        : "Diagnosis Quick Tips";
                const sections = [
                    {
                        title: "AI Suggestions",
                        items: analysisResult.recommendations,
                    },
                    codeSpecific.length
                        ? {
                            title: quickTipsLabel,
                            items: codeSpecific,
                        }
                        : null,
                    datasetList.length
                        ? {
                            title: "Clinical Notes",
                            items: datasetList,
                        }
                        : null,
                ].filter((section): section is { title: string; items: string[] } => Boolean(section && section.items.length));

                const sectionComponents = sections.map((section) => (
                    <div key={section.title} className="mb-4 last:mb-0">
                        <p className="text-sm font-semibold text-blue-600 dark:text-blue-300">{section.title}</p>
                        <ul className="mt-2 space-y-1 list-disc list-inside text-gray-700 dark:text-gray-300">
                            {section.items.map((rec) => (
                                <li key={`${section.title}-${rec}`}>{rec}</li>
                            ))}
                        </ul>
                    </div>
                ));

                if (sectionComponents.length) return sectionComponents;

                return (
                    <div>
                        <p className="text-sm font-semibold text-blue-600 dark:text-blue-300">General Care Tips</p>
                        <ul className="mt-2 space-y-1 list-disc list-inside text-gray-700 dark:text-gray-300">
                            {defaultRecommendations.map((tip) => (
                                <li key={`default-${tip}`}>{tip}</li>
                            ))}
                        </ul>
                    </div>
                );
            })()}
        </div>
    </>);
}

export default Reco;