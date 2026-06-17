import { useEffect } from "react";
import { useTranslation } from "react-i18next";

const $T: Record<string, { title: string; description: string; lang: string }> = {
  ar: {
    title: "الاتمتة الرقمية | حلول الذكاء الاصطناعي وأتمتة الأعمال",
    description: "شركة رائدة في التقنية والذكاء الاصطناعي. نقدم حلولاً متكاملة في الذكاء الاصطناعي، وأتمتة الأعمال، وتطوير التطبيقات والمواقع الإلكترونية.",
    lang: "ar"
  },
  en: {
    title: "Digital Automation | AI Solutions & Business Automation",
    description: "A leading technology and AI company. We offer integrated solutions in artificial intelligence, business automation, application and website development.",
    lang: "en"
  },
  fr: {
    title: "Digital Automation | Solutions d'IA & Automatisation",
    description: "Une entreprise leader en technologie et IA. Nous proposons des solutions intégrées en intelligence artificielle, automatisation des processus et développement.",
    lang: "fr"
  },
  it: {
    title: "Digital Automation | Soluzioni IA & Automazione Aziendale",
    description: "Un'azienda leader nella tecnologia e nell'intelligenza artificiale. Offriamo soluzioni integrate in intelligenza artificiale, automazione aziendale e sviluppo.",
    lang: "it"
  },
  zh: {
    title: "数字自动化 | 人工智能解决方案与业务自动化",
    description: "领先的技术与人工智能公司。我们提供人工智能、业务自动化以及应用程序 and 网站开发的综合解决方案。",
    lang: "zh"
  }
};

export default function SeoHead() {
  const { i18n } = useTranslation();
  const lang = i18n.language ?? "ar";
  const metadata = $T[lang] ?? $T.ar;

  useEffect(() => {
    document.title = metadata.title;
    document.documentElement.lang = metadata.lang;

    const setMeta = (nameOrProperty: string, content: string, isProperty = false) => {
      const selector = isProperty ? `meta[property="${nameOrProperty}"]` : `meta[name="${nameOrProperty}"]`;
      let el = document.querySelector(selector);
      if (!el) {
        el = document.createElement("meta");
        if (isProperty) {
          el.setAttribute("property", nameOrProperty);
        } else {
          el.setAttribute("name", nameOrProperty);
        }
        document.head.appendChild(el);
      }
      el.setAttribute("content", content);
    };

    setMeta("description", metadata.description);
    setMeta("og:title", metadata.title, true);
    setMeta("og:description", metadata.description, true);
    setMeta("og:locale", lang === "ar" ? "ar_SA" : lang, true);
    setMeta("twitter:title", metadata.title);
    setMeta("twitter:description", metadata.description);

    let canonical = document.querySelector("link[rel='canonical']");
    if (!canonical) {
      canonical = document.createElement("link");
      canonical.setAttribute("rel", "canonical");
      document.head.appendChild(canonical);
    }
    canonical.setAttribute("href", `https://digital-automation.onhercules.app/${lang}`);

    const supportedLangs = ["ar", "en", "fr", "it", "zh"];
    document.querySelectorAll("link[rel='alternate'][hreflang]").forEach(el => el.remove());
    supportedLangs.forEach(l => {
      const link = document.createElement("link");
      link.setAttribute("rel", "alternate");
      link.setAttribute("hreflang", l);
      link.setAttribute("href", `https://digital-automation.onhercules.app/${l}`);
      document.head.appendChild(link);
    });

    const defaultLink = document.createElement("link");
    defaultLink.setAttribute("rel", "alternate");
    defaultLink.setAttribute("hreflang", "x-default");
    defaultLink.setAttribute("href", "https://digital-automation.onhercules.app/ar");
    document.head.appendChild(defaultLink);
  }, [lang, metadata]);

  return null;
}
