import React, { useState, useEffect, useRef, useCallback } from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import { useNavigate } from "react-router-dom";
import { useMutation, useConvexAuth } from "convex/react";
import { useAuth } from "@/components/providers/auth";
import { api } from "../../../convex/_generated/api";
import { Spinner } from "@/components/ui/spinner";
import { Button } from "@/components/ui/button";

const T = { jsx, jsxs, Fragment: React.Fragment };

const timeoutMsDefault = 15000;
const hasAuthParams = () => typeof window !== "undefined" && window.location.search.includes("code=");

function useAuthSync(options: any = {}) {
  const {
    timeoutMs = timeoutMsDefault,
    isBackendAuthenticated = true,
    onSync,
    onSuccess,
    onNoAuthParams
  } = options;

  const { isLoading, isAuthenticated, error: authError, signinRedirect } = useAuth();
  const [status, setStatus] = useState("processing-oauth");
  const [error, setError] = useState<string | null>(null);

  const isMounted = useRef(true);
  const wasRedirected = useRef(hasAuthParams());
  const syncTriggered = useRef(false);

  useEffect(() => {
    isMounted.current = true;
    syncTriggered.current = false;
    return () => {
      isMounted.current = false;
    };
  }, []);

  // Timeout effect
  useEffect(() => {
    if (status === "success" || status === "error") return;
    const timer = setTimeout(() => {
      if (isMounted.current) {
        setStatus("error");
        setError("Authentication timed out. Please try again.");
      }
    }, timeoutMs);
    return () => clearTimeout(timer);
  }, [status, timeoutMs]);

  // Auth state listener
  useEffect(() => {
    if (status === "success" || status === "error") return;

    if (authError) {
      setStatus("error");
      setError(authError.message || "Authentication failed");
      return;
    }

    if (!wasRedirected.current && !isLoading && !isAuthenticated) {
      onNoAuthParams?.();
      return;
    }

    if (!isLoading && isAuthenticated && status === "processing-oauth") {
      setStatus("waiting-backend");
      return;
    }

    if (wasRedirected.current && !isLoading && !isAuthenticated && !authError && status === "processing-oauth") {
      const timer = setTimeout(() => {
        if (isMounted.current && !isAuthenticated) {
          setStatus("error");
          setError("Authentication was cancelled or failed. Please try again.");
        }
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [isLoading, isAuthenticated, authError, status, onNoAuthParams]);

  // Sync with backend
  useEffect(() => {
    if (status !== "waiting-backend" || !isBackendAuthenticated || syncTriggered.current) return;
    syncTriggered.current = true;

    async function sync() {
      if (isMounted.current) {
        setStatus("syncing");
        try {
          if (onSync) await onSync();
          if (isMounted.current) setStatus("success");
        } catch (err: any) {
          console.error("Auth callback sync failed:", err);
          if (!isMounted.current) return;
          const msg = err instanceof Error ? err.message : "Failed to complete authentication. Please try again.";
          setStatus("error");
          setError(msg);
        }
      }
    }
    sync();
  }, [status, isBackendAuthenticated, onSync]);

  // Success handler
  useEffect(() => {
    if (status === "success") {
      onSuccess?.();
    }
  }, [status, onSuccess]);

  const retry = useCallback(async () => {
    try {
      await signinRedirect();
    } catch (z) {
      console.error("Failed to restart auth:", z);
    }
  }, [signinRedirect]);

  return {
    status,
    error,
    isLoading: status !== "success" && status !== "error",
    isSuccess: status === "success",
    isError: status === "error",
    retry
  };
}

export default function AuthCallback() {
  const navigate = useNavigate();
  const { isAuthenticated } = useConvexAuth();
  const updateCurrentUser = useMutation(api.users.updateCurrentUser as any);

  const handleSync = useCallback(async () => {
    await updateCurrentUser();
  }, [updateCurrentUser]);

  const handleSuccess = useCallback(() => {
    navigate("/", { replace: true });
  }, [navigate]);

  const { status, error, retry } = useAuthSync({
    isBackendAuthenticated: isAuthenticated,
    onSync: handleSync,
    onSuccess: handleSuccess,
    onNoAuthParams: handleSuccess,
  });

  if (status === "error" && error) {
    return T.jsxs("div", {
      className: "flex flex-col items-center justify-center h-svh gap-6 px-4",
      children: [
        T.jsxs("div", {
          className: "flex flex-col items-center gap-2 text-center",
          children: [
            T.jsx("p", { className: "text-destructive font-medium", children: "Something went wrong" }),
            T.jsx("p", { className: "text-sm text-muted-foreground max-w-md", children: error }),
          ],
        }),
        T.jsxs("div", {
          className: "flex gap-3",
          children: [
            T.jsx(Button, { variant: "secondary", onClick: handleSuccess, children: "Return home" }),
            T.jsx(Button, { onClick: retry, children: "Try again" }),
          ],
        }),
      ],
    });
  }

  return T.jsxs("div", {
    className: "flex flex-col items-center justify-center h-svh gap-4",
    children: [
      T.jsx(Spinner, { className: "size-8" }),
      T.jsx("p", { className: "text-sm text-muted-foreground", children: "Loading..." }),
    ],
  });
}
