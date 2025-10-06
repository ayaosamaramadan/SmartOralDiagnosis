import Image from "next/image";
import {Orals} from "../../data/AllOrals";
import Link from "next/link";
export default function Alldiseases() {
  return (
    <div className="max-w-3xl mx-auto px-4 py-8 flex flex-col items-center">
      <h1 className="text-4xl font-bold text-center mb-4 text-blue-700">Diseases & Conditions</h1>
      <p className="text-lg text-center mb-8 text-gray-600">
      Easy-to-understand answers about diseases and conditions.
      </p>
      <div className="flex flex-col gap-8 w-full">


      {Orals.map((oral) => (
        <Link key={oral.id} href={`/alldiseases/${oral.id}`}>
          <div
            className="rounded-xl shadow-md transition-shadow duration-300 overflow-hidden flex flex-col md:flex-row items-center cursor-pointer group
              hover:bg-blue-50 hover:shadow-xl"
          >
            <Image
              src={oral.img[0]}
              width={200}
              height={150}
              alt={oral.title}
              className="object-cover w-full md:w-48 h-48 md:h-auto transition-transform duration-300 group-hover:scale-105"
            />
            <div className="p-4 flex-1 flex flex-col">
              <h2 className="text-2xl font-semibold text-blue-600 mb-2 transition-colors duration-300 group-hover:text-blue-800">
                {oral.title}
              </h2>
              <p className="text-gray-700 flex-1 transition-colors duration-300 group-hover:text-gray-900">
                {oral.description}
              </p>
            </div>
          </div>
        </Link>
      ))}
      </div>
    </div>
  );
}
