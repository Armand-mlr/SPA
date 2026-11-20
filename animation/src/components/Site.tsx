import React from "react";
import { C, nunito, quicksand } from "../theme";
import { Refuge } from "../data";
import { Logo, Paw } from "./Paw";

export const NAV_H = 76;

/** Barre de navigation publique (cf. .navbar dans style.css). */
export const PublicNavbar: React.FC<{ right?: React.ReactNode; employeePressed?: boolean }> = ({ right, employeePressed }) => (
  <div
    style={{
      position: "absolute",
      top: 0,
      left: 0,
      right: 0,
      height: NAV_H,
      background: "white",
      boxShadow: "0 2px 10px rgba(0,0,0,0.06)",
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      padding: "0 80px",
      zIndex: 20,
    }}
  >
    <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 28 }}>
      <Logo size={28} color="#222" />
    </div>
    {right ?? (
      <div style={{ display: "flex", alignItems: "center", gap: 36, fontFamily: nunito, fontWeight: 700, fontSize: 19 }}>
        <span style={{ color: C.text }}>Accueil</span>
        <span
          style={{
            background: employeePressed ? C.primaryDark : C.primary,
            color: "white",
            padding: "11px 26px",
            borderRadius: 26,
            transform: employeePressed ? "scale(0.95)" : "none",
          }}
        >
          Espace Employé
        </span>
      </div>
    )}
  </div>
);

/** Fond du "hero" : dégradé vert du site avec motif d'empreintes (à la place de la photo Unsplash). */
export const HeroBg: React.FC<{ children?: React.ReactNode; height: number }> = ({ children, height }) => (
  <div
    style={{
      position: "relative",
      height,
      background: "linear-gradient(rgba(58,90,64,0.92), rgba(58,90,64,0.78)), linear-gradient(120deg, #6b8f62, #a3b18a)",
      overflow: "hidden",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      color: "white",
      textAlign: "center",
    }}
  >
    {[...Array(14)].map((_, i) => (
      <div
        key={i}
        style={{
          position: "absolute",
          left: (i * 137) % 1560,
          top: ((i * 89) % (height - 60)) + 10,
          opacity: 0.07,
          transform: `rotate(${(i * 47) % 90 - 45}deg)`,
        }}
      >
        <Paw size={34 + ((i * 7) % 30)} color="white" />
      </div>
    ))}
    <div style={{ position: "relative" }}>{children}</div>
  </div>
);

export const SectionTitle: React.FC<{ children: React.ReactNode; size?: number }> = ({ children, size = 40 }) => (
  <div style={{ textAlign: "center" }}>
    <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: size, color: C.primary }}>{children}</div>
    <div style={{ width: 60, height: 4, background: C.secondary, borderRadius: 2, margin: "10px auto 0" }} />
  </div>
);

/** Carte "refuge" de la page d'accueil. */
export const RefugeCard: React.FC<{ r: Refuge; style?: React.CSSProperties; btnPressed?: boolean; btnHover?: boolean }> = ({
  r,
  style,
  btnPressed,
  btnHover,
}) => (
  <div
    style={{
      background: "white",
      borderRadius: 15,
      overflow: "hidden",
      boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
      border: "1px solid #eee",
      fontFamily: nunito,
      ...style,
    }}
  >
    <div style={{ background: C.primary, color: "white", padding: "26px 24px", position: "relative" }}>
      <div style={{ fontWeight: 800, fontSize: 22 }}>{r.nom}</div>
      <span
        style={{
          position: "absolute",
          right: 14,
          top: 14,
          background: C.secondary,
          color: C.primaryDark,
          fontSize: 13,
          fontWeight: 800,
          padding: "4px 10px",
          borderRadius: 12,
        }}
      >
        {r.ville} ({r.cp})
      </span>
    </div>
    <div style={{ padding: "20px 24px", color: "#555", fontSize: 18, lineHeight: 1.9 }}>
      <div>
        <b style={{ color: "#444" }}>Capacité :</b> {r.capacite} places
      </div>
      <div>
        <b style={{ color: "#444" }}>Téléphone :</b> {r.tel}
      </div>
      <div style={{ fontStyle: "italic", fontSize: 16, color: "#888", marginTop: 6 }}>Un refuge partenaire de la SPA.</div>
    </div>
    <div style={{ background: "#f6f6f6", borderTop: "1px solid #eee", padding: 20, textAlign: "center" }}>
      <span
        style={{
          display: "inline-block",
          background: btnHover || btnPressed ? C.primaryDark : C.primary,
          color: "white",
          fontWeight: 800,
          fontSize: 18,
          padding: "11px 24px",
          borderRadius: 8,
          transform: btnPressed ? "scale(0.94)" : "none",
        }}
      >
        Voir les animaux
      </span>
    </div>
  </div>
);
