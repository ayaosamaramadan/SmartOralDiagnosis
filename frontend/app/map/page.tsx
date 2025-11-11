"use client";

import { useState } from "react";
import { MapContainer, TileLayer, Popup, CircleMarker, Tooltip, useMapEvents } from "react-leaflet";

// React-Leaflet / Leaflet typings can be strict depending on project setup. To avoid
// TypeScript incompatibilities across environments we cast the used components to `any`
// in this simple example. For production, add proper @types or upgrade packages.
const RLMapContainer: any = MapContainer;
const RLTileLayer: any = TileLayer;
const RLCircleMarker: any = CircleMarker;
const RLPopup: any = Popup;
const RLTooltip: any = Tooltip;
import "leaflet/dist/leaflet.css";

const defaultCenter: [number, number] = [30.0444, 31.2357]; // Cairo as default

function ClickToAdd({ onAdd }: { onAdd: (latlng: [number, number]) => void }) {
            useMapEvents({
                click(e: any) {
                    onAdd([e.latlng.lat, e.latlng.lng]);
                },
            });
    return null;
}

export default function MapPage() {
    const [markers, setMarkers] = useState<Array<[number, number]>>([
        [30.0444, 31.2357],
    ]);

    const handleAdd = (latlng: [number, number]) => {
        setMarkers((m) => [...m, latlng]);
    };

    return (
        <div className="min-h-screen flex flex-col items-center justify-start p-6 bg-black">
            <h1 className="text-2xl text-white font-semibold mb-4">Map</h1>
            <div className="w-full max-w-5xl h-[70vh] rounded-lg overflow-hidden shadow-lg">
                        <RLMapContainer center={defaultCenter} zoom={12} style={{ height: "100%", width: "100%" }}>
                            <RLTileLayer
                                attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                            />

                            <ClickToAdd onAdd={handleAdd} />

                            {markers.map((pos, idx) => (
                                <RLCircleMarker key={idx} center={pos} radius={8} pathOptions={{ color: "#60A5FA", fillColor: "#60A5FA", fillOpacity: 0.9 }}>
                                    <RLPopup>
                                        <div>
                                            <strong>Marker</strong>
                                            <div>
                                                Lat: {pos[0].toFixed(5)}, Lng: {pos[1].toFixed(5)}
                                            </div>
                                        </div>
                                    </RLPopup>
                                    <RLTooltip direction="top">Marker #{idx + 1}</RLTooltip>
                                </RLCircleMarker>
                            ))}
                </RLMapContainer>
            </div>
            <p className="text-sm text-gray-300 mt-3">Click anywhere on the map to add a marker.</p>
        </div>
    );
}