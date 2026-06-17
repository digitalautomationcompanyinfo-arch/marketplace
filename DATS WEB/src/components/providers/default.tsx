import React from "react";
import { AuthProvider } from "./auth";
import { ConvexProvider } from "./convex";
import { QueryClientProvider } from "./query-client";
import { TooltipProvider } from "@/components/ui/tooltip";
import { ThemeProvider } from "./theme";
import { Toaster } from "@/components/ui/sonner";

export function DefaultProviders({ children }: { children: React.ReactNode }) {
  return (
    <AuthProvider>
      <ConvexProvider>
        <QueryClientProvider>
          <TooltipProvider>
            <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
              <Toaster />
              {children}
            </ThemeProvider>
          </TooltipProvider>
        </QueryClientProvider>
      </ConvexProvider>
    </AuthProvider>
  );
}

export { DefaultProviders as oB };
