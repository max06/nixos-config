#!/usr/bin/env bash
# Devcontainer dotfiles hook: applies flo's portable home-manager profile
# (user/flo/home/container.nix) to whatever user the container runs as.
#
# VS Code runs this after cloning the repository when it is configured as
# "dotfiles.repository" and the nix feature is enabled. It can also be run
# by hand from a checkout inside a container.
set -euo pipefail

if [ ! -f /.dockerenv ] && [ -z "${REMOTE_CONTAINERS:-}" ] && [ -z "${CODESPACES:-}" ]; then
  echo "install.sh: not inside a devcontainer, refusing to run." >&2
  exit 1
fi

cd "$(dirname "$0")"

# Pre-generated configurations exist for the usual container usernames. Any
# other user falls back to the impure configuration, which reads USER and
# HOME from the environment at evaluation time.
attr="${USER}"
extra=()
if ! nix eval --raw ".#homeConfigurations.${USER}.activationPackage.drvPath" >/dev/null 2>&1; then
  attr="container"
  extra=(--impure)
fi

echo "install.sh: applying homeConfigurations.${attr} for ${USER} (${HOME})"
nix run github:nix-community/home-manager -- switch \
  --flake ".#${attr}" -b backup "${extra[@]}"
