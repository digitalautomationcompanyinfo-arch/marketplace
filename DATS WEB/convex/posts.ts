import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Get all posts for admin panel (sorted by creation time)
export const listAll = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.query("posts").order("desc").collect();
  },
});

// Get published posts filtered by language
export const listPublished = query({
  args: {
    language: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("posts")
      .withIndex("by_published", (q) =>
        q.eq("published", true).eq("language", args.language)
      )
      .order("desc")
      .collect();
  },
});

// Get a single published post by slug
export const getPostBySlug = query({
  args: {
    slug: v.string(),
    language: v.string(),
  },
  handler: async (ctx, args) => {
    const post = await ctx.db
      .query("posts")
      .withIndex("by_published", (q) =>
        q.eq("published", true).eq("language", args.language)
      )
      .filter((q) => q.eq(q.field("slug"), args.slug))
      .first();
    return post;
  },
});

// Create a new post (Admin only)
export const create = mutation({
  args: {
    title: v.string(),
    slug: v.string(),
    excerpt: v.string(),
    content: v.string(),
    language: v.string(),
    author: v.string(),
    published: v.boolean(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.insert("posts", {
      title: args.title,
      slug: args.slug,
      excerpt: args.excerpt,
      content: args.content,
      language: args.language,
      author: args.author,
      published: args.published,
    });
  },
});

// Update an existing post (Admin only)
export const update = mutation({
  args: {
    id: v.id("posts"),
    title: v.string(),
    slug: v.string(),
    excerpt: v.string(),
    content: v.string(),
    language: v.string(),
    author: v.string(),
    published: v.boolean(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.patch(args.id, {
      title: args.title,
      slug: args.slug,
      excerpt: args.excerpt,
      content: args.content,
      language: args.language,
      author: args.author,
      published: args.published,
    });
  },
});

// Delete a post (Admin only)
export const deletePost = mutation({
  args: {
    id: v.id("posts"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.delete(args.id);
  },
});
