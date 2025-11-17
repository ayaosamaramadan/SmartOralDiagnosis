"use client";

import {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from "react";
import { authService } from "../services/api";

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  phoneNumber?: string | null;
  photo?: string | null;
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string, role: string) => Promise<void>;
  logout: () => void;
  register: (userData: RegisterData) => Promise<void>;
}

interface RegisterData {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phoneNumber: string;
  role: string;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("token");
    const userData = localStorage.getItem("user");

    if (token && userData) {
      try {
        // normalize stored user role to lowercase to make role checks consistent
        const parsed = JSON.parse(userData);
        if (parsed && typeof parsed === "object") {
          if (parsed.role && typeof parsed.role === "string") parsed.role = parsed.role.toLowerCase();
          else if (parsed.Role && typeof parsed.Role === "string") parsed.role = parsed.Role.toLowerCase();
        }
        setUser(parsed);
      } catch (error) {
        console.error("Error parsing user data:", error);
        localStorage.removeItem("token");
        localStorage.removeItem("user");
      }
    }
    setLoading(false);
  }, []);

  // If there's a token but no stored user object (some flows store only token), try to decode JWT to extract basic user info
  useEffect(() => {
    const token = localStorage.getItem("token");
    const userData = localStorage.getItem("user");
    if (token && !userData) {
      try {
        const parts = token.split('.');
        if (parts.length >= 2) {
          const payload = JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
          const u: any = {};
          if (payload.sub) u.id = payload.sub;
          if (payload.email) u.email = payload.email;
          if (payload.role) u.role = typeof payload.role === 'string' ? payload.role.toLowerCase() : payload.role;
          // store minimal user locally so UI can render
          localStorage.setItem('user', JSON.stringify(u));
          setUser(u as User);
        }
      } catch (ex) {
        console.warn('Failed to decode token for user info', ex);
      }
    }
  }, []);

  const login = async (email: string, password: string, role: string) => {
    try {
      const response = await authService.login({ email, password, role });

      if (response.token && response.user) {
        // normalize role to lowercase before storing
        const u = response.user;
        if (u) {
          if (u.role && typeof u.role === "string") u.role = u.role.toLowerCase();
          else if (u.Role && typeof u.Role === "string") { u.role = u.Role.toLowerCase(); delete u.Role; }
        }
        localStorage.setItem("token", response.token);
        localStorage.setItem("user", JSON.stringify(u));
        setUser(u);
      } else {
        throw new Error("Invalid response format");
      }
    } catch (error) {
      console.error("Login error:", error);
      throw error;
    }
  };

  const register = async (userData: RegisterData) => {
    try {
      const response = await authService.register(userData);

      if (response.token && response.user) {
        const u = response.user;
        if (u) {
          if (u.role && typeof u.role === "string") u.role = u.role.toLowerCase();
          else if (u.Role && typeof u.Role === "string") { u.role = u.Role.toLowerCase(); delete u.Role; }
        }
        localStorage.setItem("token", response.token);
        localStorage.setItem("user", JSON.stringify(u));
        setUser(u);
      } else {
        throw new Error("Invalid response format");
      }
    } catch (error) {
      console.error("Registration error:", error);
      throw error;
    }
  };

  const logout = () => {
    authService.logout();
    setUser(null);
  };

  const value = {
    user,
    loading,
    login,
    logout,
    register,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}

export type { User, AuthContextType, RegisterData };
