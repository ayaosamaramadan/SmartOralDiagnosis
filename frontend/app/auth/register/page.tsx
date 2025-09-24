"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import loginimg from "../../../assets/login-image.png";
import toast from "react-hot-toast";

export default function Register() {
  const router = useRouter();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
    confirmPassword: "",
    firstName: "",
    lastName: "",
    phoneNumber: "",
    role: "patient",
    dateOfBirth: "",
  });
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<{ [key: string]: string }>({});

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>
  ) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
    // Clear error when user starts typing
    if (errors[e.target.name]) {
      setErrors((prev) => ({
        ...prev,
        [e.target.name]: "",
      }));
    }
  };

  const validateForm = () => {
    const newErrors: { [key: string]: string } = {};

    if (!formData.email) newErrors.email = "Email is required";
    else if (!/\S+@\S+\.\S+/.test(formData.email))
      newErrors.email = "Email is invalid";

    if (!formData.password) newErrors.password = "Password is required";
    else if (formData.password.length < 6)
      newErrors.password = "Password must be at least 6 characters";

    if (!formData.confirmPassword)
      newErrors.confirmPassword = "Please confirm your password";
    else if (formData.password !== formData.confirmPassword)
      newErrors.confirmPassword = "Passwords do not match";

    if (!formData.firstName) newErrors.firstName = "First name is required";
    if (!formData.lastName) newErrors.lastName = "Last name is required";
    if (!formData.phoneNumber)
      newErrors.phoneNumber = "Phone number is required";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) return;

    setIsLoading(true);

    try {
      const response = await fetch(
        `${process.env.NEXT_PUBLIC_API_URL}/auth/register`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            email: formData.email,
            password: formData.password,
            firstName: formData.firstName,
            lastName: formData.lastName,
            phoneNumber: formData.phoneNumber,
            role: formData.role,
          }),
        }
      );

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem("token", data.token);
        localStorage.setItem("user", JSON.stringify(data.user));

        router.push("/auth/login");
      } else {
        const errorData = await response.json();
        toast.error(errorData.message || "Registration failed. Please try again.");
      }
    } catch (error) {
      console.error("Registration error:", error);
      toast.error("Registration failed. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const getRoleColor = () => {
    switch (formData.role) {
      case "doctor":
        return "green";
      case "admin":
        return "purple";
      default:
        return "blue";
    }
  };

  return (
    <div className="flex mt-[-45px] overflow-y-hidden lg:flex-row justify-center items-center min-h-screen py-8">
      <div className="hidden lg:flex lg:w-1/2 justify-center items-center">
        <Image
          src={loginimg}
          alt="Registration Illustration"
          className="w-full max-w-lg rounded-2xl shadow-2xl object-cover"
          priority
        />
      </div>

      <div className="w-full max-w-xl mx-auto lg:mx-0 lg:w-2/3">
        <div className="bg-[#3535354f] py-5 shadow-2xl rounded-3xl px-8 border border-gray-800">
          <h2 className="text-2xl font-bold text-center text-white mb-4">
            Sign up
          </h2>
          <form className="space-y-3" onSubmit={handleSubmit} autoComplete="off" noValidate>
            <div>
              <label htmlFor="role" className="block text-sm text-white">
                Account Type
              </label>
              <select
                id="role"
                name="role"
                value={formData.role}
                onChange={handleInputChange}
                className="block w-full px-3 py-2 border border-gray-700 bg-gray-800 text-white rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
              >
                <option value="patient">Patient</option>
                <option value="doctor">Doctor</option>
                <option value="admin">Admin</option>
              </select>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              <div>
                <label htmlFor="firstName" className="block text-sm text-white">
                  First Name
                </label>
                <input
                  id="firstName"
                  name="firstName"
                  type="text"
                  required
                  value={formData.firstName}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.firstName ? "border-red-500" : "border-gray-700"}`}
                />
                {errors.firstName && (
                  <p className="mt-1 text-xs text-red-500">{errors.firstName}</p>
                )}
              </div>

              <div>
                <label htmlFor="lastName" className="block text-sm text-white">
                  Last Name
                </label>
                <input
                  id="lastName"
                  name="lastName"
                  type="text"
                  required
                  value={formData.lastName}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.lastName ? "border-red-500" : "border-gray-700"}`}
                />
                {errors.lastName && (
                  <p className="mt-1 text-xs text-red-500">{errors.lastName}</p>
                )}
              </div>


              <div className="md:col-span-2">
                <label htmlFor="email" className="block text-sm text-white">
                  Email
                </label>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={formData.email}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.email ? "border-red-500" : "border-gray-700"}`}
                />
                {errors.email && (
                  <p className="mt-1 text-xs text-red-500">{errors.email}</p>
                )}
              </div>

              <div>
                <label htmlFor="dateOfBirth" className="block text-sm text-white">
                  Birth Date
                </label>
                <input
                  id="dateOfBirth"
                  name="dateOfBirth"
                  type="date"
                  required
                  value={formData.dateOfBirth}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.dateOfBirth ? "border-red-500" : "border-gray-700"}`}
                  max={new Date().toISOString().split("T")[0]}
                />
                {errors.dateOfBirth && (
                  <p className="mt-1 text-xs text-red-500">{errors.dateOfBirth}</p>
                )}
              </div>

              <div>
                <label htmlFor="phoneNumber" className="block text-sm text-white">
                  Phone
                </label>
                <input
                  id="phoneNumber"
                  name="phoneNumber"
                  type="tel"
                  required
                  value={formData.phoneNumber}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.phoneNumber ? "border-red-500" : "border-gray-700"}`}
                  pattern="^[0-9+\-\s()]{7,}$"
                  placeholder="e.g. +1234567890"
                />
                {errors.phoneNumber && (
                  <p className="mt-1 text-xs text-red-500">{errors.phoneNumber}</p>
                )}
              </div>

              <div>
                <label htmlFor="password" className="block text-sm text-white">
                  Password
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={formData.password}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.password ? "border-red-500" : "border-gray-700"}`}
                  minLength={6}
                />
                {errors.password && (
                  <p className="mt-1 text-xs text-red-500">{errors.password}</p>
                )}
              </div>

              <div>
                <label htmlFor="confirmPassword" className="block text-sm text-white">
                  Confirm
                </label>
                <input
                  id="confirmPassword"
                  name="confirmPassword"
                  type="password"
                  autoComplete="new-password"
                  required
                  value={formData.confirmPassword}
                  onChange={handleInputChange}
                  className={`block w-full px-3 py-2 border rounded-md bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 sm:text-sm ${errors.confirmPassword ? "border-red-500" : "border-gray-700"}`}
                  minLength={6}
                />
                {errors.confirmPassword && (
                  <p className="mt-1 text-xs text-red-500">{errors.confirmPassword}</p>
                )}
              </div>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-2 px-4 rounded-md text-base font-semibold text-white transition-colors duration-200 ${formData.role === "doctor"
                ? "bg-green-600 hover:bg-green-700"
                : formData.role === "admin"
                  ? "bg-purple-600 hover:bg-purple-700"
                  : "bg-blue-600 hover:bg-blue-700"
                } disabled:opacity-50`}
            >
              {isLoading ? (
                <span className="flex items-center justify-center">
                  <svg
                    className="animate-spin h-5 w-5 mr-2 text-white"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    ></circle>
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8v8z"
                    ></path>
                  </svg>
                  Creating...
                </span>
              ) : (
                "Sign up"
              )}
            </button>
          </form>

          <div className="mt-4 space-y-2">
            <div className="text-center">
              <Link
                href="/auth/login"
                className="text-sm text-indigo-400 hover:text-indigo-300"
              >
                Have an account? Sign in
              </Link>
            </div>

          </div>
        </div>
      </div>
    </div>

  );
}
