"use client";

import React from "react";
import { ThemeProvider } from "next-themes";
import ReduxProvider from "../components/ReduxProvider";
import { AuthProvider } from "../contexts/AuthContext";
import { Toaster } from "react-hot-toast";
import Navigation from "../components/Navigation";
import dynamic from "next/dynamic";
import Footer from "./Footer";

// Load Chatbot lazily on the client to avoid adding it to the initial bundle
const Chatbot = dynamic(() => import("./Chatbot"), { ssr: false, loading: () => null });

type Props = {
  children: React.ReactNode;
};

export default function ClientProviders({ children }: Props) {
  return (
    <ThemeProvider attribute="class">
      <ReduxProvider>
        <AuthProvider>
          <div className="min-h-screen mt-4 w-full">
            <Navigation />
            <main className="min-h-screen container mx-auto px-4">{children}</main>
            <Chatbot />
            <Footer />
          </div>
          <Toaster position="bottom-left" />
        </AuthProvider>
      </ReduxProvider>
    </ThemeProvider>
  );
}
