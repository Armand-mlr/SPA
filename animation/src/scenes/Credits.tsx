import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Background } from "../components/Background";
import { appear, lerp, pop, prog } from "../anim";
import { C, easeInOut, nunito, quicksand } from "../theme";
import { Paw } from "../components/Paw";

export const CREDITS_LEN = 230;

const Person: React.FC<{ initials: string; name: string; f: number; from: number; delay: number }> = ({ initials, name, f, from, delay }) => {
  const p = prog(f, delay, 24);
  return (
    <div
      style={{
        width: 470,
        background: "white",
        borderRadius: 24,
        padding: "34px 30px",
        textAlign: "center",
        boxShadow: "0 20px 50px rgba(30,50,35,0.15)",
        opacity: p,
        transform: `translateX(${(1 - p) * from}px)`,
      }}
    >
      <div
        style={{
          width: 110,
          height: 110,
          borderRadius: 55,
          margin: "0 auto 18px",
          background: `linear-gradient(135deg, ${C.primary}, #6b8f62)`,
          color: "white",
          fontFamily: quicksand,
          fontWeight: 700,
          fontSize: 42,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {initials}
      </div>
      <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 42, color: C.primaryDark }}>{name}</div>
      <div style={{ fontFamily: nunito, fontWeight: 800, fontSize: 30, color: C.secondary, marginTop: 6 }}>50 %</div>
    </div>
  );
};

export const Credits: React.FC = () => {
  const f = useCurrentFrame();
  const bar = lerp(f, [50, 90], [0, 1], easeInOut);
  const end = prog(f, 168, 30);
  const paw = pop(f, 170, 10);

  return (
    <AbsoluteFill>
      <Background />
      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", flexDirection: "column", opacity: 1 - end }}>
        <div style={{ fontFamily: nunito, fontWeight: 800, fontSize: 28, color: C.secondary, letterSpacing: 3, textTransform: "uppercase", ...appear(f, 0, 18) }}>
          Un projet réalisé à deux
        </div>
        <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 58, color: C.primary, marginTop: 8, ...appear(f, 6, 18) }}>
          Conception & développement
        </div>
        <div style={{ display: "flex", gap: 60, marginTop: 48, alignItems: "center" }}>
          <Person initials="AM" name="Armand Mulier" f={f} from={-120} delay={18} />
          <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 60, color: C.primary, opacity: prog(f, 34, 14) }}>&</div>
          <Person initials="RM" name="Ramy Metahri" f={f} from={120} delay={24} />
        </div>
        <div style={{ width: 1060, height: 16, marginTop: 40, borderRadius: 8, background: "rgba(58,90,64,0.12)", overflow: "hidden", display: "flex" }}>
          <div style={{ width: `${50 * bar}%`, background: C.primary }} />
          <div style={{ flex: 1, display: "flex", justifyContent: "flex-end" }}>
            <div style={{ width: `${100 * bar}%`, background: C.secondary }} />
          </div>
        </div>
        <div style={{ fontFamily: nunito, fontWeight: 700, fontSize: 28, color: "#4c5f4f", marginTop: 40, ...appear(f, 70, 18) }}>
          L2 Maths-Info · Université Gustave Eiffel · Décembre 2025
        </div>
        <div style={{ fontFamily: nunito, fontSize: 22, color: "#6b7d6d", marginTop: 8, ...appear(f, 80, 18) }}>
          Projet du cours de Bases de données · données de démonstration fictives
        </div>
      </AbsoluteFill>

      <AbsoluteFill style={{ alignItems: "center", justifyContent: "center", flexDirection: "column", opacity: end }}>
        <div style={{ transform: `scale(${paw})` }}>
          <Paw size={120} color={C.primary} />
        </div>
        <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 110, color: C.primary }}>Refu'Gest</div>
        <div style={{ fontFamily: nunito, fontWeight: 700, fontSize: 30, color: "#5d7360", marginTop: 6 }}>Adoptez le bonheur.</div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
