import React from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import { useTranslation as Dn } from "react-i18next";
import { Mail, Phone, MessageCircle } from "lucide-react";

const T = { jsx, jsxs, Fragment: React.Fragment };

// Custom LinkedIn SVG Icon
function Linkedin({ className }: { className?: string }) {
  return (
    <svg
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
    >
      <path d="M16 8a6 6 0 0 1 6 6v7h-4v-7a2 2 0 0 0-2-2 2 2 0 0 0-2 2v7h-4v-7a6 6 0 0 1 6-6z" />
      <rect x="2" y="9" width="4" height="12" />
      <circle cx="4" cy="4" r="2" />
    </svg>
  );
}

const pK = "https://linkedin.com/company/digital-automation-sd";
const mK = "info@digitalautomation.sd";
const gK = "+249914124471";
const gK2 = "+249118099447";

const PR = [
  { icon: MessageCircle, label: "WhatsApp 1", href: `https://wa.me/249914124471`, color: "hover:text-green-400" },
  { icon: MessageCircle, label: "WhatsApp 2", href: `https://wa.me/249118099447`, color: "hover:text-green-400" },
  { icon: Linkedin, label: "LinkedIn", href: pK, color: "hover:text-blue-400" },
  { icon: Mail, label: "Email", href: `mailto:${mK}`, color: "hover:text-accent" },
  { icon: Phone, label: "Phone 1", href: `tel:${gK}`, color: "hover:text-emerald-400" },
  { icon: Phone, label: "Phone 2", href: `tel:${gK2}`, color: "hover:text-emerald-400" }
];

export function Footer() {
  const { t: e } = Dn("common");
  return T.jsxs("footer", {
    className: "bg-sidebar text-sidebar-foreground border-t border-sidebar-border",
    children: [
      T.jsx("div", {
        className: "border-b border-sidebar-border",
        children: T.jsxs("div", {
          className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex flex-col sm:flex-row items-center justify-between gap-4",
          children: [
            T.jsx("p", { className: "text-sm text-sidebar-foreground/60", children: e("footer.followUs") }),
            T.jsx("div", {
              className: "flex items-center gap-3 flex-wrap justify-center",
              children: PR.map(({ icon: Icon, label: n, href: i, color: a }) =>
                T.jsx("a", {
                  href: i,
                  target: "_blank",
                  rel: "noopener noreferrer",
                  "aria-label": n,
                  className: `w-9 h-9 rounded-lg bg-sidebar-accent flex items-center justify-center text-sidebar-foreground/60 ${a} transition-colors cursor-pointer`,
                  children: T.jsx(Icon, { className: "w-4 h-4" })
                }, n)
              )
            })
          ]
        })
      }),
      T.jsx("div", {
        className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6",
        children: T.jsxs("div", {
          className: "flex flex-col md:flex-row items-center justify-between gap-4",
          children: [
            T.jsxs("div", {
              className: "flex items-center gap-2",
              children: [
                T.jsx("img", {
                  src: "/logo.jpg",
                  alt: "Logo",
                  className: "w-8 h-8 object-contain rounded-md border border-sidebar-border"
                }),
                T.jsx("span", { className: "font-bold text-base", children: e("footer.company") })
              ]
            }),
            T.jsx("p", { className: "text-sm text-sidebar-foreground/60 text-center", children: e("about.locationText") }),
            T.jsxs("p", {
              className: "text-sm text-sidebar-foreground/60",
              children: ["© ", new Date().getFullYear(), " ", e("footer.company"), " — ", e("footer.rights")]
            })
          ]
        })
      })
    ]
  });
}

export { Footer as yK };
