import { GrLanguage } from "react-icons/gr";
import { FaCheck } from "react-icons/fa";
import { useState, useRef, useEffect } from "react";

const Langu = () => {
    const [isOpen, setIsOpen] = useState(false);
    const [selected, setSelected] = useState("en");
    const ref = useRef<HTMLDivElement | null>(null);

    const languages = [
        { code: "en", name: "English", hint: "Default" },
        { code: "ar", name: "العربية", hint: "Arabic" },
        { code: "fr", name: "Français", hint: "French" },
    ];

    useEffect(() => {
        function onClick(e: MouseEvent) {
            if (ref.current && !ref.current.contains(e.target as Node)) {
                setIsOpen(false);
            }
        }
        document.addEventListener("mousedown", onClick);
        return () => document.removeEventListener("mousedown", onClick);
    }, []);

    return (
        <div className="relative inline-block" ref={ref}>
            <button
                type="button"
                aria-haspopup="listbox"
                aria-expanded={isOpen}
                onClick={() => setIsOpen((v) => !v)}
                onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") setIsOpen((v) => !v);
                }}
                className=" inline-flex items-center gap-2 p-2 rounded-md bg-white dark:bg-gray-700 border border-gray-100 dark:border-gray-700 text-gray-700 dark:text-gray-100 hover:shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-300"
                title="Change language"
            >
                <GrLanguage />
            </button>

            {isOpen && (
                <ul
                    role="listbox"
                    aria-label="Language selector"
                    className="mt-2 w-40 bg-white dark:bg-[rgb(49,49,49)] border border-gray-200 dark:border-gray-700 rounded-md shadow-lg p-2 space-y-1 z-50 absolute right-0"
                >
                    {languages.map((lang) => (
                        <li
                            key={lang.code}
                            role="option"
                            aria-selected={selected === lang.code}
                            onClick={() => {
                                setSelected(lang.code);
                                setIsOpen(false);
                            }}
                            className="flex items-center justify-between gap-3 p-2 rounded hover:bg-gray-50 dark:hover:bg-gray-700 cursor-pointer"
                        >
                            <div className="flex items-center gap-3">
             
                                <div>
                                    <div className="text-sm font-medium text-gray-900 dark:text-white">{lang.name}</div>
                                    <div className="text-xs text-gray-500 dark:text-gray-400">{lang.hint}</div>
                                </div>
                            </div>
                            {selected === lang.code ? (
                                <FaCheck className="text-green-600 dark:text-green-400" aria-hidden />
                            ) : null}
                        </li>
                    ))}
                </ul>
            )}
        </div>
    );
};

export default Langu;