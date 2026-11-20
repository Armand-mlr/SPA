import React from "react";
import { nunito } from "../theme";

export const FRAME_W = 1600;
export const FRAME_H = 900;
export const BAR_H = 52;
export const CONTENT_H = FRAME_H - BAR_H;

/** Fenêtre de navigateur stylisée qui contient le site. */
export const BrowserFrame: React.FC<{ url: string; children: React.ReactNode }> = ({ url, children }) => {
  return (
    <div
      style={{
        width: FRAME_W,
        height: FRAME_H,
        borderRadius: 18,
        overflow: "hidden",
        background: "white",
        boxShadow: "0 40px 90px rgba(30,50,35,0.28), 0 8px 24px rgba(30,50,35,0.14)",
        border: "1px solid rgba(0,0,0,0.08)",
        display: "flex",
        flexDirection: "column",
        fontFamily: nunito,
      }}
    >
      <div
        style={{
          height: BAR_H,
          background: "#f1f3f1",
          borderBottom: "1px solid #e2e6e2",
          display: "flex",
          alignItems: "center",
          padding: "0 22px",
          gap: 10,
          flexShrink: 0,
        }}
      >
        {["#ff5f57", "#febc2e", "#28c840"].map((c) => (
          <div key={c} style={{ width: 14, height: 14, borderRadius: 7, background: c }} />
        ))}
        <div
          style={{
            marginLeft: 26,
            flex: 1,
            maxWidth: 760,
            height: 32,
            borderRadius: 16,
            background: "white",
            border: "1px solid #e0e4e0",
            display: "flex",
            alignItems: "center",
            padding: "0 16px",
            fontSize: 16,
            color: "#555",
            gap: 8,
          }}
        >
          <span style={{ fontSize: 12, opacity: 0.55 }}>ⓘ</span>
          {url}
        </div>
      </div>
      <div style={{ position: "relative", flex: 1, overflow: "hidden" }}>{children}</div>
    </div>
  );
};
