import * as React from "react";
import { useParams, useLocation, Navigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { isValidLanguage, changeLanguage, formatLocalePath, defaultLanguage } from "@/lib/locale";

interface LocaleWrapperProps {
  children: React.ReactNode;
}

export function LocaleWrapper({ children }: LocaleWrapperProps) {
  const { lng } = useParams<{ lng: string }>();
  const { i18n } = useTranslation();
  const location = useLocation();

  React.useEffect(() => {
    if (lng && isValidLanguage(lng)) {
      changeLanguage(lng, i18n);
    }
  }, [lng, i18n]);

  if (lng && lng !== lng.toLowerCase()) {
    const path = formatLocalePath(lng.toLowerCase(), location.pathname, location.search, location.hash);
    return <Navigate to={path} replace />;
  }

  if (!lng || !isValidLanguage(lng)) {
    const path = formatLocalePath(defaultLanguage, location.pathname, location.search, location.hash);
    return <Navigate to={path} replace />;
  }

  return <>{children}</>;
}
