"use client";
import React, { useEffect, useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { appointmentService } from "../../services/api";
import Link from "next/link";
import toast from "react-hot-toast";
import Loading from "@/auth/loading";
import { Calendar, Clock, User, FileText, AlertCircle, CheckCircle, XCircle } from "lucide-react";

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
  doctor?: { id: string; name?: string; specialty?: string };
  patient?: { id: string; name?: string };
};

const STATUS_MAP: Record<string | number, { label: string; color: string; icon: React.ReactNode }> = {
  0: { label: "Pending", color: "bg-yellow-50 border-yellow-200", icon: <AlertCircle className="w-4 h-4 text-yellow-600" /> },
  1: { label: "Confirmed", color: "bg-blue-50 border-blue-200", icon: <CheckCircle className="w-4 h-4 text-blue-600" /> },
  2: { label: "Completed", color: "bg-green-50 border-green-200", icon: <CheckCircle className="w-4 h-4 text-green-600" /> },
  3: { label: "Cancelled", color: "bg-red-50 border-red-200", icon: <XCircle className="w-4 h-4 text-red-600" /> },
};

const getStatusDisplay = (status?: number | string) => {
  const key = status?.toString() ?? "0";
  return STATUS_MAP[key] || STATUS_MAP["0"];
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
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-slate-950 dark:to-slate-900">
      <div className="max-w-5xl mx-auto p-6 md:p-8">
        {/* Header */}
        <div className="mb-8 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white">Appointments</h1>
            <p className="text-gray-600 dark:text-gray-400 mt-2">Manage your medical appointments</p>
          </div>
          {user?.role !== "doctor" && (
            <Link 
              href="/find-doctors" 
              className="inline-flex items-center gap-2 px-5 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
            >
              <Calendar className="w-5 h-5" />
              Book Appointment
            </Link>
          )}
        </div>






        {/* Loading State */}
        {loadingAppts && (
          <div className="flex justify-center py-12">
            <Loading />
          </div>
        )}

        {/* Empty State */}
        {!loadingAppts && (!user || appointments.length === 0) && (
          <div className="text-center py-16">
            <div className="mb-6 flex justify-center">
              <div className="w-24 h-24 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
                <Calendar className="w-12 h-12 text-blue-600" />
              </div>
            </div>
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">No appointments yet</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-6">You don&apos;t have any scheduled appointments.</p>
            {user?.role !== "doctor" && (
              <Link 
                href="/find-doctors" 
                className="inline-flex items-center gap-2 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium"
              >
                <Calendar className="w-5 h-5" />
                Find a Doctor
              </Link>
            )}
          </div>
        )}

        {/* Appointments List */}
        <div className="space-y-4">
          {appointments.map((appointment) => {
            const statusDisplay = getStatusDisplay(appointment.status);
            const appointmentDate = new Date(appointment.appointmentDate);
            const isPast = appointmentDate < new Date();
            const isToday = appointmentDate.toDateString() === new Date().toDateString();
            const isTomorrow = appointmentDate.toDateString() === new Date(new Date().setDate(new Date().getDate() + 1)).toDateString();

            const statusBorderColor = {
              "Pending": "border-l-yellow-400",
              "Confirmed": "border-l-blue-400",
              "Completed": "border-l-green-400",
              "Cancelled": "border-l-red-400",
            } as Record<string, string>;

            return (
              <div 
                key={appointment.id} 
                className={`group p-6 bg-white dark:bg-slate-800 border-l-4 rounded-lg shadow-sm hover:shadow-md transition-all ${statusBorderColor[statusDisplay.label] || "border-l-yellow-400"}`}
              >
                <div className="flex flex-col md:flex-row md:items-start md:justify-between gap-4">
                  {/* Main Info */}
                  <div className="flex-1 min-w-0">
                    {/* Status Badge */}
                    <div className="inline-flex items-center gap-2 px-3 py-1 mb-3 bg-gray-100 dark:bg-slate-700 text-sm font-medium rounded-full">
                      {statusDisplay.icon}
                      <span>{statusDisplay.label}</span>
                    </div>

                    {/* Reason/Title */}
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-3">
                      {appointment.reason || "Medical Appointment"}
                    </h3>

                    {/* Date & Time */}
                    <div className="flex flex-col sm:flex-row gap-4 mb-4">
                      <div className="flex items-center gap-2 text-gray-700 dark:text-gray-300">
                        <Calendar className="w-4 h-4 text-blue-600 flex-shrink-0" />
                        <span className="font-medium">
                          {isToday ? "Today" : isTomorrow ? "Tomorrow" : appointmentDate.toLocaleDateString("en-US", { 
                            month: "short", 
                            day: "numeric", 
                            year: appointmentDate.getFullYear() !== new Date().getFullYear() ? "numeric" : undefined 
                          })}
                        </span>
                        {isPast && <span className="text-xs bg-red-100 text-red-700 px-2 py-1 rounded">Past</span>}
                      </div>
                      <div className="flex items-center gap-2 text-gray-700 dark:text-gray-300">
                        <Clock className="w-4 h-4 text-green-600 flex-shrink-0" />
                        <span className="font-medium">
                          {appointmentDate.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" })}
                        </span>
                        {appointment.duration && <span className="text-sm text-gray-500">• {appointment.duration} min</span>}
                      </div>
                    </div>

                    {/* Doctor/Patient Info */}
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-3 text-sm">
                      <div className="flex items-center gap-2">
                        <User className="w-4 h-4 text-gray-500 flex-shrink-0" />
                        <div>
                          <span className="text-gray-600 dark:text-gray-400">Doctor: </span>
                          <Link href={`/find-doctors/${appointment.doctorId}`} className="font-medium text-blue-600 hover:underline">
                            {appointment.doctor?.name || `Dr. ${appointment.doctorId.slice(0, 8)}`}
                          </Link>
                          {appointment.doctor?.specialty && <span className="text-gray-500 ml-1">({appointment.doctor.specialty})</span>}
                        </div>
                      </div>
                      {user?.role === "doctor" && (
                        <div className="flex items-center gap-2">
                          <User className="w-4 h-4 text-gray-500 flex-shrink-0" />
                          <div>
                            <span className="text-gray-600 dark:text-gray-400">Patient: </span>
                            <span className="font-medium">{appointment.patient?.name || appointment.patientId.slice(0, 8)}</span>
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Notes */}
                    {appointment.notes && (
                      <div className="flex gap-2 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg mb-4">
                        <FileText className="w-4 h-4 text-blue-600 flex-shrink-0 mt-0.5" />
                        <p className="text-sm text-gray-700 dark:text-gray-300">{appointment.notes}</p>
                      </div>
                    )}
                  </div>

                  {/* Actions */}
                  <div className="flex flex-col sm:flex-row md:flex-col gap-2 md:gap-3">
                    <Link 
                      href={`/appointments/${appointment.id}`} 
                      className="flex-1 md:flex-none px-4 py-2 bg-blue-600 text-white text-center rounded-lg hover:bg-blue-700 transition-colors font-medium text-sm"
                    >
                      View Details
                    </Link>
                    {user?.role === "patient" && appointment.status !== "3" && !isPast && (
                      <button 
                        disabled={deletingId === appointment.id} 
                        onClick={() => handleCancel(appointment.id)} 
                        className="flex-1 md:flex-none px-4 py-2 bg-red-50 text-red-600 border border-red-200 rounded-lg hover:bg-red-100 transition-colors font-medium text-sm disabled:opacity-50 disabled:cursor-not-allowed"
                      >
                        {deletingId === appointment.id ? "Cancelling..." : "Cancel"}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </main>
  );
}
