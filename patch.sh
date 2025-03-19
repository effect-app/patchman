#!/bin/bash

# TODO: iterate instead: schema, effect, opentelemetry, platform

pwd=$(pwd)
cd ~/pj/effect/effect
echo "cleaning, codemodding and lint fixing effect repo"
pnpm clean && pnpm codemod && pnpm lint-fix
echo "building effect packages"
cd packages/effect
cd ../effect && pnpm build
#cd ../schema && pnpm build
cd ../rpc && pnpm build
cd ../sql && pnpm build
# cd ../opentelemetry && pnpm build
cd ../cluster && pnpm build
cd ../platform && pnpm build
cd ../platform-browser && pnpm build
cd ../platform-node && pnpm build
cd ../platform-node-shared && pnpm build
cd ../experimental && pnpm build
#cd ../platform-node && pnpm build
cd ../..
git stash

cd $pwd

# npx pnpm-patch-i -y @effect/opentelemetry ~/pj/effect/effect/packages/opentelemetry/dist
npx pnpm-patch-i -y effect ~/pj/effect/effect/packages/effect/dist
npx pnpm-patch-i -y @effect/experimental ~/pj/effect/effect/packages/experimental/dist
npx pnpm-patch-i -y @effect/platform ~/pj/effect/effect/packages/platform/dist
npx pnpm-patch-i -y @effect/platform-node ~/pj/effect/effect/packages/platform-node/dist
npx pnpm-patch-i -y @effect/platform-node-shared ~/pj/effect/effect/packages/platform-node-shared/dist
npx pnpm-patch-i -y @effect/platform-browser ~/pj/effect/effect/packages/platform-browser/dist
npx pnpm-patch-i -y @effect/rpc ~/pj/effect/effect/packages/rpc/dist
npx pnpm-patch-i -y @effect/sql ~/pj/effect/effect/packages/sql/dist

~/pj/patchman.sh
