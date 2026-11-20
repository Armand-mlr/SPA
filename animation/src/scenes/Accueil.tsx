import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { HomePage } from "../components/HomePage";
import { appear, lerp, pop } from "../anim";
import { easeInOut } from "../theme";

/** Page d'accueil : hero puis défilement vers la carte, les 10 refuges tombent un à un. */
export const Accueil: React.FC = () => {
  const f = useCurrentFrame();
  const scroll = lerp(f, [62, 104], [0, 470], easeInOut);
  const zoom = lerp(f, [0, 210], [1, 1.05], easeInOut);
  const pinDrop = (i: number) => pop(f, 102 + i * 6, 10);
  const labels = lerp(f, [170, 190], [0, 1]);

  return (
    <Stage
      url="127.0.0.1:5005"
      zoom={zoom}
      caption={
        <>
          <Caption frame={f} tag="Site public" text="Les visiteurs découvrent les refuges partenaires" start={8} end={96} />
          <Caption frame={f} tag="Site public" text="Une carte interactive des 10 refuges" start={110} />
        </>
      }
    >
      <HomePage
        scroll={scroll}
        heroIn={(i) => appear(f, 4 + i * 8, 20, 30)}
        query=""
        pinDrop={pinDrop}
        showLabels={labels}
      />
    </Stage>
  );
};
