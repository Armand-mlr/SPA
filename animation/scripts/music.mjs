// Génère public/music.wav : une petite boucle "feel good" synthétisée (aucun échantillon externe,
// donc aucun souci de droits). Usage : node scripts/music.mjs
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(here, "..", "public", "music.wav");

// Durées des scènes (doivent correspondre à src/Video.tsx) → positions des transitions
const FPS = 30;
const SCENES = [110, 210, 235, 220, 165, 270, 315, 225, 230];
const TR = 18;
const TOTAL_FRAMES = SCENES.reduce((a, b) => a + b, 0) - TR * (SCENES.length - 1);
const transitions = [];
{
  let start = 0;
  for (let i = 0; i < SCENES.length - 1; i++) {
    start += SCENES[i] - TR;
    transitions.push(start / FPS);
  }
}

const SR = 44100;
const DUR = TOTAL_FRAMES / FPS + 1.5;
const N = Math.ceil(SR * DUR);
const L = new Float32Array(N);
const R = new Float32Array(N);
const SEND = new Float32Array(N); // bus de réverbe (mono)

const BPM = 96;
const BEAT = 60 / BPM;
const EIGHTH = BEAT / 2;
const BAR = BEAT * 4;
const TAU = Math.PI * 2;
const mtof = (m) => 440 * Math.pow(2, (m - 69) / 12);

let seed = 1234567;
const rnd = () => {
  seed = (Math.imul(seed, 1664525) + 1013904223) >>> 0;
  return (seed / 4294967296) * 2 - 1;
};

const put = (i, v, pan, rev) => {
  if (i < 0 || i >= N) return;
  const l = Math.cos(((pan + 1) * Math.PI) / 4);
  const r = Math.sin(((pan + 1) * Math.PI) / 4);
  L[i] += v * l;
  R[i] += v * r;
  SEND[i] += v * rev;
};

// --- Instruments --------------------------------------------------------------

function epiano(t, midi, vel, len = 1.8, pan = 0) {
  const f = mtof(midi);
  const i0 = Math.round(t * SR);
  const n = Math.round(len * SR);
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const env = (1 - Math.exp(-tt / 0.004)) * Math.exp(-tt / 0.85) * Math.min(1, (len - tt) / 0.08);
    const trem = 1 + 0.12 * Math.sin(TAU * 4.8 * tt);
    const v =
      Math.sin(TAU * f * tt) +
      0.32 * Math.sin(TAU * 2 * f * tt) * Math.exp(-tt / 0.35) +
      0.12 * Math.sin(TAU * 3 * f * tt) * Math.exp(-tt / 0.12) +
      0.05 * Math.sin(TAU * 7.1 * f * tt) * Math.exp(-tt / 0.03);
    put(i0 + k, 0.055 * vel * env * trem * v, pan, 0.35);
  }
}

function pad(t, midi, len, amp = 0.02) {
  const f = mtof(midi);
  const i0 = Math.round(t * SR);
  const n = Math.round(len * SR);
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const env = Math.min(1, tt / 0.6) * Math.min(1, (len - tt) / 0.7);
    let vl = 0;
    let vr = 0;
    for (let h = 1; h <= 5; h++) {
      const a = 1 / Math.pow(h, 1.6);
      vl += a * Math.sin(TAU * h * f * 1.003 * tt);
      vr += a * Math.sin(TAU * h * f * 0.997 * tt + 1);
    }
    const i = i0 + k;
    if (i < N) {
      L[i] += amp * env * vl;
      R[i] += amp * env * vr;
      SEND[i] += amp * env * (vl + vr) * 0.3;
    }
  }
}

function bass(t, midi, len, vel = 1) {
  const f = mtof(midi);
  const i0 = Math.round(t * SR);
  const n = Math.round(len * SR);
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const env = (1 - Math.exp(-tt / 0.006)) * Math.exp(-tt / 0.6) * Math.min(1, (len - tt) / 0.05);
    const v = Math.tanh(1.6 * (Math.sin(TAU * f * tt) + 0.25 * Math.sin(TAU * 2 * f * tt)));
    put(i0 + k, 0.2 * vel * env * v, 0, 0.02);
  }
}

function kick(t, vel = 1) {
  const i0 = Math.round(t * SR);
  const n = Math.round(0.4 * SR);
  let ph = 0;
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const f = 44 + 80 * Math.exp(-tt / 0.04);
    ph += (TAU * f) / SR;
    const env = Math.exp(-tt / 0.26);
    put(i0 + k, 0.55 * vel * env * Math.sin(ph), 0, 0.0);
  }
}

function snare(t, vel = 1) {
  const i0 = Math.round(t * SR);
  const n = Math.round(0.3 * SR);
  let lp = 0;
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const nz = rnd();
    lp += 0.25 * (nz - lp);
    const hp = nz - lp;
    const v = hp * Math.exp(-tt / 0.11) * 0.6 + 0.35 * Math.sin(TAU * 190 * tt) * Math.exp(-tt / 0.05);
    put(i0 + k, 0.2 * vel * v, 0.05, 0.45);
  }
}

function hat(t, vel = 1) {
  const i0 = Math.round(t * SR);
  const n = Math.round(0.08 * SR);
  let prev = 0;
  for (let k = 0; k < n; k++) {
    const tt = k / SR;
    const nz = rnd();
    const hp = nz - prev;
    prev = nz;
    put(i0 + k, 0.045 * vel * hp * Math.exp(-tt / 0.022), 0.35, 0.05);
  }
}

function pluck(t, midi, vel = 1, pan = -0.2) {
  const f = mtof(midi);
  const echoes = [
    [0, 1, pan],
    [3 * EIGHTH, 0.35, -pan],
    [6 * EIGHTH, 0.14, pan],
  ];
  for (const [dt, g, p] of echoes) {
    const i0 = Math.round((t + dt) * SR);
    const n = Math.round(0.9 * SR);
    for (let k = 0; k < n; k++) {
      const tt = k / SR;
      const env = (1 - Math.exp(-tt / 0.003)) * Math.exp(-tt / 0.3);
      const v =
        Math.sin(TAU * f * tt) +
        (1 / 9) * Math.sin(TAU * 3 * f * tt) * Math.exp(-tt / 0.1) +
        0.2 * Math.sin(TAU * 2 * f * tt) * Math.exp(-tt / 0.08);
      put(i0 + k, 0.075 * vel * g * env * v, p, 0.4);
    }
  }
}

function whoosh(tCenter, amp = 0.05) {
  const len = 1.0;
  const i0 = Math.round((tCenter - len * 0.6) * SR);
  const n = Math.round(len * SR);
  let lp = 0;
  for (let k = 0; k < n; k++) {
    const x = k / n;
    // monte jusqu'à 60 % puis redescend
    const env = x < 0.6 ? Math.pow(Math.sin((Math.PI / 2) * (x / 0.6)), 2) : Math.pow(Math.cos((Math.PI / 2) * ((x - 0.6) / 0.4)), 2);
    const cutoff = 0.02 + 0.25 * env;
    lp += cutoff * (rnd() - lp);
    const pan = -0.6 + 1.2 * x;
    put(i0 + k, amp * env * lp * 3, pan, 0.5);
  }
}

// --- Arrangement ---------------------------------------------------------------

// Fa majeur : F – C – Dm – Bb
const CHORDS = [
  { root: 41, notes: [65, 69, 72, 76] }, // Fmaj7
  { root: 36, notes: [64, 67, 72, 74] }, // C(add9)
  { root: 38, notes: [62, 65, 69, 72] }, // Dm7
  { root: 34, notes: [62, 65, 69, 70] }, // Bbmaj7
];

const MELODY = [
  [[0, 77], [3, 81], [6, 79]],
  [[0, 79], [2, 76], [4, 72]],
  [[0, 74], [3, 77], [5, 81], [7, 79]],
  [[0, 77], [4, 74], [6, 72]],
  [[0, 81], [2, 84], [3, 81], [6, 79]],
  [[0, 79], [3, 76], [6, 74]],
  [[0, 77], [2, 74], [4, 72], [6, 74]],
  [[0, 77]],
];

const nBars = Math.ceil((DUR - 1.5) / BAR);
const lastBar = nBars - 1;

for (let b = 0; b < nBars; b++) {
  const t0 = b * BAR;
  const ch = CHORDS[b % 4];
  const intro = b < 2;
  const outro = b >= lastBar - 1;
  const drums = !intro && !outro;
  const full = b >= 6 && !outro;

  // Nappe
  for (const m of ch.notes.slice(0, 3)) pad(t0, m - 12, BAR + 0.4, intro ? 0.014 : 0.018);

  // Piano électrique : accords syncopés
  const hits = outro && b === lastBar ? [[0, 1, 4.5]] : [[0, 1, 1.4], [3, 0.7, 1.2], [6, 0.8, 1.0]];
  for (const [e, v, len] of hits) {
    ch.notes.forEach((m, j) => epiano(t0 + e * EIGHTH + j * 0.008, m, v * (intro ? 0.75 : 1), len, j % 2 ? 0.25 : -0.25));
  }

  // Basse
  if (!intro) {
    if (b === lastBar) bass(t0, ch.root, 3, 0.9);
    else {
      bass(t0, ch.root, 3 * EIGHTH - 0.02, 1);
      bass(t0 + 3 * EIGHTH, ch.root, 3 * EIGHTH - 0.02, 0.8);
      bass(t0 + 6 * EIGHTH, ch.root + 12, 2 * EIGHTH - 0.02, 0.6);
    }
  }

  // Batterie
  if (drums) {
    kick(t0);
    kick(t0 + 4 * EIGHTH, 0.9);
    if (full) kick(t0 + 5 * EIGHTH, 0.5);
    if (b >= 4) {
      snare(t0 + 2 * EIGHTH);
      snare(t0 + 6 * EIGHTH);
    }
    for (let e = 0; e < 8; e++) hat(t0 + e * EIGHTH + (e % 2 ? 0.012 : 0), e % 2 ? 0.6 : 1);
  }

  // Mélodie
  if (b >= 6 && !outro) {
    for (const [e, m] of MELODY[(b - 6) % 8]) pluck(t0 + e * EIGHTH, m, 1, (b % 2 ? 0.25 : -0.25));
  } else if (b >= 2 && b < 6) {
    // arpège léger avant l'entrée de la mélodie
    ch.notes.forEach((m, j) => pluck(t0 + (j * 2 + 1) * EIGHTH, m + 12, 0.45, j % 2 ? 0.4 : -0.4));
  }
}

// Petits "whoosh" sur les transitions de scènes
for (const t of transitions) whoosh(t + TR / FPS / 2, 0.045);

// --- Réverbe (Freeverb simplifiée) ----------------------------------------------

function reverb(input, offset) {
  const combs = [1116, 1188, 1277, 1356, 1422, 1491].map((d) => ({ buf: new Float32Array(d + offset), i: 0, lp: 0 }));
  const aps = [556, 441, 341].map((d) => ({ buf: new Float32Array(d + offset), i: 0 }));
  const out = new Float32Array(N);
  const fb = 0.8;
  const damp = 0.3;
  for (let n = 0; n < N; n++) {
    const x = input[n] * 0.12;
    let s = 0;
    for (const c of combs) {
      const y = c.buf[c.i];
      c.lp = y * (1 - damp) + c.lp * damp;
      c.buf[c.i] = x + c.lp * fb;
      c.i = (c.i + 1) % c.buf.length;
      s += y;
    }
    for (const a of aps) {
      const y = a.buf[a.i];
      a.buf[a.i] = s + y * 0.5;
      a.i = (a.i + 1) % a.buf.length;
      s = y - s;
    }
    out[n] = s;
  }
  return out;
}

const wetL = reverb(SEND, 0);
const wetR = reverb(SEND, 23);

// --- Mixage & export ---------------------------------------------------------------

let peak = 0;
for (let n = 0; n < N; n++) {
  L[n] = Math.tanh((L[n] + wetL[n]) * 1.1);
  R[n] = Math.tanh((R[n] + wetR[n]) * 1.1);
  peak = Math.max(peak, Math.abs(L[n]), Math.abs(R[n]));
}
const gain = 0.89 / peak;

const data = Buffer.alloc(N * 4);
for (let n = 0; n < N; n++) {
  data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, L[n] * gain)) * 32767), n * 4);
  data.writeInt16LE(Math.round(Math.max(-1, Math.min(1, R[n] * gain)) * 32767), n * 4 + 2);
}
const header = Buffer.alloc(44);
header.write("RIFF", 0);
header.writeUInt32LE(36 + data.length, 4);
header.write("WAVE", 8);
header.write("fmt ", 12);
header.writeUInt32LE(16, 16);
header.writeUInt16LE(1, 20);
header.writeUInt16LE(2, 22);
header.writeUInt32LE(SR, 24);
header.writeUInt32LE(SR * 4, 28);
header.writeUInt16LE(4, 32);
header.writeUInt16LE(16, 34);
header.write("data", 36);
header.writeUInt32LE(data.length, 40);
fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, Buffer.concat([header, data]));
console.log(`music.wav : ${DUR.toFixed(1)} s, ${nBars} mesures à ${BPM} BPM, ${transitions.length} transitions`);
