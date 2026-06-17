import { useTranslation } from "react-i18next";
import SeoHead from "./_components/seo-head";
import { Navbar } from "./_components/navbar";
import HeroSection from "./_components/hero-section";
import ServicesSection from "./_components/services-section";
import AboutSection from "./_components/about-section";
import WhyUsSection from "./_components/why-us-section";
import PricingSection from "./_components/pricing-section";
import PortfolioSection from "./_components/portfolio-section";
import GallerySection from "./_components/gallery-section";
import ContactSection from "./_components/contact-section";
import { Footer } from "./_components/footer";
import { WhatsAppButton } from "@/components/whatsapp-button";

export default function IndexPage() {
  const { i18n } = useTranslation();
  const isRtl = i18n.language === "ar";

  return (
    <div dir={isRtl ? "rtl" : "ltr"} className="min-h-screen bg-background">
      <SeoHead />
      <Navbar />
      <HeroSection />
      <ServicesSection />
      <AboutSection />
      <WhyUsSection />
      <PricingSection />
      <PortfolioSection />
      <GallerySection />
      <ContactSection />
      <Footer />
      <WhatsAppButton />
    </div>
  );
}

export { IndexPage as xK };
