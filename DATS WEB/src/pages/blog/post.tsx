import { useParams, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useQuery } from "convex/react";
import { api } from "../../../convex/_generated/api";
import { motion } from "framer-motion";
import SeoHead from "../_components/seo-head";
import Navbar from "../_components/navbar";
import { Footer } from "../_components/footer";
import { Button } from "@/components/ui/button";
import { Calendar, User, ArrowLeft, ArrowRight, BookOpen } from "lucide-react";
import { STATIC_POSTS } from "@/lib/static-posts";

// Simple Markdown parser for post content to render rich text natively
function RenderMarkdown({ content }: { content: string }) {
  if (!content) return null;

  const lines = content.split("\n");
  return (
    <div className="space-y-4 text-foreground/90 leading-relaxed text-sm sm:text-base">
      {lines.map((line, idx) => {
        const trimmed = line.trim();

        // Headers
        if (trimmed.startsWith("### ")) {
          return (
            <h4 key={idx} className="text-base sm:text-lg font-black text-foreground pt-4">
              {trimmed.substring(4)}
            </h4>
          );
        }
        if (trimmed.startsWith("## ")) {
          return (
            <h3 key={idx} className="text-lg sm:text-xl font-black text-foreground pt-4 border-b border-border/60 pb-1">
              {trimmed.substring(3)}
            </h3>
          );
        }
        if (trimmed.startsWith("# ")) {
          return (
            <h2 key={idx} className="text-xl sm:text-2xl font-black text-foreground pt-4">
              {trimmed.substring(2)}
            </h2>
          );
        }

        // Bullet list items
        if (trimmed.startsWith("- ") || trimmed.startsWith("* ")) {
          return (
            <ul key={idx} className="list-disc ps-6 space-y-1">
              <li className="text-sm sm:text-base">{trimmed.substring(2)}</li>
            </ul>
          );
        }

        // Horizontal Rule
        if (trimmed === "---") {
          return <hr key={idx} className="my-6 border-border" />;
        }

        // Empty line
        if (!trimmed) {
          return <div key={idx} className="h-2" />;
        }

        // Normal paragraph (supports inline bold **text**)
        const parts = trimmed.split(/(\*\*.*?\*\*)/g);
        return (
          <p key={idx} className="text-sm sm:text-base">
            {parts.map((part, pIdx) => {
              if (part.startsWith("**") && part.endsWith("**")) {
                return (
                  <strong key={pIdx} className="font-bold text-foreground">
                    {part.slice(2, -2)}
                  </strong>
                );
              }
              return part;
            })}
          </p>
        );
      })}
    </div>
  );
}

export default function BlogPostPage() {
  const { slug } = useParams<{ slug: string }>();
  const { t, i18n } = useTranslation("common");
  const navigate = useNavigate();
  const isRtl = i18n.language === "ar";
  const lng = i18n.language || "ar";

  const post = useQuery((api as any).posts.getPostBySlug, {
    slug: slug || "",
    language: lng,
  });

  const staticPostFallback = (STATIC_POSTS[lng] || STATIC_POSTS.ar)?.find(
    (p) => p.slug === slug
  );
  const displayPost = post || (post !== undefined ? staticPostFallback : undefined);

  const ArrowIcon = isRtl ? ArrowRight : ArrowLeft;

  return (
    <div dir={isRtl ? "rtl" : "ltr"} className="min-h-screen bg-background flex flex-col">
      <SeoHead />
      <Navbar />

      <main className="flex-grow pt-28 pb-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 space-y-8">
          {/* Back button */}
          <div>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate(`/${lng}/blog`)}
              className="gap-2 cursor-pointer text-xs sm:text-sm"
            >
              <ArrowIcon className="w-4 h-4" />
              {t("blog.back")}
            </Button>
          </div>

          {displayPost === undefined ? (
            <div className="space-y-6 animate-pulse">
              <div className="h-4 w-1/4 bg-muted rounded" />
              <div className="h-10 w-3/4 bg-muted rounded" />
              <div className="h-4 w-1/2 bg-muted rounded" />
              <div className="space-y-2 pt-6">
                <div className="h-4 w-full bg-muted rounded" />
                <div className="h-4 w-full bg-muted rounded" />
                <div className="h-4 w-5/6 bg-muted rounded" />
              </div>
            </div>
          ) : !displayPost ? (
            <div className="text-center py-20 bg-card border border-border rounded-3xl max-w-md mx-auto">
              <BookOpen className="w-12 h-12 text-muted-foreground/30 mx-auto mb-4" />
              <h3 className="font-bold text-foreground text-lg mb-1">
                {isRtl ? "المقال غير موجود" : "Post not found"}
              </h3>
              <p className="text-muted-foreground text-sm mb-6">
                {isRtl
                  ? "قد يكون المقال تم حذفه أو غير منشور بهذه اللغة."
                  : "The article may have been deleted or is not published in this language."}
              </p>
              <Button onClick={() => navigate(`/${lng}/blog`)} className="cursor-pointer">
                {t("blog.back")}
              </Button>
            </div>
          ) : (
            <motion.article
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
              className="bg-card border border-border rounded-3xl p-6 sm:p-10 space-y-6 shadow-sm relative group"
            >
              <div className="tech-card-glow-bar" />

              {/* Meta information */}
              <div className="flex flex-wrap gap-4 text-xs sm:text-sm text-muted-foreground pb-4 border-b border-border/80">
                <span className="flex items-center gap-1.5">
                  <Calendar className="w-4 h-4" />
                  {new Date(displayPost._creationTime).toLocaleDateString(lng, {
                    year: "numeric",
                    month: "long",
                    day: "numeric",
                  })}
                </span>
                <span className="flex items-center gap-1.5">
                  <User className="w-4 h-4" />
                  {displayPost.author}
                </span>
              </div>

              {/* Article Header */}
              <div className="space-y-4">
                <h1 className="text-3xl sm:text-4xl md:text-5xl font-black text-foreground leading-tight">
                  {displayPost.title}
                </h1>
                <p className="text-base sm:text-lg text-muted-foreground font-medium italic border-s-4 border-primary/40 ps-4 py-1 leading-relaxed">
                  {displayPost.excerpt}
                </p>
              </div>

              {/* Article Content */}
              <div className="pt-4">
                <RenderMarkdown content={displayPost.content} />
              </div>
            </motion.article>
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
}

export { BlogPostPage as xI };
