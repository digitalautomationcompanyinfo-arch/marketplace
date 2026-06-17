import { mutation, query } from "./_generated/server";
import { v } from "convex/values";

// Submit a new order
export const submit = mutation({
  args: {
    planKey: v.string(),
    name: v.string(),
    email: v.string(),
    phone: v.string(),
    paymentMethod: v.string(),
    transactionId: v.optional(v.string()),
    price: v.string(),
    details: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    return await ctx.db.insert("orders", {
      planKey: args.planKey,
      name: args.name,
      email: args.email,
      phone: args.phone,
      paymentMethod: args.paymentMethod,
      transactionId: args.transactionId,
      status: "pending",
      price: args.price,
      details: args.details,
    });
  },
});

// List all orders (Admin only)
export const listAll = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    return await ctx.db.query("orders").order("desc").collect();
  },
});

// Update order status (Admin only)
export const updateStatus = mutation({
  args: {
    id: v.id("orders"),
    status: v.string(), // "pending" | "approved" | "rejected"
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.patch(args.id, { status: args.status });
  },
});

// Delete an order (Admin only)
export const deleteOrder = mutation({
  args: {
    id: v.id("orders"),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthenticated");
    }
    await ctx.db.delete(args.id);
  },
});
