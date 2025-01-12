#!/usr/bin/env bash

# `set -x` will leak secrets
set -eu

# One-time setup:
# - sudo npm i -g typescript
# - sudo npm i -g ts-node
# - npm install

# Compile ts to js
npx tsc

# Run js
node skeeter.js "prime.png" 2 988 1113

