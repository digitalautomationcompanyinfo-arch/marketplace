import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

export const submit = mutation({
  args: {
    name: v.string(),
    email: v.string(),
    message: v.string(),
    phone: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("contact", {
      name: args.name,
      email: args.email,
      message: args.message,
      phone: args.phone,
      read: false,
    });
  },
});

export const listAll = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.query("contact").order("desc").collect();
  },
});

export const markRead = mutation({
  args: {
    id: v.id("contact"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.patch(args.id, { read: true });
  },
});

export const deleteMessage = mutation({
  args: {
    id: v.id("contact"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.delete(args.id);
  },
});
