# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A [chezmoi](https://www.chezmoi.io/) dotfiles repository managing configuration across macOS (Homebrew) and Arch Linux (yay/pacman). Files use chezmoi naming conventions (`dot_`, `private_dot_`, `executable_`, `run_onchange_after_`).

## Key Concepts

- **Templates** (`.tmpl` files) use Go text/template syntax with chezmoi functions. The primary template variable is `.chezmoi.os` (`"darwin"` or `"linux"`) for OS-conditional logic. A single data variable `email` is prompted on init (`.chezmoi.yaml.tmpl`).
- **OS-specific ignoring**: `.chezmoiignore.tmpl` excludes Linux-only configs on macOS (i3, rofi, polybar, dunst, picom) and macOS-only configs on Linux (Brewfile, private_library).
- **Package management**: `Brewfile` for macOS, `packages.txt` for Arch Linux (installed via `yay`). The `run_onchange_after_install-packages.sh.tmpl` script auto-runs when either file changes (hash-based).

## Common Commands

```bash
chezmoi apply          # Apply dotfiles to home directory
chezmoi edit --apply   # Edit a managed file and apply (aliased as `cme`)
chezmoi diff           # Preview changes before applying
chezmoi add <file>     # Add a new file to management
chezmoi cd             # cd into this source directory
```

## Structure

- `dot_config/` — App configs (nvim, hypr, kitty, starship, waybar, etc.)
- `dot_zshrc.tmpl` — Main shell config (zinit plugins, aliases, tool initialization)
- `private_dot_gitconfig.tmpl` — Git config with SSH signing and aliases
- `Brewfile` / `packages.txt` — Package lists per OS
- `run_onchange_after_install-packages.sh.tmpl` — Auto-installs packages on change

## When Editing

- Preserve chezmoi filename prefixes (`dot_`, `private_dot_`, `executable_`, etc.) — they control target path, permissions, and privacy.
- Template files must use valid Go template syntax. Test with `chezmoi execute-template`.
- OS conditionals: `{{ if eq .chezmoi.os "darwin" }}` / `{{ if eq .chezmoi.os "linux" }}`.
- The git config uses SSH commit signing via 1Password SSH agent.
