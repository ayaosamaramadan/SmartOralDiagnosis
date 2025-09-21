"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { authService } from "../services/api";
import { CiDark } from "react-icons/ci";

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
}

export default function Navigation() {
  // const [user, setUser] = useState<User | null>(null);
  // const [isMenuOpen, setIsMenuOpen] = useState(false);
  // const router = useRouter();

  // useEffect(() => {
  //   const userData = localStorage.getItem("user");
  //   if (userData) {
  //     setUser(JSON.parse(userData));
  //   }
  // }, []);

  // const handleLogout = () => {
  //   authService.logout();
  //   setUser(null);
  //   router.push("auth/login");
  // };

  // const getNavItems = () => {
  //   if (!user) return [];

  //   const commonItems = [{ href: "/dashboard", label: "Dashboard" }];

  //   switch (user.role) {
  //     case "Patient":
  //       return [
  //         ...commonItems,
  //         { href: "/appointments", label: "Appointments" },
  //         { href: "/medical-records", label: "Medical Records" },
  //         { href: "/doctors", label: "Find Doctors" },
  //       ];
  //     case "Doctor":
  //       return [
  //         ...commonItems,
  //         { href: "/appointments", label: "Appointments" },
  //         { href: "/patients", label: "Patients" },
  //         { href: "/medical-records", label: "Medical Records" },
  //       ];
  //     case "Admin":
  //       return [
  //         ...commonItems,
  //         { href: "/users", label: "Users" },
  //         { href: "/doctors", label: "Doctors" },
  //         { href: "/patients", label: "Patients" },
  //         { href: "/appointments", label: "Appointments" },
  //         { href: "/reports", label: "Reports" },
  //       ];
  //     default:
  //       return commonItems;
  //   }
  // };

  // if (!user) {
  //   return (
  //     <nav className="bg-white shadow-lg">
  //       <div className="max-w-7xl mx-auto px-4">
  //         <div className="flex justify-between h-16">
  //           <div className="flex items-center">
  //             <Link href="/" className="text-xl font-bold text-blue-600">
  //               SMOD
  //             </Link>
  //           </div>
  //           <div className="flex items-center space-x-4">
  //             <Link
  //               href="/auth/login"
  //               className="text-gray-700 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium"
  //             >
  //               Login
  //             </Link>
  //             <Link
  //               href="/auth/register"
  //               className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md text-sm font-medium"
  //             >
  //               Register
  //             </Link>
  //           </div>
  //         </div>
  //       </div>
  //     </nav>
  //   );
  // }

  // const navItems = getNavItems();

  return (
     <header className="flex justify-between items-center px-10 py-6 bg-black">
            <h1 className="text-2xl font-bold text-blue-500">INTRINSIC</h1>
            <nav className="space-x-6 hidden md:flex">
              <a href="#" className="hover:text-blue-400">Services</a>
              <a href="#" className="hover:text-blue-400">Portfolio</a>
              <a href="#" className="hover:text-blue-400">Projects</a>
              <a href="#" className="hover:text-blue-400">About Us</a>
            </nav>
            <div className="space-x-4">
              <button className="px-7 py-2 rounded-3xl border border-white">Contact Us</button>
                <button
                  className="px-7 py-2 rounded-3xl text-black bg-gradient-to-r from-blue-500 via-blue-500 to-blue-300 hover:from-blue-600 hover:to-blue-800 transition"
                >
                  OUR TEAM
                </button>
                <button
                title="Toggle Dark Mode"
                className="px-4 py-2 rounded-xl border border-gray-500 hover:bg-gray-800 hover:text-white transition"
                // onClick={() => setDarkMode((prev) => !prev)}
                 >
            <CiDark className="inline text-blue-400 text-xl" />
                </button>
            </div>
          </header>

  );
}
