#!/bin/bash

# TODO: iterate instead: schema, effect, opentelemetry, platform

pwd=$(pwd)
cd ~/pj/effect/effect
echo "cleaning, codemodding and lint fixing effect repo"
pnpm clean && pnpm codemod && pnpm lint-fix
echo "building effect packages"
cd packages/effect
cd ../effect && pnpm build
cd ../schema && pnpm build
cd ../sql && pnpm build
# cd ../opentelemetry && pnpm build
cd ../platform && pnpm build
# cd ../platform-node && pnpm build
cd ../..
git stash

cd $pwd

# npx pnpm-patch-i -y @effect/opentelemetry ~/pj/effect/effect/packages/opentelemetry/dist
npx pnpm-patch-i -y effect ~/pj/effect/effect/packages/effect/dist
npx pnpm-patch-i -y @effect/schema ~/pj/effect/effect/packages/schema/dist
npx pnpm-patch-i -y @effect/platform ~/pj/effect/effect/packages/platform/dist
npx pnpm-patch-i -y @effect/sql ~/pj/effect/effect/packages/sql/dist
#npx pnpm-patch-i -y @effect/platform-node ~/pj/effect/effect/packages/platform-node/dist

~/pj/patchman.sh
