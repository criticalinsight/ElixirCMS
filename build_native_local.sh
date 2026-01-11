#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
eval "$($HOME/.local/bin/mise activate bash)"
cd ~/publii_build
export BURRITO_TARGET=windows
export MIX_ENV=prod

echo "=== Starting native build ==="
mix local.hex --force
mix local.rebar --force
mix deps.get
mix release publii_ex --overwrite
echo "=== Build finished ==="
ls -la burrito_out/ 2>/dev/null
find . -name "*.exe"
