import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { Background } from "../components/Background";
import { appear, pop, prog } from "../anim";
import { C, nunito, quicksand } from "../theme";

export const SCHEMA_LEN = 225;

// Modèle de données : 10 tables, centré sur Animal
const N: Record<string, { x: number; y: number; sub?: string }> = {
  Animal: { x: 560, y: 520, sub: "entité centrale" },
  Heberge: { x: 300, y: 330, sub: "historique daté" },
  Refuge: { x: 120, y: 520 },
  EstAffecte: { x: 300, y: 760 },
  Employe: { x: 560, y: 880 },
  DonneSoin: { x: 820, y: 760, sub: "ternaire" },
  Soin: { x: 1000, y: 880 },
  Adoption: { x: 820, y: 330 },
  Particulier: { x: 1000, y: 200 },
  Fourriere: { x: 560, y: 190 },
};
const E: [string, string][] = [
  ["Animal", "Heberge"],
  ["Heberge", "Refuge"],
  ["Animal", "Fourriere"],
  ["Animal", "Adoption"],
  ["Adoption", "Particulier"],
  ["Animal", "DonneSoin"],
  ["DonneSoin", "Soin"],
  ["DonneSoin", "Employe"],
  ["Employe", "EstAffecte"],
  ["EstAffecte", "Refuge"],
];
const ORDER = ["Animal", "Heberge", "Fourriere", "Adoption", "DonneSoin", "Refuge", "Particulier", "Soin", "Employe", "EstAffecte"];

export const Schema: React.FC = () => {
  const f = useCurrentFrame();
  const facts = [
    { big: "10", small: "tables" },
    { big: "2", small: "vues SQL" },
    { big: "CHECK", small: "règles métier en base" },
    { big: "COMMIT", small: "transactions + rollback" },
  ];
  return (
    <AbsoluteFill>
      <Background dark />
      <div style={{ position: "absolute", left: 120, top: 70, color: "white", ...appear(f, 0, 18) }}>
        <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 64 }}>Sous le capot</div>
        <div style={{ fontFamily: nunito, fontSize: 26, color: C.secondary, fontWeight: 700 }}>
          Une base PostgreSQL pensée pour la traçabilité de chaque animal
        </div>
      </div>

      <svg width={1920} height={1080} style={{ position: "absolute", left: 60, top: 60 }}>
        {E.map(([a, b], i) => {
          const p = prog(f, 26 + i * 5, 22);
          const A = N[a];
          const B = N[b];
          return (
            <line
              key={i}
              x1={A.x}
              y1={A.y}
              x2={A.x + (B.x - A.x) * p}
              y2={A.y + (B.y - A.y) * p}
              stroke="rgba(163,177,138,0.75)"
              strokeWidth={3}
              strokeDasharray={a === "Animal" ? "0" : "8 7"}
            />
          );
        })}
      </svg>
      {ORDER.map((k, i) => {
        const n = N[k];
        const s = pop(f, 14 + i * 5, 12);
        const center = k === "Animal";
        return (
          <div
            key={k}
            style={{
              position: "absolute",
              left: 60 + n.x,
              top: 60 + n.y,
              transform: `translate(-50%, -50%) scale(${s})`,
              background: center ? C.secondary : "white",
              color: C.primaryDark,
              borderRadius: 14,
              padding: center ? "18px 34px" : "12px 22px",
              fontFamily: "Consolas, monospace",
              fontWeight: 700,
              fontSize: center ? 34 : 24,
              boxShadow: center ? "0 0 0 8px rgba(163,177,138,0.25), 0 14px 30px rgba(0,0,0,0.3)" : "0 8px 20px rgba(0,0,0,0.25)",
              textAlign: "center",
              whiteSpace: "nowrap",
            }}
          >
            {k}
            {n.sub && <div style={{ fontFamily: nunito, fontSize: center ? 17 : 14, fontWeight: 700, color: "#5d7360" }}>{n.sub}</div>}
          </div>
        );
      })}

      <div style={{ position: "absolute", right: 110, top: 270, width: 560, display: "flex", flexDirection: "column", gap: 22 }}>
        {facts.map((x, i) => (
          <div
            key={x.big}
            style={{
              background: "rgba(255,255,255,0.08)",
              border: "1px solid rgba(255,255,255,0.15)",
              borderRadius: 18,
              padding: "20px 28px",
              display: "flex",
              alignItems: "baseline",
              gap: 18,
              color: "white",
              ...appear(f, 90 + i * 14, 18, 30),
            }}
          >
            <span style={{ fontFamily: quicksand, fontWeight: 700, fontSize: x.big.length > 5 ? 34 : 50, color: C.secondary }}>{x.big}</span>
            <span style={{ fontFamily: nunito, fontWeight: 700, fontSize: 26 }}>{x.small}</span>
          </div>
        ))}
        <div style={{ display: "flex", flexWrap: "wrap", gap: 10, marginTop: 6, ...appear(f, 150, 18) }}>
          {["Python", "Flask", "PostgreSQL", "psycopg2", "Jinja2", "Leaflet"].map((t) => (
            <span key={t} style={{ background: "white", color: C.primaryDark, borderRadius: 20, padding: "7px 16px", fontFamily: nunito, fontWeight: 800, fontSize: 18 }}>
              {t}
            </span>
          ))}
        </div>
      </div>
    </AbsoluteFill>
  );
};
