import Nav from "@/components/Navbar/page";
import Link from "next/link";

export default function Home() {
  return (
  <>
    <h1>Oral Disease Diagnosis</h1>
       
          <div >
            <Link className="pr-10" href="/login">Login</Link>
            <Link href="/register">Register</Link>
            <Nav />
          </div>
          </>
     
   
  );
}
