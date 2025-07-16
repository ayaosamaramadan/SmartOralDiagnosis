export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  userType: "admin" | "doctor" | "patient";
  phoneNumber: string;
  dateOfBirth?: string;
  specialization?: string;
  licenseNumber?: string;
  medicalHistory?: string;
}

export const authService = {
  // Get current user from localStorage
  getCurrentUser: (): User | null => {
    if (typeof window === "undefined") return null;

    const userStr = localStorage.getItem("user");
    if (!userStr) return null;

    try {
      return JSON.parse(userStr);
    } catch {
      return null;
    }
  },

  // Get token from localStorage
  getToken: (): string | null => {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("token");
  },

  // Check if user is authenticated
  isAuthenticated: (): boolean => {
    const token = authService.getToken();
    const user = authService.getCurrentUser();
    return !!(token && user);
  },

  // Check if user has specific role
  hasRole: (role: "admin" | "doctor" | "patient"): boolean => {
    const user = authService.getCurrentUser();
    return user?.userType === role;
  },

  // Logout user
  logout: async (): Promise<void> => {
    if (typeof window === "undefined") return;

    try {
      // Call logout API to clear server-side cookies
      await fetch("/api/auth/logout", {
        method: "POST",
      });
    } catch (error) {
      console.error("Logout API failed:", error);
    }

    // Clear client-side storage
    localStorage.removeItem("token");
    localStorage.removeItem("user");
    window.location.href = "/login";
  },

  // Get authorization header for API requests
  getAuthHeader: (): Record<string, string> => {
    const token = authService.getToken();
    return token ? { Authorization: `Bearer ${token}` } : {};
  },

  // Make authenticated API request
  authenticatedFetch: async (url: string, options: RequestInit = {}) => {
    const headers = {
      "Content-Type": "application/json",
      ...authService.getAuthHeader(),
      ...options.headers,
    };

    const response = await fetch(url, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      authService.logout();
      throw new Error("Unauthorized");
    }

    return response;
  },
};
