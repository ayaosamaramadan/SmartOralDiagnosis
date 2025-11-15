import dynamic from "next/dynamic";

const MapViewer = dynamic(() => import("../../components/MapViewer"), { ssr: false });

export default function MapPage() {
    return (
        <div>
            <MapViewer />
        </div>
    );
}