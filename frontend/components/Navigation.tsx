"use client";
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

  const getNavItems = () => {
    if (!user) return [];

    const commonItems = [
      { href: "/alldiseases", label: "Diseases & Conditions" },
     { href: "/editprofile", label: "Profile" },
    ];

  const rawRole = (user as any).role ?? (user as any).Role ?? (user as any).userRole ?? "";
    const role = typeof rawRole === "string" ? rawRole.toLowerCase() : "";

    switch (role) {
      case "patient":
        return [
          ...commonItems,
          { href: "/appointments", label: "Appointments" },
          { href: "/scan", label: "Oral Scanner" },
       { href: "/medical-records", label: "Medical Records" },
          { href: "/find-doctors", label: "Find Doctors" },
        ];
      case "doctor":
        return [
          ...commonItems,
          { href: "/appointments", label: "Appointments" },
          { href: "/patients", label: "Patients" },
          { href: "/medical-records", label: "Medical Records" },
        ];
      case "admin":
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

  const handleLogout = () => {
    logout();
    router.push("/auth/login");
  };

 
  return (
    <header className="dark:bg-black">
      <div className="max-w-7xl mx-auto px-6 md:px-10 py-4 flex items-center justify-between">
        {<Link href="/">
          <h1
            onClick={() => isMenuOpen && dispatch(setSidebarOpen(false))}
            className="text-2xl font-bold bg-gradient-to-t from-blue-950 via-blue-600 to-blue-100 bg-clip-text text-transparent hover:bg-gradient-to-t hover:from-blue-100 hover:via-blue-600 hover:to-blue-950 transition-colors duration-200 cursor-pointer transform hover:scale-110">
            OralScan
          </h1>
        </Link>}

        <nav role="navigation" aria-label="Main navigation" className="hidden md:block">
          <ul className="flex items-center">
            {getNavItems().map((item) => (
              <li key={item.href}>
                <Link
                  href={item.href}
                  onClick={() => isMenuOpen && dispatch(setSidebarOpen(false))}
                  className="whitespace-nowrap px-3 py-2 rounded-md text-sm font-medium text-black dark:text-white hover:text-blue-600 dark:hover:text-blue-300 hover:bg-black/5 dark:hover:bg-white/5 transition-colors duration-150 ease-in-out"
                >
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>


        <div className="flex items-center gap-4">
          {user ? (
            <>
            {( user.role === "patient") && (
              <Link href="/chatwithdoc" className="relative p-2 rounded-full text-black dark:text-white hover:bg-black/5 dark:hover:bg-white/5 mr-2" aria-label="Chat">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4-.8L3 20l1.2-4.2A7.963 7.963 0 013 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <span className="absolute -top-1 -right-1 inline-flex items-center justify-center w-4 h-4 text-xs font-bold text-white bg-red-600 rounded-full">•</span>
              </Link>
            )}

            {user.role === "doctor" && (
              <>
                <Link href="/chatwithpat" className="relative p-2 rounded-full text-black dark:text-white hover:bg-black/5 dark:hover:bg-white/5 mr-2" aria-label="Chat">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4-.8L3 20l1.2-4.2A7.963 7.963 0 013 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <span className="absolute -top-1 -right-1 inline-flex items-center justify-center w-4 h-4 text-xs font-bold text-white bg-red-600 rounded-full">•</span>
              </Link>
              <Link href="/docNotific" className="relative p-2 rounded-full text-black dark:text-white hover:bg-black/5 dark:hover:bg-white/5 mr-2" aria-label="Notifications">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6 6 0 10-12 0v3.159c0 .538-.214 1.055-.595 1.436L4 17h11z" />
                </svg>
                <span className="absolute -top-1 -right-1 inline-flex items-center justify-center w-4 h-4 text-xs font-bold text-white bg-red-600 rounded-full">•</span>
              </Link>
              </>
            )}

            <details className="relative group mr-3">
              <summary className="flex items-center gap-3 cursor-pointer list-none rounded-full px-2 py-1 hover:bg-black/5 dark:hover:bg-white/5 transition-all duration-200 ease-out focus:outline-none">
              <div
                className="w-10 h-10 rounded-full bg-blue-500 text-white flex items-center justify-center font-semibold transform transition-all duration-200 group-hover:scale-110 group-hover:-translate-y-1 group-hover:shadow-lg group-hover:ring-2 group-hover:ring-blue-300"
                aria-hidden="true"
              >
                {user?.photo ? (
                  <img
                    src={user.photo}
                    alt={`${user.firstName ?? ""} ${user.lastName ?? ""}`.trim() || "User avatar"}
                    className="w-full h-full rounded-full object-cover"
                  />
                ) : (
                  <span>{(user?.firstName?.charAt(0) || "U").toUpperCase()}</span>
                )}
              </div>

              <span className="hidden md:inline font-medium text-black dark:text-white transition-colors duration-200 group-hover:text-blue-600">
                {`${user.firstName ? user.firstName.charAt(0).toUpperCase() + user.firstName.slice(1) : ""} ${user.lastName ? user.lastName.charAt(0).toUpperCase() + user.lastName.slice(1) : ""}`.trim()}
                </span>
              </summary>

              <div
              className="absolute right-0 mt-2 w-48 bg-white dark:bg-[#383838] border border-black/5 dark:border-white/5 rounded-md shadow-lg py-1 z-50 ring-1 ring-black/5 dark:ring-white/5 transform transition-all duration-150 origin-top-right"
              role="menu"
              aria-label="User menu"
              onKeyDown={(e) => {
                if (e.key === "Escape") {
                const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                if (details) details.open = false;
                }
              }}
              >
              {/* <Link
                href="/editprofile"
                role="menuitem"
                className="block px-4 py-2 text-sm text-black dark:text-white hover:bg-gradient-to-r hover:from-blue-50 hover:to-blue-100 hover:dark:from-blue-300 hover:dark:to-blue-200 hover:text-blue-600 hover:pl-4 border-l-4 border-transparent hover:border-blue-400 transition-all duration-150"
                onClick={(e) => {
                const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                if (details) details.open = false;
                }}
              >
                Profile
              </Link> */}

              <Link
                href="/editprofile"
                role="menuitem"
                className="block px-4 py-2 text-sm text-black dark:text-white hover:bg-gradient-to-r hover:from-blue-50 hover:to-blue-100 hover:dark:from-blue-300 hover:dark:to-blue-200 hover:text-blue-600 hover:pl-4 border-l-4 border-transparent hover:border-blue-400 transition-all duration-150"
                 onClick={(e) => {
                const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                if (details) details.open = false;
                }}
              >
                Edit Profile
              </Link>
{/* 
              <Link
                href="/settings"
                role="menuitem"
               className="block px-4 py-2 text-sm text-black dark:text-white hover:bg-gradient-to-r hover:from-blue-50 hover:to-blue-100 hover:dark:from-blue-300 hover:dark:to-blue-200 hover:text-blue-600 hover:pl-4 border-l-4 border-transparent hover:border-blue-400 transition-all duration-150"
                 onClick={(e) => {
                const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                if (details) details.open = false;
                }}
              >
                Settings
              </Link> */}

              {
              user.role=== "admin" && (
                <Link
                href="/admin"
                role="menuitem"
                className="block px-4 py-2 text-sm text-black dark:text-white hover:bg-gradient-to-r hover:from-blue-50 hover:to-blue-100 dark:hover:bg-[#222222] hover:text-blue-600 hover:pl-4 border-l-4 border-transparent hover:border-blue-400 transition-all duration-150"
                onClick={(e) => {
                  const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                  if (details) details.open = false;
                }}
                >
                Admin dashboard
                </Link>
              )}

              <div className="border-t border-black/5 dark:border-white/5 mt-1">
                <button
                type="button"
                className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-red-50 dark:hover:bg-white/5 hover:text-red-700 transition-colors duration-150"
                onClick={(e) => {
                  const details = (e.currentTarget as HTMLElement).closest("details") as HTMLDetailsElement | null;
                  if (details) details.open = false;
                  handleLogout();
                }}
                >
                Logout
                </button>
              </div>
              </div>
            </details>

              <Drkbtn />
            </>
          ) : (
            <>
              <div className="hidden md:flex items-center gap-6">
                <Link href="/alldiseases" className="text-black dark:text-white hover:text-blue-600 dark:hover:text-blue-300">Diseases & Conditions</Link>
                <Link href="/scan" className="text-black dark:text-white hover:text-blue-600 dark:hover:text-blue-300">Oral Scanner</Link>
                <a href="#" className="text-black dark:text-white hover:text-blue-600 dark:hover:text-blue-300">Pricing</a>
                <a href="#" className="text-black dark:text-white hover:text-blue-600 dark:hover:text-blue-300">About Us</a>
              </div>

              <div className="hidden md:flex items-center gap-4">
                <button className="px-7 py-2 rounded-3xl border border-black dark:border-white hover:bg-black dark:hover:bg-white hover:text-white dark:hover:text-black transition-colors text-black dark:text-white duration-200">
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
            className="md:hidden p-2 rounded-md text-black dark:text-white hover:bg-black/10 dark:hover:bg-white/10 focus:outline-none"
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
        <div className="md:hidden bg-white/90 dark:bg-black/90 text-black dark:text-white">
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

            <div className="pt-2 border-t border-black/10 dark:border-white/10">
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


