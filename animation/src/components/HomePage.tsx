import React from "react";
import { C, nunito, quicksand } from "../theme";
import { refuges, Refuge } from "../data";
import { FranceMap } from "./FranceMap";
import { HeroBg, NAV_H, PublicNavbar, RefugeCard, SectionTitle } from "./Site";

// Positions dans la page (sous la barre de navigation)
export const HERO_H = 520;
export const MAP_Y = 542;
export const MAP_X = 80;
export const MAP_W = 1440;
export const MAP_H = 560;
export const CARDS_Y = 1310;
export const CARD_W = (1440 - 2 * 34) / 3;

/** Convertit une position de la page en position dans la zone de contenu du navigateur. */
export const toScreenY = (pageY: number, scroll: number) => NAV_H + pageY - scroll;

export const HomePage: React.FC<{
  scroll: number;
  heroIn?: (i: number) => React.CSSProperties;
  query: string;
  caret?: boolean;
  inputFocus?: boolean;
  searchPressed?: boolean;
  pinDrop: (i: number) => number;
  focus?: number;
  only?: number[];
  highlight?: number;
  popup?: number;
  showLabels?: number;
  cards?: Refuge[];
  cardBtnPressed?: boolean;
  cardBtnHover?: boolean;
}> = (p) => {
  const heroIn = p.heroIn ?? (() => ({}));
  const cards = p.cards ?? refuges.slice(2, 8);
  return (
    <div style={{ position: "absolute", inset: 0, background: C.bg, fontFamily: nunito }}>
      <div style={{ position: "absolute", left: 0, right: 0, top: NAV_H - p.scroll }}>
        <HeroBg height={HERO_H}>
          <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 68, ...heroIn(0) }}>Adoptez le bonheur.</div>
          <div style={{ fontSize: 24, marginTop: 14, opacity: 0.95, ...heroIn(1) }}>
            Parcourez nos refuges et trouvez l'animal qui changera votre vie.
          </div>
          <div style={{ display: "flex", gap: 14, justifyContent: "center", marginTop: 36, ...heroIn(2) }}>
            <div
              style={{
                width: 420,
                height: 54,
                borderRadius: 27,
                background: "white",
                display: "flex",
                alignItems: "center",
                padding: "0 24px",
                fontSize: 19,
                color: p.query ? "#222" : "#999",
                textAlign: "left",
                boxShadow: p.inputFocus ? "0 0 0 4px rgba(163,177,138,0.7)" : "none",
              }}
            >
              {p.query || "Ville ou Code Postal (ex: Lyon, 69002)..."}
              {p.caret && <span style={{ width: 2, height: 24, background: "#222", marginLeft: 2 }} />}
            </div>
            <div
              style={{
                height: 54,
                padding: "0 34px",
                borderRadius: 27,
                background: p.searchPressed ? "#8d9c74" : C.secondary,
                color: C.primaryDark,
                fontWeight: 800,
                fontSize: 19,
                display: "flex",
                alignItems: "center",
                transform: p.searchPressed ? "scale(0.94)" : "none",
              }}
            >
              Rechercher
            </div>
          </div>
        </HeroBg>

        <div style={{ position: "absolute", top: MAP_Y, left: MAP_X }}>
          <FranceMap
            w={MAP_W}
            h={MAP_H}
            pinDrop={p.pinDrop}
            focus={p.focus}
            only={p.only}
            highlight={p.highlight}
            popup={p.popup}
            showLabels={p.showLabels}
          />
          <div style={{ textAlign: "center", color: "#666", fontSize: 18, marginTop: 14 }}>
            💡 Cliquez sur un pin pour voir le refuge, ou cliquez sur un refuge pour le voir sur la carte.
          </div>
        </div>

        <div style={{ position: "absolute", top: CARDS_Y - 110, left: 0, right: 0 }}>
          <SectionTitle>Nos Refuges Partenaires</SectionTitle>
        </div>
        <div style={{ position: "absolute", top: CARDS_Y, left: MAP_X, display: "flex", gap: 34, flexWrap: "wrap", width: MAP_W }}>
          {cards.map((r, i) => (
            <RefugeCard
              key={r.id}
              r={r}
              style={{ width: CARD_W }}
              btnPressed={i === 0 && p.cardBtnPressed}
              btnHover={i === 0 && p.cardBtnHover}
            />
          ))}
        </div>
      </div>
      <PublicNavbar />
    </div>
  );
};
