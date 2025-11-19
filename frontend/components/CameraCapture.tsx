"use client";
import { useRef, useState, useEffect } from "react";
import Webcam from "react-webcam";
import { Camera } from "lucide-react";

interface CameraCaptureProps {
  onImageCapture: (imageData: string) => void;
}

export default function CameraCapture({ onImageCapture }: CameraCaptureProps) {
  const webcamRef = useRef<Webcam | null>(null);
  const [active, setActive] = useState(false);

  const start = () => setActive(true);

 const stop = () => {
    try {
      const inst: any = webcamRef.current;
      const stream: MediaStream | null = inst?.stream || inst?.video?.srcObject || null;
      if (stream && typeof stream.getTracks === "function") {
        stream.getTracks().forEach(t => t.stop());
      }
    } catch (err) {
    
    }
    setActive(false);
  };

  const capture = () => {
    try {
      const inst: any = webcamRef.current;
      const imageSrc = inst?.getScreenshot?.();
      if (imageSrc) onImageCapture(imageSrc);
    } catch (err) {
      console.error("capture error", err);
    }
    stop();
  };

  useEffect(() => {
    return () => {
      try {
        const inst: any = webcamRef.current;
        const stream: MediaStream | null = inst?.stream || inst?.video?.srcObject || null;
        if (stream && typeof stream.getTracks === "function") stream.getTracks().forEach(t => t.stop());
      } catch { 
        
      }
    };
  }, []);

  return (
    <div>
      {active ? (
        <div className="bg-gray-50 dark:bg-gray-900 rounded-lg p-6 text-center">
          <Webcam
            audio={false}
            ref={webcamRef}
            screenshotFormat="image/jpeg"
            videoConstraints={{ facingMode: "environment" }}
            className="max-w-full h-auto rounded-lg"
          />
          <div className="mt-4 space-x-4">
            <button onClick={capture} className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Capture Photo</button>
            <button onClick={stop} className="px-6 py-2 bg-gray-200 dark:bg-gray-600 rounded-lg">Stop</button>
          </div>
        </div>
      ) : (
        <div className="bg-gray-50 dark:bg-gray-900 rounded-lg border-2 border-dashed border-gray-300 dark:border-gray-600 p-8 text-center hover:border-blue-400 transition-colors">
          <Camera className="mx-auto h-12 w-12 text-gray-500 dark:text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">Take Photo</h3>
          <p className="text-gray-600 dark:text-gray-400 mb-4">Use your camera to capture an image</p>
          <button onClick={start} className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Start Camera</button>
        </div>
      )}
    </div>
  );
}
    
    