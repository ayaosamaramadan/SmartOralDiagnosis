import { createSlice, PayloadAction, createAsyncThunk } from '@reduxjs/toolkit';
import { aiService } from "../../services/api";
import { Oralsdata } from '../../data/Data';

type OralType = (typeof Oralsdata)[number];

interface AnalysisResult {
  confidence: number;
  diagnosis: string;
  diagnosisCode?: string;
  matchedDisease?: OralType;
  severity: 'low' | 'medium' | 'high';
  recommendations: string[];
  areas: Array<{ x: number; y: number; width: number; height: number; type: string }>;
}

interface ScanState {
  capturedImage: string | null;
  isAnalyzing: boolean;
  analysisResult: AnalysisResult | null;
  lastError?: string | null;
}

const initialState: ScanState = {
  capturedImage: null,
  isAnalyzing: false,
  analysisResult: null,
  lastError: null,
};

const normalizeKey = (value?: string) =>
  (value ?? '')
    .toString()
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '');

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

  const fallbackCode = candidateList.find((value) => /^[a-z]{2,3}$/i.test(value ?? ''));
  return { matchedDisease: undefined, diagnosisCode: fallbackCode?.toUpperCase() };
};

const normalizeRecommendations = (items: any[]): string[] =>
  items
    .flatMap((item) => {
      if (typeof item === 'string') return [item];
      if (Array.isArray(item?.dots)) return item.dots;
      const collected: string[] = [];
      if (typeof item?.type === 'string') collected.push(item.type);
      if (typeof item?.title === 'string') collected.push(item.title);
      if (typeof item?.desc === 'string') collected.push(item.desc);
      if (typeof item?.text === 'string') collected.push(item.text);
      return collected.length ? collected : [JSON.stringify(item)];
    })
    .filter((item) => Boolean(item && item.trim?.()))
    .map((item) => item.trim());

const coerceSeverity = (value: any): AnalysisResult['severity'] => {
  if (typeof value !== 'string') return 'low';
  const normalized = value.toLowerCase();
  if (normalized === 'medium' || normalized === 'high') return normalized as AnalysisResult['severity'];
  return 'low';
};

const parseAnalysisResponse = (resp: any): AnalysisResult => {
  const candidateStrings = new Set<string>();
  const pushCandidate = (value?: string) => {
    if (typeof value === 'string' && value.trim().length > 0) candidateStrings.add(value.trim());
  };

  pushCandidate(resp?.code);
  pushCandidate(resp?.diagnosisCode);
  pushCandidate(resp?.shortTitle);

  let resolvedDiagnosis = '';
  if (typeof resp?.diagnosis === 'string') {
    resolvedDiagnosis = resp.diagnosis;
    pushCandidate(resp.diagnosis);
  } else if (resp?.diagnosis && typeof resp.diagnosis === 'object') {
    if (typeof resp.diagnosis.code === 'string') pushCandidate(resp.diagnosis.code);
    if (typeof resp.diagnosis.shortTitle === 'string') pushCandidate(resp.diagnosis.shortTitle);
    const objectLabel = resp.diagnosis.label ?? resp.diagnosis.name ?? resp.diagnosis.title;
    if (typeof objectLabel === 'string') {
      resolvedDiagnosis = objectLabel;
      pushCandidate(objectLabel);
    } else {
      resolvedDiagnosis = JSON.stringify(resp.diagnosis);
    }
  } else if (typeof resp?.label === 'string') {
    resolvedDiagnosis = resp.label;
    pushCandidate(resp.label);
  } else {
    resolvedDiagnosis = JSON.stringify(resp ?? {});
  }

  const rawConfidence = typeof resp?.confidence === 'number'
    ? resp.confidence
    : typeof resp?.probability === 'number'
      ? resp.probability
      : 0;

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
    areas: normAreas,
  };
};

export const analyzeFromDataUrl = createAsyncThunk('scan/analyzeFromDataUrl', async (dataUrl: string, thunkAPI) => {
  try {
    const resp = await aiService.predictFromDataUrl(dataUrl);
    const parsed = parseAnalysisResponse(resp);
    return parsed;
  } catch (err: any) {
    return thunkAPI.rejectWithValue(err?.message ?? String(err));
  }
});

const slice = createSlice({
  name: 'scan',
  initialState,
  reducers: {
    setCapturedImage(state, action: PayloadAction<string | null>) {
      state.capturedImage = action.payload;
    },
    setIsAnalyzing(state, action: PayloadAction<boolean>) {
      state.isAnalyzing = action.payload;
    },
    setAnalysisResult(state, action: PayloadAction<AnalysisResult | null>) {
      state.analysisResult = action.payload;
    },
    resetScan(state) {
      state.capturedImage = null;
      state.isAnalyzing = false;
      state.analysisResult = null;
      state.lastError = null;
    },
  },
  extraReducers: (builder) => {
    builder.addCase(analyzeFromDataUrl.pending, (state) => {
      state.isAnalyzing = true;
      state.analysisResult = null;
      state.lastError = null;
    });
    builder.addCase(analyzeFromDataUrl.fulfilled, (state, action: PayloadAction<AnalysisResult>) => {
      state.isAnalyzing = false;
      state.analysisResult = action.payload;
    });
    builder.addCase(analyzeFromDataUrl.rejected, (state, action) => {
      state.isAnalyzing = false;
      state.lastError = action.payload as string || 'Analysis failed';
    });
  },
});

export const { setCapturedImage, setIsAnalyzing, setAnalysisResult, resetScan } = slice.actions;
export default slice.reducer;

