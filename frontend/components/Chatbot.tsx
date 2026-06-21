"use client";
import { IoChatbubbleEllipses } from "react-icons/io5";
import { TfiWrite } from "react-icons/tfi";
import { useEffect, useRef, useState } from "react";

const CHATBOT_URL = "https://web-production-3a6039.up.railway.app";

const Chatbot = () => {
    const [open, setOpen] = useState(false);
    const [loading, setLoading] = useState(true);
    const [reloadKey, setReloadKey] = useState(0);

    const iframeRef = useRef<HTMLIFrameElement | null>(null);

    useEffect(() => {
        if (open) {
            setLoading(true);
        }
    }, [open, reloadKey]);

    const handleNewChat = () => {
        setLoading(true);
        setReloadKey((k) => k + 1);
    };

    return (
        <>
            {!open && (
                <button
                    onClick={() => {
                        setOpen(true);
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
            )}

            {open && (
                <div style={{ zIndex: 2147483647 }} className="bot-aimate fixed inset-0 z-50 flex items-center justify-end p-3 sm:p-6">
                    <button
                        type="button"
                        aria-label="Close chat overlay"
                        className="absolute inset-0 bg-black/25 backdrop-blur-[1px]"
                        onClick={() => setOpen(false)}
                    />

                    <aside
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="chatbot-title"
                        className="relative pointer-events-auto w-full sm:max-w-md md:max-w-3xl h-[85vh] max-h-[90vh] bg-white/90 dark:bg-gray-900/95 rounded-2xl shadow-2xl overflow-hidden flex flex-col transition duration-300 ease-out hover:shadow-2xl focus-visible:ring-4 focus-visible:ring-blue-200"
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
                                    aria-label="New chat"
                                    title="New chat"
                                    onClick={handleNewChat}
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

                        <div className="relative flex-1 bg-white dark:bg-gray-900">
                            {loading && (
                                <div className="absolute inset-0 z-10 flex items-center justify-center bg-white dark:bg-gray-900">
                                    <div className="flex flex-col items-center gap-3 text-gray-500 dark:text-gray-400">
                                        <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
                                        <span className="text-sm">Loading chat...</span>
                                    </div>
                                </div>
                            )}
                            <iframe
                                key={reloadKey}
                                ref={iframeRef}
                                src={CHATBOT_URL}
                                title="Oral Health Assistant"
                                className="w-full h-full border-0"
                                onLoad={() => setLoading(false)}
                                allow="clipboard-write"
                            />
                        </div>
                    </aside>
                </div>
            )}
        </>
    );
};

export default Chatbot;
