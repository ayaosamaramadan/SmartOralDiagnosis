"use client";

import { useEffect, useState } from "react";
import { authService, User } from "@/lib/auth";

export default function DoctorDashboard() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const currentUser = authService.getCurrentUser();
    if (!currentUser || currentUser.userType !== "doctor") {
      window.location.href = "/login";
      return;
    }
    setUser(currentUser);
  }, []);

  if (!user) {
    return <div>Loading...</div>;
  }

  return (
    <div >
      <div >
        <div >
          <div >
            <div>
              <h1 >
                Doctor Dashboard
              </h1>
              <p >
                Specialization: {user.specialization}
              </p>
            </div>
            <div >
              <span >
                Welcome, Dr. {user.firstName}!
              </span>
              <button
                onClick={() => authService.logout()}
                
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </div>

      <div >
        <div >
          <div >
            <div >
              <h3 >
                Todays Appointments
              </h3>
              <p >0</p>
            </div>
            <div >
              <h3 >
                Total Patients
              </h3>
              <p >0</p>
            </div>
            <div >
              <h3 >
                Pending Diagnoses
              </h3>
              <p >0</p>
            </div>
          </div>

          <div >
            <div >
              <h3 >
                Recent Patients
              </h3>
            </div>
            <div >
              <p >No patients yet.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

