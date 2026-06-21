import Image from "next/image";
import {Oralsdata} from "../../data/Data";
import Link from "next/link";
export default function Alldiseases() {
  return (
    <>
    <div className="mt-8 bg-gradient-to-b from-white to-gray-50 dark:from-gray-900 dark:to-gray-950 py-12">
      <div className="max-w-5xl mx-auto px-6 py-8 flex flex-col items-center">
      <h1 className="text-5xl sm:text-6xl font-extrabold text-center mb-6 bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-indigo-400 tracking-tight drop-shadow-lg">
      Diseases & Conditions
      </h1>
      <p className="text-lg sm:text-xl text-center mb-10 text-gray-700 dark:text-gray-400 leading-relaxed max-w-2xl">
      Easy-to-understand answers about diseases and conditions.
      </p>
      <div className="flex flex-col gap-8 w-full">
      {Oralsdata.map((oral) => (
        <Link key={oral.id} href={`/alldiseases/${oral.id}`} className="group" aria-label={oral.title}>
        <div className="transition-transform duration-300 transform will-change-transform overflow-hidden flex flex-col md:flex-row items-stretch cursor-pointer hover:shadow-xl hover:-translate-y-1 focus-within:ring-2 focus-within:ring-blue-400 rounded-2xl border border-gray-200 dark:border-transparent bg-gradient-to-r from-white/80 to-white/60 dark:from-gray-800/60 dark:to-gray-800/40 backdrop-blur-sm">
          <Image
          src={oral.img && oral.img.length > 0 ? oral.img[0] : "/placeholder.svg"}
          width={220}
          height={160}
          alt={oral.title}
          className="object-cover w-full md:w-56 h-56 md:h-40 transition-transform duration-300 group-hover:scale-105"
          priority={oral.id <= 2}
          />
          <div className="p-6 md:p-8 flex-1 flex flex-col justify-between">
          <h2 className="text-2xl sm:text-3xl font-semibold text-gray-900 dark:text-white mb-2 transition-colors duration-300 group-hover:text-blue-700 dark:group-hover:text-blue-200">
            {oral.title}
          </h2>
          <p className="text-gray-700 dark:text-gray-200 flex-1 transition-colors duration-300 group-hover:text-gray-800 dark:group-hover:text-gray-300 leading-relaxed">
            {oral.description}
          </p>
          </div>
        </div>
        </Link>
      ))}
      </div>
    </div></div></>
  );
}
