#!/usr/bin/env bash

set -euo pipefail

# Apply patches
patches=$(ls patches/*.patch)

for patch in $patches; do
    echo "Applying patch: $patch"
    git apply "$patch" --directory Piped
done