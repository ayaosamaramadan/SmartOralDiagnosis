"use client"
import React, { useEffect, useState } from 'react'
import { IoSunnySharp } from "react-icons/io5";
import { useTheme } from "next-themes";
import { CiDark } from "react-icons/ci";

const ThemeToggle = () => {
  const { systemTheme, theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const currentTheme = theme === 'system' ? systemTheme : theme;
  const isDark = currentTheme === 'dark';

    if (!mounted) return null;
    
    if (isDark) {
      return (
        <button
          role="switch"
          aria-checked="true"
          title="Toggle theme"
          onClick={() => setTheme('light')}
          className="relative w-16 h-8 rounded-full p-1 transition-colors duration-300"
        >
          <span className="absolute inset-0 rounded-full transition-colors duration-300 bg-gradient-to-r from-sky-400 to-indigo-500 shadow-sm" />
          <span className="absolute top-1 right-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-md transform transition-all duration-300">
            <IoSunnySharp className="text-indigo-600" />
          </span>
        </button>
      )
    }

    return (
      <button
        role="switch"
        aria-checked="false"
        title="Toggle theme"
        onClick={() => setTheme('dark')}
        className="relative w-16 h-8 rounded-full p-1 transition-colors duration-300"
      >
        <span className="absolute inset-0 rounded-full transition-colors duration-300 bg-gradient-to-r from-sky-400 to-indigo-500 shadow-sm" />
        <span className="absolute top-1 left-1 w-6 h-6 bg-white rounded-full flex items-center justify-center shadow-md transform transition-all duration-300">
          <CiDark className="text-indigo-600" />
        </span>
      </button>
    )

  
}

export default ThemeToggle