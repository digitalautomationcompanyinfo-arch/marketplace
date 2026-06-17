import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from 'react-hot-toast';
import { useAuthStore } from './store/authStore';

import AdminLayout       from './components/layout/AdminLayout';
import LoginPage         from './pages/auth/LoginPage';
import DashboardPage     from './pages/dashboard/DashboardPage';
import ProvidersPage     from './pages/providers/ProvidersPage';
import PendingPage       from './pages/providers/PendingPage';
import UsersPage         from './pages/users/UsersPage';
import CategoriesPage    from './pages/categories/CategoriesPage';
import SubscriptionsPage from './pages/subscriptions/SubscriptionsPage';
import NotificationsPage from './pages/notifications/NotificationsPage';
import ReportsPage       from './pages/reports/ReportsPage';
import AuditLogPage      from './pages/audit/AuditLogPage';
import OrdersPage        from './pages/orders/OrdersPage';
import RevenuePage       from './pages/revenue/RevenuePage';
import RevenueMapPage    from './pages/revenue/RevenueMapPage';
import PromotionsPage    from './pages/promotions/PromotionsPage';
import ChatModerationPage from './pages/chats/ChatModerationPage';
import SettingsPage      from './pages/settings/SettingsPage';
import StatesPage        from './pages/geographic/StatesPage';
import MarketsPage       from './pages/geographic/MarketsPage';
import ErrorLogsPage     from './pages/system/ErrorLogsPage';

const queryClient = new QueryClient({
  defaultOptions: { queries: { retry: 1, staleTime: 60_000 } },
});

// FIX MEDIUM-T2: Validate JWT expiry client-side to avoid operating on expired sessions
// Uses native atob() — no external library required
function isTokenValid(token) {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return typeof payload.exp === 'number' && payload.exp > Date.now() / 1000;
  } catch {
    return false;
  }
}

function ProtectedRoute({ children }) {
  const token = useAuthStore(s => s.token);
  return token && isTokenValid(token) ? children : <Navigate to="/login" replace />;
}

class ErrorBoundary extends React.Component {
  state = { hasError: false };
  static getDerivedStateFromError(error) { return { hasError: true }; }
  render() {
    if (this.state.hasError) return <div className="p-10 text-center">حدث خطأ في النظام. يرجى تحديث الصفحة.</div>;
    return this.props.children;
  }
}

import SubscriptionApprovalsPage from './pages/subscriptions/SubscriptionApprovalsPage';

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Toaster position="top-center" toastOptions={{ duration: 3000 }} />
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route path="/" element={
            <ProtectedRoute>
              <ErrorBoundary>
                <AdminLayout />
              </ErrorBoundary>
            </ProtectedRoute>
          }>
            <Route index element={<Navigate to="/dashboard" />} />
            <Route path="dashboard"         element={<DashboardPage />} />
            <Route path="providers"         element={<ProvidersPage />} />
            <Route path="providers/pending" element={<PendingPage />} />
            <Route path="users"             element={<UsersPage />} />
            <Route path="orders"            element={<OrdersPage />} />
            <Route path="categories"        element={<CategoriesPage />} />
            <Route path="subscriptions"     element={<SubscriptionsPage />} />
            <Route path="subscriptions/approvals" element={<SubscriptionApprovalsPage />} />
            <Route path="revenue"           element={<RevenuePage />} />
            <Route path="revenue/map"       element={<RevenueMapPage />} />
            <Route path="promotions"        element={<PromotionsPage />} />
            <Route path="notifications"     element={<NotificationsPage />} />
            <Route path="chats"             element={<ChatModerationPage />} />
            <Route path="reports"           element={<ReportsPage />} />
             <Route path="audit"             element={<AuditLogPage />} />
            <Route path="settings"          element={<SettingsPage />} />
            <Route path="states"            element={<StatesPage />} />
            <Route path="markets"           element={<MarketsPage />} />
            <Route path="system/pulse"      element={<ErrorLogsPage />} />
          </Route>
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  );
}

