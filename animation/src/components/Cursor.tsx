import React from "react";
import { interpolate } from "remotion";
import { easeInOut } from "../theme";

export type CursorKey = { f: number; x: number; y: number; click?: boolean };

/** Curseur animé entre des positions-clés (coordonnées du contenu de la page), avec effet de clic. */
export const Cursor: React.FC<{ frame: number; keys: CursorKey[]; appearAt?: number }> = ({
  frame,
  keys,
  appearAt = 0,
}) => {
  const fs = keys.map((k) => k.f);
  const ext = { extrapolateLeft: "clamp", extrapolateRight: "clamp", easing: easeInOut } as const;
  const x = keys.length > 1 ? interpolate(frame, fs, keys.map((k) => k.x), ext) : keys[0].x;
  const y = keys.length > 1 ? interpolate(frame, fs, keys.map((k) => k.y), ext) : keys[0].y;

  const clicks = keys.filter((k) => k.click && k.f <= frame);
  const last = clicks[clicks.length - 1];
  const since = last ? frame - last.f : 999;
  const press = since < 8 ? interpolate(since, [0, 3, 8], [1, 0.82, 1]) : 1;
  const ripple = since < 18 ? since / 18 : 1;
  const opacity = interpolate(frame, [appearAt, appearAt + 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        position: "absolute",
        left: 0,
        top: 0,
        transform: `translate(${x}px, ${y}px)`,
        opacity,
        zIndex: 999,
        pointerEvents: "none",
      }}
    >
      {since < 18 && (
        <div
          style={{
            position: "absolute",
            left: -26,
            top: -26,
            width: 52,
            height: 52,
            borderRadius: 26,
            border: "3px solid rgba(58,90,64,0.75)",
            transform: `scale(${0.3 + ripple * 1.2})`,
            opacity: 1 - ripple,
          }}
        />
      )}
      <svg
        width="34"
        height="40"
        viewBox="0 0 24 28"
        style={{ transform: `scale(${press})`, transformOrigin: "0 0", filter: "drop-shadow(0 3px 4px rgba(0,0,0,0.3))" }}
      >
        <path
          d="M2 1 L2 22 L7.5 16.8 L11.2 25.5 L14.6 24 L10.9 15.5 L18.5 15.5 Z"
          fill="#111"
          stroke="white"
          strokeWidth="1.6"
          strokeLinejoin="round"
        />
      </svg>
    </div>
  );
};

/** Renvoie true si un clic a eu lieu dans les `win` dernières images (pour enfoncer un bouton). */
export const pressed = (frame: number, clickAt: number, win = 6) => frame >= clickAt && frame < clickAt + win;
