import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Add a new gallery item (Admin only)
export const add = mutation({
  args: {
    title: v.string(),
    src: v.string(),
    thumb: v.string(),
    categoryKey: v.string(),
    language: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.insert("gallery", {
      title: args.title,
      src: args.src,
      thumb: args.thumb,
      categoryKey: args.categoryKey,
      language: args.language,
    });
  },
});

// List all gallery items for admin panel
export const listAll = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.query("gallery").order("desc").collect();
  },
});

// List gallery items for a specific language
export const listPublished = query({
  args: {
    language: v.string(),
  },
  handler: async (ctx, args) => {
    return await ctx.db
      .query("gallery")
      .withIndex("by_language", (q) => q.eq("language", args.language))
      .order("desc")
      .collect();
  },
});

// Delete a gallery item (Admin only)
export const deleteItem = mutation({
  args: {
    id: v.id("gallery"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.delete(args.id);
  },
});
