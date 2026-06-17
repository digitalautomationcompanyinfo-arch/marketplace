// authStore.js
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export const useAuthStore = create(
  persist(
    (set) => ({
      token: null,
      admin: null,
      login: (token, admin) => set({ token, admin }),
      logout: () => set({ token: null, admin: null }),
    }),
    { name: 'auth-store' }
  )
);

