import { useLocation, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { cn } from "@/lib/utils";
import { formatLocalePath, languages } from "@/lib/locale";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Check, Globe } from "lucide-react";

export const qf: Record<string, { code: string; emoji: string; name: string; nativeName: string; dir: string }> = {
  ar: { code: "ar", emoji: "🇸🇩", name: "Arabic", nativeName: "العربية", dir: "rtl" },
  en: { code: "en", emoji: "🇬🇧", name: "English", nativeName: "English", dir: "ltr" },
  fr: { code: "fr", emoji: "🇫🇷", name: "French", nativeName: "Français", dir: "ltr" },
  it: { code: "it", emoji: "🇮🇹", name: "Italian", nativeName: "Italiano", dir: "ltr" },
  zh: { code: "zh", emoji: "🇨🇳", name: "Chinese", nativeName: "中文", dir: "ltr" }
};

export function LocaleSwitcher() {
  const { i18n } = useTranslation();
  const navigate = useNavigate();
  const location = useLocation();
  
  const currentLang = qf[i18n.language] || qf.ar;

  const handleLanguageChange = (lng: string) => {
    const path = formatLocalePath(lng, location.pathname, location.search, location.hash);
    navigate(path);
  };

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="sm" className="gap-2 cursor-pointer">
          <Globe className="h-4 w-4" />
          <span>{currentLang?.emoji}</span>
          <span className="hidden sm:inline">{currentLang?.nativeName}</span>
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48 bg-popover text-popover-foreground border border-border rounded-xl p-1 shadow-md z-50">
        {languages.map((lng) => {
          const config = qf[lng];
          const isSelected = i18n.language === lng;
          return (
            <DropdownMenuItem
              key={lng}
              onClick={() => handleLanguageChange(lng)}
              className="flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm cursor-pointer hover:bg-muted transition-colors"
            >
              <Check className={cn("h-4 w-4", isSelected ? "opacity-100" : "opacity-0")} />
              <span>{config.emoji}</span>
              <span className="flex-1">{config.nativeName}</span>
            </DropdownMenuItem>
          );
        })}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

export { LocaleSwitcher as w9 };
