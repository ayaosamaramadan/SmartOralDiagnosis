import ScanComponent from "../../components/Scan";

export const metadata = {
  title: "Smart Oral Diagnosis - Scan",
  description: "AI-powered dental analysis through image scanning",
};

export default function ScanPage() {
  return (
    <div className="min-h-screen bg-black py-8">
      <ScanComponent />
    </div>
  );
}