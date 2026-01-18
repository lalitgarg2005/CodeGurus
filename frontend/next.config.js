/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Use static export for S3 hosting, or standalone for server-side rendering
  output: process.env.NEXT_OUTPUT || 'export', // 'export' for S3, 'standalone' for Docker/App Runner
  images: {
    unoptimized: true, // Required for static export
  },
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
  },
}

module.exports = nextConfig
