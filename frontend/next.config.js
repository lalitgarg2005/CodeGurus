/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Note: Clerk requires dynamic rendering, so we can't use static export
  // Remove output: 'export' to allow dynamic rendering
  // For S3 hosting, consider using CloudFront + Lambda@Edge or deploy to App Runner
  images: {
    unoptimized: true,
  },
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
  },
}

module.exports = nextConfig
