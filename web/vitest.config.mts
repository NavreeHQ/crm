import { fileURLToPath } from "node:url";
import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: { "@": fileURLToPath(new URL("./src", import.meta.url)) },
    // The Navree packages have a React of their own. Their components must use this app's React,
    // or hooks fail with "Invalid hook call".
    dedupe: ["react", "react-dom"],
  },
  test: {
    environment: "jsdom",
    include: ["src/**/*.test.{ts,tsx}"],
    restoreMocks: true,
    // Vitest loads a package from node_modules with Node's own resolution. `@casl/react` (a
    // dependency of `@navree/next`) would get its own React there, and `@navree/next` imports
    // `next/headers`, which Node cannot resolve (Next.js has no exports map) and which the tests
    // mock. Processing both here resolves them as the app does, and the mock applies.
    server: { deps: { inline: ["@casl/react", "@navree/next"] } },
  },
});
