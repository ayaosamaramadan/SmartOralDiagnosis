"use client";

import { useEffect, useState } from "react";
import { authService, User } from "@/lib/auth";

interface DashboardStats {
  totalUsers: number;
  totalDoctors: number;
  totalPatients: number;
  totalAppointments: number;
}

export default function AdminDashboard() {
  const [user, setUser] = useState<User | null>(null);
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalDoctors: 0,
    totalPatients: 0,
    totalAppointments: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const currentUser = authService.getCurrentUser();
    if (!currentUser || currentUser.userType !== "admin") {
      window.location.href = "/login";
      return;
    }
    setUser(currentUser);

   
        setTimeout(() => {
      setStats({
        totalUsers: 156,
        totalDoctors: 23,
        totalPatients: 133,
        totalAppointments: 89,
      });
      setLoading(false);
    }, 1000);
  }, []);

  if (!user) {
    return (
      <div >
        <div >Loading...</div>
      </div>
    );
  }

  return (
    <div >
      <div >
        <div >
          <div >
            <h1 >
              Admin Dashboard
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
                Total Users
              </h3>
              <p >
                {loading ? "..." : stats.totalUsers}
              </p>
            </div>
            <div >
              <h3 >
                Total Doctors
              </h3>
              <p >
                {loading ? "..." : stats.totalDoctors}
              </p>
            </div>
            <div >
              <h3 >
                Total Patients
              </h3>
              <p >
                {loading ? "..." : stats.totalPatients}
              </p>
            </div>
            <div >
              <h3 >
                Total Appointments
              </h3>
              <p >
                {loading ? "..." : stats.totalAppointments}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

