import React from "react";
import { Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface SpinnerProps extends React.ComponentPropsWithoutRef<typeof Loader2> {}

export function Spinner({ className, ...props }: SpinnerProps) {
  return (
    <Loader2
      role="status"
      aria-label="Loading"
      className={cn("size-4 animate-spin", className)}
      {...props}
    />
  );
}

export { Spinner as zV };
