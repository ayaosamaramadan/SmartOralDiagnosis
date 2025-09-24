"use client";

import { useState, useRef, useCallback } from "react";
import { Camera } from "lucide-react";
import toast from "react-hot-toast";

interface CameraCaptureProps {
  onImageCapture: (imageData: string) => void;
}

export default function CameraCapture({ onImageCapture }: CameraCaptureProps) {
  const [useCamera, setUseCamera] = useState(false);
  const [stream, setStream] = useState<MediaStream | null>(null);
  
  const videoRef = useRef<HTMLVideoElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Start camera
  const startCamera = useCallback(async () => {
    try {
      const mediaStream = await navigator.mediaDevices.getUserMedia({ 
        video: { facingMode: "environment" } 
      });
      setStream(mediaStream);
      if (videoRef.current) {
        videoRef.current.srcObject = mediaStream;
      }
      setUseCamera(true);
    } catch (error) {
      console.error("Error accessing camera:", error);
      toast.error("Could not access camera. Please upload an image instead.");
    }
  }, []);

  // Stop camera
  const stopCamera = useCallback(() => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    setUseCamera(false);
  }, [stream]);

  // Capture photo from camera
  const capturePhoto = useCallback(() => {
    if (videoRef.current && canvasRef.current) {
      const video = videoRef.current;
      const canvas = canvasRef.current;
      const context = canvas.getContext("2d");
      
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      
      context?.drawImage(video, 0, 0);
      const imageData = canvas.toDataURL("image/jpeg", 0.8);
      onImageCapture(imageData);
      stopCamera();
    }
  }, [stopCamera, onImageCapture]);

  if (useCamera) {
    return (
      <div className="bg-gray-900 rounded-lg p-6 text-center">
        <div className="relative inline-block">
          <video
            ref={videoRef}
            autoPlay
            playsInline
            className="max-w-full h-auto rounded-lg"
          />
          <div className="absolute inset-0 border-4 border-blue-400 rounded-lg pointer-events-none"></div>
        </div>
        <div className="mt-4 space-x-4">
          <button
            onClick={capturePhoto}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Capture Photo
          </button>
          <button
            onClick={stopCamera}
            className="px-6 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
          >
            Cancel
          </button>
        </div>
        <canvas ref={canvasRef} className="hidden" />
      </div>
    );
  }

  return (
    <div className="bg-gray-900 rounded-lg border-2 border-dashed border-gray-600 p-8 text-center hover:border-blue-400 transition-colors">
      <Camera className="mx-auto h-12 w-12 text-gray-400 mb-4" />
      <h3 className="text-lg font-medium text-white mb-2">Take Photo</h3>
      <p className="text-gray-400 mb-4">Use your camera to capture an image</p>
      <button
        onClick={startCamera}
        className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
      >
        Start Camera
      </button>
    </div>
  );
}