import React from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import { ConvexReactClient as k3, ConvexProviderWithAuth as F3 } from "convex/react";
import { useAuth } from "./auth";

const T = { jsx, jsxs, Fragment: React.Fragment };

const G3 = new k3("https://proper-heron-442.convex.cloud");

function K3({
  children:e
}: { children: React.ReactNode }){
  return T.jsx(F3,{
    client:G3,
    useAuth:useAuth,
    children:e
  })
}
export { K3 as ConvexProvider, G3 as convexClient };
