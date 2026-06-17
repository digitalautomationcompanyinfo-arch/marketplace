import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery, useMutation, Authenticated, Unauthenticated, AuthLoading } from "convex/react";
import { api } from "../../../convex/_generated/api";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { toast } from "sonner";
import { SignInButton } from "@/components/ui/signin";
import { Mail, MailOpen, Trash2, ArrowRight, Phone, Zap, Check, CornerUpLeft, Plus, Edit, Eye, EyeOff, BookOpen, FileText, Globe, X, Clock, CheckCircle2, XCircle, ShoppingBag, Image as ImageIcon } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

// StatCard component
interface StatCardProps {
  icon: React.ComponentType<{ className?: string }>;
  label: string;
  value: number | string | undefined;
  color: string;
}

function StatCard({ icon: Icon, label, value, color }: StatCardProps) {
  return (
    <div className="bg-card border border-border rounded-2xl p-5 flex items-center gap-4 hover:shadow-md transition-all duration-300">
      <div className={`w-12 h-12 rounded-xl ${color} flex items-center justify-center flex-shrink-0`}>
        <Icon className="w-6 h-6" />
      </div>
      <div>
        <p className="text-xs text-muted-foreground font-medium">{label}</p>
        <h3 className="text-2xl font-black text-foreground mt-0.5">
          {value === undefined ? <Skeleton className="h-7 w-12" /> : value}
        </h3>
      </div>
    </div>
  );
}

// MessageCard component
interface MessageCardProps {
  msg: any;
  expanded: boolean;
  onToggle: () => void;
  onMarkRead: (id: any) => void;
  onDelete: (id: any) => void;
  onReply: (msg: any) => void;
}

function MessageCard({ msg, expanded, onToggle, onMarkRead, onDelete, onReply }: MessageCardProps) {
  const isRead = msg.read;
  return (
    <motion.div
      layout
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.2 }}
      className={`bg-card border rounded-2xl overflow-hidden transition-colors ${
        isRead ? "border-border opacity-85" : "border-primary/30 shadow-sm"
      }`}
    >
      <button
        className="w-full text-right px-5 py-4 flex items-start gap-3 cursor-pointer hover:bg-muted/40 transition-colors"
        onClick={onToggle}
      >
        <span
          className={`w-2 h-2 rounded-full mt-2 flex-shrink-0 transition-colors ${
            isRead ? "bg-transparent" : "bg-primary"
          }`}
        />
        <div className="flex-1 min-w-0 text-right">
          <div className="flex items-center gap-2 flex-wrap mb-1">
            <span className="font-semibold text-sm text-foreground">{msg.name}</span>
            <span className="text-muted-foreground text-xs">{msg.email}</span>
            {!isRead && (
              <Badge variant="default" className="text-[10px] px-1.5 py-0 font-bold">
                جديد
              </Badge>
            )}
          </div>
          <p className="text-sm text-muted-foreground truncate leading-relaxed">
            {msg.message}
          </p>
        </div>
        <span className="text-xs text-muted-foreground shrink-0 mt-0.5 whitespace-nowrap">
          {new Date(msg._creationTime).toLocaleDateString("ar", {
            month: "short",
            day: "numeric",
          })}
        </span>
      </button>
      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2, ease: "easeInOut" }}
            className="overflow-hidden"
          >
            <div className="px-5 pb-5 border-t border-border pt-4 space-y-4">
              <div className="bg-muted/50 rounded-xl p-4">
                <p className="text-sm text-foreground leading-relaxed whitespace-pre-wrap">
                  {msg.message}
                </p>
              </div>
              <div className="flex items-center gap-4 text-xs text-muted-foreground flex-wrap">
                <span>
                  {new Date(msg._creationTime).toLocaleString("ar", {
                    dateStyle: "short",
                    timeStyle: "short",
                  })}
                </span>
                <a href={`mailto:${msg.email}`} className="text-primary hover:underline">
                  {msg.email}
                </a>
                {msg.phone && (
                  <span className="flex items-center gap-1">
                    <Phone className="w-3.5 h-3.5" />
                    {msg.phone}
                  </span>
                )}
              </div>
              <div className="flex flex-wrap gap-2">
                <Button size="sm" className="gap-1.5 cursor-pointer" onClick={() => onReply(msg)}>
                  <CornerUpLeft className="w-3.5 h-3.5" />
                  رد بالإيميل
                </Button>
                {!isRead && (
                  <Button
                    size="sm"
                    variant="secondary"
                    className="gap-1.5 cursor-pointer"
                    onClick={() => onMarkRead(msg._id)}
                  >
                    <Check className="w-3.5 h-3.5" />
                    تمييز كمقروءة
                  </Button>
                )}
                <Button
                  size="sm"
                  variant="destructive"
                  className="gap-1.5 cursor-pointer"
                  onClick={() => onDelete(msg._id)}
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  حذف
                </Button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

// AdminMessages component
function AdminMessages() {
  const messages = useQuery(api.contact.listAll as any);
  const markRead = useMutation(api.contact.markRead as any);
  const deleteMessage = useMutation(api.contact.deleteMessage as any);

  const [filter, setFilter] = useState("all");
  const [expandedId, setExpandedId] = useState<string | null>(null);

  const totalCount = messages?.length ?? 0;
  const unreadCount = messages?.filter((m: any) => !m.read).length ?? 0;
  const readCount = messages?.filter((m: any) => m.read).length ?? 0;

  const filteredMessages = messages?.filter((m: any) => {
    if (filter === "unread") return !m.read;
    if (filter === "read") return m.read;
    return true;
  });

  const handleMarkRead = async (id: any) => {
    try {
      await markRead({ id });
      toast.success("تم تمييز الرسالة كمقروءة");
    } catch (err) {
      toast.error("فشل التحديث");
    }
  };

  const handleDelete = async (id: any) => {
    try {
      await deleteMessage({ id });
      toast.success("تم حذف الرسالة");
      if (expandedId === id) setExpandedId(null);
    } catch (err) {
      toast.error("فشل الحذف");
    }
  };

  const handleReply = (msg: any) => {
    const subject = encodeURIComponent("رد على رسالتك - شركة الاتمتة الرقمية");
    const body = encodeURIComponent(
      `مرحباً ${msg.name}،\n\nشكراً لتواصلك معنا.\n\n---\nرسالتك الأصلية:\n${msg.message}`
    );
    window.open(`mailto:${msg.email}?subject=${subject}&body=${body}`, "_blank");
    if (!msg.read) {
      handleMarkRead(msg._id);
    }
  };

  const filterTabs = [
    { key: "all", label: "الكل", count: totalCount },
    { key: "unread", label: "غير مقروءة", count: unreadCount },
    { key: "read", label: "مقروءة", count: readCount },
  ];

  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <StatCard icon={MailOpen} label="إجمالي الرسائل" value={messages === undefined ? undefined : totalCount} color="bg-blue-500/10 text-blue-500" />
        <StatCard icon={Mail} label="رسائل جديدة" value={messages === undefined ? undefined : unreadCount} color="bg-primary/10 text-primary" />
        <StatCard icon={Check} label="تمت قراءتها" value={messages === undefined ? undefined : readCount} color="bg-emerald-500/10 text-emerald-500" />
      </div>

      <div className="flex gap-2 bg-card border border-border rounded-xl p-1 w-fit">
        {filterTabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setFilter(tab.key)}
            className={`px-4 py-1.5 rounded-lg text-sm font-medium transition-all cursor-pointer flex items-center gap-2 ${
              filter === tab.key
                ? "bg-primary text-primary-foreground shadow-sm"
                : "text-muted-foreground hover:text-foreground"
            }`}
          >
            {tab.label}
            {tab.count !== undefined && (
              <span
                className={`text-xs rounded-full px-1.5 py-0.5 font-bold ${
                  filter === tab.key ? "bg-primary-foreground/20" : "bg-muted"
                }`}
              >
                {tab.count}
              </span>
            )}
          </button>
        ))}
      </div>

      {messages === undefined ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, idx) => (
            <Skeleton key={idx} className="h-24 w-full rounded-xl" />
          ))}
        </div>
      ) : filteredMessages?.length === 0 ? (
        <div className="text-center py-20 text-muted-foreground bg-card border border-border rounded-2xl">
          <Mail className="w-10 h-10 mx-auto mb-3 opacity-30" />
          <p className="font-medium">لا توجد رسائل في هذا القسم</p>
        </div>
      ) : (
        <div className="space-y-3">
          <AnimatePresence initial={false}>
            {filteredMessages?.map((msg: any) => (
              <MessageCard
                key={msg._id}
                msg={msg}
                expanded={expandedId === msg._id}
                onToggle={() => setExpandedId(expandedId === msg._id ? null : msg._id)}
                onMarkRead={handleMarkRead}
                onDelete={handleDelete}
                onReply={handleReply}
              />
            ))}
          </AnimatePresence>
        </div>
      )}
    </div>
  );
}

// AdminBlog Management Component
function AdminBlog() {
  const posts = useQuery((api as any).posts.listAll);
  const createPost = useMutation((api as any).posts.create);
  const updatePost = useMutation((api as any).posts.update);
  const deletePost = useMutation((api as any).posts.deletePost);

  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingPost, setEditingPost] = useState<any | null>(null);

  // Form states
  const [title, setTitle] = useState("");
  const [slug, setSlug] = useState("");
  const [excerpt, setExcerpt] = useState("");
  const [content, setContent] = useState("");
  const [language, setLanguage] = useState("ar");
  const [author, setAuthor] = useState("إدارة الشركة");
  const [published, setPublished] = useState(true);

  const handleTitleChange = (val: string) => {
    setTitle(val);
    const generated = val
      .toLowerCase()
      .trim()
      .replace(/[^\w\s\u0621-\u064A-]/gi, "")
      .replace(/[\s_]+/g, "-");
    setSlug(generated);
  };

  const handleOpenCreate = () => {
    setEditingPost(null);
    setTitle("");
    setSlug("");
    setExcerpt("");
    setContent("");
    setLanguage("ar");
    setAuthor("إدارة الشركة");
    setPublished(true);
    setIsFormOpen(true);
  };

  const handleOpenEdit = (post: any) => {
    setEditingPost(post);
    setTitle(post.title);
    setSlug(post.slug);
    setExcerpt(post.excerpt);
    setContent(post.content);
    setLanguage(post.language);
    setAuthor(post.author);
    setPublished(post.published);
    setIsFormOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !slug || !excerpt || !content) {
      toast.error("يرجى ملء جميع الحقول المطلوبة");
      return;
    }
    try {
      if (editingPost) {
        await updatePost({
          id: editingPost._id,
          title,
          slug,
          excerpt,
          content,
          language,
          author,
          published,
        });
        toast.success("تم تحديث المقال بنجاح");
      } else {
        await createPost({
          title,
          slug,
          excerpt,
          content,
          language,
          author,
          published,
        });
        toast.success("تم إضافة المقال بنجاح");
      }
      setIsFormOpen(false);
    } catch (err) {
      toast.error("فشلت العملية، يرجى المحاولة لاحقاً");
    }
  };

  const handleDelete = async (id: any) => {
    if (window.confirm("هل أنت متأكد من رغبتك في حذف هذا المقال نهائياً؟")) {
      try {
        await deletePost({ id });
        toast.success("تم حذف المقال بنجاح");
      } catch (err) {
        toast.error("فشل الحذف");
      }
    }
  };

  const handleTogglePublish = async (post: any) => {
    try {
      await updatePost({
        id: post._id,
        title: post.title,
        slug: post.slug,
        excerpt: post.excerpt,
        content: post.content,
        language: post.language,
        author: post.author,
        published: !post.published,
      });
      toast.success(post.published ? "تم تحويل المقال لمسودة" : "تم نشر المقال بنجاح");
    } catch (err) {
      toast.error("فشل التعديل");
    }
  };

  const languageLabels: Record<string, string> = {
    ar: "العربية",
    en: "English",
    fr: "Français",
    it: "Italiano",
    zh: "中文",
  };

  return (
    <div className="space-y-6">
      {/* Blog actions */}
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-bold text-foreground">المقالات المنشورة</h2>
        <Button onClick={handleOpenCreate} className="gap-1.5 cursor-pointer">
          <Plus className="w-4 h-4" />
          كتابة مقال جديد
        </Button>
      </div>

      {posts === undefined ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, idx) => (
            <Skeleton key={idx} className="h-16 w-full rounded-xl" />
          ))}
        </div>
      ) : posts.length === 0 ? (
        <div className="text-center py-20 text-muted-foreground bg-card border border-border rounded-2xl">
          <BookOpen className="w-10 h-10 mx-auto mb-3 opacity-30" />
          <p className="font-medium">لم يتم نشر أي مقالات بعد</p>
        </div>
      ) : (
        <div className="overflow-x-auto bg-card border border-border rounded-2xl">
          <table className="w-full text-right border-collapse text-sm">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="px-5 py-3 font-semibold text-muted-foreground">المقال</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">اللغة</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">الكاتب</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">التاريخ</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">الحالة</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {posts.map((post: any) => (
                <tr key={post._id} className="border-b border-border last:border-0 hover:bg-muted/10 transition-colors">
                  <td className="px-5 py-4">
                    <div>
                      <div className="font-bold text-foreground">{post.title}</div>
                      <div className="text-xs text-muted-foreground truncate max-w-xs">{post.excerpt}</div>
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <Badge variant="outline" className="gap-1">
                      <Globe className="w-3 h-3 text-muted-foreground" />
                      {languageLabels[post.language] || post.language}
                    </Badge>
                  </td>
                  <td className="px-5 py-4 text-muted-foreground">{post.author}</td>
                  <td className="px-5 py-4 text-muted-foreground">
                    {new Date(post._creationTime).toLocaleDateString("ar", {
                      year: "numeric",
                      month: "short",
                      day: "numeric",
                    })}
                  </td>
                  <td className="px-5 py-4">
                    <button
                      onClick={() => handleTogglePublish(post)}
                      className={`inline-flex items-center gap-1 text-xs font-bold cursor-pointer rounded-full px-2.5 py-0.5 border ${
                        post.published
                          ? "bg-emerald-500/10 text-emerald-500 border-emerald-500/20"
                          : "bg-amber-500/10 text-amber-500 border-amber-500/20"
                      }`}
                    >
                      {post.published ? <Eye className="w-3.5 h-3.5" /> : <EyeOff className="w-3.5 h-3.5" />}
                      {post.published ? "منشور" : "مسودة"}
                    </button>
                  </td>
                  <td className="px-5 py-4">
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleOpenEdit(post)}
                        className="p-1.5 rounded-lg bg-muted/60 hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer transition-colors"
                        title="تعديل"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => handleDelete(post._id)}
                        className="p-1.5 rounded-lg bg-destructive/10 hover:bg-destructive text-destructive cursor-pointer transition-colors"
                        title="حذف"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* Editor Modal Overlay */}
      <AnimatePresence>
        {isFormOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsFormOpen(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="relative bg-card border border-border w-full max-w-2xl rounded-2xl shadow-xl overflow-hidden flex flex-col z-10 max-h-[90vh]"
            >
              <div className="p-5 border-b border-border bg-muted/20 flex items-center justify-between">
                <h3 className="font-bold text-foreground">
                  {editingPost ? "تعديل مقال" : "كتابة مقال جديد"}
                </h3>
                <button
                  onClick={() => setIsFormOpen(false)}
                  className="p-1.5 rounded-lg hover:bg-muted text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 overflow-y-auto space-y-4 flex-1">
                {/* Title */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">عنوان المقال</label>
                  <input
                    type="text"
                    required
                    value={title}
                    onChange={(e) => handleTitleChange(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    placeholder="مثال: أهمية الذكاء الاصطناعي في قطاع الأعمال"
                  />
                </div>

                {/* Slug */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">الرابط الفرعي (Slug)</label>
                  <input
                    type="text"
                    required
                    value={slug}
                    onChange={(e) => setSlug(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-left"
                    dir="ltr"
                    placeholder="importance-of-ai-in-business"
                  />
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {/* Language */}
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-muted-foreground">لغة المقال</label>
                    <select
                      value={language}
                      onChange={(e) => setLanguage(e.target.value)}
                      className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    >
                      <option value="ar">العربية</option>
                      <option value="en">English</option>
                      <option value="fr">Français</option>
                      <option value="it">Italiano</option>
                      <option value="zh">中文</option>
                    </select>
                  </div>

                  {/* Author */}
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-muted-foreground">الكاتب</label>
                    <input
                      type="text"
                      required
                      value={author}
                      onChange={(e) => setAuthor(e.target.value)}
                      className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    />
                  </div>
                </div>

                {/* Excerpt */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">المقتطف (ملخص المقال)</label>
                  <input
                    type="text"
                    required
                    value={excerpt}
                    onChange={(e) => setExcerpt(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    placeholder="ملخص قصير للمقال يظهر في قائمة المقالات..."
                  />
                </div>

                {/* Content */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">محتوى المقال (يدعم Markdown)</label>
                  <textarea
                    required
                    rows={8}
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-y font-sans"
                    placeholder="اكتب المقال هنا. يمكنك استخدام # للعناوين و - للنقاط..."
                  />
                </div>

                {/* Published Checkbox */}
                <div className="flex items-center gap-2 pt-2">
                  <input
                    type="checkbox"
                    id="published"
                    checked={published}
                    onChange={(e) => setPublished(e.target.checked)}
                    className="rounded border-border text-primary focus:ring-primary"
                  />
                  <label htmlFor="published" className="text-sm font-semibold text-foreground cursor-pointer select-none">
                    نشر المقال فوراً للزوار
                  </label>
                </div>

                {/* Form Actions */}
                <div className="pt-4 border-t border-border flex gap-3 justify-end">
                  <Button
                    type="button"
                    variant="ghost"
                    onClick={() => setIsFormOpen(false)}
                    className="cursor-pointer"
                  >
                    إلغاء
                  </Button>
                  <Button type="submit" className="cursor-pointer">
                    {editingPost ? "تحديث وتعديل" : "حفظ ونشر"}
                  </Button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}

// AdminOrders component
function AdminOrders() {
  const orders = useQuery((api as any).orders.listAll);
  const updateStatus = useMutation((api as any).orders.updateStatus);
  const deleteOrder = useMutation((api as any).orders.deleteOrder);

  const handleUpdateStatus = async (id: any, status: string) => {
    try {
      await updateStatus({ id, status });
      toast.success(status === "approved" ? "تم قبول طلب الدفع بنجاح" : "تم رفض الطلب");
    } catch (err) {
      toast.error("فشل التحديث");
    }
  };

  const handleDelete = async (id: any) => {
    if (window.confirm("هل أنت متأكد من حذف هذا الطلب نهائياً؟")) {
      try {
        await deleteOrder({ id });
        toast.success("تم حذف الطلب");
      } catch (err) {
        toast.error("فشل الحذف");
      }
    }
  };

  const planNames: Record<string, string> = {
    basic: "الباقة الأساسية",
    pro: "الباقة المتوسطة",
    enterprise: "الباقة المتقدمة",
  };

  const paymentMethods: Record<string, string> = {
    bankak: "تطبيق بنكك",
    syberpay: "بوابة SyberPay",
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-bold text-foreground">طلبات الاشتراك والمبيعات</h2>
      </div>

      {orders === undefined ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, idx) => (
            <Skeleton key={idx} className="h-20 w-full rounded-xl" />
          ))}
        </div>
      ) : orders.length === 0 ? (
        <div className="text-center py-20 text-muted-foreground bg-card border border-border rounded-2xl">
          <ShoppingBag className="w-10 h-10 mx-auto mb-3 opacity-30" />
          <p className="font-medium">لا توجد طلبات شراء مسجلة حالياً</p>
        </div>
      ) : (
        <div className="overflow-x-auto bg-card border border-border rounded-2xl">
          <table className="w-full text-right border-collapse text-sm">
            <thead>
              <tr className="border-b border-border bg-muted/30">
                <th className="px-5 py-3 font-semibold text-muted-foreground">العميل والطلب</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">الباقة والسعر</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">طريقة الدفع</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">رقم المعاملة</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">الحالة</th>
                <th className="px-5 py-3 font-semibold text-muted-foreground">إجراءات</th>
              </tr>
            </thead>
            <tbody>
              {orders.map((order: any) => (
                <tr key={order._id} className="border-b border-border last:border-0 hover:bg-muted/10 transition-colors">
                  <td className="px-5 py-4">
                    <div>
                      <div className="font-bold text-foreground">{order.name}</div>
                      <div className="text-xs text-muted-foreground">{order.phone}</div>
                      <div className="text-xs text-muted-foreground">{order.email}</div>
                      {order.details && <div className="text-xs text-primary mt-1">{order.details}</div>}
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <div>
                      <div className="font-semibold text-foreground">{planNames[order.planKey] || order.planKey}</div>
                      <div className="text-xs text-muted-foreground">{order.price} دولار</div>
                    </div>
                  </td>
                  <td className="px-5 py-4">
                    <Badge variant="outline">{paymentMethods[order.paymentMethod] || order.paymentMethod}</Badge>
                  </td>
                  <td className="px-5 py-4 font-mono text-xs">{order.transactionId || "N/A"}</td>
                  <td className="px-5 py-4">
                    <span
                      className={`inline-flex items-center gap-1 text-xs font-bold rounded-full px-2.5 py-0.5 border ${
                        order.status === "approved"
                          ? "bg-emerald-500/10 text-emerald-500 border-emerald-500/20"
                          : order.status === "rejected"
                          ? "bg-rose-500/10 text-rose-500 border-rose-500/20"
                          : "bg-amber-500/10 text-amber-500 border-amber-500/20"
                      }`}
                    >
                      {order.status === "approved" ? (
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      ) : order.status === "rejected" ? (
                        <XCircle className="w-3.5 h-3.5" />
                      ) : (
                        <Clock className="w-3.5 h-3.5" />
                      )}
                      {order.status === "approved" ? "مقبول" : order.status === "rejected" ? "مرفوض" : "قيد الانتظار"}
                    </span>
                  </td>
                  <td className="px-5 py-4">
                    <div className="flex gap-2">
                      {order.status === "pending" && (
                        <>
                          <button
                            onClick={() => handleUpdateStatus(order._id, "approved")}
                            className="p-1.5 rounded-lg bg-emerald-500/10 hover:bg-emerald-500 text-emerald-500 hover:text-white cursor-pointer transition-colors"
                            title="قبول"
                          >
                            <Check className="w-4 h-4" />
                          </button>
                          <button
                            onClick={() => handleUpdateStatus(order._id, "rejected")}
                            className="p-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500 text-rose-500 hover:text-white cursor-pointer transition-colors"
                            title="رفض"
                          >
                            <X className="w-4 h-4" />
                          </button>
                        </>
                      )}
                      <button
                        onClick={() => handleDelete(order._id)}
                        className="p-1.5 rounded-lg bg-destructive/10 hover:bg-destructive text-destructive cursor-pointer transition-colors"
                        title="حذف"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

// AdminGallery component
function AdminGallery() {
  const items = useQuery((api as any).gallery.listAll);
  const addItem = useMutation((api as any).gallery.add);
  const deleteItem = useMutation((api as any).gallery.deleteItem);

  const [isFormOpen, setIsFormOpen] = useState(false);

  // Form states
  const [title, setTitle] = useState("");
  const [src, setSrc] = useState("");
  const [thumb, setThumb] = useState("");
  const [categoryKey, setCategoryKey] = useState("gallery.cat.ai");
  const [language, setLanguage] = useState("ar");
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !src) {
      toast.error("يرجى ملء الحقول المطلوبة");
      return;
    }
    setIsSubmitting(true);
    try {
      await addItem({
        title,
        src,
        thumb: thumb || src, // use full resolution as fallback for thumbnail
        categoryKey,
        language,
      });
      toast.success("تم إضافة الصورة لمعرض الأعمال بنجاح");
      setIsFormOpen(false);
      setTitle("");
      setSrc("");
      setThumb("");
    } catch (err) {
      toast.error("فشل إضافة الصورة");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async (id: any) => {
    if (window.confirm("هل أنت متأكد من رغبتك في حذف هذه الصورة من المعرض؟")) {
      try {
        await deleteItem({ id });
        toast.success("تم حذف الصورة من المعرض");
      } catch (err) {
        toast.error("فشل الحذف");
      }
    }
  };

  const categoryLabels: Record<string, string> = {
    "gallery.cat.ai": "ذكاء اصطناعي",
    "gallery.cat.web": "تطوير ويب",
    "gallery.cat.mobile": "موبايل",
    "gallery.cat.automation": "أتمتة",
  };

  const languageLabels: Record<string, string> = {
    ar: "العربية",
    en: "English",
    fr: "Français",
    it: "Italiano",
    zh: "中文",
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h2 className="text-lg font-bold text-foreground">معرض صور ومشاريع الشركة</h2>
        <Button onClick={() => setIsFormOpen(true)} className="gap-1.5 cursor-pointer">
          <Plus className="w-4 h-4" />
          إضافة صورة جديدة
        </Button>
      </div>

      {items === undefined ? (
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, idx) => (
            <Skeleton key={idx} className="aspect-square w-full rounded-2xl" />
          ))}
        </div>
      ) : items.length === 0 ? (
        <div className="text-center py-20 text-muted-foreground bg-card border border-border rounded-2xl">
          <ImageIcon className="w-10 h-10 mx-auto mb-3 opacity-30" />
          <p className="font-medium">المعرض فارغ حالياً (يتم عرض الصور الافتراضية بالموقع)</p>
        </div>
      ) : (
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {items.map((item: any) => (
            <div key={item._id} className="group relative bg-card border border-border rounded-2xl overflow-hidden aspect-square flex flex-col justify-end">
              <img
                src={item.thumb}
                alt={item.title}
                className="absolute inset-0 w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
              />
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/30 to-transparent flex flex-col justify-end p-3 space-y-2 opacity-90 transition-opacity">
                <div>
                  <h4 className="font-bold text-white text-xs leading-snug line-clamp-2">{item.title}</h4>
                  <div className="flex flex-wrap gap-1 mt-1">
                    <span className="text-[9px] font-semibold bg-white/20 text-white px-1.5 py-0.5 rounded">
                      {categoryLabels[item.categoryKey] || item.categoryKey}
                    </span>
                    <span className="text-[9px] font-semibold bg-primary/20 text-primary-foreground px-1.5 py-0.5 rounded">
                      {languageLabels[item.language] || item.language}
                    </span>
                  </div>
                </div>
                <div className="flex justify-end">
                  <button
                    onClick={() => handleDelete(item._id)}
                    className="p-1 rounded bg-rose-500/20 hover:bg-rose-500 text-rose-400 hover:text-white cursor-pointer transition-colors"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add Image Overlay Dialog */}
      <AnimatePresence>
        {isFormOpen && (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setIsFormOpen(false)}
              className="absolute inset-0 bg-black/60 backdrop-blur-sm"
            />
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.95 }}
              className="relative bg-card border border-border w-full max-w-md rounded-2xl shadow-xl overflow-hidden flex flex-col z-10"
            >
              <div className="p-5 border-b border-border bg-muted/20 flex items-center justify-between">
                <h3 className="font-bold text-foreground">إضافة صورة جديدة للمعرض</h3>
                <button
                  onClick={() => setIsFormOpen(false)}
                  className="p-1.5 rounded-lg hover:bg-muted text-muted-foreground hover:text-foreground transition-colors cursor-pointer"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="p-6 space-y-4">
                {/* Title */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">عنوان المشروع/الصورة</label>
                  <input
                    type="text"
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    placeholder="مثال: لوحة تحكم لتطبيق المبيعات"
                  />
                </div>

                {/* Src URL */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">رابط الصورة (كاملة الدقة)</label>
                  <input
                    type="url"
                    required
                    value={src}
                    onChange={(e) => setSrc(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-left"
                    dir="ltr"
                    placeholder="https://images.unsplash.com/photo-..."
                  />
                </div>

                {/* Thumb URL */}
                <div className="space-y-1">
                  <label className="text-xs font-bold text-muted-foreground">رابط الصورة المصغرة (اختياري)</label>
                  <input
                    type="url"
                    value={thumb}
                    onChange={(e) => setThumb(e.target.value)}
                    className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary text-left"
                    dir="ltr"
                    placeholder="اتركه فارغاً لاستخدام الصورة الأصلية"
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  {/* Category */}
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-muted-foreground">التصنيف</label>
                    <select
                      value={categoryKey}
                      onChange={(e) => setCategoryKey(e.target.value)}
                      className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    >
                      <option value="gallery.cat.ai">ذكاء اصطناعي</option>
                      <option value="gallery.cat.web">تطوير ويب</option>
                      <option value="gallery.cat.mobile">تطبيق موبايل</option>
                      <option value="gallery.cat.automation">أتمتة</option>
                    </select>
                  </div>

                  {/* Language */}
                  <div className="space-y-1">
                    <label className="text-xs font-bold text-muted-foreground">اللغة المستهدفة</label>
                    <select
                      value={language}
                      onChange={(e) => setLanguage(e.target.value)}
                      className="w-full bg-background border border-border rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"
                    >
                      <option value="ar">العربية</option>
                      <option value="en">English</option>
                      <option value="fr">Français</option>
                      <option value="it">Italiano</option>
                      <option value="zh">中文</option>
                    </select>
                  </div>
                </div>

                {/* Form Actions */}
                <div className="pt-4 border-t border-border flex gap-3 justify-end">
                  <Button
                    type="button"
                    variant="ghost"
                    onClick={() => setIsFormOpen(false)}
                    className="cursor-pointer"
                  >
                    إلغاء
                  </Button>
                  <Button type="submit" disabled={isSubmitting} className="cursor-pointer">
                    {isSubmitting ? "جاري الإضافة..." : "إضافة للمعرض"}
                  </Button>
                </div>
              </form>
            </motion.div>
          </div>
        )}
      </AnimatePresence>
    </div>
  );
}

// Parent dashboard component
export default function AdminPage() {
  const [activeTab, setActiveTab] = useState<"messages" | "blog" | "orders" | "gallery">("messages");
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-muted/30">
      <AuthLoading>
        <div className="flex items-center justify-center h-screen">
          <div className="space-y-3 w-64">
            <Skeleton className="h-8 w-full" />
            <Skeleton className="h-4 w-3/4" />
          </div>
        </div>
      </AuthLoading>
      <Unauthenticated>
        <div className="flex flex-col items-center justify-center h-screen gap-6 text-center px-4">
          <div className="w-16 h-16 rounded-2xl bg-primary/10 flex items-center justify-center mx-auto">
            <Mail className="w-8 h-8 text-primary" />
          </div>
          <div>
            <h2 className="text-xl font-bold text-foreground mb-1">لوحة الإدارة</h2>
            <p className="text-muted-foreground">يجب تسجيل الدخول للوصول إلى هذه الصفحة</p>
          </div>
          <SignInButton />
        </div>
      </Unauthenticated>
      <Authenticated>
        <div className="max-w-5xl mx-auto px-4 py-10 space-y-8" dir="rtl">
          {/* Main Dashboard Header */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center">
                <Zap className="w-5 h-5 text-primary" />
              </div>
              <div>
                <h1 className="text-xl font-black text-foreground">لوحة الإدارة</h1>
                <p className="text-muted-foreground text-xs">شركة الاتمتة الرقمية</p>
              </div>
            </div>
            <Button variant="ghost" className="gap-2 cursor-pointer text-sm" onClick={() => navigate("/ar")}>
              <ArrowRight className="w-4 h-4" />
              العودة للموقع
            </Button>
          </div>

          {/* Section Navigation Tabs */}
          <div className="border-b border-border flex gap-4 overflow-x-auto">
            <button
              onClick={() => setActiveTab("messages")}
              className={`pb-3 text-sm font-semibold border-b-2 transition-all cursor-pointer flex items-center gap-2 shrink-0 ${
                activeTab === "messages"
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              <Mail className="w-4 h-4" />
              رسائل العملاء
            </button>
            <button
              onClick={() => setActiveTab("blog")}
              className={`pb-3 text-sm font-semibold border-b-2 transition-all cursor-pointer flex items-center gap-2 shrink-0 ${
                activeTab === "blog"
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              <FileText className="w-4 h-4" />
              إدارة المدونة
            </button>
            <button
              onClick={() => setActiveTab("orders")}
              className={`pb-3 text-sm font-semibold border-b-2 transition-all cursor-pointer flex items-center gap-2 shrink-0 ${
                activeTab === "orders"
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              <ShoppingBag className="w-4 h-4" />
              الطلبات والمبيعات
            </button>
            <button
              onClick={() => setActiveTab("gallery")}
              className={`pb-3 text-sm font-semibold border-b-2 transition-all cursor-pointer flex items-center gap-2 shrink-0 ${
                activeTab === "gallery"
                  ? "border-primary text-primary"
                  : "border-transparent text-muted-foreground hover:text-foreground"
              }`}
            >
              <ImageIcon className="w-4 h-4" />
              معرض الصور
            </button>
          </div>

          {/* Render Tab Content */}
          {activeTab === "messages" ? (
            <AdminMessages />
          ) : activeTab === "blog" ? (
            <AdminBlog />
          ) : activeTab === "orders" ? (
            <AdminOrders />
          ) : (
            <AdminGallery />
          )}
        </div>
      </Authenticated>
    </div>
  );
}
