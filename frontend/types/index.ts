/**
 * TypeScript type definitions for the application.
 */

export type UserRole = 'ADMIN' | 'VOLUNTEER' | 'PARENT';

export interface User {
  id: number;
  clerk_id: string;
  role: UserRole;
  approved: boolean;
  created_at: string;
}

export interface Parent {
  id: number;
  user_id: number;
  email: string;
  created_at: string;
}

export interface Student {
  id: number;
  parent_id: number;
  name: string;
  age: number;
  interests?: string;
  created_at: string;
}

export interface Skill {
  id: number;
  name: string;
  description?: string;
  created_by?: number;
  created_at: string;
  updated_at?: string;
}

export interface Session {
  id: number;
  skill_id: number;
  volunteer_id: number;
  title: string;
  description?: string;
  schedule: string;
  meeting_link?: string;
  status: string;
  created_at: string;
  updated_at?: string;
}

export interface Video {
  id: number;
  skill_id: number;
  title: string;
  description?: string;
  youtube_url: string;
  created_by?: number;
  created_at: string;
  updated_at?: string;
}

export interface SessionEnrollment {
  id: number;
  student_id: number;
  session_id: number;
  enrolled_at: string;
}
