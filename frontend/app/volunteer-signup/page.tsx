'use client';

import { useUser } from '@clerk/nextjs';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, setAuthToken, getAuthToken } from '@/lib/api';

// Force dynamic rendering (Clerk requires headers)
export const dynamic = 'force-dynamic';

export default function VolunteerSignup() {
  const { user, isLoaded, isSignedIn } = useUser();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setLoading(true);
    setError(null);

    try {
      // Get auth token - not strictly required for user registration, but good to have
      let token = await getAuthToken();
      
      // Retry once if token is null (Clerk might need a moment)
      if (!token && isSignedIn) {
        await new Promise(resolve => setTimeout(resolve, 500));
        token = await getAuthToken();
      }
      
      // User registration endpoint is public, so we can proceed without token
      // But we'll set it if available for future API calls
      if (token) {
        setAuthToken(token);
      }

      await api.users.register({
        clerk_id: user.id,
        role: 'VOLUNTEER',
      });

      router.push('/dashboard');
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  if (!isLoaded) {
    return <div className="container mx-auto px-4 py-8">Loading...</div>;
  }

  if (!user) {
    router.push('/sign-in');
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-blue-600">Learn Together</h1>
        </div>
      </nav>

      <main className="container mx-auto px-4 py-16">
        <div className="card max-w-md mx-auto">
          <h2 className="text-3xl font-bold mb-4 text-center">Volunteer Registration</h2>
          <p className="text-gray-600 mb-6 text-center">
            Thank you for your interest in volunteering! Your account will require admin approval before you can create skills and sessions.
          </p>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 p-4 rounded mb-4">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Email</label>
              <input
                type="email"
                value={user.emailAddresses[0]?.emailAddress || ''}
                disabled
                className="bg-gray-100"
              />
            </div>

            <div className="form-group">
              <label>Name</label>
              <input
                type="text"
                value={user.fullName || ''}
                disabled
                className="bg-gray-100"
              />
            </div>

            <div className="bg-blue-50 p-4 rounded mb-4">
              <p className="text-sm text-blue-800">
                <strong>Note:</strong> As a volunteer, you'll be able to:
                <ul className="list-disc list-inside mt-2 space-y-1">
                  <li>Create skills and learning sessions</li>
                  <li>Upload YouTube video links for educational content</li>
                  <li>Schedule and manage sessions</li>
                </ul>
                <br />
                Your account will be reviewed by an admin before you can start teaching.
              </p>
            </div>

            <button
              type="submit"
              className="btn btn-primary w-full"
              disabled={loading}
            >
              {loading ? 'Registering...' : 'Register as Volunteer'}
            </button>
          </form>
        </div>
      </main>
    </div>
  );
}
