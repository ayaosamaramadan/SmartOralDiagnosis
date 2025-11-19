"use client";
import React, { useRef, useState } from "react";
import Webcam from "react-webcam";



const videoConstraints = {
  width: 1280,
  height: 720,
  facingMode: "user"
};

export default function CameraCapture() {
 const webcamRef = useRef<any>(null);
  const [screenshot, setScreenshot] = useState<string | null>(null);

  const capture = React.useCallback(() => {
    const imageSrc = webcamRef.current?.getScreenshot?.();
    if (imageSrc) {
      setScreenshot(imageSrc);
      console.log('Captured image length:', imageSrc.length);
    } else {
      console.warn('Unable to capture image — webcamRef not ready or permission denied');
    }
  }, [webcamRef]);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 12, alignItems: 'center' }}>
      <Webcam
        audio={false}
        height={360}
        ref={webcamRef}
        screenshotFormat="image/jpeg"
        width={640}
        videoConstraints={videoConstraints}
        forceScreenshotSourceSize={true}
      />

      <div style={{ display: 'flex', gap: 8 }}>
        <button onClick={capture} style={{ padding: '8px 12px' }}>Capture photo</button>
        <button onClick={() => setScreenshot(null)} style={{ padding: '8px 12px' }}>Clear</button>
      </div>

      {screenshot && (
        <div style={{ textAlign: 'center' }}>
          <p>Preview</p>
          <img src={screenshot} alt="captured" style={{ maxWidth: 320, borderRadius: 8 }} />
        </div>
      )}
    </div>
  );
}