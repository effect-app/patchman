import { Option, ReadonlyArray, pipe } from "effect"
const patches = (await import("./package.json", { assert: { type: "json"}})).default.pnpm.patchedDependencies

import fs from "fs"
import path from "path"

const repoNames = process.argv[2]?.split(",") ?? []

const repos = repoNames.map(repo => path.join(process.env.HOME!, "pj", repo))
const desiredPatches = Object.entries(patches).map(([name, patch]) => {
  return [name.substring(0, name.substring(1).indexOf("@") + 1), name, patch]
})

await Promise.all(repos.map(async repo => {
  const pj = (await import(path.join(repo, "package.json"), { assert: { type: "json"}})).default

  const patchies = pipe(Object.entries(pj.pnpm.patchedDependencies).map(([name, patch]) => {
    return name.substring(0, name.substring(1).indexOf("@") + 1)
  }), ReadonlyArray.filterMap(name => {
    const match = desiredPatches.find(([desiredName, desiredPatch]) => desiredName === name)
    return match ? Option.some(match) : Option.none()
  }))

  const repoPatches = path.join(repo, "patches")
  fs.rmSync(repoPatches, { recursive: true })
  fs.mkdirSync(repoPatches)

  pj.pnpm.patchedDependencies = patchies.reduce((acc, [name, desiredName, desiredPatch]) => { acc[desiredName]= desiredPatch; return acc}, { } as any)
  fs.writeFileSync(path.join(repo, "package.json"), JSON.stringify(pj, null, 2))

  patchies.forEach(([name, desiredName, desiredPatch]) => {
    fs.copyFileSync(desiredPatch, path.join(repo, desiredPatch))
  })
}))
