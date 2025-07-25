// import { useState } from 'react';
// import { useRouter } from 'next/router';
// import axios from 'axios';

// export default function LoginPage() {
//   const [email, setEmail] = useState('');
// //   const [password, setPassword] = useState('');
//   const [error, setError] = useState('');
//   const router = useRouter();

//   const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
//     e.preventDefault();
//     try {
//       const res = await axios.post('https://localhost:5001/api/auth/login', {
//         email,
//         password,
//       });

//       const { token, user } = res.data;
//       localStorage.setItem('token', token);
//       localStorage.setItem('role', user.role);
//       localStorage.setItem('userId', user.id);

//       if (user.role === 'admin') {
//         router.push('/admin/dashboard');
//       } else if (user.role === 'doctor') {
//         router.push('/doctor/home');
//       } else {
//         router.push('/patient/home');
//       }
//     // eslint-disable-next-line @typescript-eslint/no-unused-vars
//     } catch (error) {
//       setError('Invalid credentials');
//     }
//   };

//   return (
//     <div className="p-8 max-w-md mx-auto">
//       <h1 className="text-2xl font-bold mb-4">Login</h1>
//       {error && <p className="text-red-500">{error}</p>}
//       <form onSubmit={handleLogin} className="flex flex-col gap-4">
//         <input
//           type="email"
//           placeholder="Email"
//           value={email}
//           onChange={(e) => setEmail(e.target.value)}
//           className="border p-2 rounded"
//           required
//         />
//         <input
//           type="password"
//           placeholder="Password"
//           value={password}
//           onChange={(e) => setPassword(e.target.value)}
//           className="border p-2 rounded"
//           required
//         />
//         <button type="submit" className="bg-blue-600 text-white p-2 rounded">
//           Login
//         </button>
//       </form>
//     </div>
//   );
// } 


// //  { token, user: { role, id } }
// //  فيه صفحة  /admin/dashboard، /doctor/home، /patient/home
// //  localStorage cookie of tokens
