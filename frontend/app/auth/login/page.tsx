"use client";

import { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import Link from "next/link";
import { useAuth } from "../../../contexts/AuthContext";
import toast from "react-hot-toast";
import Image from "next/image";
import loginimg from "../../../assets/login-image.png";

export default function Login() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const role = searchParams.get("role") || "Patient";
  const { login } = useAuth();

  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });
  const [isLoading, setIsLoading] = useState(false);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData((prev) => ({
      ...prev,
      [e.target.name]: e.target.value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      await login(formData.email, formData.password, role);
      toast.success("Login successful!");
      router.push("/");
    } catch (error: any) {
      toast.error(error.message || "Login failed");
    } finally {
      setIsLoading(false);
    }
  };

  const getRoleTitle = () => {
    switch (role) {
      case "Doctor":
        return "Doctor Login";
      case "Admin":
        return "Admin Login";
      default:
        return "Patient Login";
    }
  };

  const getRoleColor = () => {
    switch (role) {
      case "Doctor":
        return "green";
      case "Admin":
        return "purple";
      default:
        return "blue";
    }
  };

  return (
   
      <div className="flex mt-[-40px] overflow-y-hidden lg:flex-row justify-center items-center min-h-screen py-8">
       
        <div className="hidden lg:flex lg:w-1/2 justify-center items-center">
      <Image
        src={loginimg}
        alt="Registration Illustration"
        className="w-full max-w-lg rounded-2xl shadow-2xl object-cover"
        priority
      />
      </div>
  
        <div className="w-full max-w-xl mx-auto lg:mx-0 lg:w-2/3">
          <div className="bg-[#3535354f] py-8 shadow-2xl rounded-3xl px-8 border border-gray-800">
        <h2 className="text-2xl font-bold text-center text-white mb-4">
          {getRoleTitle()}
        </h2>
        <p className="text-center text-sm text-gray-300 mb-6">
          Medical Management System
        </p>
        <form className="space-y-6" onSubmit={handleSubmit} autoComplete="off" noValidate>
          <div>
            <label
          htmlFor="email"
          className="block text-sm font-medium text-white"
            >
          Email address
            </label>
            <div className="mt-1">
          <input
            id="email"
            name="email"
            type="email"
            autoComplete="email"
            required
            value={formData.email}
            onChange={handleInputChange}
            className="appearance-none block w-full px-3 py-2 border border-gray-700 rounded-md placeholder-gray-400 bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
            </div>
          </div>

          <div>
            <label
          htmlFor="password"
          className="block text-sm font-medium text-white"
            >
          Password
            </label>
            <div className="mt-1">
          <input
            id="password"
            name="password"
            type="password"
            autoComplete="current-password"
            required
            value={formData.password}
            onChange={handleInputChange}
            className="appearance-none block w-full px-3 py-2 border border-gray-700 rounded-md placeholder-gray-400 bg-gray-800 text-white focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
          />
            </div>
          </div>

          <div>
            <button
          type="submit"
          disabled={isLoading}
          className={`w-full flex justify-center py-2 px-4 rounded-md text-base font-semibold text-white transition-colors duration-200 ${
            role === "Doctor"
              ? "bg-green-600 hover:bg-green-700"
              : role === "Admin"
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
              Signing in...
            </span>
          ) : (
            "Sign in"
          )}
            </button>
          </div>
        </form>

        <div className="mt-6 space-y-2">
          <div className="text-center">
            <Link
          href="/auth/register"
          className="text-sm text-indigo-400 hover:text-indigo-300"
            >
          Don't have an account? Register here
            </Link>
          </div>
        
        </div>
          </div>
        </div>
      </div>

  );
}
