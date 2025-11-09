"use client"
import React from 'react'
import { useTheme } from "next-themes";
import { CiDark } from "react-icons/ci";


const Button = () => {
    const { systemTheme, theme, setTheme } = useTheme();
    const currentTheme = theme === 'system' ? systemTheme : theme;

    return (

            <button
              title="Toggle Dark Mode"
                onClick={() => theme == "dark"? setTheme('light'): setTheme("dark")}
          
              className="px-4 py-2 rounded-xl border border-gray-500 hover:bg-gray-800 hover:text-white transition-colors duration-200"
            >
              <CiDark className="inline text-blue-400 text-xl" />
            </button>
    )
}

export default Button