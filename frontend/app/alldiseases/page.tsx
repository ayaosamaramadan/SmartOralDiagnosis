import Image from "next/image";
import {Orals} from "../../data/AllOrals";
import Link from "next/link";
export default function Alldiseases() {
  return (
    <>
    <div className="doodlebg mt-6">
      <div className="max-w-3xl mx-auto px-4 py-12 flex flex-col items-center">
      <h1 className="text-5xl font-extrabold text-center mb-8 text-blue-600 tracking-tight drop-shadow">
      Diseases & Conditions
      </h1>
      <p className="text-xl text-center mb-12 text-gray-700 leading-relaxed max-w-2xl">
      Easy-to-understand answers about diseases and conditions.
      </p>
      <div className="flex flex-col gap-10 w-full">
      {Orals.map((oral) => (
        <Link key={oral.id} href={`/alldiseases/${oral.id}`} className="group">
        <div className="transition duration-300 overflow-hidden flex flex-col md:flex-row items-center cursor-pointer hover:shadow-2xl border border-gray-200 rounded-2xl">
          <Image
          src={oral.img && oral.img.length > 0 ? oral.img[0] : "/placeholder.svg"}
          width={220}
          height={160}
          alt={oral.title}
          className="object-cover w-full md:w-56 h-56 md:h-auto transition-transform duration-300 group-hover:scale-105"
          priority={oral.id <= 2}
          />
          <div className="p-8 flex-1 flex flex-col bg-[#9c9c9c5d]">
          <h2 className="text-2xl font-bold text-blue-400 mb-3 transition-colors duration-300 group-hover:text-blue-200">
            {oral.title}
          </h2>
          <p className="text-gray-100 flex-1 transition-colors duration-300 group-hover:text-gray-400 leading-relaxed">
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
