"use client";
import React from "react";
import toast from "react-hot-toast";
import { useAppDispatch } from "../../store/hooks";
import { MdLocationSearching } from "react-icons/md";
import { updateField, setIsSubmitting } from "../../store/slices/profileSlice";

const detectLocationString = (options?: PositionOptions): Promise<string> => {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error("Geolocation is not supported by your browser."));
      return;
    }

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;

       (async () => {
          try {
            const url = `https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${encodeURIComponent(
              latitude,
            )}&lon=${encodeURIComponent(longitude)}`;
            const res = await fetch(url);
            if (!res.ok) throw new Error("Reverse geocoding failed");
            const data = await res.json();
            const addr = data?.address || {};
            const city =
              addr.city || addr.town || addr.village || addr.municipality || addr.county || addr.state;
            if (city) {
              resolve(city);
            } else {
              resolve(`${latitude},${longitude}`);
            }
          } catch (e) {
            resolve(`${latitude},${longitude}`);
          }
        })();
      },
      (err) => {
        reject(err);
      },
      options,
    );
  });
};

export default function DetectLocation() {
  const dispatch = useAppDispatch();

  const handleDetect = async () => {
  
    if (!navigator.geolocation) {

      toast.error("Geolocation not supported");
      return;
    }
    try {
      dispatch(setIsSubmitting(true));
      const locationStr = await detectLocationString({ timeout: 10000 });
      dispatch(updateField({ name: "location", value: locationStr }));

      toast.success("Location detected.");
    } catch (err) {
 
      toast.error("Failed to detect location.");
    } finally {
      dispatch(setIsSubmitting(false));
    }
  };

  return (
    <button
      type="button"
      onClick={handleDetect}
      title="Detect my location"
      aria-label="Detect my location"
      className="inline-flex items-center gap-2 px-3 py-2 rounded-lg border border-gray-200 bg-white text-sm font-medium text-gray-700 shadow-sm hover:shadow-md hover:bg-gray-50 dark:border-gray-700 dark:bg-gray-800 dark:text-gray-200 transition transform hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-indigo-500"
    >
      <MdLocationSearching className="w-5 h-5 text-indigo-600 dark:text-indigo-400" />
      <span className="hidden sm:inline">Detect location</span>
    </button>
  );
}