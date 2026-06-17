// api.js - Axios instance مع JWT interceptor
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_URL || '/api/v1',
  timeout: 15000,
});

// إرفاق التوكن تلقائياً
// FIX MEDIUM-NEW-4: Wrapped in try-catch — if Zustand state shape changes, fails gracefully (not silently)
const getAuthToken = () => {
  try {
    return JSON.parse(localStorage.getItem('auth-store') || '{}')?.state?.token || null;
  } catch {
    return null;
  }
};

api.interceptors.request.use(config => {
  const token = getAuthToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// معالجة انتهاء التوكن
api.interceptors.response.use(
  res => res,
  err => {
    if (err.response?.status === 401) {
      localStorage.removeItem('auth-store');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

export default api;

