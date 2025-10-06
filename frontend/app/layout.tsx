import "./globals.css";
import { Poppins } from "next/font/google";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "../contexts/AuthContext";
import Navigation from "../components/Navigation";
import Footer from "@/components/Footer";

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
  <body className={`${poppins.className}`}> 
        <AuthProvider>
          <div className="">
            <Navigation />
            <main>{children}</main>
           <Chatbot />
            <Footer/>
          </div>
          <Toaster position="top-right" />
        </AuthProvider>
      </body>
    </html>
  );
}
