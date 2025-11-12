"use client";

import { useState, useEffect } from "react";
import { MapContainer, TileLayer, Popup, CircleMarker, Tooltip, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import { FaLocationCrosshairs } from "react-icons/fa6";
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
        } catch (err) {
            map.setView(location, 14);
        }
    }, [location, map]);
    return null;
}

export default function MapPage() {
    const [userLocation, setUserLocation] = useState<[number, number] | null>(null);

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

    return (
        <>
            <button
                onClick={() => {
                    if (typeof window === "undefined") return;
                    if (!navigator.geolocation) {
                        console.warn("Geolocation not supported");
                        return;
                    }
                    navigator.geolocation.getCurrentPosition(
                        (pos) => {
                            const coords: [number, number] = [pos.coords.latitude, pos.coords.longitude];
                            setUserLocation(coords);
                        },
                        (err) => console.warn("Locate error:", err.message || err),
                        { enableHighAccuracy: true, timeout: 10000 }
                    );
                }}
                className="fixed bottom-6 left-6 bg-blue-600 text-white rounded-full p-4 shadow-lg hover:bg-blue-700 transition group"
                style={{ zIndex: 2147483647 }}
                aria-label="Locate me"
            >
                <FaLocationCrosshairs />
                <span className="absolute left-full ml-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
                    Locate Me
                </span>
            </button>
            <div className="min-h-screen flex flex-col items-center justify-start p-6 -z-10">

                <div className="w-full max-w-5xl h-[70vh] rounded-lg overflow-hidden shadow-lg relative">

                    <RLMapContainer zoom={12} style={{ height: "100%", width: "100%" }}>
                        <RLTileLayer
                            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                        />
                        <FlyToLocation location={userLocation} />
                        {userLocation && (
                            <RLCircleMarker key="user-location" center={userLocation} radius={10} pathOptions={{ color: "#60A5FA", fillColor: "#60A5FA", fillOpacity: 0.9 }}>
                                <RLPopup>
                                    <div>
                                        <strong>Your location</strong>
                                        <div>
                                            Lat: {userLocation[0].toFixed(5)}, Lng: {userLocation[1].toFixed(5)}
                                        </div>
                                    </div>
                                </RLPopup>
                                <RLTooltip direction="top">You</RLTooltip>
                            </RLCircleMarker>
                        )}
                    </RLMapContainer>
                </div>
                <p className="text-sm text-gray-300 mt-3">The map will center on your location if you allow location access.</p>
            </div>
        </>
    );
}