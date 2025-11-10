"use client";
import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "../contexts/AuthContext";
import Drkbtn from "./Dekbtn";
import { useAppSelector, useAppDispatch } from "../store/hooks";
import { toggleSidebar, setSidebarOpen } from "../store/slices/uiSlice";

export default function Navigation() {
  const isMenuOpen = useAppSelector((s) => s.ui.sidebarOpen);
  const dispatch = useAppDispatch();
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
    <header className="bg-black">
      <div className="max-w-7xl mx-auto px-6 md:px-10 py-4 flex items-center justify-between">
      {  <Link href="/">
          <h1
          onClick={() => isMenuOpen && dispatch(setSidebarOpen(false))}
             className="text-2xl font-bold bg-gradient-to-t from-blue-950 via-blue-600 to-blue-100 bg-clip-text text-transparent hover:bg-gradient-to-t hover:from-blue-100 hover:via-blue-600 hover:to-blue-950 transition-colors duration-200 cursor-pointer transform hover:scale-110">
            OralScan
          </h1>
        </Link>}

        <nav className="hidden md:flex items-center gap-8">
          {getNavItems().map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="text-white hover:text-blue-400 transition-colors duration-200 ease-in-out underline-offset-4 hover:underline"
            >
              {item.label}
            </Link>
          ))}
        </nav>

       
        <div className="flex items-center gap-4">
          {user ? (
            <>
              <div className="hidden md:flex items-center text-white text-sm">
                <span className="text-blue-400">Welcome,&nbsp;</span>
                <span className="font-semibold">{user.firstName}</span>
                <span className="text-gray-400 ml-2">({user.role})</span>
              </div>

              <button
                onClick={handleLogout}
                className="hidden md:inline-block px-4 py-2 rounded-3xl border border-red-500 text-red-500 hover:bg-red-500 hover:text-white transition-colors duration-200"
              >
                Logout
              </button>

              <Drkbtn />
            </>
          ) : (
            <>
              <div className="hidden md:flex items-center gap-6">
                <Link href="/alldiseases" className="text-white hover:text-blue-400">Diseases & Conditions</Link>
                <Link href="/scan" className="text-white hover:text-blue-400">Oral Scanner</Link>
                <a href="#" className="text-white hover:text-blue-400">Pricing</a>
                <a href="#" className="text-white hover:text-blue-400">About Us</a>
              </div>

              <div className="hidden md:flex items-center gap-4">
                <button className="px-7 py-2 rounded-3xl border border-white hover:bg-white hover:text-black transition-colors duration-200">
                  Contact Us
                </button>
                <Link href="/auth/register">
                  <button className="px-7 py-2 rounded-3xl text-black bg-gradient-to-r from-blue-500 via-blue-500 to-blue-300 hover:from-blue-600 hover:to-blue-800 hover:scale-105 transition-all duration-200">
                    SIGN UP
                  </button>
                </Link>
                <Link href="/auth/login">
                  <button className="px-7 py-2 rounded-3xl border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition-colors duration-200">
                    LOGIN
                  </button>
                </Link>
              </div>

              <Drkbtn />
            </>
          )}

          <button
            className="md:hidden p-2 rounded-md text-white hover:bg-white/10 focus:outline-none"
            onClick={() => dispatch(toggleSidebar())}
            aria-label="Toggle menu"
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={isMenuOpen ? "M6 18L18 6M6 6l12 12" : "M4 6h16M4 12h16M4 18h16"} />
            </svg>
          </button>
        </div>
      </div>

    
      {isMenuOpen && (
        <div className="md:hidden bg-black/90 text-white">
          <div className="px-6 py-4 space-y-4">
            {getNavItems().length ? (
              getNavItems().map((item) => (
                <Link key={item.href} href={item.href} className="block text-lg" onClick={() => dispatch(setSidebarOpen(false))}>
                  {item.label}
                </Link>
              ))
            ) : (
              <>
                <Link href="/alldiseases" className="block text-lg" onClick={() => dispatch(setSidebarOpen(false))}>Diseases & Conditions</Link>
                <Link href="/scan" className="block text-lg" onClick={() => dispatch(setSidebarOpen(false))}>Oral Scanner</Link>
                <a href="#" className="block text-lg">Pricing</a>
                <a href="#" className="block text-lg">About Us</a>
              </>
            )}

            <div className="pt-2 border-t border-white/10">
              {user ? (
                <>
                  <div className="py-2">Welcome, <span className="font-semibold">{user.firstName}</span></div>
                  <button onClick={handleLogout} className="w-full text-left py-2">Logout</button>
                </>
                  ) : (
                <>
                  <Link href="/auth/login" className="block py-2" onClick={() => dispatch(setSidebarOpen(false))}>Login</Link>
                  <Link href="/auth/register" className="block py-2" onClick={() => dispatch(setSidebarOpen(false))}>Sign up</Link>
                </>
              )}
            </div>
          </div>
        </div>
      )}
    </header>
  );
}


