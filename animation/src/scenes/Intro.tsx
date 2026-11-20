import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Background } from "../components/Background";
import { appear, pop, lerp } from "../anim";
import { nunito, quicksand, C } from "../theme";
import { Paw } from "../components/Paw";

export const Intro: React.FC = () => {
  const f = useCurrentFrame();
  const paw = pop(f, 6, 9);
  const letters = "Refu'Gest".split("");
  const line = lerp(f, [40, 70], [0, 1]);

  return (
    <AbsoluteFill>
      <Background dark />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", flexDirection: "column", color: "white" }}>
        <div style={{ transform: `scale(${paw}) rotate(${(1 - paw) * -40}deg)`, marginBottom: 10 }}>
          <Paw size={150} color={C.secondary} />
        </div>
        <div style={{ display: "flex", fontFamily: quicksand, fontWeight: 700, fontSize: 140, letterSpacing: -2 }}>
          {letters.map((l, i) => (
            <span key={i} style={{ display: "inline-block", ...appear(f, 16 + i * 2.5, 16, 50) }}>
              {l}
            </span>
          ))}
        </div>
        <div style={{ width: 380 * line, height: 5, borderRadius: 3, background: C.secondary, margin: "18px 0 26px" }} />
        <div style={{ fontFamily: nunito, fontWeight: 600, fontSize: 40, ...appear(f, 52, 20) }}>
          L'application de gestion des refuges de la SPA
        </div>
        <div
          style={{
            fontFamily: nunito,
            fontSize: 26,
            marginTop: 22,
            color: C.secondary,
            fontWeight: 700,
            letterSpacing: 2,
            textTransform: "uppercase",
            ...appear(f, 68, 20),
          }}
        >
          Flask · PostgreSQL · Leaflet
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
