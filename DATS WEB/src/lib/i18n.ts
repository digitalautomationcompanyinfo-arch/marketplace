import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import { defaultLanguage, languages } from "./locale";

// Statically import translation files
import arCommon from "../../public/locales/ar/common.json";
import arPortfolio from "../../public/locales/ar/portfolio.json";
import enCommon from "../../public/locales/en/common.json";
import enPortfolio from "../../public/locales/en/portfolio.json";
import frCommon from "../../public/locales/fr/common.json";
import frPortfolio from "../../public/locales/fr/portfolio.json";
import itCommon from "../../public/locales/it/common.json";
import itPortfolio from "../../public/locales/it/portfolio.json";
import zhCommon from "../../public/locales/zh/common.json";
import zhPortfolio from "../../public/locales/zh/portfolio.json";

const resources = {
  ar: { common: arCommon, portfolio: arPortfolio },
  en: { common: enCommon, portfolio: enPortfolio },
  fr: { common: frCommon, portfolio: frPortfolio },
  it: { common: itCommon, portfolio: itPortfolio },
  zh: { common: zhCommon, portfolio: zhPortfolio },
};

i18n
  .use(initReactI18next)
  .init({
    resources,
    lng: defaultLanguage,
    fallbackLng: defaultLanguage,
    supportedLngs: languages,
    defaultNS: "common",
    interpolation: {
      escapeValue: false,
    },
    react: {
      useSuspense: true,
    },
  });

export default i18n;
