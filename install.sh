#!/usr/bin/env bash
set -euo pipefail

MISE_CONFIG_URL="https://raw.githubusercontent.com/roziscoding/dotfiles/main/dot_config/mise/config.toml.tmpl"
MISE_CONFIG_DIR="${HOME}/.config/mise"

# Install mise and chezmoi (chezmoi renders the mise config template)
case "$(uname -s)" in
  Darwin)
    brew install mise chezmoi
    ;;
  Linux)
    sudo pacman -Sy --needed --noconfirm paru curl chezmoi
    paru -Sy --needed --noconfirm mise-bin
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

# Render mise's config.toml into ~/.config/mise
echo "Rendering mise config.toml to ${MISE_CONFIG_DIR}..."
mkdir -p "${MISE_CONFIG_DIR}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "${MISE_CONFIG_URL}" \
  | chezmoi execute-template --source "$tmp/src" --config "$tmp/chezmoi.yaml" \
  > "${MISE_CONFIG_DIR}/config.toml"

echo "You're ready to run \`mise bootstrap\`"
