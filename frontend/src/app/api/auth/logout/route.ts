import { NextResponse } from "next/server";

export async function POST() {
  const response = NextResponse.json({
    message: "Logged out successfully",
  });

  // Clear authentication cookies
  response.cookies.set("token", "", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
    expires: new Date(0),
  });

  response.cookies.set("userType", "", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "strict",
    expires: new Date(0),
  });

  return response;
}
