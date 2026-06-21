"use client";
import { useState, useEffect, useRef } from "react";

interface LoadingScreenProps {
  onLoadingComplete: () => void;
}

export default function LoadingScreen({ onLoadingComplete }: LoadingScreenProps) {
  const [progress, setProgress] = useState(0);
  const [videoEnded, setVideoEnded] = useState(false);
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const mountedAt = useRef<number | null>(null);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval);
          return 100;
        }
        return prev + 5;
      });
    }, 30);

    return () => clearInterval(interval);
  }, []);

 
  useEffect(() => {
    mountedAt.current = Date.now();
  }, []);

  useEffect(() => {
    if (videoEnded) {
      const minMs = 5000; 
      const now = Date.now();
      const start = mountedAt.current ?? now;
      const elapsed = now - start;
      const remaining = Math.max(0, minMs - elapsed);
      const t = setTimeout(() => onLoadingComplete(), remaining);
      return () => clearTimeout(t);
    }
  }, [videoEnded, onLoadingComplete]);

  return (
      <div className="fixed inset-0 z-50 flex flex-col items-center justify-center bg-[#000000]">
        <div className="relative flex items-center justify-center"></div>
    <div className="w-40 h-40 md:w-56 md:h-56 lg:w-96 lg:h-96">
      <video
        ref={videoRef}
        autoPlay
        muted
        playsInline
        onEnded={() => setVideoEnded(true)}
        className="w-full h-full"
        aria-hidden="true"
      >
        <source src="/assets/logo/Oracle.mp4" type="video/mp4" />
      </video>
    </div>
      </div>
  );
}