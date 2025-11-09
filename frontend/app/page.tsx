"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
// import Link from "next/link";
import Image from "next/image";
import HomePic from "../assets/home.jpg";
import Link from "next/link";
import { VscArrowRight } from "react-icons/vsc";
import { IoMailOutline } from "react-icons/io5";
import { CgArrowLongRight } from "react-icons/cg";
import { IoMdCall } from "react-icons/io";
import { FaLocationDot } from "react-icons/fa6";




export default function Home() {
  const router = useRouter();
  const [selectedRole, setSelectedRole] = useState("");

  const handleRoleSelection = (role: string) => {
    setSelectedRole(role);
    router.push(`/auth/login?role=${role}`);
  };

  return (
    <>
      <div className="dark:doodlebg mt-6 bg-slate-50 dark:bg-black text-gray-900 dark:text-gray-100 transition-colors duration-300">
        <section className="flex flex-col md:flex-row mx-auto items-center px-8 md:px-32 py-12 md:py-16 gap-12 md:gap-48">
          <div className="flex-1 space-y-6">
        <h2 className="text-3xl md:text-5xl font-bold">
          <span className="text-indigo-700 dark:text-blue-400">Scan your mouth</span> with AI to detect
          <span className="text-teal-600 dark:text-blue-600"> oral and dental diseases</span>
        </h2>
        <p className="text-gray-800 dark:text-gray-300 max-w-xl">
          Use our smart tool to analyze mouth and dental images and detect early signs of oral problems quickly and accurately. Keep your mouth healthy and your smile bright with ease.
        </p>
        <div className="flex items-center gap-4">
          <Link href="/scan">
        <button
          className="px-7 py-2 rounded-3xl font-semibold bg-gradient-to-r from-indigo-500 via-indigo-600 to-indigo-700 text-white transition-all duration-200 shadow-lg hover:scale-105 hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-400 dark:from-blue-500 dark:via-blue-600 dark:to-blue-400"
          aria-label="Start Scan Now"
          type="button"
        >
          Start Scan Now
        </button>
          </Link>
          <span>
        <VscArrowRight className="text-indigo-600 dark:text-blue-400 text-3xl md:text-4xl transition-colors duration-200" />
          </span>
        </div>
          </div>

          <div className="flex-1 flex justify-center mt-8 md:mt-0">
        <div className="relative w-[320px] md:w-[400px] h-[320px] md:h-[400px] bg-slate-50 rounded-[20%] rounded-bl-[60%] shadow-lg overflow-hidden">
          <Image
        src={HomePic}
        alt="AI-powered oral and dental scan"
        fill
        className="object-cover"
        sizes="(max-width: 768px) 300px, 400px"
        priority
          />
        </div>
          </div>
        </section>

        <section className="flex flex-col md:flex-row justify-center items-center gap-6 md:gap-10 px-6 md:px-10 py-8 md:py-10 rounded-full max-w-5xl mx-auto
          bg-slate-50 dark:bg-gradient-to-l dark:from-[rgb(31,31,31)] dark:via-[rgb(49,49,49)] dark:to-[rgb(31,31,31)] shadow-sm">
          <div className="text-start flex items-start">
        <span className="text-4xl md:text-5xl text-indigo-600 dark:text-blue-400 px-3">
          <IoMailOutline />
        </span>
        <div>
          <h3 className="text-lg md:text-xl font-semibold text-gray-900 dark:text-gray-100">Send Us a Message</h3>
          <p className="text-gray-700 dark:text-gray-300 text-sm mt-1">
        Start a conversation with our team for support.
          </p>
        </div>
          </div>

          <div className="text-start flex items-start">
        <span className="text-4xl md:text-5xl text-indigo-600 dark:text-blue-400 px-3">
          <IoMdCall />
        </span>
        <div>
          <h3 className="text-lg md:text-xl font-semibold text-gray-900 dark:text-gray-100">Schedule a Call</h3>
          <p className="text-gray-700 dark:text-gray-300 text-sm mt-1">
        Book a time with our team for a personal consultation.
          </p>
        </div>
          </div>

          <div className="text-start flex items-start">
        <span className="text-4xl md:text-5xl text-indigo-600 dark:text-blue-400 px-3">
          <FaLocationDot />
        </span>
        <div>
          <h3 className="text-lg md:text-xl font-semibold text-gray-900 dark:text-gray-100">Visit Our Office</h3>
          <p className="text-gray-700 dark:text-gray-400 text-sm mt-1">
        Visit our office for in-person assistance.
          </p>
        </div>
          </div>
        </section>

        <section className="px-6 md:px-10 py-10 md:py-16 flex flex-col md:flex-row items-start md:items-center gap-6 md:gap-12 max-w-6xl mx-auto">
          <div className="flex-1">
        <h2 className="text-2xl md:text-3xl font-bold mb-2 text-gray-900 dark:text-gray-100">TALK TO A DOCTOR NOW</h2>
        <p className="text-lg font-semibold mb-4 text-gray-800 dark:text-gray-300">Get instant medical advice</p>
        <div className="flex items-center mt-2 text-indigo-600 dark:text-blue-400 text-4xl md:text-5xl">
          <CgArrowLongRight />
        </div>
          </div>

          <p className="flex-1 text-gray-800 dark:text-gray-300 max-w-3xl p-4 md:p-10">
        Our platform ensures you get fast, reliable answers to your questions, helping you make informed decisions about your well-being.
        Enjoy peace of mind with instant access to professional medical support, anytime you need it.
          </p>
        </section>

        <section className="px-6 md:px-10 py-10 md:py-16">
          <h2 className="text-2xl md:text-3xl font-bold text-center mb-8 text-gray-900 dark:text-gray-100">Write a Review</h2>
          <form className="max-w-2xl mx-auto space-y-4">
        <div className="flex gap-4">
          <input type="text" placeholder="First Name" className="w-1/2 p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500" />
          <input type="text" placeholder="Last Name" className="w-1/2 p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500" />
        </div>
        <div className="flex gap-4">
          <input type="email" placeholder="Email" className="w-1/2 p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500" />
          <input type="text" placeholder="Phone Number" className="w-1/2 p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500" />
        </div>
        <input type="text" placeholder="Subject" className="w-full p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500" />
        <textarea placeholder="Tell us something..." rows={4} className="w-full p-3 rounded border border-gray-300 dark:border-gray-700 bg-slate-50 dark:bg-gray-800 text-gray-900 placeholder-gray-500"></textarea>
        <button className="px-6 py-3 bg-indigo-600 hover:bg-indigo-700 dark:bg-blue-600 dark:hover:bg-blue-700 rounded-lg w-full text-white transition-colors duration-150">Send</button>
          </form>
        </section>
      </div>
    </>
  );
}
