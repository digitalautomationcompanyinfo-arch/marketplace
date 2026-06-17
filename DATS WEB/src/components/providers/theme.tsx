import React from "react";
import { jsx, jsxs } from "react/jsx-runtime";
import { ThemeProvider as NextThemeProvider } from "next-themes";

const T = { jsx, jsxs, Fragment: React.Fragment };

function ThemeProvider({
  children:e,...t
}: any){
  return T.jsx(NextThemeProvider,{
    attribute:"class",defaultTheme:"system",enableSystem:!0,...t,children:e
  })
}
export { ThemeProvider as j5, ThemeProvider };
