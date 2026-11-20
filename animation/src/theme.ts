import { loadFont as loadQuicksand } from "@remotion/google-fonts/Quicksand";
import { loadFont as loadNunito } from "@remotion/google-fonts/Nunito";
import { Easing } from "remotion";

// Mêmes polices que le site (cf. templates/*.html)
export const { fontFamily: quicksand } = loadQuicksand("normal", {
  weights: ["500", "700"],
  subsets: ["latin", "latin-ext"],
});
export const { fontFamily: nunito } = loadNunito("normal", {
  weights: ["400", "600", "700", "800"],
  subsets: ["latin", "latin-ext"],
});

// Mêmes couleurs que appWeb/static/style.css
export const C = {
  primary: "#3A5A40",
  primaryDark: "#2c4530",
  sidebar: "#2F4A33",
  secondary: "#A3B18A",
  accent: "#DAD7CD",
  pop: "#E63946",
  text: "#333333",
  bg: "#f9fdf9",
  bgDash: "#eef3ef",
  slate: "#2F4F4F",
  orange: "#e67e22",
};

export const FPS = 30;
export const W = 1920;
export const H = 1080;

export const easeOut = Easing.bezier(0.22, 1, 0.36, 1);
export const easeInOut = Easing.bezier(0.65, 0, 0.35, 1);
