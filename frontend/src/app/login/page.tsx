"use client";

import { useState } from "react";
import Link from "next/link";

interface LoginFormData {
  email: string;
  password: string;
  userType: "admin" | "doctor" | "patient";
}

export default function LoginPage() {
  const [formData, setFormData] = useState<LoginFormData>({
    email: "",
    password: "",
    userType: "patient",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError("");

    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Login failed");
      }

      const data = await response.json();

      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));

       await new Promise((resolve) => setTimeout(resolve, 100));

      switch (data.user.userType) {
        case "admin":
          window.location.href = "/admin/dashboard";
          break;
        case "doctor":
          window.location.href = "/doctor/dashboard";
          break;
        case "patient":
          window.location.href = "/patient/dashboard";
          break;
        default:
          window.location.href = "/";
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "An error occurred");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      <div>
        <div>
          <h1>Welcome Back</h1>
          <p>Sign in to your account</p>
        </div>

        {error && <div>{error}</div>}

        <form onSubmit={handleSubmit}>
          <div>
            <label htmlFor="userType">User Type</label>
            <select
              id="userType"
              name="userType"
              value={formData.userType}
              onChange={handleInputChange}
              required
            >
              <option value="patient">Patient</option>
              <option value="doctor">Doctor</option>
              <option value="admin">Admin</option>
            </select>
          </div>

          <div>
            <label htmlFor="email">Email Address</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              placeholder="Enter your email"
              required
            />
          </div>

          <div>
            <label htmlFor="password">Password</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleInputChange}
              placeholder="Enter your password"
              required
            />
          </div>

          <button type="submit" disabled={isLoading}>
            {isLoading ? "Signing in..." : "Sign In"}
          </button>
        </form>

        <div>
          <p>
            Don&apos;t have an account?{" "}
            <Link href="/register">Sign up here</Link>
          </p>
        </div>

        {/* Test credentials info
        <div>
          <h3>Test Accounts:</h3>
          <div>
            <p>
              <strong>Admin:</strong> admin@test.com / admin123
            </p>
            <p>
              <strong>Doctor:</strong> doctor@test.com / doctor123
            </p>
            <p>
              <strong>Patient:</strong> patient@test.com / patient123
            </p>
          </div>
        </div> */}
      </div>
    </div>
  );
}
