import { useState } from "react";
import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Check, Zap, Star, Rocket } from "lucide-react";
import { CheckoutDialog } from "@/components/checkout-dialog";

const pricingPlans = [
  {
    key: "basic",
    icon: Zap,
    color: "from-blue-500/8 to-cyan-500/8",
    iconBg: "bg-blue-500/10 text-blue-500",
    border: "border-border",
    featured: false,
    features: 4,
  },
  {
    key: "pro",
    icon: Star,
    color: "from-primary/10 to-accent/10",
    iconBg: "bg-primary/10 text-primary",
    border: "border-primary/40",
    featured: true,
    features: 7,
  },
  {
    key: "enterprise",
    icon: Rocket,
    color: "from-violet-500/8 to-purple-500/8",
    iconBg: "bg-violet-500/10 text-violet-500",
    border: "border-border",
    featured: false,
    features: 5,
  },
];

function PricingSection() {
  const { t } = useTranslation("common");
  const [selectedPlan, setSelectedPlan] = useState<any | null>(null);

  return (
    <section id="pricing" className="py-24 bg-background">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("pricing.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("pricing.subtitle")}
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 items-start">
          {pricingPlans.map((plan, index) => {
            const PlanIcon = plan.icon;
            return (
              <motion.div
                key={plan.key}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, amount: 0 }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className={cn(
                  "group relative rounded-2xl border bg-gradient-to-br p-6 flex flex-col gap-5 tech-glass-card transition-all duration-300 hover:-translate-y-1",
                  plan.color,
                  plan.featured ? "border-primary/60 shadow-2xl shadow-primary/5 md:-mt-4 md:pb-10 md:pt-8" : "border-border hover:border-primary/30"
                )}
              >
                {plan.featured ? (
                  <div className="absolute top-0 left-0 w-full h-[3px] bg-gradient-to-r from-primary via-violet-500 to-accent rounded-t-2xl" />
                ) : (
                  <div className="tech-card-glow-bar" />
                )}

                {plan.featured && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2">
                    <span className="bg-primary text-primary-foreground text-xs font-bold px-4 py-1 rounded-full shadow">
                      {t("pricing.popular")}
                    </span>
                  </div>
                )}

                <div className="flex items-center gap-3">
                  <div
                    className={cn(
                      "w-10 h-10 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform duration-300",
                      plan.iconBg
                    )}
                  >
                    <PlanIcon className="w-5 h-5" />
                  </div>
                  <div>
                    <h3 className="font-bold text-foreground group-hover:text-primary transition-colors duration-300">
                      {t(`pricing.${plan.key}.name`)}
                    </h3>
                    <p className="text-xs text-muted-foreground">
                      {t(`pricing.${plan.key}.tagline`)}
                    </p>
                  </div>
                </div>

                <div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-3xl font-black text-foreground">
                      {t(`pricing.${plan.key}.price`)}
                    </span>
                    <span className="text-sm text-muted-foreground">
                      {t("pricing.currency")}
                    </span>
                  </div>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    {t("pricing.perProject")}
                  </p>
                </div>

                <div className="border-t border-border" />

                <ul className="space-y-2.5 flex-1">
                  {Array.from({ length: plan.features }).map((_, featureIndex) => (
                    <li
                      key={featureIndex}
                      className="flex items-start gap-2.5 text-sm"
                    >
                      <Check className="w-4 h-4 text-primary mt-0.5 flex-shrink-0" />
                      <span className="text-foreground/80">
                        {t(`pricing.${plan.key}.feature${featureIndex + 1}`)}
                      </span>
                    </li>
                  ))}
                </ul>

                <Button
                  onClick={() => setSelectedPlan({
                    key: plan.key,
                    name: t(`pricing.${plan.key}.name`),
                    price: t(`pricing.${plan.key}.price`)
                  })}
                  className={cn(
                    "w-full cursor-pointer mt-2",
                    !plan.featured && "variant-secondary"
                  )}
                  variant={plan.featured ? "default" : "secondary"}
                >
                  {t("pricing.cta")}
                </Button>
              </motion.div>
            );
          })}
        </div>

        <motion.p
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="text-center text-sm text-muted-foreground mt-10"
        >
          {t("pricing.note")}
        </motion.p>
      </div>

      {selectedPlan && (
        <CheckoutDialog
          isOpen={!!selectedPlan}
          onClose={() => setSelectedPlan(null)}
          planKey={selectedPlan.key}
          planName={selectedPlan.name}
          planPrice={selectedPlan.price}
        />
      )}
    </section>
  );
}

export { PricingSection as default };
