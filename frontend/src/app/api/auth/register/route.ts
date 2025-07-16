import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const {
      firstName,
      lastName,
      email,
      password,
      userType,
      phoneNumber,
      dateOfBirth,
      specialization,
      licenseNumber,
      medicalHistory,
    } = body;

    // For mock data, we don't validate password, but acknowledge it's received
    void password; // Explicitly ignore the unused variable

    // MOCK DATA - للتجربة قبل ما البراك End يبقى جاهز
    // Simulate user creation (in real app this would be saved to database)
    const newUser = {
      id: Math.random().toString(36).substr(2, 9),
      firstName,
      lastName,
      email,
      userType,
      phoneNumber,
      dateOfBirth,
      ...(userType === "doctor" && {
        specialization,
        licenseNumber,
      }),
      ...(userType === "patient" && {
        medicalHistory,
      }),
    };

    // Generate mock token
    const token = "mock-jwt-token-" + newUser.id;

    return NextResponse.json({
      token,
      user: newUser,
    });

    // TODO: استبدل هذا بالكود الحقيقي لما البراك End يبقى جاهز
    /*
    // Prepare data for .NET backend
    const registrationData = {
      firstName,
      lastName,
      email,
      password,
      userType,
      phoneNumber,
      dateOfBirth,
      ...(userType === "doctor" && {
        specialization,
        licenseNumber,
      }),
      ...(userType === "patient" && {
        medicalHistory,
      })
    };

    // Make request to your .NET backend
    const response = await fetch(
      `${process.env.NEXT_PUBLIC_API_URL}/api/auth/register`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(registrationData),
      }
    );

    if (!response.ok) {
      const errorData = await response.json();
      return NextResponse.json(
        { message: errorData.message || "Registration failed" },
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
        dateOfBirth: data.user.dateOfBirth,
        ...(data.user.userType === "doctor" && {
          specialization: data.user.specialization,
          licenseNumber: data.user.licenseNumber,
        }),
        ...(data.user.userType === "patient" && {
          medicalHistory: data.user.medicalHistory,
        }),
      },
    });
    */
  } catch (error) {
    console.error("Registration error:", error);
    return NextResponse.json(
      { message: "Internal server error" },
      { status: 500 }
    );
  }
}
