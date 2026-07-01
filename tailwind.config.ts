import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/app/**/*.{ts,tsx}", "./src/components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        dmc: {
          black: "#030303",
          panel: "#0b0b08",
          soft: "#12120d",
          yellow: "#ffd400",
          gold: "#ffb800",
          muted: "#b7b7a8",
        },
      },
      fontFamily: {
        display: ["var(--font-display)", "Impact", "sans-serif"],
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
      },
      boxShadow: {
        glow: "0 0 42px rgba(255, 212, 0, 0.2)",
        panel: "0 20px 70px rgba(0, 0, 0, 0.45)",
      },
    },
  },
  plugins: [],
};

export default config;
