// API base configuration
// Use the same-origin `/api` path in the browser so requests go through Next.js
// rewrites and avoid browser CORS issues in production.
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
  const backUrl = process.env.NEXT_PUBLIC_BACK_URL?.trim();

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

// Helper function to get auth headers
const getAuthHeaders = (contentType: string | null = "application/json") => {
  const token = localStorage.getItem("token");
  return {
    ...(contentType ? { "Content-Type": contentType } : {}),
    ...(token && { Authorization: `Bearer ${token}` }),
  } as Record<string, string>;
};

// Helper function to handle API responses
const handleResponse = async (response: Response) => {
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
    const message =
      (typeof errorObject?.message === "string" && errorObject.message) ||
      (typeof errorObject?.error === "string" && errorObject.error) ||
      (typeof errorObject?.title === "string" && errorObject.title) ||
      modelStateMessage ||
      (typeof parsedBody === "string" && parsedBody.trim().length > 0 ? parsedBody : "") ||
      response.statusText ||
      `Request failed with status ${response.status}`;

    throw new Error(String(message));
  }

  if (!text) return null;

  return parsedBody;
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
    return handleResponse(response);
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
    return handleResponse(response);
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

// AI Services
export const aiService = {
  predictFromDataUrl: async (dataUrl: string) => {
    // Determine AI service base URL. Prefer dedicated NEXT_PUBLIC_AI_URL.
    const AI_BASE = (process.env.NEXT_PUBLIC_AI_URL || `${API_BASE_URL}/ai`).replace(/\/$/, "");

    // Convert data URL to Blob
    const res = await fetch(dataUrl);
    const blob = await res.blob();
    const formData = new FormData();
    formData.append("image", blob, "capture.jpg");

    const response = await fetch(`${AI_BASE}/predict`, {
      method: "POST",
      headers: getAuthHeaders(null),
      body: formData,
    });

    return handleResponse(response);
  },
  predictFromFile: async (file: File) => {
    const AI_BASE = (process.env.NEXT_PUBLIC_AI_URL || `${API_BASE_URL}/ai`).replace(/\/$/, "");
    const formData = new FormData();
    formData.append("image", file, file.name || "upload.jpg");

    const response = await fetch(`${AI_BASE}/predict`, {
      method: "POST",
      headers: getAuthHeaders(null),
      body: formData,
    });

    return handleResponse(response);
  }
};
