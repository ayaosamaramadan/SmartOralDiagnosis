"use client";
import React, { useEffect, useState, useRef } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { API_BASE_URL, patientService } from "../../services/api";
import Link from "next/link";
// import toast from "react-hot-toast";

type Chat = { id: string; patientId: string; doctorId: string; lastMessageAt?: string | null };
type Message = { id: string; chatId: string; senderId: string; senderRole: string | number; content: string; createdAt: string };

const getAuthHeaders = (contentType: string | null = "application/json") => {
  const token = typeof window !== "undefined" ? localStorage.getItem("token") : null;
  return {
    ...(contentType ? { "Content-Type": contentType } : {}),
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  } as Record<string, string>;
};

export default function ChatWithPatPage() {
  const { user, loading } = useAuth();
  const [chats, setChats] = useState<Chat[]>([]);
  const [patients, setPatients] = useState<any[]>([]);
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
    if ((user as any).role !== "doctor") return;

    let cancelled = false;
    const load = async () => {
      setLoadingChats(true);
      try {
        const res = await fetch(`${API_BASE_URL}/medical-chats`, { headers: getAuthHeaders() });
        const list = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
        if (cancelled) return;
        setChats(list || []);

        // load patient names
        const map: Record<string, string> = {};
        await Promise.all((list || []).map(async (c: Chat) => {
          try {
            const p = await patientService.getById(c.patientId);
            map[c.id] = p ? `${p.firstName ?? ""} ${p.lastName ?? ""}`.trim() || "Patient" : "Patient";
          } catch {
            map[c.id] = "Patient";
          }
        }));
        if (!cancelled) setCounterparts(map);

        // fetch patients for starting new conversations/search
        const pats = await patientService.getAll().catch(() => []);
        if (!cancelled) setPatients(pats || []);

        if ((list || []).length > 0) setSelectedChatId((prev) => prev ?? list[0].id);
      } catch (ex: any) {
        console.error(ex);
        // toast.error(ex?.message || "Failed to load chats");
      } finally {
        if (!cancelled) setLoadingChats(false);
      }
    };
    load();
    return () => { cancelled = true; };
  }, [user, loading]);

  useEffect(() => {
    if (!selectedChatId) { setMessages([]); return; }
    let cancelled = false;
    const loadMessages = async () => {
      setLoadingMessages(true);
      try {
        const res = await fetch(`${API_BASE_URL}/medical-chats/${selectedChatId}/messages?limit=500`, { headers: getAuthHeaders() });
        const list = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
        if (cancelled) return;
        setMessages(list || []);
        setTimeout(() => scroller.current?.scrollTo({ top: scroller.current.scrollHeight, behavior: 'smooth' }), 50);
      } catch (ex: any) {
        console.error(ex);
      //  toast.error(ex?.message || "Failed to load messages");
      } finally { if (!cancelled) setLoadingMessages(false); }
    };
    loadMessages();
    const iv = setInterval(loadMessages, 5000);
    return () => { cancelled = true; clearInterval(iv); };
  }, [selectedChatId]);

  const startChatWithPatient = async (patientId: string) => {
    // if (!user) return toast.error('Sign in first');
    try {
      const res = await fetch(`${API_BASE_URL}/medical-chats`, {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({ patientId, doctorId: user?.id })
      });
      const chat = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
      setChats((s) => [chat, ...s]);
      setSelectedChatId(chat.id);
   
    } catch (ex: any) { console.error(ex); }
  };

  const sendMessage = async () => {
    if (!selectedChatId) return; const content = text.trim(); if (!content) return;
    try {
      const res = await fetch(`${API_BASE_URL}/medical-chats/${selectedChatId}/messages`, { method: 'POST', headers: getAuthHeaders(), body: JSON.stringify({ content }) });
      const msg = await (res.ok ? res.json() : Promise.reject(new Error(res.statusText)));
      setMessages((m) => [...m, msg]); setText("");
      setTimeout(() => scroller.current?.scrollTo({ top: scroller.current.scrollHeight, behavior: 'smooth' }), 50);
    } catch (ex: any) { console.error(ex);}
  };

  if (!user) return (<main className="max-w-4xl mx-auto p-6"><div className="p-6 bg-yellow-50 border rounded">Please sign in to use chat.</div></main>);
  if ((user as any).role !== 'doctor') return (<main className="max-w-4xl mx-auto p-6"><div className="p-6 bg-yellow-50 border rounded">This page is for doctors only.</div></main>);

  return (
    <main className="max-w-6xl mx-auto p-6">
      <div className="bg-white dark:bg-[#0b0b0b] border rounded-lg shadow-sm flex h-[70vh] overflow-hidden">
        <aside className="w-80 border-r overflow-auto">
          <div className="p-4 border-b"><div className="text-lg font-semibold">Patients</div><div className="text-sm text-gray-500">Your patient conversations</div></div>

          {loadingChats && <div className="p-4">Loading...</div>}

          {!loadingChats && chats.length === 0 && (
            <div className="p-6 text-center">
              <div className="mb-4">Your chat with patients will show here.</div>
              <div className="text-sm text-gray-600 mb-3">You can start a conversation by selecting a patient below.</div>
              <div className="space-y-2">
                {patients.slice(0,10).map(p => (
                  <div key={p.id} className="flex items-center justify-between p-2 border rounded">
                    <div>{p.firstName} {p.lastName}</div>
                    <button onClick={() => startChatWithPatient(p.id)} className="px-3 py-1 bg-blue-600 text-white rounded">Start Chat</button>
                  </div>
                ))}
              </div>
            </div>
          )}

          <div>
            {chats.map((c) => (
              <button key={c.id} onClick={() => setSelectedChatId(c.id)} className={`w-full text-left p-3 border-b flex items-center gap-3 ${selectedChatId === c.id ? 'bg-gray-100 dark:bg-[#111]' : ''}`}>
                <div className="w-10 h-10 rounded-full bg-blue-500 text-white flex items-center justify-center">{(counterparts[c.id]?.charAt(0) || 'P').toUpperCase()}</div>
                <div className="flex-1">
                  <div className="font-medium">{counterparts[c.id] ?? c.patientId}</div>
                  <div className="text-sm text-gray-500">{c.lastMessageAt ? new Date(c.lastMessageAt).toLocaleString() : 'No messages'}</div>
                </div>
              </button>
            ))}
          </div>
        </aside>

        <section className="flex-1 flex flex-col">
          {!selectedChatId ? (
            <div className="flex-1 flex items-center justify-center"><div className="text-center"><div className="text-xl font-semibold">Your chat with patients will show here</div><div className="text-sm text-gray-500 mt-2">Select a patient on the left to open the conversation.</div></div></div>
          ) : (
            <>
              <div className="p-4 border-b flex items-center justify-between"><div className="font-medium">{counterparts[selectedChatId] ?? 'Conversation'}</div></div>

              <div ref={scroller} className="flex-1 p-4 overflow-auto bg-gray-50 dark:bg-[#060606]">
                <div className="space-y-3">
                  {messages.map(m => {
                    const mine = m.senderId === (user as any).id;
                    return (<div key={m.id} className={`flex ${mine ? 'justify-end' : 'justify-start'}`}><div className={`${mine ? 'bg-blue-600 text-white' : 'bg-white dark:bg-[#111] text-black dark:text-white'} max-w-[70%] p-3 rounded-lg`}>{m.content}<div className="text-xs text-gray-400 mt-2 text-right">{new Date(m.createdAt).toLocaleString()}</div></div></div>);
                  })}
                </div>
              </div>

              <div className="p-4 border-t"><div className="flex items-center gap-2"><input value={text} onChange={(e) => setText(e.target.value)} placeholder="Type a message" className="flex-1 p-2 border rounded" /><button onClick={sendMessage} className="p-2 bg-blue-600 text-white rounded">Send</button></div></div>
            </>
          )}
        </section>
      </div>
    </main>
  );
}
