import React, { forwardRef, useCallback, useEffect } from "react";
import { useAuth } from "@/components/providers/auth";
import { Button } from "@/components/ui/button";
import { Loader2, LogIn, LogOut } from "lucide-react";
import { toast } from "sonner";

interface SignInButtonProps extends React.ComponentPropsWithoutRef<typeof Button> {
  showIcon?: boolean;
  signInText?: string;
  signOutText?: string;
  loadingText?: string;
}

export const SignInButton = forwardRef<HTMLButtonElement, SignInButtonProps>((
  {
    onClick,
    disabled,
    showIcon = true,
    signInText = "Sign In",
    signOutText = "Sign Out",
    loadingText,
    className,
    variant,
    size,
    asChild = false,
    ...props
  },
  ref
) => {
  const { isAuthenticated, signin, signout, isLoading, error } = useAuth();

  useEffect(() => {
    if (error) {
      toast.error("Login error", { description: error.message });
      console.error("Login error", error);
    }
  }, [error]);

  const handleAuth = useCallback(
    async (e: React.MouseEvent<HTMLButtonElement>) => {
      onClick?.(e);
      try {
        if (isAuthenticated) {
          await signout();
        } else {
          await signin();
        }
      } catch (err) {
        console.error("Authentication error:", err);
      }
    },
    [isAuthenticated, signout, signin, onClick]
  );

  const isBtnDisabled = disabled || isLoading;
  const buttonText = isLoading
    ? loadingText || (isAuthenticated ? "Signing Out..." : "Signing In...")
    : isAuthenticated
    ? signOutText
    : signInText;

  const Icon = isLoading ? (
    <Loader2 className="size-4 animate-spin" />
  ) : isAuthenticated ? (
    <LogOut className="size-4" />
  ) : (
    <LogIn className="size-4" />
  );

  return (
    <Button
      ref={ref}
      onClick={handleAuth}
      disabled={isBtnDisabled}
      variant={variant}
      size={size}
      className={className}
      asChild={asChild}
      aria-label={isAuthenticated ? "Sign out of your account" : "Sign in to your account"}
      {...props}
    >
      {showIcon && Icon}
      {buttonText}
    </Button>
  );
});

SignInButton.displayName = "SignInButton";

export { SignInButton as LR };
