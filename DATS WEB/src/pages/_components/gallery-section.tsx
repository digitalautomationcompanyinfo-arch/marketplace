import React, { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTranslation } from "react-i18next";
import { useQuery } from "convex/react";
import { api } from "../../../convex/_generated/api";
import { X, ChevronLeft, ChevronRight, ZoomIn } from "lucide-react";

const CATEGORY_KEYS = [
  "gallery.cat.all",
  "gallery.cat.ai",
  "gallery.cat.web",
  "gallery.cat.mobile",
  "gallery.cat.automation",
];

const GALLERY_ITEMS = [
  { id: 1, src: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=600&q=80", titleKey: "gallery.item1.title", categoryKey: "gallery.cat.ai" },
  { id: 2, src: "https://images.unsplash.com/photo-1547658719-da2b51169166?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1547658719-da2b51169166?w=600&q=80", titleKey: "gallery.item2.title", categoryKey: "gallery.cat.web" },
  { id: 3, src: "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1551650975-87deedd944c3?w=600&q=80", titleKey: "gallery.item3.title", categoryKey: "gallery.cat.mobile" },
  { id: 4, src: "https://images.unsplash.com/photo-1526628953301-3e589a6a8b74?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1526628953301-3e589a6a8b74?w=600&q=80", titleKey: "gallery.item4.title", categoryKey: "gallery.cat.automation" },
  { id: 5, src: "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1558655146-364adaf1fcc9?w=600&q=80", titleKey: "gallery.item5.title", categoryKey: "gallery.cat.mobile" },
  { id: 6, src: "https://images.unsplash.com/photo-1522542550221-31fd19575a2d?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1522542550221-31fd19575a2d?w=600&q=80", titleKey: "gallery.item6.title", categoryKey: "gallery.cat.web" },
  { id: 7, src: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=600&q=80", titleKey: "gallery.item7.title", categoryKey: "gallery.cat.ai" },
  { id: 8, src: "https://images.unsplash.com/photo-1541462608143-67571c6738dd?w=1200&q=80", thumb: "https://images.unsplash.com/photo-1541462608143-67571c6738dd?w=600&q=80", titleKey: "gallery.item8.title", categoryKey: "gallery.cat.web" },
];

class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  constructor(props: any) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: any, errorInfo: any) {
    console.warn("Convex query failed. Falling back to static items.", error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback;
    }
    return this.props.children;
  }
}

interface GalleryItem {
  id: string;
  src: string;
  thumb: string;
  title: string;
  categoryKey: string;
}

function GalleryRender({ items }: { items: GalleryItem[] }) {
  const { t } = useTranslation("portfolio");
  const [activeCategory, setActiveCategory] = useState("gallery.cat.all");
  const [lightboxIndex, setLightboxIndex] = useState<number | null>(null);

  const filteredItems =
    activeCategory === "gallery.cat.all"
      ? items
      : items.filter((item: any) => item.categoryKey === activeCategory);

  const openLightbox = (index: number) => setLightboxIndex(index);
  const closeLightbox = () => setLightboxIndex(null);

  const goToPrevious = useCallback(() => {
    setLightboxIndex((prev) =>
      prev === null ? null : (prev - 1 + filteredItems.length) % filteredItems.length
    );
  }, [filteredItems.length]);

  const goToNext = useCallback(() => {
    setLightboxIndex((prev) =>
      prev === null ? null : (prev + 1) % filteredItems.length
    );
  }, [filteredItems.length]);

  useEffect(() => {
    if (lightboxIndex === null) return;
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") closeLightbox();
      if (event.key === "ArrowLeft") goToPrevious();
      if (event.key === "ArrowRight") goToNext();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [lightboxIndex, goToPrevious, goToNext]);

  useEffect(() => {
    document.body.style.overflow = lightboxIndex !== null ? "hidden" : "";
    return () => {
      document.body.style.overflow = "";
    };
  }, [lightboxIndex]);

  return (
    <section id="gallery" className="py-24 bg-muted/30">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl sm:text-4xl font-black text-foreground mb-4">
            {t("gallery.title")}
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            {t("gallery.subtitle")}
          </p>
        </motion.div>

        {/* Category Filter Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0 }}
          transition={{ duration: 0.4, delay: 0.1 }}
          className="flex flex-wrap justify-center gap-2 mb-10"
        >
          {CATEGORY_KEYS.map((categoryKey: string) => (
            <button
              key={categoryKey}
              onClick={() => setActiveCategory(categoryKey)}
              className={`px-4 py-1.5 rounded-full text-sm font-semibold transition-all cursor-pointer ${
                activeCategory === categoryKey
                  ? "bg-primary text-primary-foreground shadow-md"
                  : "bg-background border border-border text-muted-foreground hover:text-foreground"
              }`}
            >
              {t(categoryKey)}
            </button>
          ))}
        </motion.div>

        {/* Gallery Grid */}
        <motion.div layout className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          <AnimatePresence mode="popLayout">
            {filteredItems.map((item: any, index: number) => (
              <motion.div
                key={item.id}
                layout
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ duration: 0.3 }}
                className="group relative aspect-square rounded-xl overflow-hidden cursor-pointer border border-border bg-muted"
                onClick={() => openLightbox(index)}
              >
                <img
                  src={item.thumb}
                  alt={item.title}
                  className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                  loading="lazy"
                />
                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/50 transition-all duration-300 flex flex-col items-center justify-center gap-2 opacity-0 group-hover:opacity-100">
                  <ZoomIn className="w-7 h-7 text-white" />
                  <span className="text-white text-xs font-semibold text-center px-2 line-clamp-2">
                    {item.title}
                  </span>
                  <span className="text-white/70 text-xs">
                    {t(item.categoryKey)}
                  </span>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </motion.div>
      </div>

      {/* Lightbox Overlay */}
      <AnimatePresence>
        {lightboxIndex !== null && filteredItems[lightboxIndex] && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 bg-black/90 flex items-center justify-center p-4"
            onClick={closeLightbox}
          >
            {/* Close Button */}
            <button
              onClick={closeLightbox}
              className="absolute top-4 end-4 w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors cursor-pointer z-10"
            >
              <X className="w-5 h-5" />
            </button>

            {/* Previous Button */}
            <button
              onClick={(evt: React.MouseEvent) => {
                evt.stopPropagation();
                goToPrevious();
              }}
              className="absolute start-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors cursor-pointer z-10"
            >
              <ChevronLeft className="w-5 h-5" />
            </button>

            {/* Next Button */}
            <button
              onClick={(evt: React.MouseEvent) => {
                evt.stopPropagation();
                goToNext();
              }}
              className="absolute end-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-white/10 hover:bg-white/20 flex items-center justify-center text-white transition-colors cursor-pointer z-10"
            >
              <ChevronRight className="w-5 h-5" />
            </button>

            {/* Lightbox Content */}
            <motion.div
              key={lightboxIndex}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              transition={{ duration: 0.25 }}
              className="max-w-4xl max-h-[80vh] w-full flex flex-col items-center gap-4"
              onClick={(evt: React.MouseEvent) => evt.stopPropagation()}
            >
              <img
                src={filteredItems[lightboxIndex].src}
                alt={filteredItems[lightboxIndex].title}
                className="max-h-[70vh] max-w-full rounded-xl object-contain shadow-2xl"
              />
              <div className="text-center">
                <p className="text-white font-bold text-base">
                  {filteredItems[lightboxIndex].title}
                </p>
                <p className="text-white/60 text-sm">
                  {t(filteredItems[lightboxIndex].categoryKey)}
                </p>
              </div>
              <p className="text-white/40 text-xs">
                {lightboxIndex + 1} / {filteredItems.length}
              </p>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </section>
  );
}

function StaticGallerySection() {
  const { t } = useTranslation("portfolio");
  const items = GALLERY_ITEMS.map((item) => ({
    id: item.id.toString(),
    src: item.src,
    thumb: item.thumb,
    title: t(item.titleKey),
    categoryKey: item.categoryKey,
  }));
  return <GalleryRender items={items} />;
}

function GallerySectionContent() {
  const { t, i18n } = useTranslation("portfolio");
  const lng = i18n.language || "ar";

  const dbItems = useQuery((api as any).gallery.listPublished, { language: lng });

  // Map dynamic database items or fall back to static items
  const items = dbItems && dbItems.length > 0
    ? dbItems.map((item: any) => ({
        id: item._id,
        src: item.src,
        thumb: item.thumb,
        title: item.title,
        categoryKey: item.categoryKey,
      }))
    : GALLERY_ITEMS.map((item) => ({
        id: item.id.toString(),
        src: item.src,
        thumb: item.thumb,
        title: t(item.titleKey),
        categoryKey: item.categoryKey,
      }));

  return <GalleryRender items={items} />;
}

function GallerySection() {
  return (
    <ErrorBoundary fallback={<StaticGallerySection />}>
      <GallerySectionContent />
    </ErrorBoundary>
  );
}

export default GallerySection;
export { GallerySection as jG };
