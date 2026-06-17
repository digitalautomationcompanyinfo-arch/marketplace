import { Suspense } from "react";
import { Navigate, Outlet, Route, Routes, BrowserRouter } from "react-router-dom";
import { DefaultProviders } from "@/components/providers/default";
import { LocaleWrapper } from "@/components/providers/locale-wrapper";
import AuthCallback from "@/pages/auth/Callback";
import AdminPage from "@/pages/admin/page";
import IndexPage from "@/pages/Index";
import BlogListPage from "@/pages/blog/list";
import BlogPostPage from "@/pages/blog/post";
import NotFound from "@/pages/NotFound";
import { formatLocalePath, defaultLanguage } from "@/lib/locale";

export default function App() {
  return (
    <DefaultProviders>
      <BrowserRouter>
        <Suspense fallback={<div className="min-h-screen bg-background" />}>
          <Routes>
            <Route
              path="/"
              element={<Navigate to={formatLocalePath(defaultLanguage, "/")} replace />}
            />
            <Route path="/auth/callback" element={<AuthCallback />} />
            <Route path="/admin" element={<AdminPage />} />
            <Route
              path="/:lng"
              element={
                <LocaleWrapper>
                  <Outlet />
                </LocaleWrapper>
              }
            >
              <Route index element={<IndexPage />} />
              <Route path="blog" element={<BlogListPage />} />
              <Route path="blog/:slug" element={<BlogPostPage />} />
              <Route path="*" element={<NotFound />} />
            </Route>
          </Routes>
        </Suspense>
      </BrowserRouter>
    </DefaultProviders>
  );
}

export { App as LW };
