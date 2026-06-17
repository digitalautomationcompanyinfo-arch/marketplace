import * as React from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "react-i18next";
import { X } from "lucide-react";

// WhatsApp numbers (Sudan)
const WHATSAPP_1 = "249914124471";
const WHATSAPP_2 = "2499118099447";

function Py({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="currentColor"
      className={className}
      xmlns="http://www.w3.org/2000/svg"
    >
      <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z" />
    </svg>
  );
}

function WhatsAppButton() {
  const [isOpen, setIsOpen] = React.useState(false);
  const { i18n } = useTranslation();
  const isAr = i18n.language === "ar";
  
  const text1 = encodeURIComponent(
    isAr ? "مرحباً، أود الاستفسار عن خدماتكم (الرقم الأول)" : "Hello, I would like to inquire about your services (First number)"
  );
  const text2 = encodeURIComponent(
    isAr ? "مرحباً، أود الاستفسار عن خدماتكم (الرقم الثاني)" : "Hello, I would like to inquire about your services (Second number)"
  );
  
  const href1 = `https://wa.me/${WHATSAPP_1}?text=${text1}`;
  const href2 = `https://wa.me/${WHATSAPP_2}?text=${text2}`;

  return (
    <div className={`fixed bottom-6 z-50 flex flex-col items-end gap-3 ${isAr ? "left-6" : "right-6"}`}>
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, y: 10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: 10, scale: 0.95 }}
            transition={{ duration: 0.2, ease: "easeOut" }}
            className="bg-card border border-border rounded-2xl shadow-xl p-4 w-64"
          >
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 rounded-full bg-[#25D366] flex items-center justify-center flex-shrink-0">
                <Py className="w-5 h-5 text-white" />
              </div>
              <div>
                <p className="font-bold text-sm text-foreground">
                  {isAr ? "شركة الاتمتة الرقمية" : "Digital Automation"}
                </p>
                <div className="flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-[#25D366]" />
                  <p className="text-xs text-muted-foreground">
                    {isAr ? "متاح الآن" : "Available now"}
                  </p>
                </div>
              </div>
            </div>
            <div className="bg-muted rounded-xl rounded-tl-sm px-3 py-2 mb-4">
              <p className="text-sm text-foreground leading-relaxed">
                {isAr
                  ? "👋 مرحباً! كيف يمكننا مساعدتك؟ تواصل معنا الآن عبر واتساب."
                  : "👋 Hello! How can we help you? Contact us now via WhatsApp."}
              </p>
            </div>
            <div className="space-y-2">
              <a
                href={href1}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 w-full bg-[#25D366] hover:bg-[#20b858] text-white font-semibold text-sm rounded-xl py-2.5 transition-colors cursor-pointer"
              >
                <Py className="w-4 h-4" />
                {isAr ? "الرقم الأول (واتساب)" : "WhatsApp 1"}
              </a>
              <a
                href={href2}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 w-full bg-[#25D366] hover:bg-[#20b858] text-white font-semibold text-sm rounded-xl py-2.5 transition-colors cursor-pointer"
              >
                <Py className="w-4 h-4" />
                {isAr ? "الرقم الثاني (واتساب)" : "WhatsApp 2"}
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
      <motion.button
        onClick={() => setIsOpen((prev) => !prev)}
        className="w-14 h-14 rounded-full bg-[#25D366] hover:bg-[#20b858] text-white shadow-lg hover:shadow-xl transition-all cursor-pointer flex items-center justify-center relative"
        whileHover={{ scale: 1.08 }}
        whileTap={{ scale: 0.95 }}
        aria-label="WhatsApp"
      >
        <AnimatePresence mode="wait">
          {isOpen ? (
            <motion.span
              key="close"
              initial={{ rotate: -90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: 90, opacity: 0 }}
              transition={{ duration: 0.15 }}
            >
              <X className="w-6 h-6" />
            </motion.span>
          ) : (
            <motion.span
              key="whatsapp"
              initial={{ rotate: 90, opacity: 0 }}
              animate={{ rotate: 0, opacity: 1 }}
              exit={{ rotate: -90, opacity: 0 }}
              transition={{ duration: 0.15 }}
            >
              <Py className="w-6 h-6" />
            </motion.span>
          )}
        </AnimatePresence>
        {!isOpen && (
          <span className="absolute w-14 h-14 rounded-full bg-[#25D366] opacity-30 animate-ping pointer-events-none" />
        )}
      </motion.button>
    </div>
  );
}

export { WhatsAppButton, WhatsAppButton as wV };
