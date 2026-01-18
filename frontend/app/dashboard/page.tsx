'use client';

import { useUser } from '@clerk/nextjs';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, setAuthToken, getAuthToken } from '@/lib/api';
import { User } from '@/types';
import Link from 'next/link';

export default function Dashboard() {
  const { user, isLoaded } = useUser();
  const router = useRouter();
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadUser = async () => {
      if (!isLoaded || !user) return;

      try {
        const token = await getAuthToken();
        if (token) {
          setAuthToken(token);
          const userData = await api.users.getMe();
          setCurrentUser(userData);
        }
      } catch (error) {
        console.error('Error loading user:', error);
        // User might not be registered in backend yet
      } finally {
        setLoading(false);
      }
    };

    loadUser();
  }, [isLoaded, user]);

  if (!isLoaded || loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    router.push('/');
    return null;
  }

  // Role-based navigation
  const getRoleLinks = () => {
    if (!currentUser) return null;
    
    switch (currentUser.role) {
      case 'ADMIN':
        return (
          <>
            <Link href="/admin">
              <button className="btn btn-primary">Admin Dashboard</button>
            </Link>
            <Link href="/skills">
              <button className="btn btn-secondary">Manage Skills</button>
            </Link>
          </>
        );
      case 'VOLUNTEER':
        return (
          <>
            {!currentUser.approved && (
              <div className="card bg-yellow-50 border-yellow-200 mb-4">
                <p className="text-yellow-800">
                  ⏳ Your volunteer account is pending admin approval. You'll be able to create skills and sessions once approved.
                </p>
              </div>
            )}
            <Link href="/volunteer">
              <button className="btn btn-primary">Volunteer Dashboard</button>
            </Link>
            <Link href="/skills">
              <button className="btn btn-secondary">My Skills</button>
            </Link>
            <Link href="/sessions">
              <button className="btn btn-secondary">My Sessions</button>
            </Link>
          </>
        );
      case 'PARENT':
        return (
          <>
            <Link href="/parent">
              <button className="btn btn-primary">Parent Dashboard</button>
            </Link>
            <Link href="/students">
              <button className="btn btn-secondary">My Students</button>
            </Link>
            <Link href="/sessions">
              <button className="btn btn-secondary">Available Sessions</button>
            </Link>
          </>
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link href="/dashboard" className="flex items-center gap-2 hover:opacity-80 transition-opacity">
            <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center">
              <span className="text-white font-bold text-xl">L</span>
            </div>
            <h1 className="text-2xl font-bold gradient-text">Learn Together</h1>
          </Link>
          <div className="flex gap-4 items-center">
            {currentUser ? (
              <>
                <span className="text-sm text-gray-600">
                  {currentUser.role} {currentUser.role === 'VOLUNTEER' && !currentUser.approved && '(Pending)'}
                </span>
                <Link href="/">
                  <button className="btn btn-secondary">Home</button>
                </Link>
              </>
            ) : (
              <div className="flex gap-2">
                <Link href="/volunteer-signup">
                  <button className="btn btn-primary text-sm px-4 py-2">Volunteer</button>
                </Link>
                <Link href="/parent-signup">
                  <button className="btn btn-secondary text-sm px-4 py-2">Parent</button>
                </Link>
                <Link href="/">
                  <button className="btn btn-outline text-sm px-4 py-2">Home</button>
                </Link>
              </div>
            )}
          </div>
        </div>
      </nav>

      <main className="container mx-auto px-4 py-8">
        {!currentUser && (
          <div className="mb-8 card bg-gradient-to-r from-purple-50 to-pink-50 border-2 border-purple-200">
            <div className="flex flex-col md:flex-row items-center justify-between gap-4">
              <div>
                <h3 className="text-xl font-bold mb-2 gradient-text">Complete Your Registration</h3>
                <p className="text-gray-700">
                  Please register as a Volunteer or Parent using the buttons in the navigation bar above to access all features.
                </p>
              </div>
            </div>
          </div>
        )}

        {currentUser ? (
          <>
            <div className="card mb-8">
              <h2 className="text-3xl font-bold mb-4">Welcome, {user.firstName || user.emailAddresses[0]?.emailAddress}!</h2>
              <p className="text-gray-600">
                Role: <strong>{currentUser.role}</strong>
                {currentUser.role === 'VOLUNTEER' && (
                  <span className={currentUser.approved ? 'text-green-600' : 'text-yellow-600'}>
                    {' '}({currentUser.approved ? 'Approved' : 'Pending Approval'})
                  </span>
                )}
              </p>
            </div>

            <div className="flex flex-wrap gap-4 mb-8">
              {getRoleLinks()}
            </div>
          </>
        ) : (
          <div className="card mb-8 text-center py-12">
            <h2 className="text-3xl font-bold mb-4">Welcome, {user.firstName || user.emailAddresses[0]?.emailAddress}!</h2>
            <p className="text-gray-600 mb-6">
              Get started by completing your registration above.
            </p>
          </div>
        )}

        <div className="card">
          <h3 className="text-xl font-semibold mb-4">Quick Actions</h3>
          <div className="grid md:grid-cols-2 gap-4">
            <Link href="/skills" className="card hover:shadow-lg transition-shadow">
              <h4 className="font-semibold mb-2">Browse Skills</h4>
              <p className="text-sm text-gray-600">Explore available learning skills</p>
            </Link>
            <Link href="/sessions" className="card hover:shadow-lg transition-shadow">
              <h4 className="font-semibold mb-2">View Sessions</h4>
              <p className="text-sm text-gray-600">See upcoming learning sessions</p>
            </Link>
            <Link href="/videos" className="card hover:shadow-lg transition-shadow">
              <h4 className="font-semibold mb-2">Watch Videos</h4>
              <p className="text-sm text-gray-600">Browse educational videos</p>
            </Link>
          </div>
        </div>
      </main>
    </div>
  );
}
