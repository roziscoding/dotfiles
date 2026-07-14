# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A [chezmoi](https://www.chezmoi.io/) dotfiles repository managing configuration across macOS and Arch Linux. The target user is `roz`. Files use chezmoi naming conventions (`dot_`, `private_dot_`, `executable_`, `run_once_`) to control the target path, permissions, and privacy of each managed file.

## Common Commands

```bash
chezmoi apply          # Apply dotfiles to home directory
chezmoi diff           # Preview changes before applying
chezmoi add <file>     # Add a new file to management
chezmoi cd             # cd into this source directory
cme <file>             # Alias for `chezmoi edit --apply` (edit a managed file and apply)
cm                     # Alias for `chezmoi`

chezmoi execute-template < file.tmpl   # Test template rendering
chezmoi execute-template '{{ .chezmoi.os }}'   # Evaluate an inline expression
```

## Templating

- `.tmpl` files use Go text/template syntax with chezmoi functions. `.chezmoi.os` (`"darwin"` or `"linux"`) drives OS-conditional logic: `{{ if eq .chezmoi.os "darwin" }}` / `{{ if eq .chezmoi.os "linux" }}`.
- One data variable is prompted on `chezmoi init` (`.chezmoi.yaml.tmpl`): `email`.
- `.chezmoiignore.tmpl` excludes files per-OS: on macOS it skips Linux-only WM configs (i3, rofi, polybar, dunst, picom); on Linux it skips `private_library`. It also always ignores `LICENSE`, `CLAUDE.md`, `install.sh`, and `nvim/lazy-lock.json`.

## Package Management

Packages are managed declaratively through **mise** (`dot_config/mise/config.toml`), not Brewfile/pacman lists. `[tools]` pins CLI tooling and language runtimes; `[env]` sets global environment variables; `[settings.npm]` routes npm installs through `bun`; `[shell_alias]` defines shell aliases that mise injects. To add a tool, add it to `[tools]` and run `mise install`.

## Key Setup Scripts & Mechanisms

- `run_once_before_generate-ssh-key.sh` — generates `~/.ssh/id_ed25519` on first apply if absent (no comment).
- `private_dot_gitconfig.tmpl` — resolves the commit-signing key through a fallback chain: a local `~/.ssh/id_ed25519` private key first, else a public key read from 1Password (`op://Private/main - id_ed25519/public key`) signed via the 1Password `op-ssh-sign` program (path differs macOS vs Linux). If neither resolves, signing is *intentionally* rendered broken with an explanatory comment rather than silently disabled. The commit email is also derived from the signing key's comment when it contains an `@`.
- `dot_git-merge-drivers/` — a custom `identical` git merge driver that auto-resolves conflicts when both sides are textually identical ignoring whitespace. Wired in gitconfig as `[merge "identical"]`; `git identical <merge|rebase> <branch>` temporarily activates it via a throwaway `.gitattributes`.
- `dot_envs.sh` — sourced secrets file using 1Password `op://` references (not auto-injected; see commented `secrets` function in zshrc).

## Notable Config Details

- **Hyprland uses Lua, not `hyprland.conf`.** `dot_config/hypr/*.lua` configure Hyprland through an `hl.*` Lua API (`hl.monitor{...}`, etc.), split across `hyprland.lua` (entry point), `globals.lua`, `keybindings.lua`, `autostart.lua`. `dot_luarc.json` points the Lua LSP at `/usr/share/hypr/stubs`. Reference docs for the `hl.*` API: https://alejandrominaya.github.io/hyprland-lua-docs/
- **zsh** (`dot_zshrc.tmpl`) uses zinit for plugins (self-installing on first run), starship prompt, atuin history, mise/direnv/zoxide/fzf hooks. Defines many shell functions (`yy` yazi-cd, `aws-login` SSO helper, `mkcommit` Claude commit generator, etc.).
- **nvim** is a LazyVim distribution (`dot_config/nvim/`, entry `init.lua` → `require("config.lazy")`); `lazy-lock.json` is gitignored on apply.
- **dot_claude/settings.json** manages the Claude Code config itself (model, hooks, enabled plugins, statusline) as a managed dotfile.

## When Editing

- Preserve the chezmoi filename prefixes — renaming `dot_foo` to `foo` changes where and how it deploys.
- After editing a `.tmpl`, validate rendering with `chezmoi execute-template` (or `chezmoi diff`) before assuming it works — a template error blocks `chezmoi apply` for the whole tree.
