import React from "react";
import { useCurrentFrame } from "remotion";
import { Stage } from "../components/Stage";
import { Caption } from "../components/Caption";
import { Cursor, pressed } from "../components/Cursor";
import { Sidebar, SIDEBAR_W } from "../components/Sidebar";
import { appear, caretOn, lerp, pop, prog, typed } from "../anim";
import { C, easeInOut, nunito, quicksand } from "../theme";

export const ADOPTION_LEN = 315;

// Repères temporels
const T = {
  select: 22,
  nom: 46,
  prenom: 74,
  tel: 98,
  adresse: 128,
  valider: 166,
  modal: 172,
  mLogin: 190,
  mPwd: 222,
  confirm: 252,
  success: 262,
};

const Label: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <div style={{ fontWeight: 700, fontSize: 15, color: "#445", marginBottom: 6 }}>{children}</div>
);

const Box: React.FC<{ value: string; ph: string; focus?: boolean; caret?: boolean; h?: number; big?: boolean }> = ({
  value,
  ph,
  focus,
  caret,
  h = 46,
  big,
}) => (
  <div
    style={{
      height: h,
      borderRadius: 8,
      border: `2px solid ${focus || big ? C.secondary : "#dfe3df"}`,
      boxShadow: focus ? "0 0 0 4px rgba(163,177,138,0.25)" : "none",
      display: "flex",
      alignItems: h > 50 ? "flex-start" : "center",
      padding: h > 50 ? "10px 14px" : "0 14px",
      fontSize: big ? 19 : 17,
      color: value ? "#222" : "#aaa",
      marginBottom: 16,
      boxSizing: "border-box",
      background: "white",
      letterSpacing: value.startsWith("•") ? 4 : 0,
    }}
  >
    {value || ph}
    {caret && <span style={{ width: 2, height: 22, background: "#222", marginLeft: 2 }} />}
  </div>
);

export const Adoption: React.FC = () => {
  const f = useCurrentFrame();
  const field = (text: string, start: number, speed = 2) => typed(text, f, start, speed);
  const focusOn = (start: number, end: number) => f >= start && f < end;
  const caretIf = (start: number, end: number) => focusOn(start, end) && caretOn(f);

  const nom = field("Lefèvre", T.nom + 4);
  const prenom = field("Camille", T.prenom + 4);
  const tel = field("0612345678", T.tel + 4, 1.6);
  const adresse = field("8 rue des Lilas, 75011 Paris", T.adresse + 4, 1);
  const modalP = prog(f, T.modal, 12) * (1 - prog(f, T.confirm + 4, 8));
  const mLogin = typed("jdupont", f, T.mLogin + 4, 3);
  const mPwd = "•".repeat(typed("xxxxxxxxxxxx", f, T.mPwd + 4, 2).length);
  const success = prog(f, T.success, 14);

  const zoom = lerp(f, [0, 20, 150, 175, 255, 275], [1, 1.08, 1.08, 1.18, 1.18, 1], easeInOut);
  const steps = [
    { t: "Animal", d: "statut → « Adopté »" },
    { t: "Heberge", d: "séjour clôturé (dateDepart)" },
    { t: "Adoption", d: "nouvelle ligne créée" },
  ];

  return (
    <Stage
      url="127.0.0.1:5005/adoption"
      zoom={zoom}
      ox={980}
      oy={520}
      caption={
        <>
          <Caption frame={f} tag="Adoption" text="Un formulaire simple pour enregistrer l'adoptant" start={10} end={162} />
          <Caption frame={f} tag="Sécurité" text="Chaque action sensible exige de ressaisir ses identifiants" start={176} end={258} />
          <Caption frame={f} tag="Transaction" text="3 tables mises à jour d'un coup, ou aucune (commit / rollback)" start={268} />
        </>
      }
    >
      <div style={{ position: "absolute", inset: 0, background: "#eef3ef", fontFamily: nunito }}>
        <Sidebar active="pens" />
        <div style={{ position: "absolute", left: SIDEBAR_W + 50, top: 30, right: 50 }}>
          <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 38, color: C.primary, ...appear(f, 0, 14) }}>
            Enregistrer une Adoption 🏠
          </div>
          <div
            style={{
              height: 52,
              borderRadius: 10,
              marginTop: 14,
              background: "#d4edda",
              color: "#155724",
              border: "1px solid #c3e6cb",
              display: "flex",
              alignItems: "center",
              padding: "0 20px",
              fontWeight: 800,
              fontSize: 19,
              opacity: success,
              transform: `translateY(${(1 - success) * -10}px)`,
            }}
          >
            ✅ Adoption enregistrée !
          </div>
          <div
            style={{
              position: "absolute",
              top: 92,
              left: 0,
              right: 0,
              background: "white",
              borderRadius: 18,
              padding: "28px 36px",
              boxShadow: "0 4px 14px rgba(0,0,0,0.05)",
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              columnGap: 50,
              opacity: appear(f, 4, 16).opacity,
              transform: `${appear(f, 4, 16).transform} translateY(${success * 66}px)`,
            }}
          >
            <div>
              <div style={{ color: C.primaryDark, fontWeight: 800, fontSize: 21, borderBottom: "2px solid #eee", paddingBottom: 10, marginBottom: 18 }}>
                1. L'Animal
              </div>
              <Label>Animal à adopter *</Label>
              <Box value={f >= T.select ? "Rex (Chien - Berger Allemand)" : ""} ph="-- Sélectionner --" big h={54} />
              <div style={{ fontSize: 14, color: "#666", marginTop: -8, marginBottom: 16 }}>
                Seuls les animaux avec le statut « Disponible » apparaissent ici.
              </div>
              <Label>Date de l'adoption *</Label>
              <Box value="15/12/2025" ph="" />
              {/* Résultat de la transaction */}
              <div style={{ marginTop: 18 }}>
                {steps.map((s, i) => {
                  const p = pop(f, T.success + 8 + i * 9, 13);
                  return (
                    <div
                      key={s.t}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: 12,
                        marginBottom: 10,
                        opacity: Math.min(1, p),
                        transform: `translateX(${(1 - p) * -30}px)`,
                      }}
                    >
                      <span style={{ background: C.primary, color: "white", borderRadius: 14, width: 28, height: 28, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 15, fontWeight: 800 }}>
                        ✓
                      </span>
                      <span style={{ fontFamily: "Consolas, monospace", fontWeight: 700, fontSize: 18, color: C.primaryDark }}>{s.t}</span>
                      <span style={{ fontSize: 17, color: "#555" }}>{s.d}</span>
                    </div>
                  );
                })}
              </div>
            </div>
            <div>
              <div style={{ color: C.primaryDark, fontWeight: 800, fontSize: 21, borderBottom: "2px solid #eee", paddingBottom: 10, marginBottom: 18 }}>
                2. L'Adoptant (Particulier)
              </div>
              <Label>Nom de famille *</Label>
              <Box value={nom} ph="Nom" focus={focusOn(T.nom, T.prenom)} caret={caretIf(T.nom, T.prenom)} />
              <Label>Prénom *</Label>
              <Box value={prenom} ph="Prénom" focus={focusOn(T.prenom, T.tel)} caret={caretIf(T.prenom, T.tel)} />
              <Label>Téléphone *</Label>
              <Box value={tel} ph="06..." focus={focusOn(T.tel, T.adresse)} caret={caretIf(T.tel, T.adresse)} />
              <Label>Adresse complète</Label>
              <Box value={adresse} ph="Numéro, Rue, Ville..." h={70} focus={focusOn(T.adresse, T.valider - 8)} caret={caretIf(T.adresse, T.valider - 8)} />
            </div>
            <div style={{ gridColumn: "span 2", display: "flex", justifyContent: "flex-end", marginTop: 6 }}>
              <div
                style={{
                  background: C.orange,
                  color: "white",
                  fontWeight: 800,
                  fontSize: 20,
                  padding: "15px 34px",
                  borderRadius: 10,
                  boxShadow: "0 6px 16px rgba(230,126,34,0.35)",
                  transform: pressed(f, T.valider, 8) ? "scale(0.95)" : "none",
                }}
              >
                🎉 Valider l'Adoption
              </div>
            </div>
          </div>
        </div>

        {/* Fenêtre de double authentification */}
        {modalP > 0 && (
          <div
            style={{
              position: "absolute",
              inset: 0,
              background: `rgba(20,30,22,${0.55 * modalP})`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              zIndex: 40,
            }}
          >
            <div
              style={{
                width: 460,
                background: "white",
                borderRadius: 18,
                padding: "30px 36px",
                textAlign: "center",
                boxShadow: "0 30px 60px rgba(0,0,0,0.3)",
                opacity: modalP,
                transform: `scale(${0.85 + 0.15 * modalP})`,
              }}
            >
              <div style={{ fontSize: 46 }}>🔒</div>
              <div style={{ fontFamily: quicksand, fontWeight: 700, fontSize: 28, color: C.primaryDark, margin: "4px 0 8px" }}>
                Authentification Staff
              </div>
              <div style={{ color: "#666", fontSize: 16, lineHeight: 1.5, marginBottom: 18 }}>
                L'adoption est un acte définitif. Confirmez votre identité pour procéder.
              </div>
              <div style={{ textAlign: "left" }}>
                <Label>Votre Identifiant</Label>
                <Box value={mLogin} ph="Login..." focus={focusOn(T.mLogin, T.mPwd)} caret={caretIf(T.mLogin, T.mPwd)} />
                <Label>Votre Mot de passe</Label>
                <Box value={mPwd} ph="Mot de passe..." focus={focusOn(T.mPwd, T.confirm)} caret={caretIf(T.mPwd, T.confirm)} />
              </div>
              <div style={{ display: "flex", gap: 12, marginTop: 6 }}>
                <div style={{ flex: 1, padding: "13px 0", borderRadius: 10, background: "#eee", color: "#555", fontWeight: 800, fontSize: 17 }}>Annuler</div>
                <div
                  style={{
                    flex: 1,
                    padding: "13px 0",
                    borderRadius: 10,
                    background: C.primary,
                    color: "white",
                    fontWeight: 800,
                    fontSize: 17,
                    transform: pressed(f, T.confirm, 8) ? "scale(0.94)" : "none",
                  }}
                >
                  Confirmer
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      <Cursor
        frame={f}
        appearAt={8}
        keys={[
          { f: 8, x: 900, y: 700 },
          { f: T.select - 2, x: 600, y: 261, click: true },
          { f: T.nom - 4, x: 1150, y: 258 },
          { f: T.nom, x: 1150, y: 258, click: true },
          { f: T.prenom - 4, x: 1150, y: 346 },
          { f: T.prenom, x: 1150, y: 346, click: true },
          { f: T.tel - 4, x: 1150, y: 434 },
          { f: T.tel, x: 1150, y: 434, click: true },
          { f: T.adresse - 4, x: 1150, y: 525 },
          { f: T.adresse, x: 1150, y: 525, click: true },
          { f: T.valider - 4, x: 1374, y: 620 },
          { f: T.valider, x: 1374, y: 620, click: true },
          { f: T.mLogin - 2, x: 800, y: 450, click: true },
          { f: T.mPwd - 4, x: 800, y: 535 },
          { f: T.mPwd, x: 800, y: 535, click: true },
          { f: T.confirm - 6, x: 900, y: 601 },
          { f: T.confirm, x: 900, y: 601, click: true },
          { f: T.confirm + 30, x: 1000, y: 650 },
        ]}
      />
    </Stage>
  );
};
