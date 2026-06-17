import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  contact: defineTable({
    name: v.string(),
    email: v.string(),
    message: v.string(),
    phone: v.optional(v.string()),
    read: v.boolean(),
  }),
  users: defineTable({
    tokenIdentifier: v.string(),
    name: v.optional(v.string()),
    email: v.optional(v.string()),
  }).index("by_token", ["tokenIdentifier"]),
  posts: defineTable({
    title: v.string(),
    slug: v.string(),
    excerpt: v.string(),
    content: v.string(),
    language: v.string(),
    author: v.string(),
    published: v.boolean(),
  }).index("by_published", ["published", "language"]),
  orders: defineTable({
    planKey: v.string(),
    name: v.string(),
    email: v.string(),
    phone: v.string(),
    paymentMethod: v.string(),
    transactionId: v.optional(v.string()),
    status: v.string(),
    price: v.string(),
    details: v.optional(v.string()),
  }),
  gallery: defineTable({
    title: v.string(),
    src: v.string(),
    thumb: v.string(),
    categoryKey: v.string(),
    language: v.string(),
  }).index("by_language", ["language"]),
});
