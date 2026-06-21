"use client";
import React, { useEffect, useState, useRef } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { API_BASE_URL, doctorService, patientService } from "../../services/api";
import Link from "next/link";
import Loading from "@/auth/loading";

type Chat = {
  id: string;
  patientId: string;
  doctorId: string;
  lastMessageAt?: string | null;
};

type Message = {
  id: string;
  chatId: string;
  senderId: string;
  senderRole: string | number;
  content: string;
  createdAt: string;
};

const getAuthHeaders = (contentType: string | null = "application/json") => {
  const token = typeof window !== "undefined" ? localStorage.getItem("token") : null;
  return {
    ...(contentType ? { "Content-Type": contentType } : {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  } as Record<string, string>;
};

export default function ChatWithDocPage() {
  const { user, loading } = useAuth();
  const [chats, setChats] = useState<Chat[]>([]);
  const [selectedChatId, setSelectedChatId] = useState<string | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [loadingChats, setLoadingChats] = useState(true);
  const [loadingMessages, setLoadingMessages] = useState(false);
  const [text, setText] = useState("");
  const [counterparts, setCounterparts] = useState<Record<string, string>>({});
  const scroller = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    if (loading) return;
    if (!user) return;

    let cancelled = false;
    const load = async () => {
      setLoadingChats(true);
      try {
        const res = await fetch(`${API_BASE_URL}/medical-chats`, { headers: getAuthHeaders() });
        const list = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
        if (cancelled) return;
        setChats(list || []);

        // load counterpart names (doctor or patient)
        const map: Record<string, string> = {};
        await Promise.all((list || []).map(async (c: Chat) => {
          try {
            if ((user as any).role === "patient") {
              const d = await doctorService.getById(c.doctorId);
              map[c.id] = d ? `${d.firstName ?? ""} ${d.lastName ?? ""}`.trim() || "Doctor" : "Doctor";
            } else {
              const p = await patientService.getById(c.patientId);
              map[c.id] = p ? `${p.firstName ?? ""} ${p.lastName ?? ""}`.trim() || "Patient" : "Patient";
            }
          } catch {
            map[c.id] = "Contact";
          }
        }));
        if (!cancelled) setCounterparts(map);

        if ((list || []).length > 0) {
          setSelectedChatId((prev) => prev ?? list[0].id);
        }
      } catch (ex: any) {
        console.error(ex);
         } finally {
        if (!cancelled) setLoadingChats(false);
      }
    };

    load();
    return () => { cancelled = true; };
  }, [user, loading]);

  useEffect(() => {
    if (!selectedChatId) {
      setMessages([]);
      return;
    }

    let cancelled = false;
    const loadMessages = async () => {
      setLoadingMessages(true);
      try {
        const res = await fetch(`${API_BASE_URL}/medical-chats/${selectedChatId}/messages?limit=500`, { headers: getAuthHeaders() });
        const list = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
        if (cancelled) return;
        setMessages(list || []);
        // scroll to bottom
        setTimeout(() => scroller.current?.scrollTo({ top: scroller.current.scrollHeight, behavior: 'smooth' }), 50);
      } catch (ex: any) {
        console.error(ex);
      } finally {
        if (!cancelled) setLoadingMessages(false);
      }
    };
    loadMessages();
    // optionally poll for new messages every 5s
    const iv = setInterval(() => { loadMessages(); }, 5000);
    return () => { cancelled = true; clearInterval(iv); };
  }, [selectedChatId]);

  const sendMessage = async () => {
    if (!selectedChatId) return;
    const content = text.trim();
    if (!content) return;
    try {
      const res = await fetch(`${API_BASE_URL}/medical-chats/${selectedChatId}/messages`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ content })
      });
      const msg = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
      setMessages((m) => [...m, msg]);
      setText("");
      setTimeout(() => scroller.current?.scrollTo({ top: scroller.current.scrollHeight, behavior: 'smooth' }), 50);
    } catch (ex: any) {
      console.error(ex);
    
    }
  };



  return (
    <main className="max-w-6xl mx-auto p-6">
      <div className="bg-white dark:bg-[#0b0b0b] border rounded-lg shadow-sm flex h-[70vh] overflow-hidden">
        {/* left column: chats */}
        <aside className="w-80 border-r overflow-auto">
          <div className="p-4 border-b">
            <div className="text-lg font-semibold">Chats</div>
            <div className="text-sm text-gray-500">{user?.role === 'doctor' ? 'Patients' : 'Doctors'}</div>
          </div>

          {loadingChats && <div className="p-4 mt-40 flex items-center justify-center h-32"><Loading/></div>}

          {!loadingChats && chats.length === 0 && (
            <div className="p-6 text-center">
              <div className="mb-4">No conversations yet.</div>
              <Link href="/find-doctors" className="inline-block px-4 py-2 bg-blue-600 text-white rounded">Chat with doctors</Link>
            </div>
          )}

          <div>
            {chats.map((c) => (
              <button
                key={c.id}
                onClick={() => setSelectedChatId(c.id)}
                className={`w-full text-left p-3 border-b flex items-center gap-3 ${selectedChatId === c.id ? 'bg-gray-100 dark:bg-[#111]' : ''}`}
              >
                <div className="w-10 h-10 rounded-full bg-blue-500 text-white flex items-center justify-center">{(counterparts[c.id]?.charAt(0) || 'C').toUpperCase()}</div>
                <div className="flex-1">
                  <div className="font-medium">{counterparts[c.id] ?? (user?.role === 'doctor' ? c.patientId : c.doctorId)}</div>
                  <div className="flex items-center gap-2 text-sm text-gray-500">
                    <svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4-.8L3 20l1.2-4.2A7.963 7.963 0 013 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                    </svg>
                    <div>{c.lastMessageAt ? new Date(c.lastMessageAt).toLocaleString() : 'No messages'}</div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </aside>

        {/* right column: messages */}
        <section className="flex-1 flex flex-col">
          {!selectedChatId ? (
            <div className="flex-1 flex items-center justify-center">
              <div className="text-center">
                <div className="text-xl font-semibold">Select a conversation</div>
                <div className="text-sm text-gray-500 mt-2">Choose a chat from the left to start messaging.</div>
              </div>
            </div>
          ) : (
            <>
              <div className="p-4 border-b flex items-center justify-between">
                <div className="font-medium">{counterparts[selectedChatId] ?? 'Conversation'}</div>
                <div className="text-sm text-gray-500">{messages.length ? new Date(messages[messages.length-1].createdAt).toLocaleString() : ''}</div>
              </div>

              <div ref={scroller} className="flex-1 p-4 overflow-auto bg-gray-50 dark:bg-[#060606]">
                {loadingMessages && <div className="text-sm text-gray-500">Loading messages...</div>}
                <div className="space-y-3">
                  {messages.map((m) => {
                    const mine = m.senderId === (user as any).id;
                    return (
                      <div key={m.id} className={`flex ${mine ? 'justify-end' : 'justify-start'}`}>
                        <div className={`${mine ? 'bg-blue-600 text-white' : 'bg-white dark:bg-[#111] text-black dark:text-white'} max-w-[70%] p-3 rounded-lg`}>{m.content}
                          <div className="text-xs text-gray-400 mt-2 text-right">{new Date(m.createdAt).toLocaleString()}</div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              <div className="p-4 border-t">
                <div className="flex items-center gap-2">
                  <button type="button" className="p-2 rounded border hover:bg-black/5 dark:hover:bg-white/5" aria-label="Attach file">
                    <svg className="w-5 h-5 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828L19 9.828a4 4 0 10-5.657-5.657L7.05 11.464a6 6 0 108.486 8.486L20 17.485" />
                    </svg>
                  </button>

                  <input value={text} onChange={(e) => setText(e.target.value)} placeholder="Type a message" className="flex-1 p-2 border rounded" />

                  <button onClick={sendMessage} className="p-2 bg-blue-600 text-white rounded flex items-center justify-center" aria-label="Send message">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2z" />
                    </svg>
                  </button>
                </div>
              </div>
            </>
          )}
        </section>
      </div>
    </main>
  );
}
