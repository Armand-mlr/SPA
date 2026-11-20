import React from "react";
import { AbsoluteFill, Audio, interpolate, staticFile } from "remotion";
import { TransitionSeries, linearTiming } from "@remotion/transitions";
import { fade } from "@remotion/transitions/fade";
import { slide } from "@remotion/transitions/slide";
import { Intro } from "./scenes/Intro";
import { Accueil } from "./scenes/Accueil";
import { Recherche, RECHERCHE_LEN } from "./scenes/Recherche";
import { RefugeDetail } from "./scenes/RefugeDetail";
import { Login, LOGIN_LEN } from "./scenes/Login";
import { Dashboard, DASH_LEN } from "./scenes/Dashboard";
import { Adoption, ADOPTION_LEN } from "./scenes/Adoption";
import { Schema, SCHEMA_LEN } from "./scenes/Schema";
import { Credits, CREDITS_LEN } from "./scenes/Credits";
import { easeInOut } from "./theme";

const T = 18; // durée de chaque transition (images)

export const SCENES: { C: React.FC; len: number }[] = [
  { C: Intro, len: 110 },
  { C: Accueil, len: 210 },
  { C: Recherche, len: RECHERCHE_LEN },
  { C: RefugeDetail, len: 220 },
  { C: Login, len: LOGIN_LEN },
  { C: Dashboard, len: DASH_LEN },
  { C: Adoption, len: ADOPTION_LEN },
  { C: Schema, len: SCHEMA_LEN },
  { C: Credits, len: CREDITS_LEN },
];

export const TOTAL = SCENES.reduce((s, x) => s + x.len, 0) - T * (SCENES.length - 1);

// Transition utilisée AVANT la scène d'indice i (i ≥ 1)
const transitionFor = (i: number) => {
  if (i === 1 || i === 7) return slide({ direction: "from-bottom" });
  if (i === 4) return slide({ direction: "from-right" });
  return fade();
};

export const Video: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: "#e4ece0" }}>
      <TransitionSeries>
        {SCENES.flatMap(({ C, len }, i) => {
          const items = [];
          if (i > 0) {
            items.push(
              <TransitionSeries.Transition
                key={`t${i}`}
                presentation={transitionFor(i)}
                timing={linearTiming({ durationInFrames: T, easing: easeInOut })}
              />,
            );
          }
          items.push(
            <TransitionSeries.Sequence key={`s${i}`} durationInFrames={len}>
              <C />
            </TransitionSeries.Sequence>,
          );
          return items;
        })}
      </TransitionSeries>
      <Audio
        src={staticFile("music.wav")}
        volume={(f) =>
          interpolate(f, [0, 20, TOTAL - 75, TOTAL - 5], [0, 0.85, 0.85, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          })
        }
      />
    </AbsoluteFill>
  );
};
