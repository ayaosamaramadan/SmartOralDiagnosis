"use client";
import { useState, useEffect } from "react";

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
          setTimeout(onLoadingComplete, 500); 
          return 100;
        }
        return prev + 2; 
      });
    }, 30);

    return () => clearInterval(interval);
  }, [onLoadingComplete]);

  return (
      <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-[#0656b3]">
        <div className="relative flex items-center justify-center"></div>
    <div className="w-40 h-40 md:w-56 md:h-56 lg:w-96 lg:h-96">
      <video
        autoPlay
        muted
        loop
        playsInline
        className="w-full h-full"
        aria-hidden="true"
      >
        <source src="/assets/logo/Oracle.mp4" type="video/mp4" />
      </video>
    </div>
      </div>
  );
}