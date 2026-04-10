# PATCHMAN

also use https://github.com/antfu/pnpm-patch-i?tab=readme-ov-file

Quick patch refresh commands:

- `pnpm patch:query-core`
- `pnpm patch:dir <package-name> <source-dir> [target-dir]`

`pnpm patch:query-core` now also runs this prep flow automatically:

- fetches tags in `~/pj/tanstack/tanstack-query`
- checks out the release tag that matches patchman's installed `@tanstack/query-core` version (detached HEAD)
- runs `pnpm clean && pnpm build` in `packages/query-core`
- patches from `packages/query-core/build`