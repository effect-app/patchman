#!/bin/bash

# TODO: iterate instead: schema, effect, opentelemetry, platform

pwd=$(pwd)

cd ~/pj/effect/effect
git stash
echo "cleaning, codemodding and lint fixing effect repo"
pnpm clean && pnpm codemod && pnpm lint-fix
echo "building and patching effect packages"

#npx pnpm-patch-i -y @tanstack/query-core /Users/patrickroza/pj/tanstack/query/packages/query-core/build

declare -a arr1=(
"effect"
)

declare -a arr=(
#  "rpc"
  "sql"
  "platform"
#  "platform-node"
  "opentelemetry"
)

for i in "${arr1[@]}"
do
  cd ~/pj/effect/effect/packages/${i}
  pnpm build
  cd $pwd
  pnpm pnpm-patch-i -y ${i} ~/pj/effect/effect/packages/${i}/dist
done

for i in "${arr[@]}"
do
  cd ~/pj/effect/effect/packages/${i}
  pnpm build
  cd $pwd
  pnpm pnpm-patch-i -y @effect/${i} ~/pj/effect/effect/packages/${i}/dist
done

cd ~/pj/effect/effect
git stash

#~/pj/patchman.sh
