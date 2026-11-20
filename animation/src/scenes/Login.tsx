import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { Cursor, pressed } from "../components/Cursor";
import { NAV_H, PublicNavbar } from "../components/Site";
import { appear, caretOn, lerp, typed } from "../anim";
import { C, easeInOut, nunito, quicksand } from "../theme";

export const LOGIN_LEN = 165;

const Input: React.FC<{ value: string; placeholder: string; focus: boolean; caret: boolean }> = ({ value, placeholder, focus, caret }) => (
  <div
    style={{
      height: 54,
      borderRadius: 10,
      border: `2px solid ${focus ? C.secondary : "#dde2dd"}`,
      boxShadow: focus ? "0 0 0 4px rgba(163,177,138,0.25)" : "none",
      display: "flex",
      alignItems: "center",
      padding: "0 18px",
      fontSize: 19,
      color: value ? "#222" : "#999",
      marginBottom: 16,
      letterSpacing: value.startsWith("•") ? 4 : 0,
    }}
  >
    {value || placeholder}
    {caret && <span style={{ width: 2, height: 24, background: "#222", marginLeft: 2 }} />}
  </div>
);

export const Login: React.FC = () => {
  const f = useCurrentFrame();
  const login = typed("jdupont", f, 30, 3);
  const pwd = "•".repeat(typed("xxxxxxxxxxxx", f, 64, 2).length);
  const zoom = lerp(f, [0, 30, 120, 150], [1, 1.22, 1.22, 1.3], easeInOut);
  const loading = lerp(f, [112, 120], [0, 1]);

  return (
    <Stage
      url="127.0.0.1:5005/login"
      zoom={zoom}
      ox={960}
      oy={560}
      caption={<Caption frame={f} tag="Espace staff" text="Accès réservé aux employés · mots de passe hachés (pbkdf2:sha256)" start={14} />}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background: "linear-gradient(135deg, #f0f5ee 0%, #dfe9da 100%)",
          fontFamily: nunito,
        }}
      >
        <PublicNavbar
          right={<span style={{ fontWeight: 700, fontSize: 19, color: C.text }}>Retour au site public</span>}
        />
        <div
          style={{
            position: "absolute",
            left: 800 - 240,
            top: NAV_H + 170,
            width: 480,
            background: "white",
            borderRadius: 18,
            padding: "36px 40px 40px",
            boxSizing: "border-box",
            boxShadow: "0 20px 50px rgba(30,50,35,0.15)",
            textAlign: "center",
            ...appear(f, 0, 18, 30),
          }}
        >
          <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 32, color: C.primary, marginBottom: 26 }}>Identification</div>
          <Input value={login} placeholder="Identifiant (ex: jdupont)" focus={f >= 26 && f < 60} caret={f >= 26 && f < 60 && caretOn(f)} />
          <Input value={pwd} placeholder="Mot de passe" focus={f >= 60 && f < 108} caret={f >= 60 && f < 108 && caretOn(f)} />
          <div
            style={{
              marginTop: 18,
              height: 56,
              borderRadius: 10,
              background: pressed(f, 108, 8) ? C.primaryDark : C.primary,
              color: "white",
              fontWeight: 800,
              fontSize: 20,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 12,
              transform: pressed(f, 108, 8) ? "scale(0.96)" : "none",
            }}
          >
            {loading > 0 ? (
              <>
                <span
                  style={{
                    width: 22,
                    height: 22,
                    borderRadius: 11,
                    border: "3px solid rgba(255,255,255,0.35)",
                    borderTopColor: "white",
                    transform: `rotate(${f * 18}deg)`,
                    opacity: loading,
                  }}
                />
                Connexion…
              </>
            ) : (
              "Se connecter"
            )}
          </div>
        </div>
      </div>
      <Cursor
        frame={f}
        appearAt={8}
        keys={[
          { f: 8, x: 1100, y: 700 },
          { f: 24, x: 760, y: 383 },
          { f: 26, x: 760, y: 383, click: true },
          { f: 54, x: 760, y: 383 },
          { f: 58, x: 760, y: 453 },
          { f: 60, x: 760, y: 453, click: true },
          { f: 90, x: 760, y: 453 },
          { f: 104, x: 800, y: 545 },
          { f: 108, x: 800, y: 545, click: true },
        ]}
      />
    </Stage>
  );
};
