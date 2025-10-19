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

    return (
        <>
            <button
                onClick={() => setOpen((s) => !s)}
                className="fixed bottom-6 right-6 z-50 bg-blue-600 text-white rounded-full p-4 shadow-lg hover:bg-blue-700 transition group"
                aria-label="Open chat overlay"
            >
                <IoChatbubbleEllipses />
                <span className="absolute right-full mr-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
                    Ask Chat
                </span>
            </button>

            {open && (
                <div className="bot-aimate fixed w-[45%] z-50 flex items-end justify-end p-6 ">
                 
                    <div
                        className="absolute inset-0 bg-[rgb(0 0 0 / 0.4)] "
                        onClick={() => setOpen(false)}
                        aria-hidden="true"
                    />

                    <aside
                        role="dialog"
                        aria-modal="true"
                        aria-labelledby="chatbot-title"
                        className="relative pointer-events-auto w-full max-w-3xl h-[90vh] max-h-[90vh] bg-white/95 dark:bg-gray-900/95 rounded-2xl shadow-2xl overflow-hidden flex flex-col transition duration-300 ease-out hover:shadow-2xl focus-visible:ring-4 focus-visible:ring-blue-200"
                        onKeyDown={(e) => {
                            if (e.key === "Escape") setOpen(false);
                        }}
                    >
                        <header id="chatbot-title" className="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-800">
                            <h3 className="text-lg font-semibold transition-colors duration-200 hover:text-blue-600">Chat</h3>
                            <div className="flex items-center gap-2">
                                <button
                                    type="button"
                                    className="flex items-center gap-2 px-3 py-1 rounded-md bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transform transition duration-150 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    aria-label="Discover"
                                    title="Discover"
                                >
                                    <RiCompassDiscoverFill className="w-4 h-4 text-gray-700 dark:text-gray-200" />
                                    <span className="text-sm text-gray-700 dark:text-gray-200">Discover</span>
                                </button>

                                <button
                                    type="button"
                                    className="flex items-center gap-2 px-3 py-1 rounded-md bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transform transition duration-150 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    aria-label="New chat"
                                    title="New chat"
                                >
                                    <TfiWrite className="w-4 h-4 text-gray-700 dark:text-gray-200" />
                                    <span className="text-sm text-gray-700 dark:text-gray-200">New Chat</span>
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

                        <div className="backdrop-blur-sm p-8 overflow-y-auto flex-1 flex items-center justify-center flex-col text-center space-y-4 group" role="document">
                            <PiChatCenteredDotsDuotone className="w-20 h-20 text-gray-400 transition-transform duration-300 group-hover:scale-110 group-hover:text-blue-500" />
                            <h2 className="text-2xl md:text-2xl font-semibold text-gray-800 dark:text-gray-100 transition-all duration-200 group-hover:tracking-wide">Chat with Medical Assistant</h2>
                            <p className="text-md md:text-md text-gray-700 dark:text-gray-300 max-w-2xl transition-colors duration-200 group-hover:text-gray-900 dark:group-hover:text-gray-100">
                                Immediate and reliable medical answers — clear, concise, and trustworthy.
                            </p>
                            <p className="text-base md:text-md text-gray-600 dark:text-gray-300 max-w-2xl transition-colors duration-200 group-hover:text-gray-800 dark:group-hover:text-gray-200">
                                Hey! Curious about something medical? Let’s dive in
                            </p>
                        </div>

                        <form
                            className="p-4 border-t border-gray-200 dark:border-gray-800"
                            onSubmit={(e) => {
                                e.preventDefault();
                                    }}
                        >
                            <div className="flex gap-2 items-end">
                                 <div className="flex-1 rounded-md border border-gray-200 dark:border-gray-800 px-3 py-2 bg-white dark:bg-gray-900 text-sm flex items-center gap-3 transition-shadow duration-200 hover:shadow-md">
                                 
                                <input
                                    name="message"
                                    aria-label="Message"
                                    autoFocus
                                    className="flex-1 rounded-md bg-transparent text-sm placeholder:text-gray-400 dark:placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all duration-150 px-2 py-1"
                                    placeholder="Write your message here..."
                                />
                             
                                    <button
                                        type="button"
                                        className="ml-2 mt-0 flex-none flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded-md hover:scale-105 transform transition duration-150 hover:bg-gradient-to-r hover:from-blue-500 hover:to-blue-900 hover:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
                                        aria-label="Talk to doctor"
                                        title="Talk to doctor"
                                     
                                    >
                                        <FaUserDoctor className="w-4 h-4" />
                                        <span>Talk to Doctor</span>
                                    </button>

                                  
                                </div>
                                <button
                                    type="submit"
                                    aria-label="Send message"
                                    className="w-12 h-12 mt-0 flex items-center justify-center rounded-full bg-gradient-to-r from-blue-950 via-blue-600 to-blue-400 text-white hover:scale-110 transform transition duration-150 shadow hover:shadow-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                >
                                    <IoSend className="w-5 h-5" />
                                </button>
                            </div>
                        </form>
                    </aside>
                </div>
            )}
        </>
    );
};

export default Chatbot;