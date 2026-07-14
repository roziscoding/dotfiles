#!/usr/bin/env bash
set -euo pipefail

MISE_CONFIG_URL="https://raw.githubusercontent.com/roziscoding/dotfiles/main/dot_config/mise/config.toml"
MISE_CONFIG_DIR="${HOME}/.config/mise"

# Install mise via pacman
sudo pacman -Sy --needed --noconfirm paru curl
paru -Sy --needed --noconfirm mise-bin

# Download mise's config.toml into ~/.config/mise
echo "Downloading mise config.toml to ${MISE_CONFIG_DIR}..."
mkdir -p "${MISE_CONFIG_DIR}"
curl -fsSL "${MISE_CONFIG_URL}" -o "${MISE_CONFIG_DIR}/config.toml"

echo "You're ready to run \`mise bootstrap\`"
