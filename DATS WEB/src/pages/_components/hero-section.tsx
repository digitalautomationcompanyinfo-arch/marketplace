import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { Button } from "@/components/ui/button";
import { ArrowRight, ArrowLeft, ChevronDown } from "lucide-react";

function HeroSection() {
  const { t, i18n } = useTranslation("common");
  const isRtl = i18n.language === "ar";

  const scrollTo = (selector: string) => {
    document.querySelector(selector)?.scrollIntoView({
      behavior: "smooth",
    });
  };

  const stats = [
    { value: t("hero.stat1.value"), label: t("hero.stat1.label") },
    { value: t("hero.stat2.value"), label: t("hero.stat2.label") },
    { value: t("hero.stat3.value"), label: t("hero.stat3.label") },
  ];

  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  return (
    <section
      id="hero"
      className="relative min-h-screen flex flex-col items-center justify-center overflow-hidden tech-grid-flow"
    >
      {/* Background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-primary/5 via-background to-accent/5" />

      {/* Decorative blurred circles */}
      <div className="absolute inset-0">
        <div className="absolute top-20 left-10 w-72 h-72 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-10 w-96 h-96 bg-accent/10 rounded-full blur-3xl" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-primary/5 rounded-full blur-3xl" />
      </div>

      {/* Grid pattern overlay */}
      <div
        className="absolute inset-0 opacity-[0.03]"
        style={{
          backgroundImage:
            "linear-gradient(var(--foreground) 1px, transparent 1px), linear-gradient(90deg, var(--foreground) 1px, transparent 1px)",
          backgroundSize: "50px 50px",
        }}
      />

      {/* Main content */}
      <div className="relative z-10 max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 text-center py-32 pt-40">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: "easeOut" }}
        >
          <div className="inline-flex items-center gap-2 bg-primary/10 border border-primary/20 text-primary rounded-full px-4 py-1.5 text-sm font-medium mb-8 backdrop-blur-md shadow-sm shadow-primary/5">
            <span className="w-2 h-2 bg-primary rounded-full animate-pulse" />
            {t("hero.badge")}
          </div>
        </motion.div>

        {/* Title, subtitle, description */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1, ease: "easeOut" }}
        >
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-balance mb-4 leading-tight bg-clip-text text-transparent bg-gradient-to-r from-primary via-blue-500 to-accent">
            {t("hero.title")}
          </h1>
          <p className="text-2xl sm:text-3xl font-light text-accent mb-6">
            {t("hero.subtitle")}
          </p>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto text-balance leading-relaxed mb-10">
            {t("hero.description")}
          </p>
        </motion.div>

        {/* CTA Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2, ease: "easeOut" }}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center"
        >
          <Button
            size="lg"
            className="gap-2 cursor-pointer px-8 text-base"
            onClick={() => scrollTo("#services")}
          >
            {t("hero.cta1")}
            <ArrowIcon className="w-4 h-4" />
          </Button>
          <Button
            size="lg"
            variant="secondary"
            className="cursor-pointer px-8 text-base"
            onClick={() => scrollTo("#contact")}
          >
            {t("hero.cta2")}
          </Button>
        </motion.div>

        {/* Stats */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.35, ease: "easeOut" }}
          className="grid grid-cols-3 gap-2 sm:gap-8 md:gap-16 justify-items-center mt-16 pt-10 border-t border-border/50"
        >
          {stats.map((stat, index) => (
            <div key={index} className="text-center">
              <div className="text-2xl sm:text-3xl font-black text-primary">
                {stat.value}
              </div>
              <div className="text-xs sm:text-sm text-muted-foreground mt-1">
                {stat.label}
              </div>
            </div>
          ))}
        </motion.div>
      </div>

      {/* Scroll down indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 -translate-x-1/2 cursor-pointer"
        animate={{ y: [0, 8, 0] }}
        transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}
        onClick={() => scrollTo("#services")}
      >
        <ChevronDown className="w-6 h-6 text-muted-foreground" />
      </motion.div>
    </section>
  );
}

export default HeroSection;
export { HeroSection as wG };
