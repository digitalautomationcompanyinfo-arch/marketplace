import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "react-i18next";
import { useMutation } from "convex/react";
import { api } from "../../convex/_generated/api";
import { X, CheckCircle2, CreditCard, Building2, Phone, Mail, User, Info } from "lucide-react";
import { Button } from "./ui/button";

interface CheckoutDialogProps {
  isOpen: boolean;
  onClose: () => void;
  planKey: string;
  planName: string;
  planPrice: string;
}

export function CheckoutDialog({ isOpen, onClose, planKey, planName, planPrice }: CheckoutDialogProps) {
  const { t, i18n } = useTranslation("common");
  const isAr = i18n.language === "ar";
  
  const submitOrder = useMutation((api as any).orders.submit);

  const [paymentMethod, setPaymentMethod] = useState<"bankak" | "syberpay">("bankak");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);

  // Form inputs
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [transactionId, setTransactionId] = useState("");
  const [details, setDetails] = useState("");
  
  // Simulated SyberPay inputs
  const [cardNumber, setCardNumber] = useState("");
  const [pin, setPin] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      const payload = {
        planKey,
        name,
        email,
        phone,
        paymentMethod,
        price: planPrice,
        details,
        transactionId: paymentMethod === "bankak" ? transactionId : `SYBER-${Math.floor(100000 + Math.random() * 900000)}`,
      };
      await submitOrder(payload);
      setIsSuccess(true);
    } catch (err) {
      alert(isAr ? "فشل إرسال الطلب، يرجى المحاولة لاحقاً" : "Failed to submit request, please try again.");
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4" dir={isAr ? "rtl" : "ltr"}>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
            className="absolute inset-0 bg-black/60 backdrop-blur-md"
          />

          {/* Modal content */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 15 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 15 }}
            transition={{ duration: 0.3 }}
            className="relative w-full max-w-lg bg-card border border-border rounded-3xl shadow-2xl overflow-hidden z-10 max-h-[90vh] flex flex-col"
          >
            {/* Header */}
            <div className="p-5 border-b border-border bg-muted/20 flex items-center justify-between shrink-0">
              <div>
                <h3 className="font-black text-foreground text-lg">
                  {t("checkout.title")}
                </h3>
                <p className="text-xs text-muted-foreground mt-0.5">
                  {planName} — {planPrice} {t("pricing.currency")}
                </p>
              </div>
              <button
                onClick={onClose}
                className="p-1.5 rounded-lg hover:bg-muted text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Scrollable Body */}
            <div className="flex-1 overflow-y-auto p-6 space-y-6">
              {isSuccess ? (
                <motion.div
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  className="flex flex-col items-center justify-center text-center py-10 space-y-4"
                >
                  <CheckCircle2 className="w-16 h-16 text-emerald-500 animate-bounce" />
                  <h4 className="text-xl font-bold text-foreground">
                    {t("checkout.successTitle")}
                  </h4>
                  <p className="text-muted-foreground text-sm leading-relaxed max-w-xs">
                    {t("checkout.successDesc")}
                  </p>
                  <Button onClick={onClose} className="mt-4 px-6 cursor-pointer">
                    {isAr ? "إغلاق" : "Close"}
                  </Button>
                </motion.div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-4">
                  {/* Basic customer details */}
                  <div className="space-y-3">
                    <h4 className="font-bold text-xs uppercase tracking-wider text-muted-foreground border-b border-border/60 pb-1">
                      {isAr ? "معلومات التواصل والطلب" : "Contact & Order Info"}
                    </h4>
                    <div className="space-y-3">
                      <div className="relative">
                        <User className="absolute start-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <input
                          type="text"
                          required
                          value={name}
                          onChange={(e) => setName(e.target.value)}
                          placeholder={t("contact.name")}
                          className="w-full bg-background border border-border rounded-xl ps-10 pe-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                        />
                      </div>
                      <div className="relative">
                        <Mail className="absolute start-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <input
                          type="email"
                          required
                          value={email}
                          onChange={(e) => setEmail(e.target.value)}
                          placeholder={t("contact.email")}
                          className="w-full bg-background border border-border rounded-xl ps-10 pe-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-left"
                          dir="ltr"
                        />
                      </div>
                      <div className="relative">
                        <Phone className="absolute start-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                        <input
                          type="tel"
                          required
                          value={phone}
                          onChange={(e) => setPhone(e.target.value)}
                          placeholder={isAr ? "رقم الهاتف والواتساب" : "Phone / WhatsApp number"}
                          className="w-full bg-background border border-border rounded-xl ps-10 pe-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-left"
                          dir="ltr"
                        />
                      </div>
                      <div className="relative">
                        <textarea
                          value={details}
                          onChange={(e) => setDetails(e.target.value)}
                          placeholder={isAr ? "تفاصيل إضافية حول مشروعك (اختياري)..." : "Additional details about your project (optional)..."}
                          rows={2}
                          className="w-full bg-background border border-border rounded-xl px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-none"
                        />
                      </div>
                    </div>
                  </div>

                  {/* Payment method selector */}
                  <div className="space-y-3 pt-2">
                    <h4 className="font-bold text-xs uppercase tracking-wider text-muted-foreground border-b border-border/60 pb-1">
                      {t("checkout.paymentMethod")}
                    </h4>
                    <div className="grid grid-cols-2 gap-3">
                      <button
                        type="button"
                        onClick={() => setPaymentMethod("bankak")}
                        className={`flex flex-col items-center justify-center p-3 rounded-2xl border text-center transition-all cursor-pointer ${
                          paymentMethod === "bankak"
                            ? "border-primary bg-primary/5 text-primary"
                            : "border-border hover:border-primary/20 text-muted-foreground"
                        }`}
                      >
                        <Building2 className="w-6 h-6 mb-1.5" />
                        <span className="font-bold text-xs">{t("checkout.bankak.name")}</span>
                      </button>
                      <button
                        type="button"
                        onClick={() => setPaymentMethod("syberpay")}
                        className={`flex flex-col items-center justify-center p-3 rounded-2xl border text-center transition-all cursor-pointer ${
                          paymentMethod === "syberpay"
                            ? "border-primary bg-primary/5 text-primary"
                            : "border-border hover:border-primary/20 text-muted-foreground"
                        }`}
                      >
                        <CreditCard className="w-6 h-6 mb-1.5" />
                        <span className="font-bold text-xs">{t("checkout.syberpay.name")}</span>
                      </button>
                    </div>
                  </div>

                  {/* Payment forms */}
                  <div className="bg-muted/30 border border-border/80 rounded-2xl p-4 space-y-4">
                    {paymentMethod === "bankak" ? (
                      <div className="space-y-3">
                        <div className="bg-primary/5 border border-primary/20 text-primary rounded-xl p-3 flex gap-2 text-xs sm:text-sm items-start">
                          <Info className="w-5 h-5 shrink-0 mt-0.5" />
                          <div>
                            <p className="font-bold leading-normal">{t("checkout.bankak.account")}</p>
                            <p className="opacity-90 leading-relaxed mt-1">{t("checkout.bankak.desc")}</p>
                          </div>
                        </div>
                        <div className="space-y-1">
                          <label className="text-xs font-bold text-muted-foreground">
                            {t("checkout.transactionId")}
                          </label>
                          <input
                            type="text"
                            required
                            value={transactionId}
                            onChange={(e) => setTransactionId(e.target.value)}
                            placeholder="مثال: 18492019"
                            className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-center"
                          />
                        </div>
                      </div>
                    ) : (
                      <div className="space-y-3">
                        <div className="bg-primary/5 border border-primary/20 text-primary rounded-xl p-3 text-xs flex gap-2 items-start">
                          <Info className="w-5 h-5 shrink-0 mt-0.5" />
                          <p className="leading-relaxed">{t("checkout.syberpay.desc")}</p>
                        </div>
                        <div className="space-y-3">
                          <div className="space-y-1">
                            <label className="text-xs font-bold text-muted-foreground">
                              {t("checkout.cardNumber")}
                            </label>
                            <input
                              type="text"
                              required
                              value={cardNumber}
                              onChange={(e) => setCardNumber(e.target.value.replace(/\s?/g, "").replace(/(\d{4})/g, "$1 ").trim())}
                              placeholder="1234 5678 1234 5678"
                              maxLength={19}
                              className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-center"
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-xs font-bold text-muted-foreground">
                              {t("checkout.pin")}
                            </label>
                            <input
                              type="password"
                              required
                              value={pin}
                              onChange={(e) => setPin(e.target.value)}
                              placeholder="••••"
                              maxLength={4}
                              className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-center"
                            />
                          </div>
                        </div>
                      </div>
                    )}
                  </div>

                  <div className="pt-2">
                    <Button
                      type="submit"
                      disabled={isSubmitting}
                      className="w-full gap-2 cursor-pointer py-6 font-bold text-base"
                    >
                      {isSubmitting ? (
                        <span className="w-5 h-5 border-2 border-primary-foreground border-t-transparent animate-spin rounded-full" />
                      ) : (
                        t("checkout.submit")
                      )}
                    </Button>
                  </div>
                </form>
              )}
            </div>
          </motion.div>
        </div>
      )}
    </AnimatePresence>
  );
}
