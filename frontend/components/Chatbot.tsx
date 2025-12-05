"use client";
import { IoChatbubbleEllipses } from "react-icons/io5";
import { FaUserDoctor } from "react-icons/fa6";
import { IoSend } from "react-icons/io5";
import { PiChatCenteredDotsDuotone } from "react-icons/pi";
import { useState } from "react";
import { TfiWrite } from "react-icons/tfi";
import { RiCompassDiscoverFill } from "react-icons/ri";

const Chatbot = () => {
    const [open, setOpen] = useState(false);
    const [showStreamlit, setShowStreamlit] = useState(false);

    return (
        <>
            <button
                onClick={() => {
                    setOpen(true);
                    setShowStreamlit(true);
                }}
                className="fixed bottom-6 right-6 z-50 bg-blue-600 text-white rounded-full p-4 shadow-lg hover:bg-blue-700 transition group"
                aria-label="Open chat overlay"
                style={{ zIndex: 2147483647 }}
            >
                <IoChatbubbleEllipses />
                <span className="absolute right-full mr-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
                    Ask Chat
                </span>
            </button>

            {open && (
                <div style={{ zIndex: 2147483647 }} className="bot-aimate fixed inset-0 z-50 flex items-center justify-end p-6">

                    <aside
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="chatbot-title"
                        className="relative pointer-events-auto w-full sm:max-w-md md:max-w-3xl h-[85vh] max-h-[90vh] bg-white/85 dark:bg-gray-900/95 rounded-2xl shadow-2xl overflow-hidden flex flex-col transition duration-300 ease-out hover:shadow-2xl focus-visible:ring-4 focus-visible:ring-blue-200"
                        onKeyDown={(e) => {
                            if (e.key === "Escape") setOpen(false);
                        }}
                    >
                        <header id="chatbot-title" className="flex items-center justify-between p-3 sm:p-4 border-b border-gray-200 dark:border-gray-800">
                            <h3 className="text-lg font-semibold transition-colors duration-200 hover:text-blue-600">Chat</h3>
                            <div className="flex items-center gap-2">
                                <button
                                    type="button"
                                    className="flex items-center gap-2 px-3 py-1 rounded-md bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transform transition duration-150 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    aria-label="Discover"
                                    title="Discover"
                                >
                                    <RiCompassDiscoverFill className="w-4 h-4 text-gray-700 dark:text-gray-200" />
                                    <span className="text-sm text-gray-700 dark:text-gray-200 hidden sm:inline">Discover</span>
                                </button>

                                <button
                                    type="button"
                                    className="flex items-center gap-2 px-3 py-1 rounded-md bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transform transition duration-150 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    aria-label="New chat"
                                    title="New chat"
                                >
                                    <TfiWrite className="w-4 h-4 text-gray-700 dark:text-gray-200" />
                                    <span className="text-sm text-gray-700 dark:text-gray-200 hidden sm:inline">New Chat</span>
                                </button>



                                <button
                                    onClick={() => setOpen(false)}
                                    aria-label="Close chat"
                                    title="Close chat"
                                    className="px-2 py-0 rounded-full bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-200 border border-gray-200 dark:border-gray-700 transition-transform duration-200 transform focus:outline-none focus:ring-4 focus:ring-red-300 hover:bg-gradient-to-r hover:from-red-500 hover:to-red-700 hover:text-white hover:shadow-[0_10px_30px_rgba(220,38,38,0.18)]"
                                >
                                    ×
                                </button>
                            </div>
                        </header>



                        <div className="overflow-y-auto flex-1 flex flex-col">
                            {showStreamlit && (
                                <div className="w-full h-full rounded-md overflow-hidden" style={{ minHeight: '60vh' }}>
                                    <div className="w-full border-t-4 border-blue-500 h-full rounded-t-md overflow-hidden">
                                        <iframe
                                            src={"http://localhost:8501/?embed=true"}
                                            title="Embedded Streamlit Chat"
                                            className="w-full h-full border-0"
                                            style={{ border: 'none', outline: 'none' }}
                                        />
                                    </div>
                                </div>
                            )}
                        </div>

                    </aside>
                </div>
            )}
        </>
    );
};

export default Chatbot;