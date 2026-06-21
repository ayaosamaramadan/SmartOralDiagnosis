"use client";
import React, { useEffect, useState } from "react";
import Link from "next/link";
import { doctorService } from "../../services/api";
import { useAuth } from "../../contexts/AuthContext";
import Image from "next/image";

type Doctor = {
  id: string;
  firstName: string;
  lastName: string;
  specialty?: string;
  photo?: string | null;
  location?: string | null;
  rate?: number | null;
  experienceYears?: number | null;
  consultationFee?: number | null;
};

export default function FindDoctorsPage() {
  const { user } = useAuth();
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [query, setQuery] = useState("");
  const [loading, setLoading] = useState(false);
  const [, setError] = useState<string | null>(null);
  const [sort, setSort] = useState<string>("name_asc");

  useEffect(() => {
    let cancelled = false;
    const fetchDoctors = async () => {
      setLoading(true);
      setError(null);
      try {
        const data = await doctorService.getAll();
        if (!cancelled) setDoctors(data || []);
        // fetch average ratings for doctors in parallel
        if (!cancelled && data && Array.isArray(data) && data.length > 0) {
          try {
            const ratings = await Promise.all(
              data.map((d: any) => doctorService.getAverageRating(d.id).catch(() => ({ average: 0, count: 0 })))
            );
            if (!cancelled) {
              const withRates = (data as any[]).map((d, i) => ({ ...d, rate: ratings[i]?.average ?? 0 }));
              setDoctors(withRates);
            }
          } catch (e) {
            console.error("Error fetching ratings:", e);
          }
        }
      } catch (e: any) {
        console.error(e);
        if (!cancelled) setError(e.message || "Error loading doctors");
        if (!cancelled) setDoctors([]);
      } finally {
        if (!cancelled) setLoading(false);
      }
    };
    fetchDoctors();
    return () => {
      cancelled = true;
    };
  }, [user]);

  const filtered = doctors.filter((d) => {
    const full = `${d.firstName} ${d.lastName} ${d.specialty ?? ""} ${d.location ?? ""}`.toLowerCase();
    return full.includes(query.toLowerCase());
  });

  const getPlaceholder = (name: string, i: number) => `https://ui-avatars.com/api/?name=${encodeURIComponent(name)}&background=0D8ABC&color=ffffff&size=256&rounded=true`;

  const sorted = [...filtered].sort((a, b) => {
    const key = sort || "name_asc";
    switch (key) {
      case "name_asc":
        return (`${a.firstName} ${a.lastName}`.localeCompare(`${b.firstName} ${b.lastName}`));
      case "name_desc":
        return (`${b.firstName} ${b.lastName}`.localeCompare(`${a.firstName} ${a.lastName}`));
      case "rate_desc":
        return ( (b.rate ?? 0) - (a.rate ?? 0) );
      case "rate_asc":
       return ( (a.rate ?? 0) - (b.rate ?? 0) );
    //   case "experience_desc":
    //     return ( (b.experienceYears ?? 0) - (a.experienceYears ?? 0) );
    //   case "fee_asc":
    //     return ( (a.consultationFee ?? Number.MAX_SAFE_INTEGER) - (b.consultationFee ?? Number.MAX_SAFE_INTEGER) );
      default:
        return 0;
    }
  });

  return (
    <main className="max-w-7xl mx-auto p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Doctors</h1>
        <div className="flex items-center gap-3">
          <div className="w-80">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search by name, specialty or location"
              className="w-full px-4 py-2 border rounded-full"
            />
          </div>

          <div className="flex items-center gap-2">
            <label className="text-sm text-gray-600">Sort:</label>
            <select value={sort} onChange={(e) => setSort(e.target.value)} className="px-3 py-2 border rounded">
              <option value="name_asc">Name A→Z</option>
              <option value="name_desc">Name Z→A</option>
              <option value="rate_desc">Rating High → Low</option>
              <option value="rate_asc">Rating Low → High</option>
 
            </select>
          </div>
        </div>
      </div>

      {/* {loading && <div>Loading doctors…</div>}
      {error && <div className="text-red-600 mb-2">Error: {error}</div>} */}

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {sorted.map((doc, i) => (
          <div key={doc.id} className="bg-white dark:bg-[#111111] border border-black/5 dark:border-white/5 rounded-lg p-4 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex flex-col items-center text-center gap-3">
              <div className="w-24 h-24 rounded-full overflow-hidden bg-blue-50 flex items-center justify-center border">
                {
                  // use a real image element for external placeholders to avoid next/image remote config
                }
                <img
                  src={doc.photo ?? getPlaceholder(`${doc.firstName} ${doc.lastName}`, i)}
                  alt={`${doc.firstName} ${doc.lastName}`}
                  className="w-full h-full object-cover"
                  loading="lazy"
                />
              </div>

              <div className="font-medium text-lg">{doc.firstName} {doc.lastName}</div>
              <div className="text-sm text-gray-600 dark:text-gray-300">{doc.specialty ?? "General"}</div>


   <div>
    {typeof doc.rate === 'number' && (
      <div className="flex justify-center gap-1">
        {[1, 2, 3, 4, 5].map((star) => (
          <span key={star} className={star <= Math.round(doc.rate ?? 0) ? "text-yellow-400 text-lg" : "text-gray-300 text-lg"}>
            ★
          </span>
        ))}
      </div>
    )}
   </div>


              <div className="flex items-center gap-2 pt-3">
                <Link href={`/find-doctors/${doc.id}`} className="px-3 py-1 rounded-full bg-blue-600 text-white text-sm">View Profile</Link>
                <button className="px-3 py-1 rounded-full border text-sm">Make a call</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      {!loading && filtered.length === 0 && <div className="mt-6 text-center text-gray-500">No doctors found.</div>}
    </main>
  );
}