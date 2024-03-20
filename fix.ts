const effectPJ = `{
  "type": "module",
  "sideEffects": [
    "./fluentExtensions.js",
    "./index.js"
   ]
}
`;

import fs from "fs";
fs.writeFileSync(
  "/Users/patrickroza/pj/effect/effect/packages/effect/dist/dist/esm/package.json",
  effectPJ,
  { encoding: "utf-8" }
);
