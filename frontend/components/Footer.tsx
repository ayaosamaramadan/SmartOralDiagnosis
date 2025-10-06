import { FaFacebook } from "react-icons/fa";
import { FaLinkedin } from "react-icons/fa";
import { FaYoutube } from "react-icons/fa";
import { FaXTwitter } from "react-icons/fa6";

const Footer = () => {
    return (
        <>
            <footer className="bg-black mx-auto rounded-xl shadow-lg p-8 bg-gradient-to-br from-[#23252641] via-[#35353594] to-[#24242442]">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 items-start">
                    <section>
                        <h2 className="text-lg font-semibold text-white mb-4">Quick Links</h2>
                        <ul className="space-y-2 text-gray-300 text-sm">
                            <li><a className="hover:underline">Find a doctor</a></li>
                            <li><a className="hover:underline">Explore careers</a></li>
                            <li><a className="hover:underline">Sign up for free e-newsletters</a></li>
                            <li><a className="hover:underline">About Smart Oral Diagnosis</a></li>
                            <li><a className="hover:underline">Contact Us</a></li>
                            <li><a className="hover:underline">Locations</a></li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-lg font-semibold text-white mb-4">Resources</h2>
                        <ul className="space-y-2 text-gray-300 text-sm">
                            <li><a className="hover:underline">Health Information Policy</a></li>
                            <li><a className="hover:underline">Clinical Trials</a></li>
                            <li><a className="hover:underline">Refer a Patient</a></li>
                            <li><a className="hover:underline">Admissions Requirements</a></li>
                            <li><a className="hover:underline">Degree Programs</a></li>
                            <li><a className="hover:underline">Community Health Needs Assessment</a></li>
                        </ul>
                    </section>

                    <section>
                        <h2 className="text-lg font-semibold text-white mb-4">Follow Us</h2>
                        <div className="flex items-center gap-4 mb-4">
                            <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer" aria-label="LinkedIn" className="hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-blue-600 rounded">
                                <FaLinkedin className="text-blue-600 text-2xl" />
                            </a>
                            <a href="https://www.youtube.com/" target="_blank" rel="noopener noreferrer" aria-label="YouTube" className="hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-red-600 rounded">
                                <FaYoutube className="text-red-600 text-2xl" />
                            </a>
                            <a href="https://www.facebook.com/" target="_blank" rel="noopener noreferrer" aria-label="Facebook" className="hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-blue-600 rounded">
                                <FaFacebook className="text-blue-600 text-2xl" />
                            </a>
                            <a href="https://twitter.com/" target="_blank" rel="noopener noreferrer" aria-label="Twitter" className="hover:scale-110 transition-transform focus:outline-none focus:ring-2 focus:ring-white rounded">
                                <FaXTwitter className="text-white text-2xl" />
                            </a>
                        </div>
                        <ul className="space-y-2 text-gray-300 text-xs">
                            <li><a className="hover:underline">Terms & Conditions</a></li>
                            <li><a className="hover:underline">Privacy Policy</a></li>
                            <li><a className="hover:underline">Notice of Nondiscrimination</a></li>
                            <li><a className="hover:underline">Digital Accessibility Statement</a></li>
                            <li><a className="hover:underline">Site Map</a></li>
                            <li><a className="hover:underline">Manage Cookies</a></li>
                        </ul>
                    </section>
                </div>
                <div className="flex flex-col md:flex-row justify-between items-center mt-8 border-t border-gray-700 pt-4">
                    <span className="text-xs text-gray-400">
                        &copy; {new Date().getFullYear()} Smart Oral Diagnosis. All rights reserved.
                    </span>
                    <span className="text-xs text-gray-400 mt-2 md:mt-0">Language: English</span>
                </div>
            </footer>
        </>
    );
}

export default Footer;