import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { Cursor, pressed } from "../components/Cursor";
import { Sidebar, SIDEBAR_W } from "../components/Sidebar";
import { appear, lerp, prog } from "../anim";
import { C, easeInOut, nunito, quicksand } from "../theme";
import { alertesLocal, alertesReseau, equipeParis, top5 } from "../data";

export const DASH_LEN = 270;
const ADOPT_CLICK = 248;

const Title: React.FC<{ children: React.ReactNode; style?: React.CSSProperties }> = ({ children, style }) => (
  <div style={{ textAlign: "center", ...style }}>
    <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 32, color: C.primary }}>{children}</div>
    <div style={{ width: 50, height: 4, background: C.secondary, borderRadius: 2, margin: "8px auto 0" }} />
  </div>
);

const Toggle: React.FC<{ a: string; b: string; onB: number }> = ({ a, b, onB }) => (
  <div style={{ position: "relative", display: "flex", background: "#eef0ee", borderRadius: 20, padding: 4, fontSize: 15, fontWeight: 800 }}>
    <div
      style={{
        position: "absolute",
        top: 4,
        bottom: 4,
        left: 4 + onB * 92,
        width: 92,
        background: "white",
        borderRadius: 16,
        boxShadow: "0 2px 6px rgba(0,0,0,0.12)",
      }}
    />
    {[a, b].map((t, i) => (
      <div
        key={t}
        style={{
          position: "relative",
          width: 92,
          textAlign: "center",
          padding: "7px 0",
          color: (i === 1 ? onB : 1 - onB) > 0.5 ? "#222" : "#999",
        }}
      >
        {t}
      </div>
    ))}
  </div>
);

export const Dashboard: React.FC = () => {
  const f = useCurrentFrame();
  const network = prog(f, 84, 10);
  const rows = f >= 86 ? alertesReseau : alertesLocal;
  const zoom = lerp(f, [60, 90, 200, 232], [1, 1.16, 1.16, 1], easeInOut);
  const oy = lerp(f, [110, 150], [380, 780], easeInOut);
  const bars = (i: number) => prog(f, 136 + i * 6, 26);

  const tiles = [
    { e: "🐶", t: "Nouveau\nAnimal" },
    { e: "💉", t: "Saisir\nun Soin" },
    { e: "🏠", t: "Nouvelle\nAdoption" },
    { e: "🚚", t: "Transférer\nAnimal" },
  ];
  const hoverTile = f >= 236 ? 2 : -1;

  return (
    <Stage
      url="127.0.0.1:5005/dashboard"
      zoom={zoom}
      ox={1300}
      oy={oy}
      caption={
        <>
          <Caption frame={f} tag="Tableau de bord" text="Rappels de vaccins : mon refuge… ou tout le réseau" start={12} end={124} />
          <Caption frame={f} tag="Tableau de bord" text="Top 5 des refuges les plus actifs en transferts (vue SQL)" start={136} end={204} />
          <Caption frame={f} tag="Tableau de bord" text="Ajout, soin, adoption, transfert : tout se gère ici" start={216} />
        </>
      }
    >
      <div style={{ position: "absolute", inset: 0, background: "#eef3ef", fontFamily: nunito }}>
        <Sidebar />
        {/* Colonne gauche : actions + équipe */}
        <div style={{ position: "absolute", left: SIDEBAR_W + 30, top: 26, width: 380 }}>
          <Title style={appear(f, 4, 16)}>⚡ Mon Refuge : Actions</Title>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14, marginTop: 24 }}>
            {tiles.map((t, i) => {
              const hov = hoverTile === i;
              const press = i === 2 && pressed(f, ADOPT_CLICK, 8);
              return (
                <div
                  key={i}
                  style={{
                    height: 124,
                    background: hov ? "#f4f8f2" : "white",
                    borderRadius: 14,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                    justifyContent: "center",
                    gap: 8,
                    boxShadow: hov ? "0 10px 22px rgba(58,90,64,0.2)" : "0 3px 10px rgba(0,0,0,0.05)",
                    border: hov ? `2px solid ${C.secondary}` : "2px solid transparent",
                    ...appear(f, 8 + i * 4, 16),
                    transform: `${appear(f, 8 + i * 4, 16).transform} translateY(${hov ? -4 : 0}px) scale(${press ? 0.95 : 1})`,
                  }}
                >
                  <span style={{ fontSize: 32 }}>{t.e}</span>
                  <span style={{ fontWeight: 800, fontSize: 16, color: C.primaryDark, textAlign: "center", whiteSpace: "pre-line", lineHeight: 1.2 }}>
                    {t.t}
                  </span>
                </div>
              );
            })}
          </div>
          <Title style={{ marginTop: 36, ...appear(f, 20, 16) }}>👥 Mon Équipe</Title>
          <div style={{ background: "white", borderRadius: 14, marginTop: 22, padding: "8px 20px", ...appear(f, 24, 16) }}>
            {equipeParis.map((p, i) => (
              <div
                key={p.nom}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 14,
                  padding: "14px 0",
                  borderBottom: i < equipeParis.length - 1 ? "1px solid #eee" : "none",
                }}
              >
                <div style={{ width: 38, height: 38, borderRadius: 19, background: "#eee", display: "flex", alignItems: "center", justifyContent: "center", fontWeight: 800, color: "#555" }}>
                  {p.initiale}
                </div>
                <div>
                  <div style={{ fontWeight: 800, fontSize: 17, color: "#222" }}>{p.nom}</div>
                  <div style={{ fontSize: 14, color: "#888" }}>{p.fonction}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Colonne droite : suivi vétérinaire */}
        <div
          style={{
            position: "absolute",
            left: SIDEBAR_W + 440,
            top: 26,
            width: 850,
            height: 440,
            background: "white",
            borderRadius: 18,
            padding: "26px 30px",
            boxSizing: "border-box",
            boxShadow: "0 4px 14px rgba(0,0,0,0.05)",
            ...appear(f, 10, 18),
          }}
        >
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 32, color: C.primary }}>🩺 Suivi Vétérinaire</div>
            <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
              <Toggle a="Mon Refuge" b="Réseau" onB={network} />
              <Toggle a="Vaccins" b="Tout" onB={0} />
              <div
                style={{
                  width: 30,
                  height: 30,
                  borderRadius: 15,
                  background: C.pop,
                  color: "white",
                  fontWeight: 800,
                  fontSize: 15,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  transform: `scale(${f >= 86 && f < 96 ? 1.25 : 1})`,
                }}
              >
                {rows.length}
              </div>
            </div>
          </div>
          <div style={{ display: "flex", color: "#777", fontSize: 15, fontWeight: 700, padding: "26px 0 12px", borderBottom: "1px solid #e5e5e5" }}>
            <div style={{ width: 300 }}>Pensionnaire</div>
            <div style={{ width: 250 }}>Soin attendu</div>
            <div>Échéance</div>
          </div>
          {rows.map((r, i) => {
            const st = f >= 86 && i > 0 ? appear(f, 88 + i * 6, 14, 14) : {};
            return (
              <div key={r.animal} style={{ display: "flex", alignItems: "center", padding: "13px 0", borderBottom: "1px solid #f0f0f0", ...st }}>
                <div style={{ width: 300 }}>
                  <div style={{ fontWeight: 800, fontSize: 18, color: "#222" }}>{r.animal}</div>
                  <div style={{ fontSize: 14, color: "#888" }}>
                    {r.espece}
                    {f >= 86 ? ` · ${r.refuge}` : ""}
                  </div>
                </div>
                <div style={{ width: 250 }}>
                  <span style={{ background: "#e8eefc", color: "#3557c4", fontWeight: 800, fontSize: 14, padding: "5px 12px", borderRadius: 6 }}>
                    {r.soin}
                  </span>
                </div>
                <div style={{ color: C.pop, fontWeight: 800, fontSize: 18 }}>{r.date}</div>
              </div>
            );
          })}
        </div>

        {/* Top 5 des transferts sortants */}
        <div
          style={{
            position: "absolute",
            left: SIDEBAR_W + 440,
            top: 484,
            width: 850,
            height: 340,
            background: "white",
            borderRadius: 18,
            padding: "24px 30px",
            boxSizing: "border-box",
            boxShadow: "0 4px 14px rgba(0,0,0,0.05)",
            ...appear(f, 16, 18),
          }}
        >
          <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 28, color: C.primary, marginBottom: 18 }}>
            🏆 Top 5 · transferts sortants (2 ans)
          </div>
          {top5.map((t, i) => (
            <div key={t.nom} style={{ display: "flex", alignItems: "center", marginBottom: 13 }}>
              <div style={{ width: 230, fontWeight: 700, fontSize: 17, color: "#333" }}>
                {i + 1}. {t.nom}
              </div>
              <div style={{ flex: 1, height: 30, background: "#f1f4f0", borderRadius: 8, overflow: "hidden" }}>
                <div
                  style={{
                    width: `${(t.n / 4) * 100 * bars(i)}%`,
                    height: "100%",
                    borderRadius: 8,
                    background: i === 0 ? C.primary : i < 2 ? "#5b7d5f" : C.secondary,
                  }}
                />
              </div>
              <div style={{ width: 50, textAlign: "right", fontWeight: 800, fontSize: 18, color: C.primary, opacity: bars(i) }}>{t.n}</div>
            </div>
          ))}
        </div>
      </div>
      <Cursor
        frame={f}
        appearAt={30}
        keys={[
          { f: 30, x: 900, y: 700 },
          { f: 48, x: 405, y: 152 },
          { f: 62, x: 600, y: 230 },
          { f: 80, x: 1218, y: 64 },
          { f: 84, x: 1218, y: 64, click: true },
          { f: 120, x: 1300, y: 300 },
          { f: 150, x: 1340, y: 640 },
          { f: 200, x: 1340, y: 640 },
          { f: 236, x: 405, y: 288 },
          { f: ADOPT_CLICK, x: 405, y: 288, click: true },
        ]}
      />
    </Stage>
  );
};
