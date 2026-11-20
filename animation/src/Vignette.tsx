import React from "react";
import { AbsoluteFill } from "remotion";
import { Accueil } from "./scenes/Accueil";
import { C, nunito, quicksand } from "./theme";

/** Image d'aperçu pour le README : la carte des refuges + bouton lecture (rendre l'image 195). */
export const Vignette: React.FC = () => (
  <AbsoluteFill>
    <Accueil />
    <AbsoluteFill style={{ background: "rgba(20,35,24,0.38)", alignItems: "center", justifyContent: "center", flexDirection: "column" }}>
      <div
        style={{
          width: 190,
          height: 190,
          borderRadius: 95,
          background: "rgba(255,255,255,0.95)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          boxShadow: "0 20px 50px rgba(0,0,0,0.35)",
        }}
      >
        <svg width="80" height="90" viewBox="0 0 80 90" style={{ marginLeft: 14 }}>
          <path d="M6 4 L76 45 L6 86 Z" fill={C.primary} strokeLinejoin="round" stroke={C.primary} strokeWidth="8" />
        </svg>
      </div>
      <div
        style={{
          marginTop: 34,
          background: "rgba(255,255,255,0.95)",
          borderRadius: 40,
          padding: "14px 36px",
          fontFamily: quicksand,
          fontWeight: 700,
          fontSize: 44,
          color: C.primaryDark,
          boxShadow: "0 12px 30px rgba(0,0,0,0.25)",
        }}
      >
        Voir la présentation <span style={{ fontFamily: nunito, fontWeight: 700, color: "#6b7d6d" }}>· 1 min</span>
      </div>
    </AbsoluteFill>
  </AbsoluteFill>
);
