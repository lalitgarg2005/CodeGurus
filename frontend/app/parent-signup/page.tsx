'use client';

import { useUser, useAuth } from '@clerk/nextjs';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, setAuthToken } from '@/lib/api';

export default function ParentSignup() {
  const { user, isLoaded, isSignedIn } = useUser();
  const { getToken } = useAuth();
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [email, setEmail] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    const parentEmail = email || user.emailAddresses[0]?.emailAddress;
    if (!parentEmail) {
      setError('Email is required for parent registration.');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Step 1: Register or update user role (this doesn't require auth)
      // This will create a new user or update existing user's role to PARENT
      let existingUser = null;
      
      // Try to register/update user (public endpoint)
      try {
        const registeredUser = await api.users.register({
          clerk_id: user.id,
          role: 'PARENT',
        });
        // User registered or role updated successfully
        existingUser = registeredUser;
      } catch (userErr: any) {
        // Registration failed - log error but continue to try getting token
        console.error('User registration error:', userErr);
        // We'll try to get the user after getting the token
      }

      // Step 2: Get auth token - required for parent registration endpoint
      let token: string | null = null;
      
      // Try multiple methods to get the token
      try {
        // Method 1: Use useAuth hook's getToken
        token = await getToken();
      } catch (tokenError) {
        console.error('Error getting token from useAuth:', tokenError);
      }
      
      // Method 2: Try fallback if hook method failed
      if (!token) {
        try {
          // Import getToken directly as fallback
          const { getToken: getTokenDirect } = await import('@clerk/nextjs');
          token = await getTokenDirect();
        } catch (fallbackError) {
          console.error('Error getting token from direct import:', fallbackError);
        }
      }
      
      // Retry once if token is still null (Clerk might need a moment to initialize)
      if (!token && isSignedIn) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        try {
          token = await getToken();
          if (!token) {
            const { getToken: getTokenDirect } = await import('@clerk/nextjs');
            token = await getTokenDirect();
          }
        } catch (retryError) {
          console.error('Retry token error:', retryError);
        }
      }
      
      if (!token) {
        console.error('All token retrieval methods failed');
        setError('Unable to get authentication token. Please make sure you are signed in with Clerk. Try refreshing the page or signing out and signing back in.');
        setLoading(false);
        return;
      }
      
      setAuthToken(token);

      // Step 3: Check if user exists and has correct role
      // If user exists with different role, the registration endpoint will update it
      // So we can proceed to parent registration
      try {
        existingUser = await api.users.getMe();
        // If role is not PARENT, the registration above should have updated it
        // But let's verify
        if (existingUser.role !== 'PARENT') {
          // Role might still be updating, wait a moment and check again
          await new Promise(resolve => setTimeout(resolve, 500));
          const updatedUser = await api.users.getMe();
          if (updatedUser.role !== 'PARENT') {
            setError(`Unable to update your role. Current role: ${updatedUser.role}. Please try again or contact support.`);
            setLoading(false);
            return;
          }
          existingUser = updatedUser;
        }
      } catch (getMeError) {
        // User might not exist yet, but we just registered them
        // This is okay, continue to parent registration
        console.log('User not found in backend yet, continuing with parent registration');
      }

      // Check if parent already exists
      let existingParent = null;
      try {
        existingParent = await api.parents.getMe();
      } catch {
        // Parent doesn't exist yet, that's fine
      }

      // Register as parent if doesn't exist
      if (!existingParent) {
        try {
          await api.parents.register({
            email: parentEmail,
            clerk_id: user.id,
          });
        } catch (parentErr: any) {
          // If parent already exists, that's fine - redirect
          if (parentErr.response?.status === 400 && parentErr.response?.data?.detail?.includes('already exists')) {
            // Parent already registered, redirect to dashboard
            router.push('/dashboard');
            return;
          }
          throw parentErr;
        }
      }

      // Success - redirect to dashboard
      router.push('/dashboard');
    } catch (err: any) {
      console.error('Registration error:', err);
      let errorMessage = 'Registration failed. Please try again.';
      
      if (err.response?.data?.detail) {
        errorMessage = err.response.data.detail;
      } else if (err.message) {
        errorMessage = err.message;
      }
      
      setError(errorMessage);
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
          <h2 className="text-3xl font-bold mb-4 text-center">Parent Registration</h2>
          <p className="text-gray-600 mb-6 text-center">
            Register as a parent to manage your children's learning journey. Parent email is required for student safety.
          </p>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-800 p-4 rounded mb-4">
              {error}
            </div>
          )}

          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label>Parent Email *</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder={user.emailAddresses[0]?.emailAddress || 'your-email@example.com'}
                required
              />
              <p className="text-sm text-gray-500 mt-1">
                This email will be used for all student account management and safety communications.
              </p>
            </div>

            <div className="bg-blue-50 p-4 rounded mb-4">
              <p className="text-sm text-blue-800">
                <strong>As a parent, you can:</strong>
                <ul className="list-disc list-inside mt-2 space-y-1">
                  <li>Register and manage your children's accounts</li>
                  <li>Enroll students in learning sessions</li>
                  <li>View all content and session information</li>
                  <li>Monitor your children's learning progress</li>
                </ul>
                <br />
                <strong>Safety:</strong> All student accounts are linked to your parent account. No direct messaging is allowed between volunteers and students.
              </p>
            </div>

            <button
              type="submit"
              className="btn btn-primary w-full"
              disabled={loading}
            >
              {loading ? 'Registering...' : 'Register as Parent'}
            </button>
          </form>
        </div>
      </main>
    </div>
  );
}
