"use client";
import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { doctorService, appointmentService } from "../../../services/api";
import { useAuth } from "../../../contexts/AuthContext";
import Link from "next/link";
import toast from "react-hot-toast";

type DoctorFull = {
  id: string;
  email?: string;
  firstName?: string;
  lastName?: string;
  phoneNumber?: string | null;
  role?: string | number;
  isActive?: boolean;
  createdAt?: string;
  updatedAt?: string;
  dateOfBirth?: string | null;
  addressJson?: string | null;
  emergencyContactJson?: string | null;
  medicalHistoryJson?: string | null;
  assignedDoctorId?: string | null;
  photo?: string | null;
  location?: string | null;
  specialization?: string | null;
  licenseNumber?: string | null;
  department?: string | null;
  experience?: number | null;
  availabilityJson?: string | null;
  consultationFee?: number | null;
};

export default function DoctorProfilePage() {
  const params = useParams() as { id?: string };
  const router = useRouter();
  const id = params?.id;

  const [doctor, setDoctor] = useState<DoctorFull | null>(null);
  const [rating, setRating] = useState<{ average: number; count: number } | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user } = useAuth();

  const [selectedRating, setSelectedRating] = useState<number | null>(null);
  const [comment, setComment] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [showBookingForm, setShowBookingForm] = useState(false);
  const [appointmentDate, setAppointmentDate] = useState<string | null>(null);
  const [reasonText, setReasonText] = useState<string>("");
  const [bookingSubmitting, setBookingSubmitting] = useState(false);

  useEffect(() => {
    if (!id) return;
    let cancelled = false;
    const load = async () => {
      setLoading(true);
      setError(null);
      try {
        const d = await doctorService.getById(id);
        if (!cancelled) setDoctor(d || null);
      } catch (e: any) {
        console.error(e);
        if (!cancelled) setError(e?.message || "Failed to load doctor");
        if (!cancelled) setDoctor(null);
      } finally {
        if (!cancelled) setLoading(false);
      }

      try {
        const avg = await doctorService.getAverageRating(id).catch(() => ({ average: 0, count: 0 }));
        if (!cancelled) setRating(avg);
      } catch {
        // ignore
      }
    };
    load();
    return () => { cancelled = true; };
  }, [id]);

//   if (!id) return <div className="p-6">Missing doctor id</div>;

  const SendPatDetailsToDoc = () => {
    if (!user) {
      toast.error("Please sign in as a patient to book an appointment.");
      return;
    }
    if (user.role && user.role !== "patient") {
      toast.error("Only patients can book appointments.");
      return;
    }
    setShowBookingForm(true);
  };

  const submitBooking = async () => {
    if (!user) return toast.error("Not authenticated");
    if (!id) return toast.error("Missing doctor id");
    // use now if no date selected
    const apptDate = appointmentDate ? new Date(appointmentDate).toISOString() : new Date().toISOString();
    setBookingSubmitting(true);
    try {
      await appointmentService.create({
        patientId: user.id,
        doctorId: id,
        appointmentDate: apptDate,
        duration: 30,
        type: "Consultation",
        reason: reasonText || "Booked via app",
      } as any);
      toast.success("Appointment booked");
      setShowBookingForm(false);
      setReasonText("");
      setAppointmentDate(null);
      // optionally redirect to patient's appointments page
    } catch (ex: any) {
      console.error(ex);
      toast.error(ex?.message || "Failed to book appointment");
    } finally {
      setBookingSubmitting(false);
    }
  };

  return (
    <main className="max-w-4xl mx-auto p-6">
      <div className="mb-4">
        <button onClick={() => router.back()} className="text-sm text-blue-600 underline">← Back</button>
      </div>

      {loading && <div>Loading doctor...</div>}
    
      {doctor && (
        <section className="bg-white dark:bg-[#111] border rounded-lg p-6 shadow-sm">
          <div className="flex flex-col md:flex-row gap-6">
            <div className="flex-shrink-0 w-36 h-36 rounded-full overflow-hidden bg-gray-100 border">
              {doctor.photo ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={doctor.photo} alt={`${doctor.firstName} ${doctor.lastName}`} className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-2xl text-blue-600">{(doctor.firstName?.charAt(0) ?? "") + (doctor.lastName?.charAt(0) ?? "")}</div>
              )}
            </div>

            <div className="flex-1">
              <h2 className="text-2xl font-semibold">{doctor.firstName} {doctor.lastName}</h2>
              <div className="text-sm text-gray-600 dark:text-gray-300">{doctor.specialization ?? "General"}</div>

              {rating && (
                <div className="mt-2 flex items-center gap-3">
                  <div className="flex gap-1">
                    {[1,2,3,4,5].map(s => (
                      <span key={s} className={s <= Math.round(rating.average) ? "text-yellow-400" : "text-gray-300"}>★</span>
                    ))}
                  </div>
                  <div className="text-sm text-gray-600">{rating.average?.toFixed(1)} ({rating.count} reviews)</div>
                </div>
              )}

              <div className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div><strong>Phone:</strong> <a href={`tel:${doctor.phoneNumber}`} className="text-blue-600">{doctor.phoneNumber ?? "—"}</a></div>
                <div><strong>Email:</strong> <a href={`mailto:${doctor.email}`} className="text-blue-600">{doctor.email ?? "—"}</a></div>
                <div><strong>Location:</strong> {doctor.location ?? "—"}</div>
                <div><strong>Experience:</strong> {doctor.experience ? `${doctor.experience} years` : "—"}</div>
                <div><strong>Consultation Fee:</strong> {doctor.consultationFee ? `$${doctor.consultationFee}` : "—"}</div>
                <div><strong>License:</strong> {doctor.licenseNumber ?? "—"}</div>
              </div>

              <div className="mt-4">
                <h3 className="font-medium">Rate this doctor</h3>
                <div className="flex items-center gap-3 mt-2">
                  <div className="flex gap-1 text-2xl">
                    {[1, 2, 3, 4, 5].map((s) => (
                      <button
                        key={s}
                        type="button"
                        onClick={() => setSelectedRating(s)}
                        className={s <= (selectedRating ?? Math.round(rating?.average ?? 0)) ? "text-yellow-400" : "text-gray-300"}
                        aria-label={`Rate ${s} star`}
                      >
                        ★
                      </button>
                    ))}
                  </div>
                  <div className="text-sm text-gray-600">{selectedRating ? `${selectedRating} / 5` : `${rating?.average?.toFixed(1) ?? "0.0"} / 5`}</div>
                </div>

                <textarea
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  placeholder="Leave a short comment (optional)"
                  className="w-full mt-3 p-2 border rounded h-24"
                />

                <div className="mt-2">
                 <button
                    onClick={async () => {
                      if (!selectedRating) {
                       toast.error("Please rating before submitting");
                        return;
                      }
                      setSubmitting(true);
                      try {
                        await doctorService.createRating({ doctorId: id!, score: selectedRating, comment: comment || undefined });
                        const avg = await doctorService.getAverageRating(id!);
                        setRating(avg);
                        setSelectedRating(null);
                        setComment("");
                        // small inline confirmation instead of alert
                        setError("Thank you for your feedback.");
                        setTimeout(() => setError(null), 2500);
                      } catch (ex: any) {
                        console.error(ex);
                        setError(ex?.message || "Failed to submit rating");
                      } finally {
                        setSubmitting(false);
                      }
                    }}
                  
                    className="mt-2 px-3 py-2 rounded bg-blue-600 text-white"
                  >
                    {submitting ? "Submitting..." : "Submit Rating"}
                  </button>
                  {error && <div className="text-sm text-green-600 mt-2">{error}</div>}
                </div>
              </div>

              <div className="mt-4">
                <h3 className="font-medium">About</h3>
                <p className="text-sm text-gray-700 dark:text-gray-300 mt-2">{doctor.department ? `${doctor.department}` : "—"}</p>
              </div>

              <div className="mt-4">
                <h3 className="font-medium">Medical History / Notes</h3>
                <pre className="text-sm text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-[#0b0b0b] p-3 rounded mt-2 overflow-auto">{doctor.medicalHistoryJson ? doctor.medicalHistoryJson : "No notes."}</pre>
              </div>

              <div className="mt-4">
                {!showBookingForm ? (
                  <div className="flex gap-2">
                    <Link href={`/find-doctors`} className="px-3 py-2 rounded bg-blue-600 text-white">All Doctors</Link>
                    <button className="px-3 py-2 rounded border" onClick={SendPatDetailsToDoc}>Book Appointment</button>
                  </div>
                ) : (
                  <div className="p-3 border rounded space-y-2 bg-gray-50 dark:bg-[#0b0b0b] border-gray-200 dark:border-gray-700">
                    <div className="flex flex-col sm:flex-row gap-2">
                      <label className="flex-1">
                        <div className="text-sm text-gray-700 dark:text-gray-300">Preferred date & time</div>
                        <input
                          type="datetime-local"
                          value={appointmentDate ?? ""}
                          onChange={(e) => setAppointmentDate(e.target.value)}
                          className="w-full p-2 rounded mt-1 bg-white dark:bg-[#0b0b0b] text-gray-900 dark:text-gray-300 border border-gray-300 dark:border-gray-700"
                        />
                      </label>
                    </div>

                    <div>
                      <div className="text-sm text-gray-700 dark:text-gray-300">Reason (optional)</div>
                      <input value={reasonText} onChange={(e) => setReasonText(e.target.value)} className="w-full p-2 rounded mt-1 bg-white dark:bg-[#0b0b0b] text-gray-900 dark:text-gray-300 border border-gray-300 dark:border-gray-700" />
                    </div>

                    <div className="flex gap-2">
                      <button disabled={bookingSubmitting} onClick={submitBooking} className="px-3 py-2 rounded bg-green-600 text-white">{bookingSubmitting ? "Booking..." : "Confirm Booking"}</button>
                      <button disabled={bookingSubmitting} onClick={() => setShowBookingForm(false)} className="px-3 py-2 rounded border">Cancel</button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </section>
      )}
    </main>
  );
}
