"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

interface RegisterFormData {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  confirmPassword: string;
  userType: "doctor" | "patient";
  phoneNumber: string;
  dateOfBirth: string;
  specialization?: string;
  licenseNumber?: string;
  medicalHistory?: string;
}

export default function RegisterPage() {
  const [formData, setFormData] = useState<RegisterFormData>({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    confirmPassword: "",
    userType: "patient",
    phoneNumber: "",
    dateOfBirth: "",
    specialization: "",
    licenseNumber: "",
    medicalHistory: "",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const router = useRouter();

  const handleInputChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement
    >
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const validateForm = () => {
    if (formData.password !== formData.confirmPassword) {
      setError("Passwords do not match");
      return false;
    }
    if (formData.password.length < 6) {
      setError("Password must be at least 6 characters long");
      return false;
    }
    if (
      formData.userType === "doctor" &&
      (!formData.specialization || !formData.licenseNumber)
    ) {
      setError("Specialization and License Number are required for doctors");
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setError("");

    if (!validateForm()) {
      setIsLoading(false);
      return;
    }

    try {
      const response = await fetch("/api/auth/register", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || "Registration failed");
      }

      const data = await response.json();

      // Store token and user info
      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));

      // Redirect based on user type
      switch (data.user.userType) {
        case "doctor":
          router.push("/doctor/dashboard");
          break;
        case "patient":
          router.push("/patient/dashboard");
          break;
        default:
          router.push("/");
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
          <h1>Create Account</h1>
          <p>Join our healthcare platform</p>
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
            </select>
          </div>

          <div>
            <div>
              <label htmlFor="firstName">First Name</label>
              <input
                type="text"
                id="firstName"
                name="firstName"
                value={formData.firstName}
                onChange={handleInputChange}
                placeholder="First name"
                required
              />
            </div>
            <div>
              <label htmlFor="lastName">Last Name</label>
              <input
                type="text"
                id="lastName"
                name="lastName"
                value={formData.lastName}
                onChange={handleInputChange}
                placeholder="Last name"
                required
              />
            </div>
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
            <label htmlFor="phoneNumber">Phone Number</label>
            <input
              type="tel"
              id="phoneNumber"
              name="phoneNumber"
              value={formData.phoneNumber}
              onChange={handleInputChange}
              placeholder="Enter your phone number"
              required
            />
          </div>

          <div>
            <label htmlFor="dateOfBirth">Date of Birth</label>
            <input
              type="date"
              id="dateOfBirth"
              name="dateOfBirth"
              value={formData.dateOfBirth}
              onChange={handleInputChange}
              required
            />
          </div>

          {/* Doctor specific fields */}
          {formData.userType === "doctor" && (
            <>
              <div>
                <label htmlFor="specialization">Specialization</label>
                <input
                  type="text"
                  id="specialization"
                  name="specialization"
                  value={formData.specialization}
                  onChange={handleInputChange}
                  placeholder="e.g., Orthodontist, Periodontist"
                  required
                />
              </div>
              <div>
                <label htmlFor="licenseNumber">License Number</label>
                <input
                  type="text"
                  id="licenseNumber"
                  name="licenseNumber"
                  value={formData.licenseNumber}
                  onChange={handleInputChange}
                  placeholder="Medical license number"
                  required
                />
              </div>
            </>
          )}

          {/* Patient specific fields */}
          {formData.userType === "patient" && (
            <div>
              <label htmlFor="medicalHistory">Medical History (Optional)</label>
              <textarea
                id="medicalHistory"
                name="medicalHistory"
                value={formData.medicalHistory}
                onChange={handleInputChange}
                rows={3}
                placeholder="Brief medical history, allergies, etc."
              />
            </div>
          )}

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

          <div>
            <label htmlFor="confirmPassword">Confirm Password</label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleInputChange}
              placeholder="Confirm your password"
              required
            />
          </div>

          <button type="submit" disabled={isLoading}>
            {isLoading ? "Creating Account..." : "Create Account"}
          </button>
        </form>

        <div>
          <p>
            Already have an account? <Link href="/login">Sign in here</Link>
          </p>
        </div>
      </div>
    </div>
  );
}
