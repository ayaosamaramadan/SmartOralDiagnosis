import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Smart Oral Diagnosis",
  description: "AI-powered oral disease diagnosis platform",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
