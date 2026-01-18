'use client';

import { useUser } from '@clerk/nextjs';
import { useEffect, useState } from 'react';
import { api, setAuthToken, getAuthToken } from '@/lib/api';
import { Skill, User } from '@/types';
import Link from 'next/link';

export default function SkillsPage() {
  const { user, isLoaded } = useUser();
  const [skills, setSkills] = useState<Skill[]>([]);
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadData = async () => {
      if (!isLoaded) return;

      try {
        const token = await getAuthToken();
        if (token) {
          setAuthToken(token);
          const skillsData = await api.skills.getAll();
          setSkills(skillsData);

          try {
            const userData = await api.users.getMe();
            setCurrentUser(userData);
          } catch {
            // User might not be registered
          }
        }
      } catch (error) {
        console.error('Error loading skills:', error);
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
          <h2 className="text-3xl font-bold">Available Skills</h2>
          {canCreate && (
            <Link href="/skills/create">
              <button className="btn btn-primary">Create Skill</button>
            </Link>
          )}
        </div>

        {skills.length === 0 ? (
          <div className="card text-center">
            <p className="text-gray-600">No skills available yet.</p>
          </div>
        ) : (
          <div className="grid md:grid-cols-3 gap-4">
            {skills.map((skill) => (
              <Link key={skill.id} href={`/skills/${skill.id}`}>
                <div className="card hover:shadow-lg transition-shadow cursor-pointer">
                  <h3 className="text-xl font-semibold mb-2">{skill.name}</h3>
                  <p className="text-gray-600 text-sm">{skill.description || 'No description'}</p>
                </div>
              </Link>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
