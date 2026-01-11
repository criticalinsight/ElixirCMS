#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"
eval "$($HOME/.local/bin/mise activate bash)"

cd /mnt/c/Users/Lenovo/Desktop/publii/publii_ex

echo "=== Checking tools ==="
elixir --version
zig version

echo "=== Building release for Windows target ==="
mix local.hex --force
mix local.rebar --force
mix deps.get

# Set BURRITO_TARGET to force Windows ERTS download
export BURRITO_TARGET=windows
export MIX_ENV=prod

mix release publii_ex --overwrite

echo "=== Build complete ==="
ls -la _build/prod/rel/publii_ex/bin/
ls -la burrito_out/ 2>/dev/null || echo "Checking for burrito output..."
find . -name "publii_ex*.exe" 2>/dev/null | head -5
