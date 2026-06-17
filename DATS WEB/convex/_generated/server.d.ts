import type {
  ActionCtx as GenericActionCtx,
  QueryCtx as GenericQueryCtx,
  MutationCtx as GenericMutationCtx,
  DatabaseReader as GenericDatabaseReader,
  DatabaseWriter as GenericDatabaseWriter,
} from "convex/server";
import type { DataModel } from "./dataModel.d.ts";

export declare function query(definition: { args?: any; handler: (ctx: QueryCtx, args: any) => any }): any;
export declare function mutation(definition: { args?: any; handler: (ctx: MutationCtx, args: any) => any }): any;

export type DatabaseReader = GenericDatabaseReader<DataModel>;
export type DatabaseWriter = GenericDatabaseWriter<DataModel>;
export type QueryCtx = GenericQueryCtx<DataModel>;
export type MutationCtx = GenericMutationCtx<DataModel>;
