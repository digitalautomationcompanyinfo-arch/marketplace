import { motion } from "framer-motion";
import { useTranslation } from "react-i18next";
import { Star, Quote } from "lucide-react";

const TESTIMONIALS = [
  { key: "t1", avatar: "AN" },
  { key: "t2", avatar: "FA" },
  { key: "t3", avatar: "OI" },
  { key: "t4", avatar: "MH" },
];

const AVATAR_COLORS = [
  "bg-blue-500",
  "bg-violet-500",
  "bg-emerald-500",
  "bg-orange-500",
];

function TestimonialsSection() {
  const { t } = useTranslation("portfolio");

  return (
    <section id="testimonials" className="py-24 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("testimonials.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("testimonials.subtitle")}
          </p>
        </motion.div>

        {/* Testimonials Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
          {TESTIMONIALS.map((testimonial, index) => (
            <motion.div
              key={testimonial.key}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="group relative tech-glass-card tech-card-hover border border-border rounded-2xl p-6 transition-all duration-300"
            >
              <div className="tech-card-glow-bar" />
              {/* Quote Icon */}
              <Quote className="absolute top-5 end-5 w-8 h-8 text-primary/10" />

              {/* Star Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: 5 }).map((_, starIndex) => (
                  <Star
                    key={starIndex}
                    className="w-4 h-4 fill-amber-400 text-amber-400"
                  />
                ))}
              </div>

              {/* Testimonial Text */}
              <p className="text-foreground/80 text-sm leading-relaxed mb-6 italic">
                {`"${t(`testimonials.${testimonial.key}.text`)}"`}
              </p>

              {/* Author Info */}
              <div className="flex items-center gap-3">
                <div
                  className={`w-10 h-10 rounded-full ${AVATAR_COLORS[index]} flex items-center justify-center text-white font-bold text-sm flex-shrink-0 group-hover:scale-105 transition-transform duration-300`}
                >
                  {testimonial.avatar}
                </div>
                <div>
                  <p className="font-bold text-sm text-foreground group-hover:text-primary transition-colors duration-300">
                    {t(`testimonials.${testimonial.key}.name`)}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {t(`testimonials.${testimonial.key}.role`)}
                  </p>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}

export { TestimonialsSection as UG };
export default TestimonialsSection;
