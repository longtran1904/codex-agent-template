#!/usr/bin/env bash

set -euo pipefail

echo "==> Linting"
pnpm lint

echo "==> Type checking"
pnpm exec tsc --noEmit

echo "==> Building production application"
pnpm build

if [ -f "playwright.config.ts" ]; then
  echo "==> Running browser tests"
  pnpm exec playwright test
fi

echo "==> Verification passed"