import type { Doctor, Patient } from "../types";

// API base configuration for backend requests.
const normalizeBaseUrl = (value: string) => {
  const trimmed = value.trim().replace(/\/+$/, '');

  if (!trimmed) return '';
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  if (trimmed.startsWith('//')) return `https:${trimmed}`;
  if (trimmed.startsWith('/')) return trimmed;

  const isLocalHost =
    /^localhost(?::\d+)?(?:\/|$)/i.test(trimmed) ||
    /^127(?:\.\d{1,3}){3}(?::\d+)?(?:\/|$)/.test(trimmed) ||
    /^0\.0\.0\.0(?::\d+)?(?:\/|$)/.test(trimmed);

  return `${isLocalHost ? 'http' : 'https'}://${trimmed}`;
};

const buildApiBaseUrl = () => {
  if (typeof window !== 'undefined') {
    return '/api';
  }

  const apiUrl = process.env.NEXT_PUBLIC_API_URL?.trim();
  const backUrl = process.env.NEXT_PUBLIC_BACK_URL?.trim()
    || process.env.NEXT_PUBLIC_BACKEND_URL?.trim()
    || process.env.NEXT_BACKEND_SERVER?.trim();

  if (apiUrl) {
    const normalizedApiUrl = normalizeBaseUrl(apiUrl);
    return normalizedApiUrl.endsWith('/api') ? normalizedApiUrl : `${normalizedApiUrl}/api`;
  }

  if (backUrl) {
    const normalizedBackUrl = normalizeBaseUrl(backUrl);
    return normalizedBackUrl.endsWith('/api') ? normalizedBackUrl : `${normalizedBackUrl}/api`;
  }

  return process.env.NODE_ENV === 'production'
    ? 'https://oralbackend-production.up.railway.app/api'
    : 'http://localhost:5000/api';
};

export const API_BASE_URL = buildApiBaseUrl();

const buildAiPredictUrl = () => {
  if (typeof window !== 'undefined') {
    return '/api/ai/predict';
  }

  const configuredUrl = process.env.NEXT_PUBLIC_AI_URL?.trim();
  const normalized = normalizeBaseUrl(configuredUrl || "https://web-production-4e3e5.up.railway.app").replace(/\/+$/, "");

  if (/\/predict$/i.test(normalized)) {
    return normalized;
  }

  return `${normalized}/predict`;
};

const AI_PREDICT_URL = buildAiPredictUrl();

const normalizeAiUploadError = (error: unknown) => {
  const raw =
    error instanceof Error
      ? error.message
      : typeof error === "string"
        ? error
        : String(error ?? "Unknown AI upload error");

  const message = raw.trim();
  if (/^internal server error$/i.test(message) || /request failed with status 500/i.test(message)) {
    return new Error("AI service is currently unavailable on Railway. Please try again later.");
  }

  return error instanceof Error ? error : new Error(message);
};

const mapRoleToBackendValue = (role: string) => {
  const normalized = String(role || "").trim().toLowerCase();
  if (normalized === "doctor") return "Doctor";
  if (normalized === "admin") return "Admin";
  return "Patient";
};

const getModelStateError = (errors: unknown) => {
  if (!errors || typeof errors !== "object") return null;

  for (const value of Object.values(errors as Record<string, unknown>)) {
    if (Array.isArray(value)) {
      const first = value.find((item) => typeof item === "string" && item.trim().length > 0);
      if (typeof first === "string") return first;
      continue;
    }

    if (typeof value === "string" && value.trim().length > 0) {
      return value;
    }
  }

  return null;
};

const getDetailError = (detail: unknown): string | null => {
  if (typeof detail === "string" && detail.trim().length > 0) {
    return detail.trim();
  }

  if (Array.isArray(detail)) {
    for (const item of detail) {
      const nested = getDetailError(item);
      if (nested) return nested;
    }
    return null;
  }

  if (detail && typeof detail === "object") {
    const detailObj = detail as Record<string, unknown>;
    if (typeof detailObj.message === "string" && detailObj.message.trim().length > 0) {
      return detailObj.message.trim();
    }

    if (typeof detailObj.msg === "string" && detailObj.msg.trim().length > 0) {
      return detailObj.msg.trim();
    }
  }

  return null;
};

// Helper function to get auth headers
const getAuthHeaders = (contentType: string | null = "application/json") => {
  const token = localStorage.getItem("token");
  return {
    ...(contentType ? { "Content-Type": contentType } : {}),
    ...(token && { Authorization: `Bearer ${token}` }),
  } as Record<string, string>;
};

// Helper function to handle API responses
const handleResponse = async <T = any>(response: Response): Promise<T> => {
  // Read response body as text first to safely handle empty bodies
  const text = await response.text();
  let parsedBody: unknown = null;

  if (text) {
    try {
      parsedBody = JSON.parse(text);
    } catch {
      parsedBody = text;
    }
  }

  if (!response.ok) {
    const errorObject =
      parsedBody && typeof parsedBody === "object"
        ? (parsedBody as Record<string, unknown>)
        : null;

    const modelStateMessage = getModelStateError(errorObject?.errors);
    const detailMessage = getDetailError(errorObject?.detail);
    const baseMessage =
      (typeof errorObject?.message === "string" && errorObject.message) ||
      (typeof errorObject?.error === "string" && errorObject.error) ||
      (typeof errorObject?.title === "string" && errorObject.title) ||
      modelStateMessage ||
      detailMessage ||
      (typeof parsedBody === "string" && parsedBody.trim().length > 0 ? parsedBody : "") ||
      response.statusText ||
      `Request failed with status ${response.status}`;

    const shouldAppendDetail =
      typeof detailMessage === "string" &&
      detailMessage.length > 0 &&
      typeof baseMessage === "string" &&
      baseMessage.length > 0 &&
      !baseMessage.toLowerCase().includes(detailMessage.toLowerCase()) &&
      (/internal server error/i.test(baseMessage) || /request failed/i.test(baseMessage));

    const message = shouldAppendDetail ? `${baseMessage}: ${detailMessage}` : baseMessage;

    throw new Error(String(message));
  }

  if (!text) return null as T;

  return parsedBody as T;
};

// Authentication Services
export const authService = {
  login: async (credentials: {
    email: string;
    password: string;
    role?: string;
  }) => {
    const payload = {
      email: credentials.email.trim().toLowerCase(),
      password: credentials.password,
    };

    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    return handleResponse(response);
  },

  register: async (userData: {
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    phoneNumber: string;
    role: string;
    dateOfBirth: string;
  }) => {
    const payload = {
      email: userData.email.trim().toLowerCase(),
      password: userData.password,
      firstName: userData.firstName.trim(),
      lastName: userData.lastName.trim(),
      phoneNumber: userData.phoneNumber?.trim(),
      role: mapRoleToBackendValue(userData.role),
      dateOfBirth: userData.dateOfBirth?.trim(),
    };

    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
    return handleResponse(response);
  },

  logout: () => {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
  },
};

// Patient Services
export const patientService = {
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/patients`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getById: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/patients/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse<Patient | null>(response);
  },

  create: async (patientData: any) => {
    const response = await fetch(`${API_BASE_URL}/patients`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(patientData),
    });
    return handleResponse(response);
  },

  update: async (id: string, patientData: any) => {
    const response = await fetch(`${API_BASE_URL}/patients/${id}`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(patientData),
    });
    return handleResponse(response);
  },

  delete: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/patients/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getByDoctorId: async (doctorId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/patients/doctor/${doctorId}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },
};

// Doctor Services
export const doctorService = {
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/doctors`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getById: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/doctors/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse<Doctor | null>(response);
  },

  create: async (doctorData: any) => {
    const response = await fetch(`${API_BASE_URL}/doctors`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(doctorData),
    });
    return handleResponse(response);
  },

  update: async (id: string, doctorData: any) => {
    const response = await fetch(`${API_BASE_URL}/doctors/${id}`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(doctorData),
    });
    return handleResponse(response);
  },

  delete: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/doctors/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getBySpecialization: async (specialization: string) => {
    const response = await fetch(
      `${API_BASE_URL}/doctors/specialization/${specialization}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },
  getAverageRating: async (doctorId: string) => {
    const response = await fetch(`${API_BASE_URL}/doctors/ratings/average/${doctorId}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },
  createRating: async (rating: { doctorId: string; score: number; comment?: string }) => {
    const response = await fetch(`${API_BASE_URL}/doctors/ratings`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(rating),
    });
    return handleResponse(response);
  },
};

// Appointment Services
export const appointmentService = {
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/appointments`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getById: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/appointments/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  create: async (appointmentData: {
    patientId: string;
    doctorId: string;
    appointmentDate: string;
    duration?: number;
    type: string;
    reason: string;
  }) => {
    // map frontend fields to backend Appointment model shape and ensure enum uses numeric value
    const mapType = (t: any) => {
      if (t == null) return 0;
      if (typeof t === "number") return t;
      const s = String(t).toLowerCase();
      if (s.includes("consult")) return 0;
      if (s.includes("follow")) return 1;
      if (s.includes("emerg")) return 2;
      if (s.includes("rout")) return 3;
      return 0;
    };

    const payload = {
      PatientId: appointmentData.patientId,
      DoctorId: appointmentData.doctorId,
      AppointmentDate: appointmentData.appointmentDate,
      Duration: appointmentData.duration,
      Type: mapType(appointmentData.type),
      Reason: appointmentData.reason,
    };

    const response = await fetch(`${API_BASE_URL}/appointments`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(payload),
    });
    return handleResponse(response);
  },

  update: async (id: string, appointmentData: any) => {
    const response = await fetch(`${API_BASE_URL}/appointments/${id}`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(appointmentData),
    });
    return handleResponse(response);
  },

  delete: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/appointments/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getByPatientId: async (patientId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/appointments/patient/${patientId}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },

  getByDoctorId: async (doctorId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/appointments/doctor/${doctorId}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },

  getByDate: async (date: string) => {
    const response = await fetch(`${API_BASE_URL}/appointments/date/${date}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },
};

// Medical Record Services
export const medicalRecordService = {
  getAll: async () => {
    const response = await fetch(`${API_BASE_URL}/medicalrecords`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getById: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/medicalrecords/${id}`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  create: async (recordData: any) => {
    const response = await fetch(`${API_BASE_URL}/medicalrecords`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(recordData),
    });
    return handleResponse(response);
  },

  update: async (id: string, recordData: any) => {
    const response = await fetch(`${API_BASE_URL}/medicalrecords/${id}`, {
      method: "PUT",
      headers: getAuthHeaders(),
      body: JSON.stringify(recordData),
    });
    return handleResponse(response);
  },

  delete: async (id: string) => {
    const response = await fetch(`${API_BASE_URL}/medicalrecords/${id}`, {
      method: "DELETE",
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getByPatientId: async (patientId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/medicalrecords/patient/${patientId}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },

  getByDoctorId: async (doctorId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/medicalrecords/doctor/${doctorId}`,
      {
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },
};

// Admin Services
export const adminService = {
  getDashboardStats: async () => {
    const response = await fetch(`${API_BASE_URL}/admin/dashboard-stats`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  getAllUsers: async () => {
    const response = await fetch(`${API_BASE_URL}/admin/users`, {
      headers: getAuthHeaders(),
    });
    return handleResponse(response);
  },

  activateUser: async (userId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/admin/users/${userId}/activate`,
      {
        method: "PUT",
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },

  deactivateUser: async (userId: string) => {
    const response = await fetch(
      `${API_BASE_URL}/admin/users/${userId}/deactivate`,
      {
        method: "PUT",
        headers: getAuthHeaders(),
      }
    );
    return handleResponse(response);
  },
};

// Upload Services
export const uploadService = {
  uploadProfilePhoto: async (file: File, userId?: string) => {
    const formData = new FormData();
    formData.append("file", file);
    if (userId) {
      formData.append("userId", userId);
    }

    const response = await fetch(`${API_BASE_URL}/uploads/profile-photo`, {
      method: "POST",
      headers: getAuthHeaders(null),
      body: formData,
    });

    return handleResponse(response);
  },
};

export const aiService = {
  predictFromDataUrl: async (dataUrl: string) => {
    // Convert data URL to Blob
    const res = await fetch(dataUrl);
    const blob = await res.blob();
    const formData = new FormData();
    formData.append("file", blob, "capture.jpg");

    try {
      const response = await fetch(AI_PREDICT_URL, {
        method: "POST",
        body: formData,
      });

      return handleResponse(response);
    } catch (error) {
      throw normalizeAiUploadError(error);
    }
  },
  predictFromFile: async (file: File) => {
    const formData = new FormData();
    formData.append("file", file, file.name || "upload.jpg");

    try {
      const response = await fetch(AI_PREDICT_URL, {
        method: "POST",
        body: formData,
      });

      return handleResponse(response);
    } catch (error) {
      throw normalizeAiUploadError(error);
    }
  },
};
