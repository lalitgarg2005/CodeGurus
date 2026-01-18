'use client';

import { useUser } from '@clerk/nextjs';
import { useEffect, useState } from 'react';
import { api, setAuthToken, getAuthToken } from '@/lib/api';
import { Session, User } from '@/types';
import Link from 'next/link';

// Force dynamic rendering (Clerk requires headers)
export const dynamic = 'force-dynamic';

export default function SessionsPage() {
  const { user, isLoaded } = useUser();
  const [sessions, setSessions] = useState<Session[]>([]);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      if (!isLoaded) return;

      try {
        const token = await getAuthToken();
        if (token) {
          setAuthToken(token);
          const sessionsData = await api.sessions.getAll();
          setSessions(sessionsData);

          try {
            const userData = await api.users.getMe();
            setCurrentUser(userData);
          } catch {
            // User might not be registered
          }
        }
      } catch (error) {
        console.error('Error loading sessions:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [isLoaded]);

  if (!isLoaded || loading) {
    return <div className="container mx-auto px-4 py-8">Loading...</div>;
  }

  const canCreate = currentUser && (currentUser.role === 'VOLUNTEER' || currentUser.role === 'ADMIN') && currentUser.approved;

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link href="/dashboard">
            <h1 className="text-2xl font-bold text-blue-600">Learn Together</h1>
          </Link>
          <Link href="/dashboard">
            <button className="btn btn-secondary">Back to Dashboard</button>
          </Link>
        </div>
      </nav>

      <main className="container mx-auto px-4 py-8">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-3xl font-bold">Learning Sessions</h2>
          {canCreate && (
            <Link href="/sessions/create">
              <button className="btn btn-primary">Create Session</button>
            </Link>
          )}
        </div>

        {sessions.length === 0 ? (
          <div className="card text-center">
            <p className="text-gray-600">No sessions available yet.</p>
          </div>
        ) : (
          <div className="space-y-4">
            {sessions.map((session) => (
              <div key={session.id} className="card">
                <div className="flex justify-between items-start">
                  <div>
                    <h3 className="text-xl font-semibold mb-2">{session.title}</h3>
                    <p className="text-gray-600 mb-2">{session.description || 'No description'}</p>
                    <p className="text-sm text-gray-500">
                      Scheduled: {new Date(session.schedule).toLocaleString()}
                    </p>
                    <p className="text-sm text-gray-500">
                      Status: <span className={`font-semibold ${
                        session.status === 'scheduled' ? 'text-green-600' :
                        session.status === 'completed' ? 'text-gray-600' :
                        'text-red-600'
                      }`}>
                        {session.status}
                      </span>
                    </p>
                    {session.meeting_link && (
                      <a
                        href={session.meeting_link}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="text-blue-600 hover:underline text-sm"
                      >
                        Join Meeting →
                      </a>
                    )}
                  </div>
                  <Link href={`/sessions/${session.id}`}>
                    <button className="btn btn-secondary">View Details</button>
                  </Link>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
