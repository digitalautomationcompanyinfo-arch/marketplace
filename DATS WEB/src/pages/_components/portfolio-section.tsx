import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "react-i18next";
import { X, Check, Cpu, Settings, Globe, Smartphone, ExternalLink } from "lucide-react";
import { Button } from "@/components/ui/button";

const portfolioProjects = [
  {
    key: "p1",
    tags: ["automation", "web"],
    color: "from-blue-500/8 to-indigo-500/8",
    accent: "bg-blue-500/15 text-blue-600",
    gradient: "from-blue-600 to-indigo-600",
  },
  {
    key: "p2",
    tags: ["ai", "web"],
    color: "from-violet-500/8 to-purple-500/8",
    accent: "bg-violet-500/15 text-violet-600",
    gradient: "from-violet-600 to-purple-600",
  },
  {
    key: "p3",
    tags: ["web", "automation"],
    color: "from-emerald-500/8 to-teal-500/8",
    accent: "bg-emerald-500/15 text-emerald-600",
    gradient: "from-emerald-600 to-teal-600",
  },
  {
    key: "p4",
    tags: ["mobile", "ai"],
    color: "from-orange-500/8 to-amber-500/8",
    accent: "bg-orange-500/15 text-orange-600",
    gradient: "from-orange-600 to-amber-600",
  },
  {
    key: "p5",
    tags: ["ai", "automation"],
    color: "from-rose-500/8 to-pink-500/8",
    accent: "bg-rose-500/15 text-rose-600",
    gradient: "from-rose-600 to-pink-600",
  },
  {
    key: "p6",
    tags: ["web", "mobile"],
    color: "from-cyan-500/8 to-sky-500/8",
    accent: "bg-cyan-500/15 text-cyan-600",
    gradient: "from-cyan-600 to-sky-600",
  },
];

const categoryIcons: Record<string, any> = {
  ai: Cpu,
  automation: Settings,
  web: Globe,
  mobile: Smartphone,
};

function PortfolioSection() {
  const { t, i18n } = useTranslation("portfolio");
  const [selectedProject, setSelectedProject] = useState<any | null>(null);

  // Disable scroll when modal is open
  useEffect(() => {
    if (selectedProject) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [selectedProject]);

  const handleRequestService = (projectKey: string) => {
    const projectName = t(`portfolio.${projectKey}.title`);
    let message = "";
    
    if (i18n.language === "ar") {
      message = `مرحباً شركة الأتمتة الرقمية، أود الاستفسار عن خدمة مماثلة لمشروع: "${projectName}".`;
    } else if (i18n.language === "fr") {
      message = `Bonjour Digital Automation, je souhaite me renseigner sur un service similaire pour le projet: "${projectName}".`;
    } else if (i18n.language === "it") {
      message = `Buongiorno Digital Automation, desidero informazioni su un servizio simile per il progetto: "${projectName}".`;
    } else if (i18n.language === "zh") {
      message = `您好，数字自动化，我想咨询关于类似项目的服务："${projectName}"。`;
    } else {
      message = `Hello Digital Automation, I would like to inquire about a similar service for the project: "${projectName}".`;
    }

    window.dispatchEvent(
      new CustomEvent("portfolio-request-service", {
        detail: { message },
      })
    );

    setSelectedProject(null);
  };

  return (
    <section id="portfolio" className="py-24 bg-background">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("portfolio.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("portfolio.subtitle")}
          </p>
        </motion.div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {portfolioProjects.map((project, index) => (
            <motion.div
              key={project.key}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, amount: 0 }}
              transition={{ duration: 0.5, delay: index * 0.08 }}
              className={`group relative bg-gradient-to-br ${project.color} tech-glass-card tech-card-hover border border-border rounded-2xl p-6 transition-all duration-300`}
            >
              <div className="tech-card-glow-bar" />
              <div className="flex flex-wrap gap-2 mb-4">
                {project.tags.map((tag) => (
                  <span
                    key={tag}
                    className={`text-xs font-semibold px-2.5 py-1 rounded-full ${project.accent}`}
                  >
                    {t(`portfolio.tag.${tag}`)}
                  </span>
                ))}
              </div>

              <h3 className="font-bold text-base text-foreground mb-2 leading-snug group-hover:text-primary transition-colors duration-300">
                {t(`portfolio.${project.key}.title`)}
              </h3>
              <p className="text-muted-foreground text-sm leading-relaxed mb-4">
                {t(`portfolio.${project.key}.desc`)}
              </p>

              <button
                onClick={() => setSelectedProject(project)}
                className="flex items-center gap-1.5 text-xs font-semibold text-muted-foreground hover:text-foreground transition-colors cursor-pointer group-hover:gap-2"
              >
                <ExternalLink className="w-3.5 h-3.5" />
                <span>{t("portfolio.viewProject")}</span>
              </button>
            </motion.div>
          ))}
        </div>
      </div>

      {/* Details Modal */}
      <AnimatePresence>
        {selectedProject && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            {/* Backdrop */}
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedProject(null)}
              className="absolute inset-0 bg-black/60 backdrop-blur-md"
            />

            {/* Content box */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95, y: 15 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.95, y: 15 }}
              transition={{ duration: 0.3, ease: "easeOut" }}
              className="relative w-full max-w-2xl bg-card border border-border rounded-3xl shadow-2xl overflow-hidden z-10 max-h-[90vh] flex flex-col"
            >
              {/* Header gradient banner */}
              <div className={`h-24 bg-gradient-to-r ${selectedProject.gradient} relative opacity-90 shrink-0`}>
                <div className="absolute inset-0 bg-black/10" />
                <button
                  onClick={() => setSelectedProject(null)}
                  className="absolute top-4 end-4 w-9 h-9 rounded-full bg-black/20 hover:bg-black/40 text-white flex items-center justify-center transition-colors cursor-pointer"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              {/* Scrollable details */}
              <div className="p-6 sm:p-8 overflow-y-auto space-y-6">
                <div>
                  <div className="flex flex-wrap gap-2 mb-3">
                    {selectedProject.tags.map((tag: string) => {
                      const Icon = categoryIcons[tag] || Globe;
                      return (
                        <span
                          key={tag}
                          className={`inline-flex items-center gap-1 text-xs font-semibold px-3 py-1 rounded-full ${selectedProject.accent}`}
                        >
                          <Icon className="w-3.5 h-3.5" />
                          {t(`portfolio.tag.${tag}`)}
                        </span>
                      );
                    })}
                  </div>
                  <h3 className="text-2xl font-black text-foreground">
                    {t(`portfolio.${selectedProject.key}.title`)}
                  </h3>
                </div>

                {/* Description */}
                <div className="space-y-2">
                  <p className="text-muted-foreground text-sm sm:text-base leading-relaxed">
                    {t(`portfolio.${selectedProject.key}.details.description`)}
                  </p>
                </div>

                {/* Key Features */}
                <div className="space-y-3">
                  <h4 className="font-bold text-sm sm:text-base text-foreground">
                    {i18n.language === "ar" ? "أهم المميزات" : "Key Features"}
                  </h4>
                  <ul className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                    {t(`portfolio.${selectedProject.key}.details.features`)
                      .split(",")
                      .map((feature: string, idx: number) => (
                        <li key={idx} className="flex items-start gap-2 text-sm text-foreground">
                          <Check className="w-4 h-4 text-emerald-500 mt-0.5 shrink-0" />
                          <span>{feature.trim()}</span>
                        </li>
                      ))}
                  </ul>
                </div>

                {/* Technologies */}
                <div className="space-y-3 pt-2">
                  <h4 className="font-bold text-sm sm:text-base text-foreground">
                    {i18n.language === "ar" ? "التقنيات المستخدمة" : "Technologies Used"}
                  </h4>
                  <div className="flex flex-wrap gap-2">
                    {t(`portfolio.${selectedProject.key}.details.tech`)
                      .split(",")
                      .map((tech: string) => (
                        <span
                          key={tech}
                          className="bg-muted text-muted-foreground text-xs font-mono font-medium px-2.5 py-1 rounded-md border border-border/80"
                        >
                          {tech.trim()}
                        </span>
                      ))}
                  </div>
                </div>
              </div>

              {/* Actions Footer */}
              <div className="p-6 border-t border-border bg-muted/20 shrink-0 flex flex-col sm:flex-row gap-3 justify-end items-center">
                <Button
                  variant="ghost"
                  onClick={() => setSelectedProject(null)}
                  className="w-full sm:w-auto cursor-pointer"
                >
                  {i18n.language === "ar" ? "إغلاق" : "Close"}
                </Button>
                <Button
                  onClick={() => handleRequestService(selectedProject.key)}
                  className="w-full sm:w-auto cursor-pointer"
                >
                  {t("portfolio.requestSimilar")}
                </Button>
              </div>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </section>
  );
}

export { PortfolioSection as default };

