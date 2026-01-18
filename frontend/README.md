# Frontend - Nonprofit Learning Platform

Next.js 14 frontend application with App Router and TypeScript.

## Structure

```
frontend/
├── app/                  # Next.js App Router pages
│   ├── layout.tsx       # Root layout with ClerkProvider
│   ├── page.tsx         # Landing page
│   ├── dashboard/       # User dashboard
│   ├── admin/           # Admin dashboard
│   ├── volunteer-signup/# Volunteer registration
│   └── parent-signup/        # Parent registration
├── components/          # React components
├── lib/                 # API client and utilities
│   └── api.ts           # API service layer
├── types/               # TypeScript definitions
└── public/              # Static assets
```

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.local.example .env.local
   # Edit .env.local with your configuration
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```

   Application will be available at `http://localhost:3000`

## Environment Variables

See `.env.local.example` for required environment variables.

## Features

- **Clerk Authentication**: Integrated with Clerk for user authentication
- **Role-Based Navigation**: Different views for Admin, Volunteer, and Parent
- **Protected Routes**: Middleware protects routes based on authentication
- **API Integration**: Axios-based API client with automatic token injection

## Building for Production

```bash
npm run build
npm start
```

## Deployment

The frontend can be deployed to:
- Vercel (recommended for Next.js)
- Netlify
- AWS Amplify
- Any static hosting service

Make sure to set all environment variables in your deployment platform.
