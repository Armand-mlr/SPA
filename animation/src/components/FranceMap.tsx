import React from "react";
import { refuges } from "../data";
import { nunito } from "../theme";

// Contour simplifié de la France métropolitaine (lon, lat)
const FRANCE: [number, number][] = [
  [2.55, 51.08], [1.85, 50.95], [1.6, 50.73], [1.58, 50.52], [1.55, 50.2], [1.38, 50.06], [1.08, 49.93],
  [0.37, 49.76], [0.1, 49.49], [0.23, 49.42], [-0.3, 49.33], [-1.05, 49.39], [-1.26, 49.67], [-1.62, 49.65],
  [-1.94, 49.72], [-1.8, 49.37], [-1.6, 48.84], [-1.51, 48.63], [-2.02, 48.65], [-2.76, 48.52], [-3.05, 48.78],
  [-3.45, 48.82], [-3.98, 48.72], [-4.5, 48.62], [-4.77, 48.33], [-4.55, 48.2], [-4.33, 48.1], [-4.73, 48.03],
  [-4.37, 47.8], [-3.92, 47.87], [-3.37, 47.73], [-3.12, 47.48], [-2.75, 47.5], [-2.52, 47.29], [-2.2, 47.27],
  [-2.1, 47.1], [-2.2, 46.95], [-1.78, 46.5], [-1.15, 46.15], [-1.0, 45.94], [-1.03, 45.62], [-1.07, 45.57],
  [-1.2, 45.0], [-1.25, 44.65], [-1.3, 44.2], [-1.45, 43.65], [-1.56, 43.48], [-1.78, 43.37], [-1.4, 43.25],
  [-1.0, 43.05], [-0.6, 42.9], [0.0, 42.75], [0.7, 42.85], [1.4, 42.6], [1.75, 42.5], [2.2, 42.42], [2.7, 42.42],
  [3.17, 42.43], [3.05, 42.55], [3.03, 42.75], [3.05, 42.9], [3.15, 43.15], [3.47, 43.28], [3.7, 43.4],
  [3.95, 43.53], [4.1, 43.55], [4.4, 43.45], [4.85, 43.35], [4.95, 43.42], [5.3, 43.3], [5.55, 43.2],
  [5.93, 43.1], [6.2, 43.08], [6.65, 43.25], [6.75, 43.42], [7.0, 43.53], [7.27, 43.68], [7.5, 43.78],
  [7.65, 44.0], [7.0, 44.2], [6.9, 44.45], [7.0, 44.7], [6.65, 45.0], [6.85, 45.15], [7.1, 45.3], [7.0, 45.6],
  [6.8, 45.85], [6.85, 46.0], [6.1, 46.15], [5.95, 46.3], [6.1, 46.6], [6.45, 46.95], [6.95, 47.3], [7.0, 47.45],
  [7.5, 47.55], [7.55, 47.95], [7.62, 48.3], [7.8, 48.6], [8.1, 48.85], [8.2, 48.97], [7.6, 49.08], [7.0, 49.15],
  [6.7, 49.2], [6.4, 49.47], [5.95, 49.45], [5.8, 49.55], [5.4, 49.6], [4.85, 49.8], [4.85, 50.15], [4.2, 49.97],
  [4.15, 50.25], [3.7, 50.3], [3.3, 50.5], [2.9, 50.7], [2.6, 50.82],
];
const CORSE: [number, number][] = [
  [9.35, 43.0], [9.5, 42.8], [9.55, 42.1], [9.4, 41.7], [9.2, 41.37], [8.8, 41.55], [8.6, 41.9], [8.6, 42.25],
  [8.7, 42.55], [9.1, 42.75],
];

// Villes dont l'étiquette est placée à gauche du marqueur (évite les chevauchements)
const LABEL_LEFT = ["Toulouse", "Bordeaux", "Nantes", "Rennes"];

const LON0 = -5.2;
const LAT0 = 51.3;
const KX = Math.cos((46.5 * Math.PI) / 180);

/** Projection équirectangulaire simple → coordonnées dans la boîte de la carte. */
export const makeProjection = (w: number, h: number) => {
  const spanX = (9.8 - LON0) * KX;
  const spanY = LAT0 - 41.2;
  const k = Math.min((w - 40) / spanX, (h - 30) / spanY);
  const offX = (w - spanX * k) / 2;
  const offY = (h - spanY * k) / 2;
  return (lon: number, lat: number): [number, number] => [offX + (lon - LON0) * KX * k, offY + (LAT0 - lat) * k];
};

const path = (pts: [number, number][], proj: (lon: number, lat: number) => [number, number]) =>
  pts.map(([lo, la], i) => `${i ? "L" : "M"}${proj(lo, la).map((v) => v.toFixed(1)).join(" ")}`).join(" ") + " Z";

/** Marqueur façon Leaflet. */
export const Pin: React.FC<{ x: number; y: number; drop: number; highlight?: number; size?: number }> = ({
  x,
  y,
  drop,
  highlight = 0,
  size = 1,
}) => {
  if (drop <= 0) return null;
  const w = 30 * size;
  const h = 46 * size;
  const fall = (1 - Math.min(drop, 1)) * -60;
  return (
    <div style={{ position: "absolute", left: x - w / 2, top: y - h + fall, width: w, height: h, opacity: Math.min(1, drop * 2) }}>
      {highlight > 0 && (
        <div
          style={{
            position: "absolute",
            left: w / 2 - 30,
            top: h - 30,
            width: 60,
            height: 60,
            borderRadius: 30,
            background: "rgba(230,57,70,0.25)",
            transform: `scale(${0.6 + highlight * 0.7})`,
            opacity: 1 - highlight * 0.5,
          }}
        />
      )}
      <svg width={w} height={h} viewBox="0 0 30 46" style={{ position: "absolute", filter: "drop-shadow(0 4px 3px rgba(0,0,0,0.3))" }}>
        <path
          d="M15 1 C7 1 1.5 7 1.5 14.5 C1.5 25 15 44 15 44 C15 44 28.5 25 28.5 14.5 C28.5 7 23 1 15 1 Z"
          fill={highlight > 0 ? "#E63946" : "#2a81cb"}
          stroke={highlight > 0 ? "#a32630" : "#1c5f99"}
          strokeWidth="1.5"
        />
        <circle cx="15" cy="14.5" r="5.5" fill="white" />
      </svg>
    </div>
  );
};

/**
 * Carte stylisée des refuges.
 * - pinDrop(i) : progression d'apparition (0→1) du marqueur i
 * - focus : 0→1 zoom vers le refuge `focusId`
 * - only : n'afficher que ces refuges (résultat d'une recherche)
 */
export const FranceMap: React.FC<{
  w: number;
  h: number;
  pinDrop: (i: number) => number;
  focus?: number;
  focusId?: number;
  only?: number[];
  highlight?: number;
  popup?: number;
  showLabels?: number;
}> = ({ w, h, pinDrop, focus = 0, focusId = 2, only, highlight = 0, popup = 0, showLabels = 0 }) => {
  const proj = makeProjection(w, h);
  const target = refuges.find((r) => r.id === focusId)!;
  const [tx, ty] = proj(target.lon, target.lat);
  const s = 1 + focus * 0.7;
  const cx = tx + (w / 2 - tx) * focus;
  const cy = ty + (h / 2 + 60 - ty) * focus;
  const place = (x: number, y: number): [number, number] => [cx + (x - tx) * s, cy + (y - ty) * s];

  return (
    <div
      style={{
        position: "relative",
        width: w,
        height: h,
        overflow: "hidden",
        borderRadius: 14,
        background: "linear-gradient(160deg, #e9efe6 0%, #dde6d8 100%)",
        boxShadow: "inset 0 0 0 1px rgba(0,0,0,0.06)",
      }}
    >
      <svg width={w} height={h} style={{ position: "absolute", inset: 0 }}>
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M40 0 L0 0 0 40" fill="none" stroke="rgba(58,90,64,0.06)" strokeWidth="1" />
          </pattern>
        </defs>
        <rect width={w} height={h} fill="url(#grid)" />
        <g transform={`translate(${cx} ${cy}) scale(${s}) translate(${-tx} ${-ty})`}>
          {[FRANCE, CORSE].map((pts, i) => (
            <path
              key={i}
              d={path(pts, proj)}
              fill="#f7f5ec"
              stroke="#9fb18f"
              strokeWidth={2 / s}
              strokeLinejoin="round"
            />
          ))}
        </g>
      </svg>
      {refuges.map((r, i) => {
        if (only && !only.includes(r.id)) return null;
        const [px, py] = place(...proj(r.lon, r.lat));
        const isFocus = r.id === focusId;
        return (
          <React.Fragment key={r.id}>
            <Pin x={px} y={py} drop={pinDrop(i)} highlight={isFocus ? highlight : 0} />
            {showLabels > 0 && (
              <div
                style={{
                  position: "absolute",
                  left: LABEL_LEFT.includes(r.ville) ? undefined : px + 16,
                  right: LABEL_LEFT.includes(r.ville) ? w - px + 16 : undefined,
                  top: r.ville === "Marseille" ? py - 8 : py - 30,
                  fontFamily: nunito,
                  fontWeight: 700,
                  fontSize: 15,
                  color: "#2c4530",
                  opacity: Math.min(showLabels, pinDrop(i)),
                  textShadow: "0 0 4px white, 0 0 4px white",
                  whiteSpace: "nowrap",
                }}
              >
                {r.ville}
              </div>
            )}
            {isFocus && popup > 0 && (
              <div
                style={{
                  position: "absolute",
                  left: px - 130,
                  top: py - 46 - 100,
                  width: 260,
                  background: "white",
                  borderRadius: 12,
                  padding: "14px 18px",
                  boxShadow: "0 6px 20px rgba(0,0,0,0.2)",
                  fontFamily: nunito,
                  textAlign: "center",
                  opacity: popup,
                  transform: `translateY(${(1 - popup) * 12}px) scale(${0.9 + popup * 0.1})`,
                }}
              >
                <div style={{ fontWeight: 800, fontSize: 20, color: "#2c4530" }}>{r.nom}</div>
                <div style={{ fontSize: 15, color: "#666" }}>
                  📍 {r.ville} ({r.cp}) · {r.capacite} places
                </div>
                <div
                  style={{
                    position: "absolute",
                    left: 120,
                    bottom: -9,
                    width: 20,
                    height: 20,
                    background: "white",
                    transform: "rotate(45deg)",
                  }}
                />
              </div>
            )}
          </React.Fragment>
        );
      })}
      <div
        style={{
          position: "absolute",
          right: 0,
          bottom: 0,
          background: "rgba(255,255,255,0.8)",
          fontSize: 12,
          padding: "2px 8px",
          color: "#444",
          fontFamily: nunito,
        }}
      >
        Leaflet | © OpenStreetMap contributors
      </div>
      <div
        style={{
          position: "absolute",
          left: 14,
          top: 14,
          background: "white",
          borderRadius: 6,
          boxShadow: "0 1px 4px rgba(0,0,0,0.3)",
          fontFamily: nunito,
          fontSize: 22,
          lineHeight: "30px",
          width: 34,
          textAlign: "center",
          color: "#333",
        }}
      >
        <div style={{ borderBottom: "1px solid #ccc" }}>+</div>
        <div>−</div>
      </div>
    </div>
  );
};
