
import Link from "next/link";
import { IoChatbubbleEllipses } from "react-icons/io5";

const Chatbot = () => {
    return (<> <Link href="/chat">
    <button
        className="fixed bottom-6 right-6 z-50 bg-blue-600 text-white rounded-full p-4 shadow-lg hover:bg-blue-700 transition group"
        aria-label="Fixed Action Button"
    >
        <IoChatbubbleEllipses />
        <span className="absolute right-full mr-2 bottom-1/2 translate-y-1/2 bg-gray-800 text-white text-xs rounded px-2 py-1 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none whitespace-nowrap">
            Ask Chat
        </span>
    </button>
    </Link>
  </>);
}

export default Chatbot;