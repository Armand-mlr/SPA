import React from "react";
import { interpolate } from "remotion";
import { C, nunito, quicksand, easeOut } from "../theme";

/** Légende en bas d'écran : une étiquette + une phrase. */
export const Caption: React.FC<{ frame: number; tag: string; text: string; start?: number; end?: number }> = ({
  frame,
  tag,
  text,
  start = 10,
  end,
}) => {
  const inP = interpolate(frame, [start, start + 18], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: easeOut,
  });
  const outP = end
    ? interpolate(frame, [end, end + 12], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })
    : 1;
  return (
    <div
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        bottom: 26,
        display: "flex",
        justifyContent: "center",
        opacity: inP * outP,
        transform: `translateY(${(1 - inP) * 30}px)`,
        zIndex: 50,
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 16,
          background: "rgba(255,255,255,0.96)",
          borderRadius: 40,
          padding: "10px 30px 10px 10px",
          boxShadow: "0 12px 30px rgba(30,50,35,0.2)",
        }}
      >
        <span
          style={{
            background: C.primary,
            color: "white",
            fontFamily: quicksand,
            fontWeight: 700,
            fontSize: 20,
            borderRadius: 30,
            padding: "8px 18px",
          }}
        >
          {tag}
        </span>
        <span style={{ fontFamily: nunito, fontWeight: 700, fontSize: 26, color: C.primaryDark }}>{text}</span>
      </div>
    </div>
  );
};
