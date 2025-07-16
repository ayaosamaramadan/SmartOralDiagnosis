import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  const token = request.cookies.get("token")?.value;
  const { pathname } = request.nextUrl;

  // Protected routes that require authentication
  const protectedPaths = ["/admin", "/doctor", "/patient"];

  // Check if the current path is protected
  const isProtectedPath = protectedPaths.some((path) =>
    pathname.startsWith(path)
  );

  // If accessing protected route without token, redirect to login
  if (isProtectedPath && !token) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  // If accessing login/register with token, redirect to appropriate dashboard
  if ((pathname === "/login" || pathname === "/register") && token) {
    const userType = request.cookies.get("userType")?.value;

    // Redirect based on user type
    if (userType === "admin") {
      return NextResponse.redirect(new URL("/admin/dashboard", request.url));
    } else if (userType === "doctor") {
      return NextResponse.redirect(new URL("/doctor/dashboard", request.url));
    } else if (userType === "patient") {
      return NextResponse.redirect(new URL("/patient/dashboard", request.url));
    }

    // Default fallback
    return NextResponse.redirect(new URL("/", request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    "/admin/:path*",
    "/doctor/:path*",
    "/patient/:path*",
    "/login",
    "/register",
  ],
};
