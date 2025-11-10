"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import loginimg from "../assets/login-image.png";

interface LoadingScreenProps {
  onLoadingComplete: () => void;
}

export default function LoadingScreen({ onLoadingComplete }: LoadingScreenProps) {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          setTimeout(onLoadingComplete, 500); // Small delay after reaching 100%
          return 100;
        }
        return prev + 2; // Increment by 2% every 30ms for smooth 3 second animation
      });
    }, 30);

    return () => clearInterval(interval);
  }, [onLoadingComplete]);

  return (
    <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-gradient-to-br from-blue-50 via-white to-blue-100 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      {/* Logo/Brand Section */}
      <div className="flex flex-col items-center space-y-8 mb-12">
        <div className="relative">
          <Image
            src={loginimg}
            alt="OralScan Logo"
            width={120}
            height={120}
            className="rounded-2xl shadow-2xl animate-pulse"
            priority
          />
          <div className="absolute -inset-4 bg-gradient-to-r from-blue-400 to-blue-600 rounded-3xl blur-lg opacity-30 animate-pulse"></div>
        </div>

        <div className="text-center space-y-2">
          <h1 className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-blue-600 to-blue-800 dark:from-blue-400 dark:to-blue-600 bg-clip-text text-transparent">
            OralScan
          </h1>
          <p className="text-lg text-gray-600 dark:text-gray-300 font-medium">
            AI-Powered Oral Health
          </p>
        </div>
      </div>

      {/* Loading Animation */}
      <div className="flex flex-col items-center space-y-6">
        <div className="relative w-64 h-2 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
          <div
            className="absolute left-0 top-0 h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full transition-all duration-300 ease-out"
            style={{ width: `${progress}%` }}
          ></div>
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-shimmer"></div>
        </div>

        <div className="flex items-center space-x-2">
          <div className="loading-dots flex space-x-1">
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
            <div className="w-2 h-2 bg-blue-500 rounded-full animate-bounce"></div>
          </div>
          <span className="text-sm text-gray-600 dark:text-gray-300 font-medium">
            Loading... {progress}%
          </span>
        </div>
      </div>

      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute inset-0 loading-pattern"></div>
      </div>
    </div>
  );
}