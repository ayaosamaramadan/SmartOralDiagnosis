// API base configuration
const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api";

// Helper function to get auth headers
const getAuthHeaders = () => {
  const token = localStorage.getItem("token");
  return {
    "Content-Type": "application/json",
    ...(token && { Authorization: `Bearer ${token}` }),
  };
};

// Helper function to handle API responses
const handleResponse = async (response: Response) => {
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || "API request failed");
  }
  return response.json();
};

// Authentication Services
export const authService = {
  login: async (credentials: {
    email: string;
    password: string;
    role: string;
  }) => {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(credentials),
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
  }) => {
    const response = await fetch(`${API_BASE_URL}/auth/register`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(userData),
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
    const response = await fetch(`${API_BASE_URL}/appointments`, {
      method: "POST",
      headers: getAuthHeaders(),
      body: JSON.stringify(appointmentData),
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
