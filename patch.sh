#!/bin/bash

pnpm tsx ./fix.ts

npx pnpm-patch-i -y effect ~/pj/effect/effect/packages/effect/dist
# npx pnpm-patch-i -y @effect/schema ~/pj/effect/effect/packages/schema/dist
# npx pnpm-patch-i -y @effect/opentelemetry ~/pj/effect/effect/packages/opentelemetry/dist

#~/pj/patchman.sh