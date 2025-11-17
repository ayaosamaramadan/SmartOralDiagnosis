import "./globals.css";
import { Poppins } from "next/font/google";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "../contexts/AuthContext";
import Navigation from "../components/Navigation";
import Footer from "@/components/Footer";
import ClientProviders from "../components/ClientProviders";
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
        {/* Inline script to initialize theme class on <html> before React hydration.
            This prevents hydration mismatches where the client adds `class`/`style`
            attributes to the documentElement that weren't present in the server HTML. */}
        <script dangerouslySetInnerHTML={{ __html: `(() => {
          try {
            const theme = localStorage.getItem('theme');
            if (theme) {
              document.documentElement.classList.add(theme);
              // ensure color-scheme is set so browser rendering matches theme
              document.documentElement.style.colorScheme = theme === 'dark' ? 'dark' : 'light';
            }
          } catch (e) {}
        })();` }} />

        <ClientProviders>{children}</ClientProviders>
      </body>
    </html>
  );
}
