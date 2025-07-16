import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password, userType } = body;

    // MOCK DATA - للتجربة قبل ما البراك End يبقى جاهز
    // Mock users for testing
    const mockUsers = {
      "admin@test.com": {
        id: "1",
        email: "admin@test.com",
        firstName: "Admin",
        lastName: "User",
        userType: "admin",
        phoneNumber: "+1234567890",
        password: "admin123",
      },
      "doctor@test.com": {
        id: "2",
        email: "doctor@test.com",
        firstName: "Ahmed",
        lastName: "Hassan",
        userType: "doctor",
        phoneNumber: "+1234567891",
        password: "doctor123",
        specialization: "Orthodontist",
        licenseNumber: "LIC001",
      },
      "patient@test.com": {
        id: "3",
        email: "patient@test.com",
        firstName: "Sara",
        lastName: "Mohamed",
        userType: "patient",
        phoneNumber: "+1234567892",
        password: "patient123",
        medicalHistory: "No allergies",
      },
    };

    // Check if user exists and password is correct
    const user = mockUsers[email as keyof typeof mockUsers];
    if (!user || user.password !== password || user.userType !== userType) {
      return NextResponse.json(
        { message: "Invalid credentials" },
        { status: 401 }
      );
    }

    // Generate mock token
    const token = "mock-jwt-token-" + user.id;

    // Remove password from response
    const { password: _, ...userWithoutPassword } = user;
    void _; // Explicitly ignore the unused variable

    // Create response with cookies
    const response = NextResponse.json({
      token,
      user: userWithoutPassword,
    });

    // Set secure HTTP-only cookie for middleware
    response.cookies.set("token", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    // Also set user type cookie for easier middleware access
    response.cookies.set("userType", userType, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 60 * 60 * 24 * 7, // 7 days
    });

    return response;

    // BEnd يبقى جاهز
    /*
    // Make request to your .NET backend
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_URL}/api/auth/login`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email,
          password,
          userType,
        }),
      }
    );

    if (!response.ok) {
      const errorData = await response.json();
      return NextResponse.json(
        { message: errorData.message || "Login failed" },
        { status: response.status }
      );
    }

    const data = await response.json();

    return NextResponse.json({
      token: data.token,
      user: {
        id: data.user.id,
        email: data.user.email,
        firstName: data.user.firstName,
        lastName: data.user.lastName,
        userType: data.user.userType,
        phoneNumber: data.user.phoneNumber,
        ...(data.user.userType === "doctor" && {
          specialization: data.user.specialization,
          licenseNumber: data.user.licenseNumber,
        }),
      },
    });
    */
  } catch (error) {
    console.error("Login error:", error);
    return NextResponse.json(
      { message: "Internal server error" },
      { status: 500 }
    );
  }
}
