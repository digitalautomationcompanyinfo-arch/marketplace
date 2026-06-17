import React, { useState } from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import { motion as et } from "framer-motion";
import { useTranslation as Dn } from "react-i18next";
import { toast as Ea } from "sonner";
import { useMutation as Pf } from "convex/react";
import { api as Mu } from "../../../convex/_generated/api";
import { VT } from "@/components/ui/input";
import { lK } from "@/components/ui/textarea";
import { My } from "@/components/ui/label";
import { Pn } from "@/components/ui/button";
import { oK } from "@/components/map-view";
import { MapPin as Hf, CheckCircle as UU, Send as xV, Mail as Ap, Phone as BA, MessageCircle } from "lucide-react";

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

// Contact constants
const pK = "https://linkedin.com/company/digital-automation";
const mK = "info@digital-automation.net";
const gK = "+249914124471";
const gK2 = "+249118099447";

const PR = [
  { icon: MessageCircle, label: "WhatsApp 1", href: `https://wa.me/249914124471`, color: "hover:text-green-400" },
  { icon: MessageCircle, label: "WhatsApp 2", href: `https://wa.me/249118099447`, color: "hover:text-green-400" },
  { icon: Linkedin, label: "LinkedIn", href: pK, color: "hover:text-blue-400" },
  { icon: Ap, label: "Email", href: `mailto:${mK}`, color: "hover:text-accent" }
];

// Helper components
function Oy({ icon: e, label: t, value: n }: any) {
  const Icon = e;
  return T.jsxs("div", {
    className: "flex items-start gap-3",
    children: [
      T.jsx("div", {
        className: "w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5",
        children: T.jsx(Icon, { className: "w-5 h-5 text-primary" })
      }),
      T.jsxs("div", {
        children: [
          T.jsx("h4", { className: "font-bold text-foreground text-sm", children: t }),
          T.jsx("p", { className: "text-muted-foreground text-xs leading-relaxed whitespace-pre-line", children: n })
        ]
      })
    ]
  });
}

function vK(){
  const { t: e } = Dn("common");
  const [t, n] = useState(false);
  const [i, a] = useState(false);
  const [c, u] = useState("");
  const [f, p] = useState("");
  const [m, _] = useState("");
  
  const y = Pf(Mu.contact.submit as any);

  React.useEffect(() => {
    const handlePrefill = (event: Event) => {
      const customEvent = event as CustomEvent<{ message: string }>;
      if (customEvent.detail && customEvent.detail.message) {
        _(customEvent.detail.message);
        const element = document.getElementById("contact");
        if (element) {
          element.scrollIntoView({ behavior: "smooth" });
          setTimeout(() => {
            const textarea = document.getElementById("message");
            if (textarea) {
              (textarea as HTMLTextAreaElement).focus();
            }
          }, 600);
        }
      }
    };
    window.addEventListener("portfolio-request-service", handlePrefill);
    return () => {
      window.removeEventListener("portfolio-request-service", handlePrefill);
    };
  }, []);

  const x = async (E: React.FormEvent) => {
    E.preventDefault();
    n(true);
    try {
      await y({
        name: c,
        email: f,
        message: m
      });
      a(true);
      u("");
      p("");
      _("");
      Ea.success(e("contact.successMessage"));
    } catch (k) {
      if (k instanceof Error) {
        Ea.error(k.message);
      } else {
        Ea.error(e("contact.errorMessage"));
      }
    } finally {
      n(false);
    }
  };

  return T.jsx("section",{
    id:"contact",className:"py-24 bg-background",children:T.jsxs("div",{
      className:"max-w-7xl mx-auto px-4 sm:px-6 lg:px-8",children:[T.jsxs(et.div,{
        initial:{
          opacity:0,y:20
        },whileInView:{
          opacity:1,y:0
        },viewport:{
          once:!0,amount:0
        },transition:{
          duration:.5
        },className:"text-center mb-16",children:[T.jsx("h2",{
          className:"text-3xl sm:text-4xl font-black text-foreground mb-4",children:e("contact.title")
        }),T.jsx("p",{
          className:"text-muted-foreground text-lg max-w-2xl mx-auto",children:e("contact.subtitle")
        })]
      }),T.jsxs("div",{
        className:"grid grid-cols-1 lg:grid-cols-5 gap-10",children:[T.jsxs(et.div,{
          initial:{
            opacity:0,x:-20
          },whileInView:{
            opacity:1,x:0
          },viewport:{
            once:!0,amount:0
          },transition:{
            duration:.5
          },className:"lg:col-span-2 space-y-6",children:[T.jsxs("div",{
            className:"group relative bg-gradient-to-br from-primary/5 to-accent/5 border border-border rounded-2xl p-6 space-y-5 tech-glass-card transition-all duration-300 hover:border-primary/20",children:[T.jsx("div", { className: "tech-card-glow-bar" }),T.jsx(Oy,{
              icon:Hf,label:e("contact.address"),value:e("contact.addressValue")
            }),T.jsx(Oy,{
              icon:BA,label:e("contact.phone"),value:`${gK}\n${gK2}`
            }),T.jsx(Oy,{
              icon:Ap,label:e("contact.email"),value:mK
            }),T.jsx("div",{
              className:"pt-2 border-t border-border flex items-center gap-2 flex-wrap",children:PR.map(({
                icon:E,label:k,href:M,color:R
              })=>T.jsx("a",{
                href:M,target:"_blank",rel:"noopener noreferrer","aria-label":k,className:`w-9 h-9 rounded-lg bg-muted flex items-center justify-center text-muted-foreground ${R} transition-colors cursor-pointer`,children:T.jsx(E,{
                  className:"w-4 h-4"
                })
              },k))
            })]
          }),T.jsx("div",{
            className:"rounded-2xl overflow-hidden border border-border h-56 hover:border-primary/20 transition-colors duration-300",children:T.jsx(oK,{
              lat:15.4607,lng:36.4,zoom:14,label:e("contact.addressValue"),className:"h-56 w-full"
            })
          })]
        }),T.jsx(et.div,{
          initial:{
            opacity:0,x:20
          },whileInView:{
            opacity:1,x:0
          },viewport:{
            once:!0,amount:0
          },transition:{
            duration:.5
          },className:"lg:col-span-3",children:i?T.jsxs("div",{
            className:"bg-card border border-border rounded-2xl p-8 flex flex-col items-center justify-center gap-4 text-center h-full min-h-[300px]",children:[T.jsx(UU,{
              className:"w-14 h-14 text-primary"
            }),T.jsx("h3",{
              className:"text-xl font-bold text-foreground",children:e("contact.successTitle")
            }),T.jsx("p",{
              className:"text-muted-foreground",children:e("contact.successDesc")
            }),T.jsx(Pn,{
              variant:"ghost",className:"cursor-pointer",onClick:()=>a(!1),children:e("contact.sendAnother")
            })]
          }):T.jsxs("form",{
            onSubmit:x,className:"group relative bg-card border border-border rounded-2xl p-6 sm:p-8 space-y-5 tech-glass-card transition-all duration-300 hover:border-primary/20",children:[T.jsx("div", { className: "tech-card-glow-bar" }),T.jsxs("div",{
              className:"grid grid-cols-1 sm:grid-cols-2 gap-5",children:[T.jsxs("div",{
                className:"space-y-2",children:[T.jsx(My,{
                  htmlFor:"name",children:e("contact.name")
                }),T.jsx(VT,{
                  id:"name",placeholder:"محمد أحمد",required:!0,value:c,onChange:(E: any)=>u(E.target.value)
                })]
              }),T.jsxs("div",{
                className:"space-y-2",children:[T.jsx(My,{
                  htmlFor:"email",children:e("contact.email")
                }),T.jsx(VT,{
                  id:"email",type:"email",placeholder:"example@email.com",required:!0,value:f,onChange:(E: any)=>p(E.target.value)
                })]
              })]
            }),T.jsxs("div",{
              className:"space-y-2",children:[T.jsx(My,{
                htmlFor:"message",children:e("contact.message")
              }),T.jsx(lK,{
                id:"message",rows:5,placeholder:"...",required:!0,className:"resize-none",value:m,onChange:(E: any)=>_(E.target.value)
              })]
            }),T.jsxs(Pn,{
              type:"submit",className:"w-full gap-2 cursor-pointer",disabled:t,children:[t?T.jsx("span",{
                className:"animate-spin w-4 h-4 border-2 border-primary-foreground border-t-transparent rounded-full"
              }):T.jsx(xV,{
                className:"w-4 h-4"
              }),e("contact.send")]
            })]
          })
        })]
      })]
    })
  })
}

export { vK as default };
