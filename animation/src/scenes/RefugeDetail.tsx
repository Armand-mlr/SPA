import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { Cursor, pressed } from "../components/Cursor";
import { HeroBg, NAV_H, PublicNavbar } from "../components/Site";
import { appear, lerp, prog } from "../anim";
import { C, easeInOut, nunito, quicksand } from "../theme";
import { Animal, especesLyon, lyonAnimaux } from "../data";

const HERO = 260;
const FILTERS_Y = 284;
const GRID_Y = 530;
const CW = (1440 - 3 * 28) / 4;
const CH = 212;

const AnimalCard: React.FC<{ a: Animal; style: React.CSSProperties }> = ({ a, style }) => (
  <div
    style={{
      position: "absolute",
      width: CW,
      height: CH,
      background: "white",
      borderRadius: 15,
      overflow: "hidden",
      boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
      border: "1px solid #eee",
      display: "flex",
      flexDirection: "column",
      ...style,
    }}
  >
    <div
      style={{
        background: C.secondary,
        color: C.primary,
        padding: "16px 20px",
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
      }}
    >
      <span style={{ fontWeight: 800, fontSize: 22 }}>{a.nom}</span>
      <span style={{ background: "white", color: C.primary, fontWeight: 800, fontSize: 14, padding: "4px 12px", borderRadius: 12 }}>
        {a.espece}
      </span>
    </div>
    <div style={{ padding: "14px 20px", fontSize: 17, color: "#555", lineHeight: 1.7, flex: 1 }}>
      <div>
        <b>Race :</b> {a.race}
      </div>
      <div>
        <b>Âge :</b> {a.age} ans
      </div>
    </div>
    <div style={{ background: "#f8f8f8", borderTop: "1px solid #eee", padding: "12px", textAlign: "center" }}>
      <span
        style={{
          display: "inline-block",
          padding: "4px 16px",
          borderRadius: 20,
          fontWeight: 800,
          fontSize: 15,
          ...(a.statut === "Disponible"
            ? { background: "#d4edda", color: "#155724", border: "1px solid #c3e6cb" }
            : { background: "#f8d7da", color: "#721c24", border: "1px solid #f5c6cb" }),
        }}
      >
        {a.statut}
      </span>
    </div>
  </div>
);

const Field: React.FC<{ label: string; w: number; children: React.ReactNode; active?: boolean }> = ({ label, w, children, active }) => (
  <div style={{ width: w }}>
    <div style={{ fontSize: 15, fontWeight: 700, color: "#556", marginBottom: 6 }}>{label}</div>
    <div
      style={{
        height: 48,
        borderRadius: 12,
        border: `2px solid ${active ? C.secondary : "#e3e7e3"}`,
        background: "#fbfcfb",
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 14px",
        fontSize: 17,
        color: "#333",
      }}
    >
      {children}
    </div>
  </div>
);

const pos = (i: number) => ({ x: 80 + (i % 4) * (CW + 28), y: GRID_Y + Math.floor(i / 4) * (CH + 24) });

export const RefugeDetail: React.FC = () => {
  const f = useCurrentFrame();
  const scroll = lerp(f, [26, 62], [0, 250], easeInOut);
  const zoom = lerp(f, [0, 240], [1, 1.04], easeInOut);
  const open = f >= 82 && f < 106;
  const chosen = f >= 106;
  const filterAt = 130;
  const swap = prog(f, filterAt + 4, 30, easeInOut);

  const before = lyonAnimaux.filter((a) => a.nom !== "Nala").slice(0, 8);
  const after = lyonAnimaux.filter((a) => a.espece === "Chat");
  const all = Array.from(new Set([...before, ...after]));

  return (
    <Stage
      url={f < filterAt ? "127.0.0.1:5005/refuge/2" : "127.0.0.1:5005/refuge/2?espece=Chat"}
      zoom={zoom}
      caption={
        <>
          <Caption frame={f} tag="Fiche refuge" text="Les animaux actuellement hébergés, en temps réel" start={14} end={120} />
          <Caption frame={f} tag="Fiche refuge" text="Filtres par espèce, race, sexe et âge" start={134} />
        </>
      }
    >
      <div style={{ position: "absolute", inset: 0, background: C.bg, fontFamily: nunito }}>
        <div style={{ position: "absolute", left: 0, right: 0, top: NAV_H - scroll }}>
          <HeroBg height={HERO}>
            <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 60, ...appear(f, 2, 18) }}>SPA Lyon Centre</div>
            <div style={{ fontSize: 22, marginTop: 8, ...appear(f, 8, 18) }}>📍 Lyon (69002)</div>
            <div style={{ fontSize: 22, ...appear(f, 12, 18) }}>📞 0478001122</div>
          </HeroBg>

          {/* Bloc de filtres */}
          <div
            style={{
              position: "absolute",
              top: FILTERS_Y,
              left: 80,
              width: 1440,
              background: "white",
              borderRadius: 20,
              padding: "22px 35px 26px",
              boxShadow: "0 10px 30px rgba(47,79,79,0.08)",
              boxSizing: "border-box",
              zIndex: 5,
            }}
          >
            <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 22, color: C.slate, marginBottom: 14 }}>
              🔍 Trouver le compagnon idéal
            </div>
            <div style={{ display: "flex", gap: 24, alignItems: "flex-end" }}>
              <div style={{ position: "relative" }}>
                <Field label="Espèce" w={230} active={open || chosen}>
                  <span>{chosen ? "Chat" : "Toutes les espèces"}</span>
                  <span style={{ fontSize: 12, color: "#888" }}>▼</span>
                </Field>
                {open && (
                  <div
                    style={{
                      position: "absolute",
                      top: 80,
                      left: 0,
                      width: 230,
                      background: "white",
                      borderRadius: 10,
                      boxShadow: "0 10px 30px rgba(0,0,0,0.18)",
                      border: "1px solid #ddd",
                      overflow: "hidden",
                      zIndex: 30,
                      opacity: prog(f, 82, 5),
                    }}
                  >
                    {["Toutes les espèces", ...especesLyon].map((e, i) => (
                      <div
                        key={e}
                        style={{
                          height: 40,
                          lineHeight: "40px",
                          padding: "0 14px",
                          fontSize: 17,
                          background: e === "Chat" && f >= 96 ? C.primary : "white",
                          color: e === "Chat" && f >= 96 ? "white" : "#333",
                        }}
                      >
                        {e}
                      </div>
                    ))}
                  </div>
                )}
              </div>
              <Field label="Race" w={230}>
                <span>Toutes les races</span>
                <span style={{ fontSize: 12, color: "#888" }}>▼</span>
              </Field>
              <Field label="Sexe" w={200}>
                <span>Peu importe</span>
                <span style={{ fontSize: 12, color: "#888" }}>▼</span>
              </Field>
              <div>
                <div style={{ fontSize: 15, fontWeight: 700, color: "#556", marginBottom: 6 }}>Âge (ans)</div>
                <div style={{ display: "flex", gap: 10, alignItems: "center" }}>
                  {["Min", "Max"].map((t, i) => (
                    <React.Fragment key={t}>
                      {i === 1 && <span style={{ color: "#aaa" }}>à</span>}
                      <div
                        style={{
                          width: 90,
                          height: 48,
                          borderRadius: 12,
                          border: "2px solid #e3e7e3",
                          display: "flex",
                          alignItems: "center",
                          padding: "0 12px",
                          color: "#aaa",
                          fontSize: 17,
                          boxSizing: "border-box",
                        }}
                      >
                        {t}
                      </div>
                    </React.Fragment>
                  ))}
                </div>
              </div>
              <div style={{ marginLeft: "auto", textAlign: "center" }}>
                <div
                  style={{
                    background: pressed(f, filterAt) ? "#1e3535" : C.slate,
                    color: "white",
                    height: 48,
                    width: 250,
                    borderRadius: 12,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    fontWeight: 800,
                    fontSize: 17,
                    transform: pressed(f, filterAt) ? "scale(0.95)" : "none",
                  }}
                >
                  Filtrer les résultats
                </div>
              </div>
            </div>
          </div>

          <div style={{ position: "absolute", top: GRID_Y - 62, left: 80, fontFamily: quicksand, fontWeight: 700, fontSize: 32, color: C.primary }}>
            Nos pensionnaires actuels
          </div>

          {all.map((a, k) => {
            const i0 = before.indexOf(a);
            const i1 = after.indexOf(a);
            const p0 = i0 >= 0 ? pos(i0) : pos(i1);
            const p1 = i1 >= 0 ? pos(i1) : pos(i0);
            const x = p0.x + (p1.x - p0.x) * swap;
            const y = p0.y + (p1.y - p0.y) * swap;
            let opacity = 1;
            let scale = 1;
            if (i0 < 0) {
              const p = prog(f, filterAt + 18, 16);
              opacity = p;
              scale = 0.85 + 0.15 * p;
            } else if (i1 < 0) {
              const p = prog(f, filterAt + 2, 12);
              opacity = 1 - p;
              scale = 1 - 0.15 * p;
            }
            const intro = i0 >= 0 ? appear(f, 40 + i0 * 3, 18, 30) : { opacity: 1, transform: "" };
            return (
              <AnimalCard
                key={k}
                a={a}
                style={{
                  left: x,
                  top: y,
                  opacity: opacity * (intro.opacity as number),
                  transform: `scale(${scale}) ${intro.transform}`,
                }}
              />
            );
          })}
        </div>
        <PublicNavbar
          right={<span style={{ fontWeight: 700, fontSize: 19, color: C.text }}>Retour à l'accueil</span>}
        />
      </div>
      <Cursor
        frame={f}
        appearAt={60}
        keys={[
          { f: 60, x: 700, y: 620 },
          { f: 80, x: 230, y: 232 },
          { f: 82, x: 230, y: 232, click: true },
          { f: 96, x: 200, y: 318 },
          { f: 104, x: 200, y: 318, click: true },
          { f: 126, x: 1360, y: 232 },
          { f: filterAt, x: 1360, y: 232, click: true },
          { f: 170, x: 1300, y: 380 },
        ]}
      />
    </Stage>
  );
};
