const normalizeBackendOrigin = (value) => {
  const trimmed = (value || '').trim().replace(/\/+$/, '');

  if (!trimmed) return '';
  if (/^https?:\/\//i.test(trimmed)) return trimmed.replace(/\/api$/, '');
  if (trimmed.startsWith('//')) return `https:${trimmed}`.replace(/\/api$/, '');

  const isLocalHost =
    /^localhost(?::\d+)?(?:\/|$)/i.test(trimmed) ||
    /^127(?:\.\d{1,3}){3}(?::\d+)?(?:\/|$)/.test(trimmed) ||
    /^0\.0\.0\.0(?::\d+)?(?:\/|$)/.test(trimmed);

  return `${isLocalHost ? 'http' : 'https'}://${trimmed}`.replace(/\/api$/, '');
};

/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
  },
  async rewrites() {
    const backendOrigin =
      normalizeBackendOrigin(process.env.NEXT_PUBLIC_API_URL) ||
      normalizeBackendOrigin(process.env.NEXT_PUBLIC_BACK_URL) ||
      normalizeBackendOrigin(process.env.BACKEND_URL) ||
      'https://oralbackend-production.up.railway.app';

    return [
      {
        source: '/api/:path*',
        destination: `${backendOrigin}/api/:path*`,
      },
      {
        source: '/uploads/:path*',
        destination: `${backendOrigin}/uploads/:path*`,
      },
    ];
  },
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
      },
      {
        protocol: 'https',
        hostname: 'randomuser.me',
      },
      {
        protocol: 'https',
        hostname: 'cdn.worldvectorlogo.com',
      }
    ]
  }
};

module.exports = nextConfig;
