import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { MapPin, Building2, Target } from "lucide-react";

function AboutSection() {
  const { t } = useTranslation("common");

  return (
    <section id="about" className="py-24 bg-background tech-grid-flow">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left column — Image with overlays */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, amount: 0 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="relative"
          >
            <div className="relative rounded-3xl overflow-hidden shadow-2xl aspect-[4/3]">
              <img
                src="https://images.unsplash.com/photo-1758626104169-6835c0bd03e3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080"
                alt="Digital Automation"
                className="w-full h-full object-cover"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-primary/60 to-transparent" />
              <div className="absolute bottom-6 left-6 right-6">
                <div className="flex items-center gap-2 text-white">
                  <MapPin className="w-5 h-5 flex-shrink-0" />
                  <span className="font-medium">
                    {t("about.locationText")}
                  </span>
                </div>
              </div>
            </div>

            {/* Floating company card */}
            <div className="absolute -bottom-6 end-4 sm:-end-6 tech-glass-card border border-border rounded-2xl p-4 shadow-xl group hover:border-primary/40 transition-all duration-300">
              <div className="tech-card-glow-bar" />
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-accent/10 flex items-center justify-center group-hover:scale-105 transition-transform duration-300">
                  <Building2 className="w-6 h-6 text-accent animate-pulse" />
                </div>
                <div>
                  <div className="font-bold text-sm text-foreground">
                    {t("footer.company")}
                  </div>
                  <div className="text-xs text-muted-foreground">
                    Sudan, Kassala
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Right column — Text content */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, amount: 0 }}
            transition={{ duration: 0.6, ease: "easeOut" }}
            className="space-y-6"
          >
            <div>
              <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-2">
                {t("about.title")}
              </h2>
              <p className="text-accent font-semibold text-lg">
                {t("about.subtitle")}
              </p>
            </div>

            <p className="text-muted-foreground leading-relaxed text-base">
              {t("about.description")}
            </p>

            {/* Mission card */}
            <div className="bg-primary/5 border border-primary/15 rounded-2xl p-5">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Target className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <h4 className="font-bold text-foreground mb-1">
                    {t("about.mission")}
                  </h4>
                  <p className="text-muted-foreground text-sm leading-relaxed">
                    {t("about.missionText")}
                  </p>
                </div>
              </div>
            </div>

            {/* Location line */}
            <div className="flex items-center gap-3 text-muted-foreground">
              <MapPin className="w-5 h-5 text-accent flex-shrink-0" />
              <span className="font-medium">{t("about.locationText")}</span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}

export default AboutSection;
export { AboutSection as EG };
