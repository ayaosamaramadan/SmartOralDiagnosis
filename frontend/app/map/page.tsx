"use client";
import { useState, useEffect, useRef } from "react";
import { useTheme } from "next-themes";
import { MapContainer, TileLayer, Popup, CircleMarker, Tooltip, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import { FaLocationCrosshairs } from "react-icons/fa6";
import { IoLocationSharp } from "react-icons/io5";
import { FaSatelliteDish } from "react-icons/fa6";
import { SiGooglemaps } from "react-icons/si";
import { MdContentCopy } from "react-icons/md";
import { ClinicsPlaces } from "../../data/Clinics";
import toast from "react-hot-toast";
const RLMapContainer: any = MapContainer;
const RLTileLayer: any = TileLayer;
const RLCircleMarker: any = CircleMarker;
const RLPopup: any = Popup;
const RLTooltip: any = Tooltip;

function FlyToLocation({ location }: { location: [number, number] | null }) {
    const map: any = useMap();
    useEffect(() => {
        if (!location || !map) return;
        try {
            map.flyTo(location, 14, { duration: 1 });
        } catch {
            map.setView(location, 14);
        }
    }, [location, map]);
    return null;
}

export default function MapPage() {
    const [userLocation, setUserLocation] = useState<[number, number] | null>(null);
    const [satelliteView, setSatelliteView] = useState(false);

  const [focusedClinicId, setFocusedClinicId] = useState<string | null>(null);
    const [focusedLocation, setFocusedLocation] = useState<[number, number] | null>(null);
    const markerRefs = useRef<Record<string, any>>({});

   useEffect(() => {
        if (!focusedClinicId) return;
        const el = markerRefs.current[focusedClinicId];
        if (el && typeof el.openPopup === "function") {
            setTimeout(() => {
                try { el.openPopup(); } catch (e) { }
            }, 250);
        }
    }, [focusedClinicId]);

    const { theme, resolvedTheme } = useTheme();
    const [mounted, setMounted] = useState(false);
    useEffect(() => setMounted(true), []);

    type Clinic = { id: string; name: string; lat: number; lng: number; address?: string };
    const [clinics, setClinics] = useState<Clinic[]>([]);

    useEffect(() => {
        if (typeof window === "undefined") return;
        if (!navigator.geolocation) return;
        navigator.geolocation.getCurrentPosition(
            (pos) => {
                const coords: [number, number] = [pos.coords.latitude, pos.coords.longitude];
                setUserLocation(coords);
            },
            (err) => {
                console.warn("Geolocation error:", err.message || err);
            },
            { enableHighAccuracy: true, timeout: 10000 }
        );
    }, []);

    useEffect(() => {
        const load = async () => {
            try {
                const res = await fetch('/api/clinics');
                if (res.ok) {
                    const data = await res.json();
                    if (Array.isArray(data) && data.length) {
                        setClinics(data as Clinic[]);
                        return;
                    }
                }
            } catch (e) {

            }

            setClinics([
                ...ClinicsPlaces
            ]);
        };
        load();
    }, []);

    const effectiveTheme = mounted ? (resolvedTheme ?? theme) : "light";
    const isDark = effectiveTheme === "dark";
    const tileUrl = satelliteView
        ? "https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}.jpg"
        : isDark
            ? "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png"
            : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
    const clinicColor = isDark ? "#34D399" : "#10B981";
    const userColor = "#60A5FA";

    return (
        <>
            <button
                onClick={() => {
                    setSatelliteView(!satelliteView);

                }}
                className="fixed bottom-24 left-6 bg-green-500 text-[white] rounded-full p-4 shadow-lg hover:bg-green-700 transition group"
                style={{ zIndex: 2147483647 }}
                aria-label="Locate me"
            >
                <FaSatelliteDish />
                <span className="absolute left-full ml-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
                    satellite view
                </span>
            </button>
                <button
                    onClick={() => {
                        setFocusedClinicId && setFocusedClinicId(null);
                        setFocusedLocation && setFocusedLocation(null);
                        if (typeof window === "undefined") return;
                        if (!navigator.geolocation) {
                            console.warn("Geolocation not supported");
                            return;
                        }
                        navigator.geolocation.getCurrentPosition(
                            (pos) => {
                                const coords: [number, number] = [pos.coords.latitude, pos.coords.longitude];
                                setUserLocation(coords);
                                setFocusedClinicId && setFocusedClinicId(null);
                                setFocusedLocation && setFocusedLocation(null);
                            },
                            (err) => console.warn("Locate error:", err.message || err),
                            { enableHighAccuracy: true, timeout: 10000 }
                        );
                    }}
                className="fixed bottom-6 left-6 bg-gray-500 text-[white] rounded-full p-4 shadow-lg hover:bg-gray-700 transition group"
                style={{ zIndex: 2147483647 }}
                aria-label="Locate me"
            >
                <FaLocationCrosshairs />
                <span className="absolute left-full ml-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
                    Locate Me
                </span>
            </button>
            <div className="min-h-screen flex flex-col items-center justify-start p-6 -z-10">
                <h1 className="text-4xl sm:text-3xl md:text-4xl mb-5 tracking-tight leading-tight sm:leading-snug text-gray-900 dark:text-white antialiased">
                    Find Nearby Clinics
                </h1>
                <div className="w-full flex flex-col md:flex-row gap-4 items-start md:items-stretch">
                    <aside
                        aria-label="Clinic list"
                        className="hidden md:block w-72 bg-gray-400 dark:bg-gray-800 text-black dark:text-white rounded-md p-3 shadow-lg max-h-[80vh] overflow-auto z-50 sticky top-20"
                    >
                        <div className="mb-3">
                            <h2 className="text-lg font-semibold">Clinics</h2>
                            <p className="text-xs text-gray-500 dark:text-gray-400">Tap a clinic to center it on the map</p>
                        </div>
                        <ul className="space-y-3">
                            {(clinics.length ? clinics : ClinicsPlaces).map((clinic) => (
                                <li
                                    key={clinic.id}
                                    className="bg-gray-50 dark:bg-gray-900 rounded p-2 hover:shadow-md transition cursor-pointer"
                                    onClick={() => {
                                        setFocusedClinicId(clinic.id);
                                        setFocusedLocation([clinic.lat, clinic.lng]);
                                    }}
                                >
                                    <div className="flex justify-between items-start">
                                        <div>
                                            <h3 className="font-semibold text-sm text-gray-900 dark:text-white">{clinic.name}</h3>
                                            {clinic.address && <div className="text-xs text-gray-600 dark:text-gray-300 mt-1">{clinic.address}</div>}
                                        </div>
                                        <div className="text-xs text-gray-500 dark:text-gray-400 ml-2">→</div>
                                    </div>
                                </li>
                            ))}
                        </ul>
                    </aside>

                    <details className="md:hidden w-full mb-2">
                        <summary className="w-full flex items-center justify-between bg-white dark:bg-gray-800 text-black dark:text-white rounded-md p-3 shadow-sm cursor-pointer">
                            <div>
                                <span className="font-medium">Clinics</span>
                                <div className="text-xs text-gray-500 dark:text-gray-400">Tap to open list</div>
                            </div>
                            <div className="text-sm text-gray-500 dark:text-gray-400">▾</div>
                        </summary>
                        <div className="mt-2 bg-white dark:bg-gray-800 rounded-md p-3 shadow-inner max-h-[40vh] overflow-auto">
                            <ul className="space-y-3">
                                {(clinics.length ? clinics : ClinicsPlaces).map((clinic) => (
                                    <li
                                        key={clinic.id}
                                        className="bg-gray-50 dark:bg-gray-900 rounded p-2 hover:shadow transition cursor-pointer"
                                        onClick={(e: any) => {
                                            const d = (e.currentTarget.closest('details') as HTMLDetailsElement | null);
                                            if (d) d.open = false;
                                            setFocusedClinicId(clinic.id);
                                            setFocusedLocation([clinic.lat, clinic.lng]);
                                        }}
                                    >
                                        <h3 className="font-semibold text-sm text-gray-900 dark:text-white">{clinic.name}</h3>
                                        <div className="flex gap-2 mt-2 px-2">

                                        </div>
                                        {clinic.address && <div className="text-xs text-gray-600 dark:text-gray-300 mt-1">{clinic.address}</div>}
                                    </li>
                                ))}
                            </ul>
                        </div>
                    </details>

                    <div className="flex-1 w-full rounded-lg overflow-hidden shadow-lg relative">
                        <div className="w-full h-[60vh] md:h-[80vh]">
                            <RLMapContainer
                                center={
                                    userLocation ??
                                    (clinics[0] ? [clinics[0].lat, clinics[0].lng] : [20, 0])
                                }
                                zoom={12}
                                scrollWheelZoom={true}
                                style={{ height: "100%", width: "100%" }}
                            >
                                <RLTileLayer url={tileUrl} />
                                <FlyToLocation location={focusedLocation ?? userLocation} />

                                {(clinics.length ? clinics : ClinicsPlaces).map((c) => (
                                    <RLCircleMarker
                                        key={c.id}
                                        center={[c.lat, c.lng]}
                                        radius={9}
                                        pathOptions={{
                                            color: c.id === focusedClinicId ? "#16A34A" : clinicColor,
                                            fillColor: c.id === focusedClinicId ? "#16A34A" : clinicColor,
                                            fillOpacity: 0.95,
                                        }}
                                        ref={(el: any) => { markerRefs.current[c.id] = el; }}
                                        eventHandlers={{
                                            click: () => {
                                                setFocusedClinicId(c.id);
                                                setFocusedLocation([c.lat, c.lng]);
                                            }
                                        }}
                                    >
                                        <RLPopup onClose={() => setFocusedClinicId(null)}>
                                            <div className="text-left">
                                                <div className="font-semibold flex ">
                                                    <IoLocationSharp className={`${c.id === focusedClinicId ? 'text-green-600' : 'text-blue-500'} mr-2`} />
                                                    {c.name}</div>
                                                {c.address && <div className="text-sm">{c.address}</div>
                                                }
                                                <div className="flex gap-2 mt-3 items-center">
                                                    <button
                                                    
                                                        onClick={async (e) => {
                                                            e.stopPropagation();
                                                            const text = `${c.lat.toFixed(6)}, ${c.lng.toFixed(6)}`;
                                                            try {
                                                                await navigator.clipboard.writeText(text);
                                                                toast.success("Copied clinic coordinates");
                                                            } catch {
                                                                toast.error("Failed to copy");
                                                            }
                                                        }}
                                                        aria-label="Copy clinic coordinates"
                                                        className="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium rounded-md bg-white dark:bg-gray-800 text-gray-800 dark:text-gray-100 border border-gray-200 dark:border-gray-700 shadow-sm hover:bg-gray-50 dark:hover:bg-gray-700 transition-transform transform hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-blue-400"
                                                    >
                                                        <span className="inline-flex items-center gap-2">
                                                            <MdContentCopy className="w-4 h-4" aria-hidden="true" />
                                                            <span>Copy coords</span>
                                                          </span>
                                                    </button>

                                                    <a
                                                        href={`https://www.google.com/maps/search/?api=1&query=${c.lat},${c.lng}`}
                                                        target="_blank"
                                                        rel="noreferrer"
                                                        onClick={(e) => e.stopPropagation()}
                                                        aria-label="Open clinic in Google Maps"
                                                        className="inline-flex items-center gap-2 px-3 py-1.5 text-xs font-medium rounded-md bg-green-50 dark:bg-green-800 text-green-800 dark:text-white border border-green-100 dark:border-transparent shadow-sm hover:bg-green-100 dark:hover:bg-green-700 transition-transform transform hover:-translate-y-0.5 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-green-400"
                                                    >
                                                        <SiGooglemaps  className="w-4 h-4 text-green-600 dark:text-green-200" />
                                                        <span>Open in Google Maps</span>
                                                    </a>
                                                </div>

                                            </div>
                                        </RLPopup>
                                        <RLTooltip direction="top">{c.name}</RLTooltip>
                                    </RLCircleMarker>
                                ))}

                                {userLocation && (
                                    <RLCircleMarker
                                        key="user-location"
                                        center={userLocation}
                                        radius={10}
                                        pathOptions={{ color: userColor, fillColor: userColor, fillOpacity: 0.95 }}
                                    >
                                        <RLPopup>
                                            <div className="min-w-[180px]">
                                                <div className="flex items-center gap-2 font-semibold px-2">
                                                    <IoLocationSharp className="text-blue-500" />
                                                    <span>Your location</span>
                                                </div>

                                            </div>
                                        </RLPopup>
                                        <RLTooltip direction="top">You</RLTooltip>
                                    </RLCircleMarker>
                                )}
                            </RLMapContainer>
                        </div>
                    </div>
                </div>
                <p className="text-sm justify-center items-center text-center dark:text-gray-300 text-gray-900 mt-3">The map will center on your location if you allow location access.</p>

            </div>

        </>
    );
}