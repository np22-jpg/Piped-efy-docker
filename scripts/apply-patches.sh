#!/usr/bin/env bash

set -euo pipefail

# Git sign-in
git config --global user.email "bot@github.com"
git config --global user.name "GitHub Bot"

# Apply patches
patches=$(ls patches/*.patch)

for patch in $patches; do
    echo "Applying patch: $patch"
    git apply "$patch" --directory Piped
done