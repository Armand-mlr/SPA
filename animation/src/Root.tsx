import React from "react";
import { Composition } from "remotion";
import { Video, TOTAL } from "./Video";
import { Vignette } from "./Vignette";
import { FPS, W, H } from "./theme";

export const RemotionRoot: React.FC = () => (
  <>
    <Composition id="RefuGest" component={Video} durationInFrames={TOTAL} fps={FPS} width={W} height={H} />
    <Composition id="Vignette" component={Vignette} durationInFrames={210} fps={FPS} width={W} height={H} />
  </>
);
