import { interpolate, spring } from "remotion";
import { easeOut, FPS } from "./theme";

const clamp = { extrapolateLeft: "clamp", extrapolateRight: "clamp" } as const;

/** 0 → 1 entre `start` et `start + dur` (ease-out). */
export const prog = (f: number, start: number, dur = 15, easing = easeOut) =>
  interpolate(f, [start, start + dur], [0, 1], { ...clamp, easing });

/** Interpolation bornée sur plusieurs points. */
export const lerp = (f: number, input: number[], output: number[], easing = easeOut) =>
  interpolate(f, input, output, { ...clamp, easing });

/** Apparition : opacité + petit glissement vers le haut. */
export const appear = (f: number, start: number, dur = 18, dist = 24) => {
  const p = prog(f, start, dur);
  return { opacity: p, transform: `translateY(${(1 - p) * dist}px)` };
};

/** Ressort rebondi pour les "pop". */
export const pop = (f: number, start: number, damping = 12) =>
  spring({ frame: f - start, fps: FPS, config: { damping, stiffness: 180, mass: 0.6 } });

/** Texte tapé au clavier, `speed` images par caractère. */
export const typed = (text: string, f: number, start: number, speed = 3) => {
  const n = Math.max(0, Math.floor((f - start) / speed));
  return text.slice(0, Math.min(text.length, n));
};

export const typingDone = (text: string, start: number, speed = 3) => start + text.length * speed;

/** Barre de saisie clignotante. */
export const caretOn = (f: number) => Math.floor(f / 15) % 2 === 0;
