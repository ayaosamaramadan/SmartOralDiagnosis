"use client";
import Link from "next/link";
import { IoHome, IoPerson, IoHelpCircle, IoMedkit } from "react-icons/io5";

const Nav = () => {
  return (
    <>
      <header className="rounded-br-4xl rounded-tr-4xl fixed pt-15 bg-[#00000083] opacity-90 w-auto hover:w-[250px] duration-300 ease-in-out z-10 sm:w-[80px] sm:hover:w-[250px]">
        <div>
          <ul>
            <li>
              <div className="z-50 ml-1 p-5 flex-col items-center">
                <Link href="/">
                  <IoHome className="z-50 cursor-pointer text-white mb-10 mt-[-10px] text-2xl transition-all duration-300 hover:text-yellow-400 hover:scale-125 hover:rotate-6" />
                </Link>
                <Link href="/diagnosis">
                  <IoMedkit className="z-50 cursor-pointer text-white mb-10 text-2xl transition-all duration-300 hover:text-green-400 hover:scale-125 hover:rotate-6" />
                </Link>

                <Link href="/profile">
                  <IoPerson className="z-50 cursor-pointer text-white mb-10 text-2xl transition-all duration-300 hover:text-yellow-400 hover:scale-125 hover:rotate-3" />
                </Link>
                <Link href="/help">
                  <IoHelpCircle className="z-50 cursor-pointer text-white mb-10 text-2xl transition-all duration-300 hover:text-yellow-400 hover:scale-125 hover:-rotate-3" />
                </Link>
              </div>
            </li>
            <li>
              <ul className="flex flex-col justify-center items-center absolute top-5 left-0 w-full h-full text-white opacity-0 hover:opacity-100 transition-opacity duration-300 bg-opacity-50">
                <Link href="/">
                  <li className="cursor-pointer mb-10 mt-[-19px] transition-all duration-300 hover:text-yellow-400 hover:scale-110 hover:translate-x-2">
                    Home
                  </li>
                </Link>
                <Link href="/diagnosis">
                  <li className="cursor-pointer mb-10 transition-all duration-300 hover:text-yellow-400 hover:scale-110 hover:translate-x-2">
                    Diagnosis
                  </li>
                </Link>

                <Link href="/profile">
                  <li className="cursor-pointer mb-10 transition-all duration-300 hover:text-yellow-400 hover:scale-110 hover:translate-x-2">
                    Profile
                  </li>
                </Link>
                <Link href="/help">
                  <li className="cursor-pointer transition-all duration-300 hover:text-yellow-400 hover:scale-110 hover:translate-x-2">
                    Help
                  </li>
                </Link>
              </ul>
            </li>
          </ul>
        </div>
      </header>
    </>
  );
};

export default Nav;
