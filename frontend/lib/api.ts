/**
 * API service layer for communicating with the backend.
 */
import axios from 'axios';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

// Create axios instance
const apiClient = axios.create({
  baseURL: `${API_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Helper to set auth token
export const setAuthToken = (token: string | null) => {
  if (token) {
    apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  } else {
    delete apiClient.defaults.headers.common['Authorization'];
  }
};

// API functions
export const api = {
  // Health check
  health: async () => {
    const response = await apiClient.get('/health');
    return response.data;
  },

  // Users
  users: {
    register: async (data: { clerk_id: string; role: string }) => {
      const response = await apiClient.post('/users/register', data);
      return response.data;
    },
    getMe: async () => {
      const response = await apiClient.get('/users/me');
      return response.data;
    },
    getAll: async () => {
      const response = await apiClient.get('/users');
      return response.data;
    },
    getPendingVolunteers: async () => {
      const response = await apiClient.get('/users/pending-volunteers');
      return response.data;
    },
    approveUser: async (userId: number) => {
      const response = await apiClient.patch(`/users/${userId}/approve`);
      return response.data;
    },
  },

  // Parents
  parents: {
    register: async (data: { email: string; clerk_id: string }) => {
      const response = await apiClient.post('/users/parents/register', data);
      return response.data;
    },
    getMe: async () => {
      const response = await apiClient.get('/users/parents/me');
      return response.data;
    },
  },

  // Students
  students: {
    create: async (data: { name: string; age: number; interests?: string }) => {
      const response = await apiClient.post('/users/students', data);
      return response.data;
    },
    getAll: async () => {
      const response = await apiClient.get('/users/students');
      return response.data;
    },
    getById: async (id: number) => {
      const response = await apiClient.get(`/users/students/${id}`);
      return response.data;
    },
    update: async (id: number, data: { name?: string; age?: number; interests?: string }) => {
      const response = await apiClient.patch(`/users/students/${id}`, data);
      return response.data;
    },
  },

  // Skills
  skills: {
    create: async (data: { name: string; description?: string }) => {
      const response = await apiClient.post('/skills', data);
      return response.data;
    },
    getAll: async () => {
      const response = await apiClient.get('/skills');
      return response.data;
    },
    getById: async (id: number) => {
      const response = await apiClient.get(`/skills/${id}`);
      return response.data;
    },
    update: async (id: number, data: { name?: string; description?: string }) => {
      const response = await apiClient.patch(`/skills/${id}`, data);
      return response.data;
    },
    delete: async (id: number) => {
      const response = await apiClient.delete(`/skills/${id}`);
      return response.data;
    },
  },

  // Sessions
  sessions: {
    create: async (data: {
      skill_id: number;
      title: string;
      description?: string;
      schedule: string;
      meeting_link?: string;
    }) => {
      const response = await apiClient.post('/sessions', data);
      return response.data;
    },
    getAll: async () => {
      const response = await apiClient.get('/sessions');
      return response.data;
    },
    getMySessions: async () => {
      const response = await apiClient.get('/sessions/my-sessions');
      return response.data;
    },
    getById: async (id: number) => {
      const response = await apiClient.get(`/sessions/${id}`);
      return response.data;
    },
    update: async (id: number, data: any) => {
      const response = await apiClient.patch(`/sessions/${id}`, data);
      return response.data;
    },
    delete: async (id: number) => {
      const response = await apiClient.delete(`/sessions/${id}`);
      return response.data;
    },
    enroll: async (data: { student_id: number; session_id: number }) => {
      const response = await apiClient.post('/sessions/enroll', data);
      return response.data;
    },
    getStudentEnrollments: async (studentId: number) => {
      const response = await apiClient.get(`/sessions/students/${studentId}/enrollments`);
      return response.data;
    },
  },

  // Videos
  videos: {
    create: async (data: {
      skill_id: number;
      title: string;
      description?: string;
      youtube_url: string;
    }) => {
      const response = await apiClient.post('/videos', data);
      return response.data;
    },
    getAll: async () => {
      const response = await apiClient.get('/videos');
      return response.data;
    },
    getBySkill: async (skillId: number) => {
      const response = await apiClient.get(`/videos/skill/${skillId}`);
      return response.data;
    },
    getById: async (id: number) => {
      const response = await apiClient.get(`/videos/${id}`);
      return response.data;
    },
    update: async (id: number, data: any) => {
      const response = await apiClient.patch(`/videos/${id}`, data);
      return response.data;
    },
    delete: async (id: number) => {
      const response = await apiClient.delete(`/videos/${id}`);
      return response.data;
    },
  },
};

// Helper function to get auth token from Clerk
// This works in client components using Clerk's client-side API
export const getAuthToken = async (): Promise<string | null> => {
  if (typeof window === 'undefined') return null;
  
  try {
    // Use Clerk's client-side getToken function
    // This is the recommended way to get tokens in Next.js App Router client components
    const { getToken } = await import('@clerk/nextjs');
    
    // getToken() can be called without arguments in client components
    // It will automatically use the current session
    const token = await getToken();
    
    if (!token) {
      console.warn('getToken() returned null - user might not be fully authenticated');
      // Try to wait a bit and retry (Clerk might need time to initialize)
      await new Promise(resolve => setTimeout(resolve, 300));
      const retryToken = await getToken();
      return retryToken;
    }
    
    return token;
  } catch (error) {
    console.error('Error getting auth token:', error);
    
    // Fallback: try to get token from Clerk instance on window
    try {
      if ((window as any).__clerk_frontend_api) {
        const clerk = (window as any).__clerk_frontend_api;
        if (clerk.session) {
          return await clerk.session.getToken();
        }
      }
    } catch (fallbackError) {
      console.error('Fallback token retrieval failed:', fallbackError);
    }
    
    return null;
  }
};
