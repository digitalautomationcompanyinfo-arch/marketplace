import * as React from "react";
import { QueryClient, QueryClientProvider as Provider } from "@tanstack/react-query";

const queryClient = new QueryClient();

interface QueryClientProviderProps {
  children: React.ReactNode;
}

export function QueryClientProvider({ children }: QueryClientProviderProps) {
  return (
    <Provider client={queryClient}>
      {children}
    </Provider>
  );
}
