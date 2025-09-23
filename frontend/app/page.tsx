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



export default function Home() {
  const router = useRouter();
  const [selectedRole, setSelectedRole] = useState("");

  const handleRoleSelection = (role: string) => {
    setSelectedRole(role);
    router.push(`/auth/login?role=${role}`);
  };

  return (
    <>
      <section className="flex flex-col md:flex-row ml-[100px] items-center px-10 py-16">
        <div className="flex-1 space-y-6">
          <h2 className="text-4xl md:text-5xl font-bold">
            <span className="text-blue-400">Scan your mouth</span> with AI to detect
            <span className="text-blue-600"> oral and dental diseases</span>
          </h2>
          <p className="text-gray-300 max-w-xl">
            Use our smart tool to analyze mouth and dental images and detect early signs of oral problems quickly and accurately. Keep your mouth healthy and your smile bright with ease.
          </p>
          <br />
          <div className="flex items-center gap-4">
            <Link href="/scan">
              <button
                // onClick={() => handleRoleSelection("patient")}
                className="px-7 py-2 rounded-3xl text-black font-semibold bg-gradient-to-r from-blue-500 via-blue-600 to-blue-400 transition-all duration-200 shadow-lg
                  hover:from-blue-700 hover:via-blue-800 hover:to-blue-600
                  hover:scale-105 hover:shadow-xl
                  focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2"
                aria-label="Start Scan Now"
                type="button"
              >
                Start Scan Now
              </button></Link>
            <span>
              <VscArrowRight className="text-blue-400 text-4xl group-hover:text-blue-600 group-hover:scale-125 transition-all duration-200" />
            </span>
          </div>
        </div>
        <div className="flex-1 flex justify-center mt-10 md:mt-0">
          <div className="relative w-[400px] h-[400px]">
            <Image
              src={HomePic}
              alt="AI-powered oral and dental scan"
              fill
              className="object-cover rounded-[20%] rounded-bl-[60%] shadow-lg"
              sizes="(max-width: 768px) 300px, 400px"
              priority
            />
          </div>
        </div>
      </section>

      <section className="flex flex-col bg-gradient-to-l from-[rgb(31,31,31)] via-[rgb(49,49,49)] to-[rgb(31,31,31)] md:flex-row justify-center items-center gap-10 px-10 py-10 rounded-full max-w-5xl mx-auto">
        <div className="text-start flex items-start">
          <span className="text-5xl text-blue-500 px-4">
            <IoMailOutline />
          </span>
          <div>
            <h3 className="text-xl font-semibold">Send Us a Message</h3>
            <p className="text-gray-500 text-sm mt-1">
              Start a conversation withrt.
            </p>
          </div>
        </div> <div className="text-start flex items-start">
          <span className="text-5xl text-blue-500 px-4">
            <IoMailOutline />
          </span>
          <div>
            <h3 className="text-xl font-semibold">Send Us a Message</h3>
            <p className="text-gray-500 text-sm mt-1">
              Start a conversation withrt.
            </p>
          </div>
        </div> <div className="text-start flex items-start">
          <span className="text-5xl text-blue-500 px-4">
            <IoMailOutline />
          </span>
          <div>
            <h3 className="text-xl font-semibold">Send Us a Message</h3>
            <p className="text-gray-500 text-sm mt-1">
              Start a conversation withrt.
            </p>
          </div>
        </div>

      </section>
      <section className="px-10 py-16 flex ml-[100px]">
        <div className="flex flex-col md:flex-row items-center gap-6">
          <div>
        <h2 className="text-2xl font-bold mb-4">TALK TO A DOCTOR NOW</h2>
        <p className="text-lg font-semibold mb-2">Get instant medical advice</p>
          </div>
          <div className="flex items-center mt-12 text-blue-500 text-5xl">
        <CgArrowLongRight />
          </div>
        </div>
        <p className="text-gray-300 max-w-3xl p-10">
        Our platform ensures you get fast, reliable answers to your questions, helping you make informed decisions about your well-being.<br />
          Enjoy peace of mind with instant access to professional medical support, anytime you need it.
        </p>
      </section>

      <section className="px-10 py-16 bg-gray-900">
        <h2 className="text-3xl font-bold text-center mb-10">Our Team</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-8">
          <div className="text-center">
            <Image
              src="https://randomuser.me/api/portraits/men/32.jpg"
              alt="member"
              width={96}
              height={96}
              className="rounded-full mx-auto mb-4 object-cover"
            />
            <h3 className="font-semibold">Hansaka Danuja</h3>
            <p className="text-gray-400 text-sm">SE Team</p>
          </div>
          <div className="text-center">
            <Image
              src="https://randomuser.me/api/portraits/women/65.jpg"
              alt="member"
              width={96}
              height={96}
              className="rounded-full mx-auto mb-4 object-cover"
            />
            <h3 className="font-semibold">Dilma Pulammany</h3>
            <p className="text-gray-400 text-sm">Design Team</p>
          </div>
          <div className="text-center">
            <Image
              src="https://randomuser.me/api/portraits/men/45.jpg"
              alt="member"
              width={96}
              height={96}
              className="rounded-full mx-auto mb-4 object-cover"
            />
            <h3 className="font-semibold">Thilina Gunarathne</h3>
            <p className="text-gray-400 text-sm">QA Team</p>
          </div>
        </div>
      </section>

      {/* Technology Logos */}
      <section className="px-10 py-16">
        <h2 className="text-3xl font-bold text-center mb-10">Technologies & Hardware</h2>
        <div className="flex justify-center gap-10">
          <Image alt="Figma" src="https://cdn.worldvectorlogo.com/logos/figma-1.svg" width={64} height={64} />
          <Image alt="VS Code" src="https://cdn.worldvectorlogo.com/logos/visual-studio-code.svg" width={64} height={64} />
          <Image alt="HTML" src="https://cdn.worldvectorlogo.com/logos/html-1.svg" width={64} height={64} />
          <Image alt="CSS" src="https://cdn.worldvectorlogo.com/logos/css-3.svg" width={64} height={64} />
          <Image alt="JavaScript" src="https://cdn.worldvectorlogo.com/logos/javascript-1.svg" width={64} height={64} />
        </div>
      </section>

      {/* Process Section */}
      <section className="px-10 py-16 bg-gray-900">
        <h2 className="text-3xl font-bold text-center mb-10">How We Build</h2>
        <div className="flex flex-wrap justify-center gap-8 text-center">
          <div><h3 className="text-xl font-semibold">01</h3><p>Planning Phase</p></div>
          <div><h3 className="text-xl font-semibold">02</h3><p>Design Phase</p></div>
          <div><h3 className="text-xl font-semibold">03</h3><p>Development Phase</p></div>
          <div><h3 className="text-xl font-semibold">04</h3><p>Testing & Deployment</p></div>
        </div>
      </section>

      {/* Review Form */}
      <section className="px-10 py-16">
        <h2 className="text-3xl font-bold text-center mb-10">Write a Review</h2>
        <form className="max-w-2xl mx-auto space-y-4">
          <div className="flex gap-4">
            <input type="text" placeholder="First Name" className="w-1/2 p-3 rounded bg-gray-800 text-white" />
            <input type="text" placeholder="Last Name" className="w-1/2 p-3 rounded bg-gray-800 text-white" />
          </div>
          <div className="flex gap-4">
            <input type="email" placeholder="Email" className="w-1/2 p-3 rounded bg-gray-800 text-white" />
            <input type="text" placeholder="Phone Number" className="w-1/2 p-3 rounded bg-gray-800 text-white" />
          </div>
          <input type="text" placeholder="Subject" className="w-full p-3 rounded bg-gray-800 text-white" />
          <textarea placeholder="Tell us something..." rows={4} className="w-full p-3 rounded bg-gray-800 text-white"></textarea>
          <button className="px-6 py-3 bg-blue-600 rounded-lg hover:bg-blue-700 w-full">Send</button>
        </form>
      </section>

      {/* Footer */}
      <footer className="px-10 py-8 bg-black border-t border-gray-800 text-center">
        <p className="text-gray-400 text-sm">
          2025 © Intrinsic Landing Page - By Design Team - All Rights Reserved
        </p>
      </footer>

    </>
  );
}
