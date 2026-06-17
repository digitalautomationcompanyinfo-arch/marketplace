import i18next from "i18next";

export const defaultLanguage = "ar";
export const languages = ["ar", "en", "fr", "it", "zh"];

export const languageDirections: Record<string, "ltr" | "rtl"> = {
  ar: "rtl",
  en: "ltr",
  fr: "ltr",
  it: "ltr",
  zh: "ltr",
};

export const languageNames: Record<string, string> = {
  ar: "العربية",
  en: "English",
  fr: "Français",
  it: "Italiano",
  zh: "中文",
};

export function isValidLanguage(lng: string): boolean {
  return !!lng && languages.includes(lng);
}

export function formatLocalePath(lng: string, pathname: string, search = "", hash = ""): string {
  const a = isValidLanguage(lng) ? lng : defaultLanguage;
  if (pathname === "/") return `/${a}${search}${hash}`;
  const c = pathname.split("/").filter(Boolean);
  const f = c[0]?.toLowerCase();
  if (f && isValidLanguage(f)) {
    c[0] = a;
    return `/${c.join("/")}${search}${hash}`;
  }
  return `/${a}${pathname}${search}${hash}`;
}

export async function changeLanguage(lng: string, i18nInstance = i18next) {
  try {
    await i18nInstance.changeLanguage(lng);
    document.documentElement.lang = lng;
    document.documentElement.dir = languageDirections[lng] || "ltr";
    try {
      localStorage.setItem("locale", lng);
    } catch (e) {
      console.warn("localStorage not available", e);
    }
  } catch (t) {
    console.error("Failed to change locale:", t);
    throw t;
  }
}
