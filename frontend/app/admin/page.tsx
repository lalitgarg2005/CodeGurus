'use client';

import { useUser } from '@clerk/nextjs';
import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api, setAuthToken, getAuthToken } from '@/lib/api';
import { User } from '@/types';
import Link from 'next/link';

// Force dynamic rendering (Clerk requires headers)
export const dynamic = 'force-dynamic';

export default function AdminDashboard() {
  const { user, isLoaded } = useUser();
  const router = useRouter();
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [pendingVolunteers, setPendingVolunteers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      if (!isLoaded || !user) return;

      try {
        const token = await getAuthToken();
        if (token) {
          setAuthToken(token);
          const userData = await api.users.getMe();
          setCurrentUser(userData);

          if (userData.role === 'ADMIN') {
            const volunteers = await api.users.getPendingVolunteers();
            setPendingVolunteers(volunteers);
          }
        }
      } catch (error) {
        console.error('Error loading data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [isLoaded, user]);

  const handleApprove = async (userId: number) => {
    try {
      await api.users.approveUser(userId);
      setPendingVolunteers(pendingVolunteers.filter(v => v.id !== userId));
    } catch (error) {
      console.error('Error approving user:', error);
      alert('Failed to approve user');
    }
  };

  if (!isLoaded || loading) {
    return <div className="container mx-auto px-4 py-8">Loading...</div>;
  }

  if (!user || !currentUser || currentUser.role !== 'ADMIN') {
    router.push('/dashboard');
    return null;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <Link href="/dashboard">
            <h1 className="text-2xl font-bold text-blue-600">Learn Together - Admin</h1>
          </Link>
          <Link href="/dashboard">
            <button className="btn btn-secondary">Back to Dashboard</button>
          </Link>
        </div>
      </nav>

      <main className="container mx-auto px-4 py-8">
        <h2 className="text-3xl font-bold mb-8">Admin Dashboard</h2>

        <div className="card mb-8">
          <h3 className="text-2xl font-semibold mb-4">Pending Volunteer Approvals</h3>
          {pendingVolunteers.length === 0 ? (
            <p className="text-gray-600">No pending volunteer approvals.</p>
          ) : (
            <div className="space-y-4">
              {pendingVolunteers.map((volunteer) => (
                <div key={volunteer.id} className="border p-4 rounded flex justify-between items-center">
                  <div>
                    <p className="font-semibold">User ID: {volunteer.id}</p>
                    <p className="text-sm text-gray-600">Clerk ID: {volunteer.clerk_id}</p>
                    <p className="text-sm text-gray-600">Created: {new Date(volunteer.created_at).toLocaleDateString()}</p>
                  </div>
                  <button
                    onClick={() => handleApprove(volunteer.id)}
                    className="btn btn-primary"
                  >
                    Approve
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="grid md:grid-cols-3 gap-4">
          <Link href="/skills" className="card hover:shadow-lg transition-shadow">
            <h4 className="font-semibold mb-2">Manage Skills</h4>
            <p className="text-sm text-gray-600">View and manage all skills</p>
          </Link>
          <Link href="/sessions" className="card hover:shadow-lg transition-shadow">
            <h4 className="font-semibold mb-2">Manage Sessions</h4>
            <p className="text-sm text-gray-600">View and manage all sessions</p>
          </Link>
          <Link href="/users" className="card hover:shadow-lg transition-shadow">
            <h4 className="font-semibold mb-2">Manage Users</h4>
            <p className="text-sm text-gray-600">View all users</p>
          </Link>
        </div>
      </main>
    </div>
  );
}
