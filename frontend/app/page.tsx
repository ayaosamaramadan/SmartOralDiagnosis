"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
// import Link from "next/link";
import Image from "next/image";
import HomePic from "../assets/home.jpg";



export default function Home() {
  const router = useRouter();
  const [selectedRole, setSelectedRole] = useState("");

  const handleRoleSelection = (role: string) => {
    setSelectedRole(role);
    router.push(`/auth/login?role=${role}`);
  };

  return (
    // <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
    //   <div className="container mx-auto px-4 py-16">
    //     <div className="text-center mb-16">
    //       <h1 className="text-5xl font-bold text-gray-900 mb-4">
    //         Medical Management System
    //       </h1>
    //       <p className="text-xl text-gray-600 max-w-2xl mx-auto">
    //         Comprehensive healthcare management platform for doctors, patients,
    //         and administrators
    //       </p>
    //     </div>

    //     <div className="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
    //       {/* Patient Portal */}
    //       <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
    //         <div className="text-center">
    //           <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
    //             <svg
    //               className="w-8 h-8 text-blue-600"
    //               fill="none"
    //               stroke="currentColor"
    //               viewBox="0 0 24 24"
    //             >
    //               <path
    //                 strokeLinecap="round"
    //                 strokeLinejoin="round"
    //                 strokeWidth={2}
    //                 d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
    //               />
    //             </svg>
    //           </div>
    //           <h3 className="text-xl font-semibold text-gray-900 mb-4">
    //             Patient Portal
    //           </h3>
    //           <p className="text-gray-600 mb-6">
    //             Access your medical records, schedule appointments, and
    //             communicate with your healthcare providers
    //           </p>
    //           <button
    //             onClick={() => handleRoleSelection("patient")}
    //             className="w-full bg-blue-600 text-white py-3 px-6 rounded-lg hover:bg-blue-700 transition-colors"
    //           >
    //             Patient Login
    //           </button>
    //         </div>
    //       </div>

    //       {/* Doctor Portal */}
    //       <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
    //         <div className="text-center">
    //           <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
    //             <svg
    //               className="w-8 h-8 text-green-600"
    //               fill="none"
    //               stroke="currentColor"
    //               viewBox="0 0 24 24"
    //             >
    //               <path
    //                 strokeLinecap="round"
    //                 strokeLinejoin="round"
    //                 strokeWidth={2}
    //                 d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"
    //               />
    //             </svg>
    //           </div>
    //           <h3 className="text-xl font-semibold text-gray-900 mb-4">
    //             Doctor Portal
    //           </h3>
    //           <p className="text-gray-600 mb-6">
    //             Manage patient records, appointments, and provide quality
    //             healthcare services
    //           </p>
    //           <button
    //             onClick={() => handleRoleSelection("doctor")}
    //             className="w-full bg-green-600 text-white py-3 px-6 rounded-lg hover:bg-green-700 transition-colors"
    //           >
    //             Doctor Login
    //           </button>
    //         </div>
    //       </div>

    //       {/* Admin Portal */}
    //       <div className="bg-white rounded-xl shadow-lg p-8 hover:shadow-xl transition-shadow">
    //         <div className="text-center">
    //           <div className="w-16 h-16 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
    //             <svg
    //               className="w-8 h-8 text-purple-600"
    //               fill="none"
    //               stroke="currentColor"
    //               viewBox="0 0 24 24"
    //             >
    //               <path
    //                 strokeLinecap="round"
    //                 strokeLinejoin="round"
    //                 strokeWidth={2}
    //                 d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"
    //               />
    //               <path
    //                 strokeLinecap="round"
    //                 strokeLinejoin="round"
    //                 strokeWidth={2}
    //                 d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"
    //               />
    //             </svg>
    //           </div>
    //           <h3 className="text-xl font-semibold text-gray-900 mb-4">
    //             Admin Panel
    //           </h3>
    //           <p className="text-gray-600 mb-6">
    //             System administration, user management, and comprehensive
    //             reporting
    //           </p>
    //           <button
    //             onClick={() => handleRoleSelection("admin")}
    //             className="w-full bg-purple-600 text-white py-3 px-6 rounded-lg hover:bg-purple-700 transition-colors"
    //           >
    //             Admin Login
    //           </button>
    //         </div>
    //       </div>
    //     </div>

    //     <div className="text-center mt-16">
    //       <div className="max-w-3xl mx-auto">
    //         <h2 className="text-2xl font-semibold text-gray-900 mb-4">
    //           Features
    //         </h2>
    //         <div className="grid md:grid-cols-2 gap-6 text-left">
    //           <div className="flex items-start space-x-3">
    //             <div className="w-6 h-6 bg-blue-100 rounded-full flex items-center justify-center mt-1">
    //               <div className="w-2 h-2 bg-blue-600 rounded-full"></div>
    //             </div>
    //             <div>
    //               <h4 className="font-medium text-gray-900">
    //                 Appointment Management
    //               </h4>
    //               <p className="text-gray-600 text-sm">
    //                 Schedule and manage appointments efficiently
    //               </p>
    //             </div>
    //           </div>
    //           <div className="flex items-start space-x-3">
    //             <div className="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center mt-1">
    //               <div className="w-2 h-2 bg-green-600 rounded-full"></div>
    //             </div>
    //             <div>
    //               <h4 className="font-medium text-gray-900">Medical Records</h4>
    //               <p className="text-gray-600 text-sm">
    //                 Digital patient records and history
    //               </p>
    //             </div>
    //           </div>
    //           <div className="flex items-start space-x-3">
    //             <div className="w-6 h-6 bg-purple-100 rounded-full flex items-center justify-center mt-1">
    //               <div className="w-2 h-2 bg-purple-600 rounded-full"></div>
    //             </div>
    //             <div>
    //               <h4 className="font-medium text-gray-900">User Management</h4>
    //               <p className="text-gray-600 text-sm">
    //                 Role-based access control
    //               </p>
    //             </div>
    //           </div>
    //           <div className="flex items-start space-x-3">
    //             <div className="w-6 h-6 bg-yellow-100 rounded-full flex items-center justify-center mt-1">
    //               <div className="w-2 h-2 bg-yellow-600 rounded-full"></div>
    //             </div>
    //             <div>
    //               <h4 className="font-medium text-gray-900">
    //                 Reporting & Analytics
    //               </h4>
    //               <p className="text-gray-600 text-sm">
    //                 Comprehensive system reports
    //               </p>
    //             </div>
    //           </div>
    //         </div>
    //       </div>
    //     </div>
    //   </div>
    // </div>
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
              <button className="px-6 py-3 bg-blue-600 rounded-lg hover:bg-blue-700">Start Scan Now</button>
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

          {/* Contact / Info Bar */}
          <section className="flex flex-col md:flex-row justify-center items-center gap-10 px-10 py-10 bg-gray-900 rounded-xl max-w-5xl mx-auto">
            <div className="text-center">
              <h3 className="text-xl font-semibold">Visit Us</h3>
              <p className="text-gray-400">Colombo, Sri Lanka</p>
            </div>
            <div className="text-center">
              <h3 className="text-xl font-semibold">Give Us a Call</h3>
              <p className="text-gray-400">(+94) 123 456 789</p>
            </div>
            <div className="text-center">
              <h3 className="text-xl font-semibold">Send Us a Message</h3>
              <p className="text-gray-400">info@intrinsic.org</p>
            </div>
          </section>

          {/* Intro Section */}
          <section className="px-10 py-16">
            <h2 className="text-3xl font-bold mb-4">Introduction</h2>
            <p className="text-gray-300 max-w-3xl">
              Welcome to Intrinsic, a vibrant hub of software and innovative web design.
              Our mission is to harness modern tools and techniques to empower businesses.
            </p>
          </section>

          {/* Team Section */}
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
