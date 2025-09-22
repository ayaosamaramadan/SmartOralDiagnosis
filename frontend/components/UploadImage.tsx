"use client";

import { useRef, useCallback } from "react";
import { Upload } from "lucide-react";

interface UploadImageProps {
  onImageCapture: (imageData: string) => void;
}

export default function UploadImage({ onImageCapture }: UploadImageProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Handle file upload
  const handleFileUpload = useCallback((event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = (e) => {
        onImageCapture(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  }, [onImageCapture]);

  // Drag and drop handlers
  const handleDragOver = useCallback((e: React.DragEvent) => {
    e.preventDefault();
  }, []);

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault();
    const files = e.dataTransfer.files;
    if (files[0] && files[0].type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = (event) => {
        onImageCapture(event.target?.result as string);
      };
      reader.readAsDataURL(files[0]);
    }
  }, [onImageCapture]);

  return (
    <div 
      className="bg-gray-900 rounded-lg border-2 border-dashed border-gray-600 p-8 text-center hover:border-blue-400 transition-colors cursor-pointer"
      onDragOver={handleDragOver}
      onDrop={handleDrop}
      onClick={() => fileInputRef.current?.click()}
    >
      <Upload className="mx-auto h-12 w-12 text-gray-400 mb-4" />
      <h3 className="text-lg font-medium text-white mb-2">Upload Image</h3>
      <p className="text-gray-400 mb-4">Drag and drop or click to select</p>
      <input
        title="Upload Image"
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileUpload}
        className="hidden"
      />
      <button className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors">
        Choose File
      </button>
    </div>
  );
}