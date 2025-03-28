#!/bin/bash

# TODO: iterate instead: schema, effect, opentelemetry, platform

pwd=$(pwd)

cd ~/pj/effect/effect
echo "cleaning, codemodding and lint fixing effect repo"
pnpm clean && pnpm codemod && pnpm lint-fix
echo "building and patching effect packages"

declare -a arr=(
  "effect"
#  "rpc"
  "sql"
  "platform"
#  "platform-node"
  "opentelemetry"
)

for i in "${arr[@]}"
do
  cd ~/pj/effect/effect/packages/${i}
  pnpm build
  cd $pwd
  npx pnpm-patch-i -y $i ~/pj/effect/effect/packages/${i}/dist
done

cd ~/pj/effect/effect
git stash

~/pj/patchman.sh
