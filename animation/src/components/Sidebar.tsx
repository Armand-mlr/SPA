import React from "react";
import { C, nunito, quicksand } from "../theme";
import { Logo, Paw } from "./Paw";

export const SIDEBAR_W = 280;

/** Barre latérale de l'espace staff (cf. dashboard.css). */
export const Sidebar: React.FC<{ active?: "dash" | "pens" }> = ({ active = "dash" }) => {
  const item = (label: React.ReactNode, on: boolean, color = "rgba(255,255,255,0.9)") => (
    <div
      style={{
        padding: "13px 16px",
        borderRadius: 10,
        background: on ? "rgba(255,255,255,0.14)" : "transparent",
        color,
        fontWeight: 700,
        fontSize: 18,
        marginBottom: 6,
      }}
    >
      {label}
    </div>
  );
  return (
    <div
      style={{
        position: "absolute",
        left: 0,
        top: 0,
        bottom: 0,
        width: SIDEBAR_W,
        background: "linear-gradient(180deg, #2F4A33 0%, #263d2a 100%)",
        color: "white",
        fontFamily: nunito,
        padding: "26px 22px",
        boxSizing: "border-box",
      }}
    >
      <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 26 }}>
        <Logo size={26} color="white" />
      </div>
      <span
        style={{
          display: "inline-block",
          marginTop: 8,
          background: C.secondary,
          color: C.primaryDark,
          fontSize: 12,
          fontWeight: 800,
          padding: "3px 10px",
          borderRadius: 10,
          letterSpacing: 1,
        }}
      >
        STAFF ACCESS
      </span>
      <div style={{ display: "flex", alignItems: "center", gap: 14, margin: "30px 0 22px", paddingBottom: 22, borderBottom: "1px solid rgba(255,255,255,0.15)" }}>
        <div
          style={{
            width: 46,
            height: 46,
            borderRadius: 23,
            background: C.secondary,
            color: C.primaryDark,
            fontWeight: 800,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 18,
          }}
        >
          JD
        </div>
        <div>
          <div style={{ fontWeight: 800, fontSize: 17 }}>Jean Dupont</div>
          <div style={{ fontSize: 14, opacity: 0.75 }}>Connecté</div>
        </div>
      </div>
      {item("📊 Vue d'ensemble", active === "dash")}
      {item(
        <>
          <Paw size={18} color="white" style={{ marginRight: 6, marginTop: -3 }} />
          Pensionnaires
        </>,
        active === "pens",
      )}
      {item("🌍 Retour au site public", false)}
      <div style={{ borderTop: "1px solid rgba(255,255,255,0.15)", margin: "14px 0" }} />
      {item("🚪 Déconnexion", false, "#ff9b9b")}
    </div>
  );
};
