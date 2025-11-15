import "./globals.css";
import { Poppins } from "next/font/google";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "../contexts/AuthContext";
import Navigation from "../components/Navigation";
import Footer from "@/components/Footer";
import { ThemeProvider } from "next-themes"
import ReduxProvider from "../components/ReduxProvider";

import Chatbot from "@/components/Chatbot";

const poppins = Poppins({ subsets: ["latin"], weight: ["400", "600", "700"] });

export const metadata = {
  title: "Medical Management System",
  description:
    "Comprehensive medical management system for doctors, patients, and administrators",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${poppins.className} bg-[#f7f7f7] dark:bg-black text-gray-800 dark:text-gray-100 transition-colors duration-200`}>
           <ThemeProvider attribute="class">
        <ReduxProvider>
          <AuthProvider>
        <div className="min-h-screen mt-4 w-full">
          <Navigation />
          <main className="min-h-screen container mx-auto px-4">{children}</main>
          <Chatbot />
          <Footer />
        </div>
        <Toaster position="top-right" />
          </AuthProvider>
        </ReduxProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
