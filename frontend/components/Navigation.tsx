"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "../contexts/AuthContext";
import { CiDark } from "react-icons/ci";

export default function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const { user, logout } = useAuth();
  const router = useRouter();

  const handleLogout = () => {
    logout();
    router.push("/auth/login");
  };

  const getNavItems = () => {
    if (!user) return [];

    const commonItems = [{ href: "/", label: "Dashboard" }];

    switch (user.role) {
      case "Patient":
        return [
          ...commonItems,
          { href: "/appointments", label: "Appointments" },
          { href: "/medical-records", label: "Medical Records" },
          { href: "/doctors", label: "Find Doctors" },
        ];
      case "Doctor":
        return [
          ...commonItems,
          { href: "/appointments", label: "Appointments" },
          { href: "/patients", label: "Patients" },
          { href: "/medical-records", label: "Medical Records" },
        ];
      case "Admin":
        return [
          ...commonItems,
          { href: "/users", label: "Users" },
          { href: "/doctors", label: "Doctors" },
          { href: "/patients", label: "Patients" },
          { href: "/appointments", label: "Appointments" },
          { href: "/reports", label: "Reports" },
        ];
      default:
        return commonItems;
    }
  };

  return (
    <header className="flex justify-between items-center px-10 py-6 bg-black">
      <Link href="/">
        <h1 className="text-2xl font-bold bg-gradient-to-t from-blue-950 via-blue-600 to-blue-100 bg-clip-text text-transparent hover:bg-gradient-to-t hover:from-blue-100 hover:via-blue-600 hover:to-blue-950 transition-colors duration-200 cursor-pointer transform hover:scale-110">
          OralScan
        </h1>
      </Link>

      {user ? (
         <>
          <nav className="space-x-6 hidden md:flex">
            {getNavItems().map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
              >
                {item.label}
              </Link>
            ))}
          </nav>
          
          <div className="flex items-center space-x-4">
            <div className="text-white text-sm">
              <span className="text-blue-400">Welcome, </span>
              <span className="font-semibold">{user.firstName}
                
              </span>
              <span className="text-gray-400 ml-2">({user.role})</span>
            </div>
            <button
              onClick={handleLogout}
              className="px-4 py-2 rounded-3xl border border-red-500 text-red-500 hover:bg-red-500 hover:text-white transition-colors duration-200"
            >
              Logout
            </button>
          </div>
        </>
      ) : (
         <>
          <nav className="space-x-6 hidden md:flex">
            <Link
              href="/alldiseases"
              className="hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
            >
              Diseases & Conditions
            </Link>
            <Link
              href="/scan"
              className="hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
            >
              Oral Scanner
            </Link>
            <a
              href="#"
              className="hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
            >
              Pricing
            </a>
            <a
              href="#"
              className="hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
            >
              About Us
            </a>
          </nav>
          <div className="space-x-4">
            <button className="px-7 py-2 rounded-3xl border border-white hover:bg-white hover:text-black transition-colors duration-200">
              Contact Us
            </button>
            <Link href="/auth/register">
              <button
                className="px-7 py-2 rounded-3xl text-black bg-gradient-to-r from-blue-500 via-blue-500 to-blue-300 hover:from-blue-600 hover:to-blue-800 hover:scale-105 transition-all duration-200"
              >
                SIGN UP
              </button>
            </Link>
            <Link href="/auth/login">
              <button className="px-7 py-2 rounded-3xl border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition-colors duration-200">
                LOGIN
              </button>
            </Link>
            <button
              title="Toggle Dark Mode"
              className="px-4 py-2 rounded-xl border border-gray-500 hover:bg-gray-800 hover:text-white transition-colors duration-200"
            >
              <CiDark className="inline text-blue-400 text-xl" />
            </button>
          </div>
        </>
      )}
    </header>
  );
}
