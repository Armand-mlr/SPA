// Rend quelques images fixes pour vérifier la mise en page : node scripts/stills.mjs 132 449 960
import path from "node:path";
import { fileURLToPath } from "node:url";
import { bundle } from "@remotion/bundler";
import { renderStill, selectComposition } from "@remotion/renderer";

const root = path.join(path.dirname(fileURLToPath(import.meta.url)), "..");
const frames = process.argv.slice(2).map(Number);
const serveUrl = await bundle({ entryPoint: path.join(root, "src", "index.ts") });
const composition = await selectComposition({ serveUrl, id: "RefuGest" });
for (const frame of frames) {
  const output = path.join(root, "out", "stills", `f${String(frame).padStart(4, "0")}.jpg`);
  await renderStill({ serveUrl, composition, frame, output, imageFormat: "jpeg", jpegQuality: 70, scale: 0.6 });
  console.log("ok", output);
}
