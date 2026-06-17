import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useQuery } from "convex/react";
import { api } from "../../../convex/_generated/api";
import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import SeoHead from "../_components/seo-head";
import Navbar from "../_components/navbar";
import { Footer } from "../_components/footer";
import { Input } from "@/components/ui/input";
import { Calendar, User, ArrowLeft, ArrowRight, Search, BookOpen } from "lucide-react";
import { STATIC_POSTS } from "@/lib/static-posts";

export default function BlogListPage() {
  const { t, i18n } = useTranslation("common");
  const isRtl = i18n.language === "ar";
  const lng = i18n.language || "ar";

  const posts = useQuery((api as any).posts.listPublished, { language: lng });
  const [searchQuery, setSearchQuery] = useState("");

  const displayPosts = (posts && posts.length > 0) ? posts : (posts !== undefined ? (STATIC_POSTS[lng] || STATIC_POSTS.ar) : undefined);

  const filteredPosts = displayPosts?.filter((post: any) =>
    post.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    post.excerpt.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const ArrowIcon = isRtl ? ArrowLeft : ArrowRight;

  return (
    <div dir={isRtl ? "rtl" : "ltr"} className="min-h-screen bg-background flex flex-col">
      <SeoHead />
      <Navbar />

      <main className="flex-grow pt-28 pb-16">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 space-y-12">
          {/* Header */}
          <div className="text-center space-y-4 max-w-2xl mx-auto">
            <motion.div
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <h1 className="text-4xl sm:text-5xl font-black text-foreground">
                {t("blog.title")}
              </h1>
            </motion.div>
            <motion.p
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.1 }}
              className="text-muted-foreground text-sm sm:text-base leading-relaxed"
            >
              {t("blog.subtitle")}
            </motion.p>
          </div>

          {/* Search bar */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            className="max-w-md mx-auto relative"
          >
            <div className="relative">
              <Search className="absolute start-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                type="text"
                placeholder={isRtl ? "ابحث عن مقال..." : "Search articles..."}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="ps-10 h-11 border border-border rounded-xl"
              />
            </div>
          </motion.div>

          {/* Blog posts list */}
          {displayPosts === undefined ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 pt-6">
              {Array.from({ length: 3 }).map((_, idx) => (
                <div key={idx} className="bg-card border border-border rounded-2xl h-80 animate-pulse" />
              ))}
            </div>
          ) : filteredPosts?.length === 0 ? (
            <div className="text-center py-20 bg-card border border-border rounded-3xl max-w-md mx-auto">
              <BookOpen className="w-12 h-12 text-muted-foreground/30 mx-auto mb-4" />
              <h3 className="font-bold text-foreground text-lg mb-1">
                {isRtl ? "لم نعثر على نتائج" : "No articles found"}
              </h3>
              <p className="text-muted-foreground text-sm">
                {searchQuery ? (isRtl ? "حاول البحث بكلمات مختلفة" : "Try searching for other keywords") : t("blog.noPosts")}
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 pt-6">
              {filteredPosts?.map((post: any, index: number) => (
                <motion.div
                  key={post._id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.4, delay: index * 0.05 }}
                  className="group relative bg-card border border-border rounded-2xl overflow-hidden flex flex-col h-full hover:border-primary/20 transition-all duration-300 hover:shadow-md"
                >
                  <div className="p-6 flex flex-col flex-grow space-y-4">
                    {/* Excerpt/Tag */}
                    <div className="flex items-center gap-4 text-xs text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3.5 h-3.5" />
                        {new Date(post._creationTime).toLocaleDateString(lng, {
                          year: "numeric",
                          month: "short",
                          day: "numeric",
                        })}
                      </span>
                      <span className="flex items-center gap-1">
                        <User className="w-3.5 h-3.5" />
                        {post.author}
                      </span>
                    </div>

                    <h2 className="font-bold text-lg text-foreground line-clamp-2 leading-snug group-hover:text-primary transition-colors duration-300">
                      {post.title}
                    </h2>

                    <p className="text-sm text-muted-foreground line-clamp-3 leading-relaxed flex-grow">
                      {post.excerpt}
                    </p>

                    <div className="pt-2">
                      <Link
                        to={`/${lng}/blog/${post.slug}`}
                        className="inline-flex items-center gap-1 text-xs font-bold text-primary hover:gap-1.5 transition-all"
                      >
                        <span>{t("blog.readMore")}</span>
                        <ArrowIcon className="w-3.5 h-3.5" />
                      </Link>
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
}

export { BlogListPage as xJ };
