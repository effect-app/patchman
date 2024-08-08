import { Array, pipe } from "effect";
import fs from "fs";
import path from "path";

const touch = async (filename: string) => {
  const time = new Date();

  await fs.promises.utimes(filename, time, time).catch(async function (err) {
    if ("ENOENT" !== err.code) {
      throw err;
    }
    let fh = await fs.promises.open(filename, "a");
    await fh.close();
  });
};

const repoNames = process.argv[2]?.split(",") ?? [];

const patches = (await import("./package.json", { assert: { type: "json" } }))
  .default.pnpm.patchedDependencies;

const repos = repoNames.map((repo) => path.join(process.env.HOME!, "pj", repo));
const availablePatches = Object.entries(patches).map(([name, patch]) => {
  return [
    name.substring(1).includes("@")
      ? name.substring(0, name.substring(1).indexOf("@") + 1)
      : name,
    name,
    patch,
  ];
});

await Promise.all(
  repos.map(async (repo) => {
    const pj = await import(path.join(repo, "package.json"), {
      assert: { type: "json" },
    }).then((_) => _.default);

    const desiredPatches = pipe(
      Object.entries(pj.pnpm.patchedDependencies).map(([name, patch]) => {
        return name.substring(1).includes("@")
          ? name.substring(0, name.substring(1).indexOf("@") + 1)
          : name;
      }),
      Array.filterMap((name) =>
        Array.findFirst(
          availablePatches,
          ([desiredName]) => desiredName === name
        )
      )
    );

    const repoPatches = path.join(repo, "patches");
    if (fs.existsSync(repoPatches)) {
      fs.rmSync(repoPatches, { recursive: true });
    }
    fs.mkdirSync(repoPatches);
    await touch(repoPatches + "/.gitkeep");

    pj.pnpm.patchedDependencies = desiredPatches.reduce(
      (acc, [_, desiredName, desiredPatch]) => {
        acc[desiredName] = desiredPatch;
        return acc;
      },
      {} as any
    );
    fs.writeFileSync(
      path.join(repo, "package.json"),
      JSON.stringify(pj, null, 2)
    );

    desiredPatches.forEach(([_, __, desiredPatch]) => {
      fs.copyFileSync(desiredPatch, path.join(repo, desiredPatch));
    });
  })
);
