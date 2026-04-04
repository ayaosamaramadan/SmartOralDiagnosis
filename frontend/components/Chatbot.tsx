"use client";
import { IoChatbubbleEllipses } from "react-icons/io5";
import { FormEvent, useEffect, useMemo, useRef, useState } from "react";
import { TfiWrite } from "react-icons/tfi";
import { RiCompassDiscoverFill } from "react-icons/ri";

type Role = "user" | "assistant";

type UiMessage = {
    id: string;
    role: Role;
    content: string;
};

const DISCOVERY_PROMPTS = [
    "What are early signs of gum disease?",
    "How can I reduce tooth sensitivity at home?",
    "When is a toothache considered urgent?",
];

const STARTER_MESSAGE: UiMessage = {
    id: "starter",
    role: "assistant",
    content: "Hi, I am your oral-health assistant. Describe your symptoms and I will help with guidance.",
};

const Chatbot = () => {
    const [open, setOpen] = useState(false);
    const [messages, setMessages] = useState<UiMessage[]>([STARTER_MESSAGE]);
    const [input, setInput] = useState("");
    const [error, setError] = useState<string | null>(null);
    const [sending, setSending] = useState(false);

    const inputRef = useRef<HTMLInputElement | null>(null);
    const listRef = useRef<HTMLDivElement | null>(null);

    const canSend = useMemo(() => input.trim().length > 0 && !sending, [input, sending]);

    useEffect(() => {
        if (open) {
            inputRef.current?.focus();
        }
    }, [open]);

    useEffect(() => {
        if (listRef.current) {
            listRef.current.scrollTop = listRef.current.scrollHeight;
        }
    }, [messages, sending]);

    const resetChat = () => {
        setMessages([STARTER_MESSAGE]);
        setInput("");
        setError(null);
    };

    const buildPayload = (chat: UiMessage[]) =>
        chat.map((m) => ({
            role: m.role,
            content: m.content,
        }));

    const sendMessage = async (e: FormEvent) => {
        e.preventDefault();
        const content = input.trim();
        if (!content || sending) return;

        const userMessage: UiMessage = {
            id: `${Date.now()}-u`,
            role: "user",
            content,
        };

        const nextMessages = [...messages, userMessage];
        setMessages(nextMessages);
        setInput("");
        setError(null);
        setSending(true);

        try {
            const response = await fetch("/api/chatbot", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ messages: buildPayload(nextMessages) }),
            });

            const rawText = await response.text();
            let data: { message?: string; reply?: string } | null = null;

            if (rawText) {
                try {
                    data = JSON.parse(rawText);
                } catch {
                    const snippet = rawText.slice(0, 120).replace(/\s+/g, " ").trim();
                    if (snippet.startsWith("<!DOCTYPE") || snippet.startsWith("<html")) {
                        throw new Error("Chat API returned HTML instead of JSON. Check that the Next frontend is running and /api/chatbot is reachable.");
                    }
                    throw new Error(`Chat API returned non-JSON response: ${snippet}`);
                }
            }

            if (!response.ok) {
                throw new Error(data?.message || "Failed to get AI response");
            }

            const reply = typeof data?.reply === "string" ? data.reply.trim() : "";
            if (!reply) {
                throw new Error("AI returned an empty response");
            }

            setMessages((prev) => [
                ...prev,
                {
                    id: `${Date.now()}-a`,
                    role: "assistant",
                    content: reply,
                },
            ]);
        } catch (err: any) {
            setError(err?.message || "Something went wrong");
        } finally {
            setSending(false);
        }
    };

    const applyPrompt = (prompt: string) => {
        setInput(prompt);
        setTimeout(() => inputRef.current?.focus(), 0);
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
                                    aria-label="Discover"
                                    title="Discover"
                                    onClick={() => applyPrompt(DISCOVERY_PROMPTS[Math.floor(Math.random() * DISCOVERY_PROMPTS.length)])}
                                >
                                    <RiCompassDiscoverFill className="w-4 h-4 text-gray-700 dark:text-gray-200" />
                                    <span className="text-sm text-gray-700 dark:text-gray-200 hidden sm:inline">Discover</span>
                                </button>

                                <button
                                    type="button"
                                    className="flex items-center gap-2 px-3 py-1 rounded-md bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transform transition duration-150 hover:scale-105 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                    aria-label="New chat"
                                    title="New chat"
                                    onClick={resetChat}
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

                        <div ref={listRef} className="overflow-y-auto flex-1 flex flex-col gap-3 p-3 sm:p-4 bg-gradient-to-b from-white/0 to-blue-50/30 dark:to-gray-800/30">
                            {messages.map((message) => {
                                const isUser = message.role === "user";
                                return (
                                    <div key={message.id} className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
                                        <div
                                            className={`max-w-[86%] px-3 py-2 rounded-2xl text-sm sm:text-[15px] whitespace-pre-wrap ${
                                                isUser
                                                    ? "bg-blue-600 text-white rounded-br-md"
                                                    : "bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-gray-100 rounded-bl-md"
                                            }`}
                                        >
                                            {message.content}
                                        </div>
                                    </div>
                                );
                            })}

                            {sending && (
                                <div className="flex justify-start">
                                    <div className="max-w-[86%] px-3 py-2 rounded-2xl rounded-bl-md bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 text-sm">
                                        Typing...
                                    </div>
                                </div>
                            )}

                            {error && (
                                <div className="text-xs sm:text-sm text-red-600 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-900 px-3 py-2 rounded-lg">
                                    {error}
                                </div>
                            )}
                        </div>

                        <form onSubmit={sendMessage} className="border-t border-gray-200 dark:border-gray-800 p-3 sm:p-4">
                            <div className="flex items-center gap-2">
                                <input
                                    ref={inputRef}
                                    value={input}
                                    onChange={(e) => setInput(e.target.value)}
                                    placeholder="Ask about oral symptoms, care, or prevention..."
                                    className="w-full rounded-xl border border-gray-300 dark:border-gray-700 bg-white dark:bg-gray-900 px-3 py-2 text-sm sm:text-base outline-none focus:ring-2 focus:ring-blue-500"
                                    maxLength={1200}
                                />
                                <button
                                    type="submit"
                                    disabled={!canSend}
                                    className="rounded-xl px-4 py-2 text-sm sm:text-base bg-blue-600 text-white disabled:opacity-50 disabled:cursor-not-allowed hover:bg-blue-700 transition"
                                >
                                    Send
                                </button>
                            </div>
                            <p className="mt-2 text-[11px] sm:text-xs text-gray-500 dark:text-gray-400">
                                This assistant gives general information and does not replace professional medical care.
                            </p>
                        </form>
                    </aside>
                </div>
            )}
        </>
    );
};

export default Chatbot;