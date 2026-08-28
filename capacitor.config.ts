import type { CapacitorConfig } from "@capacitor/cli";

const config: CapacitorConfig = {
  appId: "com.jamiematheson.vellumpad",
  appName: "Vellum Pad",
  webDir: "dist/client",
  // Local bundled desk only. Do not set server.url — that would load a remote
  // host (including the login-walled Vercel preview) instead of dist/client.
  ios: {
    contentInset: "never",
    scrollEnabled: true,
    preferredContentMode: "mobile",
  },
  plugins: {
    Keyboard: {
      resize: "none",
      resizeOnFullScreen: false,
    },
    StatusBar: {
      style: "DARK",
      backgroundColor: "#E6D7C0",
    },
  },
};

export default config;
