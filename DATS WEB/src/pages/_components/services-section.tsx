import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { toast } from "sonner";
import {
  ArrowRight,
  ArrowLeft,
  Zap,
  Building2,
  Rocket,
  MapPin,
} from "lucide-react";

const cardGradients = [
  "from-blue-500/10 to-indigo-500/10 border-blue-500/20",
  "from-orange-500/10 to-amber-500/10 border-orange-500/20",
  "from-emerald-500/10 to-teal-500/10 border-emerald-500/20",
  "from-violet-500/10 to-purple-500/10 border-violet-500/20",
];

const cardIcons = [Zap, Building2, Rocket, MapPin];

const cardIconColors = [
  "text-blue-500",
  "text-orange-500",
  "text-emerald-500",
  "text-violet-500",
];

function ServicesSection() {
  const { t, i18n } = useTranslation("common");
  const ArrowIcon = i18n.language === "ar" ? ArrowLeft : ArrowRight;
  const serviceKeys = ["ai", "automation", "apps", "web"];

  return (
    <section id="services" className="py-24 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5, ease: "easeOut" }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("services.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("services.subtitle")}
          </p>
        </motion.div>

        {/* Service cards grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {serviceKeys.map((key, index) => {
            const Icon = cardIcons[index];
            return (
              <motion.div
                key={key}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, amount: 0 }}
                transition={{
                  duration: 0.5,
                  delay: index * 0.1,
                  ease: "easeOut",
                }}
                className={`group relative bg-gradient-to-br ${cardGradients[index]} tech-glass-card tech-card-hover border rounded-2xl p-6 transition-all duration-300`}
              >
                <div className="tech-card-glow-bar" />
                <div className="w-12 h-12 rounded-xl bg-background flex items-center justify-center mb-4 shadow-sm group-hover:scale-110 transition-transform duration-300">
                  <Icon className={`w-6 h-6 ${cardIconColors[index]}`} />
                </div>
                <h3 className="font-bold text-lg text-foreground mb-2 group-hover:text-primary transition-colors duration-300">
                  {t(`services.${key}.title`)}
                </h3>
                <p className="text-muted-foreground text-sm leading-relaxed mb-4">
                  {t(`services.${key}.desc`)}
                </p>
                <button
                  onClick={() =>
                    toast.info("Coming soon in a future milestone!")
                  }
                  className={`flex items-center gap-1 text-sm font-medium ${cardIconColors[index]} cursor-pointer hover:gap-2 transition-all`}
                >
                  {t("services.learnMore")}
                  <ArrowIcon className="w-4 h-4" />
                </button>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export default ServicesSection;
export { ServicesSection as TG };
