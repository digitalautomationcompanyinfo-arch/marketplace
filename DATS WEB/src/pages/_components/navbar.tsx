import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";
import { useTheme } from "next-themes";
import { useLocation, useNavigate } from "react-router-dom";
import { LocaleSwitcher } from "@/components/ui/locale-switcher";
import { Button } from "@/components/ui/button";
import { Sun, Moon, Menu, X } from "lucide-react";

function Navbar() {
  const { t, i18n } = useTranslation("common");
  const [isScrolled, setIsScrolled] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { theme, setTheme } = useTheme();
  const location = useLocation();
  const navigate = useNavigate();
  const lng = i18n.language || "ar";

  useEffect(() => {
    const handleScroll = () => setIsScrolled(window.scrollY > 20);
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  const navLinks = [
    { label: t("nav.home"), href: "#hero" },
    { label: t("nav.services"), href: "#services" },
    { label: t("nav.about"), href: "#about" },
    { label: t("nav.contact"), href: "#contact" },
    { label: t("nav.blog"), href: `/${lng}/blog`, isExternal: true },
  ];

  const handleNavClick = (link: { href: string; isExternal?: boolean }) => {
    setIsMobileMenuOpen(false);
    if (link.isExternal) {
      navigate(link.href);
      return;
    }

    const isMainPage = location.pathname === `/${lng}` || location.pathname === `/${lng}/`;
    if (isMainPage) {
      document.querySelector(link.href)?.scrollIntoView({ behavior: "smooth" });
    } else {
      navigate(`/${lng}${link.href}`);
    }
  };

  const toggleTheme = () => setTheme(theme === "dark" ? "light" : "dark");

  return (
    <header
      className={cn(
        "fixed top-0 left-0 right-0 z-50 transition-all duration-300",
        isScrolled
          ? "bg-background/95 backdrop-blur-md shadow-sm border-b border-border"
          : "bg-transparent"
      )}
    >
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <div
            onClick={() => navigate(`/${lng}`)}
            className="flex items-center gap-2 cursor-pointer select-none"
          >
            <img
              src="/logo.jpg"
              alt="Logo"
              className="w-10 h-10 object-contain rounded-md border border-border/40"
            />
            <span className="font-bold text-lg text-foreground tracking-tight">
              {t("footer.company")}
            </span>
          </div>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-6">
            {navLinks.map((link) => (
              <button
                key={link.href}
                onClick={() => handleNavClick(link)}
                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
              >
                {link.label}
              </button>
            ))}
          </nav>

          {/* Actions */}
          <div className="flex items-center gap-1">
            {/* Language Switcher */}
            <LocaleSwitcher />

            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="p-2 rounded-md text-muted-foreground hover:text-foreground hover:bg-muted transition-colors cursor-pointer"
              aria-label="Toggle theme"
            >
              <AnimatePresence mode="wait">
                {theme === "dark" ? (
                  <motion.span
                    key="sun"
                    initial={{ rotate: -90, opacity: 0 }}
                    animate={{ rotate: 0, opacity: 1 }}
                    exit={{ rotate: 90, opacity: 0 }}
                    transition={{ duration: 0.2 }}
                    className="block"
                  >
                    <Sun className="w-4 h-4" />
                  </motion.span>
                ) : (
                  <motion.span
                    key="moon"
                    initial={{ rotate: 90, opacity: 0 }}
                    animate={{ rotate: 0, opacity: 1 }}
                    exit={{ rotate: -90, opacity: 0 }}
                    transition={{ duration: 0.2 }}
                    className="block"
                  >
                    <Moon className="w-4 h-4" />
                  </motion.span>
                )}
              </AnimatePresence>
            </button>

            {/* Desktop CTA Button */}
            <Button
              size="sm"
              className="hidden md:flex cursor-pointer ms-1"
              onClick={() => handleNavClick({ href: "#contact" })}
            >
              {t("nav.cta")}
            </Button>

            {/* Mobile Menu Toggle */}
            <button
              className="md:hidden p-2 cursor-pointer"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? (
                <X className="w-5 h-5" />
              ) : (
                <Menu className="w-5 h-5" />
              )}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            transition={{ duration: 0.2 }}
            className="md:hidden bg-background/95 backdrop-blur-md border-b border-border px-4 pb-4"
          >
            {navLinks.map((link) => (
              <button
                key={link.href}
                onClick={() => handleNavClick(link)}
                className="block w-full text-start py-3 text-sm font-medium text-muted-foreground hover:text-foreground border-b border-border last:border-0 cursor-pointer"
              >
                {link.label}
              </button>
            ))}
            <Button
              size="sm"
              className="w-full mt-3 cursor-pointer"
              onClick={() => handleNavClick({ href: "#contact" })}
            >
              {t("nav.cta")}
            </Button>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}

export { Navbar, Navbar as bG };
export default Navbar;
