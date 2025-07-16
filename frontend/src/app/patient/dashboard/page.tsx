"use client";

import { useEffect, useState } from "react";
import { authService, User } from "@/lib/auth";

export default function PatientDashboard() {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const currentUser = authService.getCurrentUser();
    if (!currentUser || currentUser.userType !== "patient") {
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
            <h1 >
              Patient Dashboard
            </h1>
            <div >
              <span >
                Welcome, {user.firstName}!
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
                Upcoming Appointments
              </h3>
              <p >0</p>
            </div>
            <div >
              <h3 >
                Past Diagnoses
              </h3>
              <p >0</p>
            </div>
            <div >
              <h3 >
                Pending Results
              </h3>
              <p >0</p>
            </div>
          </div>

          <div >
            <div >
              <h3 >
                Quick Actions
              </h3>
            </div>
            <div >
              <div >
                <button >
                  Book Appointment
                </button>
                <button >
                  Upload Image for Diagnosis
                </button>
                <button >
                  View Medical History
                </button>
                <button >
                  Contact Doctor
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

