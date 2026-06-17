import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { MapPin, Star, HeartHandshake, Rocket } from "lucide-react";

const icons = [MapPin, Star, HeartHandshake, Rocket];
const cardKeys = ["local", "quality", "support", "fast"];
const cardColors = [
  "bg-blue-500/10 text-blue-500",
  "bg-amber-500/10 text-amber-500",
  "bg-emerald-500/10 text-emerald-500",
  "bg-violet-500/10 text-violet-500",
];

function WhyUsSection() {
  const { t } = useTranslation("common");

  return (
    <section id="why" className="py-24 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("why.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("why.subtitle")}
          </p>
        </motion.div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {cardKeys.map((cardKey, index) => {
            const Icon = icons[index];
            return (
              <motion.div
                key={cardKey}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, amount: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="group relative tech-glass-card tech-card-hover border rounded-2xl p-6 text-center transition-all duration-300"
              >
                <div className="tech-card-glow-bar" />
                <div
                  className={`w-14 h-14 rounded-2xl ${cardColors[index]} flex items-center justify-center mx-auto mb-4 group-hover:scale-110 transition-transform duration-300`}
                >
                  <Icon className="w-7 h-7" />
                </div>
                <h3 className="font-bold text-foreground mb-2 group-hover:text-primary transition-colors duration-300">
                  {t(`why.${cardKey}.title`)}
                </h3>
                <p className="text-muted-foreground text-sm leading-relaxed">
                  {t(`why.${cardKey}.desc`)}
                </p>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
}

export { WhyUsSection as default };
