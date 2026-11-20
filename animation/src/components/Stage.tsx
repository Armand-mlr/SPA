import React from "react";
import { AbsoluteFill } from "remotion";
import { Background } from "./Background";
import { BrowserFrame, FRAME_W, FRAME_H } from "./BrowserFrame";
import { W, H } from "../theme";

/**
 * Scène "navigateur" : fond + fenêtre centrée, avec une caméra (zoom + décalage).
 * `zoom` agrandit autour du point (ox, oy) exprimé en pixels écran.
 */
export const Stage: React.FC<{
  url: string;
  zoom?: number;
  ox?: number;
  oy?: number;
  children: React.ReactNode;
  caption?: React.ReactNode;
}> = ({ url, zoom = 1, ox = W / 2, oy = H / 2, children, caption }) => {
  const left = (W - FRAME_W) / 2;
  const top = (H - FRAME_H) / 2 - 22;
  return (
    <AbsoluteFill>
      <Background />
      <AbsoluteFill style={{ transform: `scale(${zoom})`, transformOrigin: `${ox}px ${oy}px` }}>
        <div style={{ position: "absolute", left, top }}>
          <BrowserFrame url={url}>{children}</BrowserFrame>
        </div>
      </AbsoluteFill>
      {caption}
    </AbsoluteFill>
  );
};
