import { useEffect } from "react";
import { useLocation, Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { Pn as Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { Home, ArrowRight, ArrowLeft } from "lucide-react";

export default function NotFound() {
  const location = useLocation();
  const { i18n } = useTranslation("common");
  const isRtl = i18n.language === "ar";
  const Arrow = isRtl ? ArrowLeft : ArrowRight;

  useEffect(() => {
    console.error(
      "404 Error: User attempted to access non-existent route:",
      location.pathname
    );
  }, [location.pathname]);

  return (
    <div
      dir={isRtl ? "rtl" : "ltr"}
      className="min-h-screen flex items-center justify-center bg-background relative overflow-hidden"
    >
      {/* Background decorations */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-10 w-72 h-72 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-10 w-96 h-96 bg-accent/10 rounded-full blur-3xl" />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, ease: "easeOut" }}
        className="relative z-10 text-center space-y-8 px-4"
      >
        {/* Large 404 */}
        <motion.div
          initial={{ scale: 0.8, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <h1 className="text-9xl font-black bg-gradient-to-br from-primary to-accent bg-clip-text text-transparent select-none">
            404
          </h1>
        </motion.div>

        {/* Text content */}
        <div className="space-y-3">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground">
            {isRtl ? "الصفحة غير موجودة" : "Page Not Found"}
          </h2>
          <p className="text-lg text-muted-foreground max-w-md mx-auto">
            {isRtl
              ? "عذراً، الصفحة التي تبحث عنها غير موجودة أو تم نقلها."
              : "Sorry, the page you're looking for doesn't exist or has been moved."}
          </p>
        </div>

        {/* CTA Button */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, delay: 0.3 }}
          className="pt-2"
        >
          <Link to={`/${i18n.language || "ar"}`}>
            <Button size="lg" className="gap-2 cursor-pointer px-8 text-base">
              <Home className="w-4 h-4" />
              {isRtl ? "العودة للرئيسية" : "Return to Home"}
              <Arrow className="w-4 h-4" />
            </Button>
          </Link>
        </motion.div>
      </motion.div>
    </div>
  );
}

export { NotFound as SK };
