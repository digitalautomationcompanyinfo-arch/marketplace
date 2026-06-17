import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";
import type * as contact from "../contact.js";
import type * as users from "../users.js";

declare const fullApi: ApiFromModules<{
  contact: typeof contact;
  users: typeof users;
}>;
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, any, any, any>
>;
