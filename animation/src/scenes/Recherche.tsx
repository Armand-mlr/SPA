import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { Cursor, pressed } from "../components/Cursor";
import { HomePage } from "../components/HomePage";
import { caretOn, lerp, pop, typed } from "../anim";
import { easeInOut } from "../theme";
import { refuges } from "../data";

export const RECHERCHE_LEN = 235;

/** Recherche "Lyon" → la carte zoome sur le refuge → clic sur "Voir les animaux". */
export const Recherche: React.FC = () => {
  const f = useCurrentFrame();
  const query = typed("Lyon", f, 38, 5);
  const zoom = lerp(f, [0, 24, 86, 116], [1, 1.38, 1.38, 1], easeInOut);
  const scroll = lerp(f, [90, 124, 172, 204], [0, 470, 470, 1130], easeInOut);
  const lyon = refuges.find((r) => r.id === 2)!;

  return (
    <Stage
      url={f < 84 ? "127.0.0.1:5005" : "127.0.0.1:5005/?query=Lyon"}
      zoom={zoom}
      ox={868}
      oy={540}
      caption={
        <>
          <Caption frame={f} tag="Recherche" text="Par ville ou code postal, même partiel (ex. « 69 »)" start={30} end={160} />
          <Caption frame={f} tag="Recherche" text="Chaque refuge présente ses pensionnaires" start={176} />
        </>
      }
    >
      <HomePage
        scroll={scroll}
        query={query}
        caret={f >= 32 && f < 84 && caretOn(f)}
        inputFocus={f >= 32 && f < 84}
        searchPressed={pressed(f, 80)}
        pinDrop={(i) => (f < 84 ? 1 : pop(f, 112, 10))}
        only={f < 84 ? undefined : [2]}
        focus={lerp(f, [124, 154], [0, 1], easeInOut)}
        highlight={f > 140 ? 0.5 + 0.5 * Math.sin((f - 140) / 6) : 0}
        popup={lerp(f, [150, 166], [0, 1])}
        cards={f < 84 ? undefined : [lyon]}
        cardBtnHover={f > 212}
        cardBtnPressed={pressed(f, 222)}
      />
      <Cursor
        frame={f}
        appearAt={6}
        keys={[
          { f: 6, x: 1080, y: 640 },
          { f: 30, x: 700, y: 424 },
          { f: 32, x: 700, y: 424, click: true },
          { f: 62, x: 700, y: 424 },
          { f: 78, x: 1016, y: 424 },
          { f: 80, x: 1016, y: 424, click: true },
          { f: 120, x: 1180, y: 600 },
          { f: 190, x: 1180, y: 600 },
          { f: 218, x: 300, y: 532 },
          { f: 222, x: 300, y: 532, click: true },
        ]}
      />
    </Stage>
  );
};
