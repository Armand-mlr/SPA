import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Paw } from "./Paw";

/** Fond vert doux avec des empreintes qui dérivent lentement. */
export const Background: React.FC<{ dark?: boolean }> = ({ dark }) => {
  const f = useCurrentFrame();
  const paws = [
    { x: 70, y: 150, s: 70, r: -20 },
    { x: 1790, y: 110, s: 80, r: 25 },
    { x: 1800, y: 760, s: 70, r: -10 },
    { x: 40, y: 800, s: 90, r: 15 },
    { x: 1500, y: 990, s: 50, r: 30 },
    { x: 330, y: 990, s: 50, r: -30 },
  ];
  return (
    <AbsoluteFill
      style={{
        background: dark
          ? "radial-gradient(ellipse at 30% 20%, #4a6e50 0%, #3A5A40 45%, #263c2b 100%)"
          : "radial-gradient(ellipse at 30% 20%, #f6faf3 0%, #e4ece0 55%, #d3dfcd 100%)",
      }}
    >
      {paws.map((p, i) => (
        <div
          key={i}
          style={{
            position: "absolute",
            left: p.x,
            top: p.y + Math.sin((f + i * 40) / 50) * 10,
            transform: `rotate(${p.r + Math.sin((f + i * 25) / 70) * 6}deg)`,
            opacity: dark ? 0.1 : 0.1,
          }}
        >
          <Paw size={p.s} color={dark ? "#ffffff" : "#3A5A40"} />
        </div>
      ))}
    </AbsoluteFill>
  );
};
