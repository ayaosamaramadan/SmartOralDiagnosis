"use client";
import React, { useEffect, useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { appointmentService } from "../../services/api";
import Link from "next/link";
import toast from "react-hot-toast";
import Loading from "@/auth/loading";

type Appointment = {
  id: string;
  patientId: string;
  doctorId: string;
  appointmentDate: string;
  duration?: number | null;
  type?: number | string;
  status?: number | string;
  reason?: string | null;
  notes?: string | null;
  createdAt?: string;
  updatedAt?: string;
};

export default function AppointmentsPage() {
  const { user, loading } = useAuth();
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loadingAppts, setLoadingAppts] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  useEffect(() => {
    if (loading) return;
    if (!user) {
      setAppointments([]);
      setLoadingAppts(false);
      return;
    }

    let cancelled = false;
    const load = async () => {
      setLoadingAppts(true);
      try {
        let list: any;
        if (user.role === "patient") {
          list = await appointmentService.getByPatientId(user.id);
        } else if (user.role === "doctor") {
          list = await appointmentService.getByDoctorId(user.id);
        } else {
          list = await appointmentService.getAll();
        }
        if (!cancelled) setAppointments(Array.isArray(list) ? list : []);
      } catch (ex: any) {
        console.error(ex);
        toast.error(ex?.message || "Failed to load appointments");
        if (!cancelled) setAppointments([]);
      } finally {
        if (!cancelled) setLoadingAppts(false);
      }
    };
    load();
    return () => { cancelled = true; };
  }, [user, loading]);

  const handleCancel = async (id: string) => {
    if (!confirm("Cancel this appointment?")) return;
    setDeletingId(id);
    try {
      await appointmentService.delete(id);
      setAppointments((s) => s.filter((a) => a.id !== id));
      toast.success("Appointment cancelled");
    } catch (ex: any) {
      console.error(ex);
      toast.error(ex?.message || "Failed to cancel appointment");
    } finally {
      setDeletingId(null);
    }
  };

  return (
    <main className="max-w-4xl mx-auto p-6">
      <div className="mb-4 flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Appointments</h1>
        <Link href="/find-doctors" className="text-sm text-blue-600 underline">Find a doctor</Link>
      </div>






      {loadingAppts &&   <div className="-mt-20"><Loading /></div>}

      {!loadingAppts && user && appointments.length === 0 && (
        <div className="p-4 bg-gray-50 border rounded">No appointments found.</div>
      )}

      <div className="space-y-3">
        {appointments.map((a) => (
          <div key={a.id} className="p-4 border rounded bg-white dark:bg-[#0b0b0b]">
            <div className="flex items-start justify-between">
              <div>
                <div className="text-sm text-gray-500">{new Date(a.appointmentDate).toLocaleString()}</div>
                <div className="font-medium mt-1">{a.reason ?? "Appointment"}</div>
                <div className="text-sm text-gray-600 mt-1">Doctor: <Link href={`/find-doctors/${a.doctorId}`} className="text-blue-600">{a.doctorId}</Link></div>
                <div className="text-sm text-gray-600">Patient: {a.patientId}</div>
              </div>

              <div className="flex flex-col items-end gap-2">
                <div className="text-sm text-gray-600">{a.duration ? `${a.duration} mins` : "—"}</div>
                <div className="flex gap-2">
                  {user?.role === "patient" && (
                    <button disabled={deletingId === a.id} onClick={() => handleCancel(a.id)} className="px-3 py-1 rounded border text-sm">{deletingId === a.id ? "Cancelling..." : "Cancel"}</button>
                  )}
                  <Link href={`/appointments/${a.id}`} className="px-3 py-1 rounded bg-blue-600 text-white text-sm">Details</Link>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </main>
  );
}
