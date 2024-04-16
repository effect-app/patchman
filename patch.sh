#!/bin/bash

# TODO: iterate instead: schema, effect, opentelemetry, platform

pwd=$(pwd)
cd ~/pj/effect/effect
pnpm clean
cd packages/schema && pnpm build
cd ../effect && pnpm build
#cd ../opentelemetry && pnpm build
#cd ../platform && pnpm build
cd ../platform-node && pnpm build

cd $pwd

pnpm tsx ./fix.ts

npx pnpm-patch-i -y effect ~/pj/effect/effect/packages/effect/dist
npx pnpm-patch-i -y @effect/schema ~/pj/effect/effect/packages/schema/dist
#npx pnpm-patch-i -y @effect/platform ~/pj/effect/effect/packages/platform/dist
#npx pnpm-patch-i -y @effect/platform-node ~/pj/effect/effect/packages/platform-node/dist
#npx pnpm-patch-i -y @effect/opentelemetry ~/pj/effect/effect/packages/opentelemetry/dist

~/pj/patchman.sh
