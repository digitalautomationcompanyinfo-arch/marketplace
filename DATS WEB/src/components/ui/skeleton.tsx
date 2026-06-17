import React from "react";
import { cn } from "@/lib/utils";

function Skeleton({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "bg-muted-foreground/10 rounded-md opacity-0 animate-[fade-in_1s_ease-in-out_1s_forwards,pulse_2s_ease-in-out_1s_infinite]",
        className
      )}
      {...props}
    />
  );
}

export { Skeleton, Skeleton as sp };
