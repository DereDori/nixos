#!/usr/bin/env bash
# Rebuild NixOS from this flake, then commit + push on success.
#
# Host attribute defaults to this machine's hostname; pass one to override:
#   ./rebuild.sh                 # builds nixosConfigurations.$HOSTNAME
#   ./rebuild.sh other-host      # builds nixosConfigurations.other-host
set -euo pipefail

cd "$HOME/nixos"

# Flake host: first arg if given, otherwise this machine's live hostname.
# (Uses `hostname` rather than $HOSTNAME, which is a shell variable that
# can be stale or unset depending on how the shell was started.)
host="${1:-$(hostname)}"

# Refuse to build a host attribute the flake doesn't actually define —
# silently falling back to the wrong one applies the wrong machine's
# hardware profile (disk UUIDs, kernel modules) and can make the next
# boot unable to mount its own root/boot partitions.
known_hosts="$(nix eval --json "$HOME/nixos#nixosConfigurations" --apply builtins.attrNames 2>/dev/null)"
if ! echo "$known_hosts" | grep -q "\"$host\""; then
  echo "error: '$host' is not a nixosConfigurations attribute (have: $known_hosts)" >&2
  exit 1
fi
echo "Target host: ${host}"

# Pull latest without clobbering local edits.
git pull --ff-only || true

# Format nix files if the formatter is present.
if command -v alejandra >/dev/null; then
  alejandra . >/dev/null || true
fi

# Show what changed.
git --no-pager diff -U0 || true

# Stage everything (incl. new files) so the flake, which only sees tracked
# files, can evaluate the current working tree.
git add -A

echo "Rebuilding (flake) → ${host}…"
if ! sudo nixos-rebuild switch --flake "$HOME/nixos#$host"; then
  echo "Rebuild failed." >&2
  exit 1
fi

# Commit + push (no-op if nothing changed).
if ! git diff --quiet || ! git diff --cached --quiet; then
  current="$(nixos-rebuild list-generations 2>/dev/null | grep -iE 'current' || true)"
  git commit -am "rebuild: ${current:-ok}"
  git push || true
else
  echo "No file changes to commit."
fi

echo "NixOS rebuild successful."
