const effectPJ = `{
  "type": "module",
  "sideEffects": [
    "./fluentExtensions.js",
    "./index.js"
   ]
}
`;

const bs = `"sideEffects": [
  "./dist/esm/fluentExtensions.js",
  "./dist/esm/index.js",
  "./dist/cjs/fluentExtensions.js",
  "./dist/cjs/index.js"
],`

import fs from "fs";
fs.writeFileSync(
  "/Users/patrickroza/pj/effect/effect/packages/effect/dist/dist/esm/package.json",
  effectPJ,
  { encoding: "utf-8" }
);

fs.writeFileSync(
  "/Users/patrickroza/pj/effect/effect/packages/effect/dist/package.json", 
  fs.readFileSync(
    "/Users/patrickroza/pj/effect/effect/packages/effect/dist/package.json", "utf-8")
    .replace(`"sideEffects": [],`, bs), 
  "utf-8"
)
