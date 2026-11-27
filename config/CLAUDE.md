# CLAUDE.md

Guidance for working on the dotfiles of user `roz`, on Arch Linux and macOS.

mise manages them through `[dotfiles]` and `[bootstrap.*]` in this directory (`~/.config/mise`). There is no separate source repository: this directory is tracked like any other dotfile and is stored as `config/` in `roziscoding/dotfiles`.

## Layout

- `config.toml`: tools, env, aliases, `[bootstrap.*]` and every `[dotfiles]` entry.
- `config.linux.toml`, `config.macos.toml`: platform-only settings. `auto_env = true` in `miserc.toml` loads the one matching the OS.
- `config.local.toml`: machine-local (origin connection, sync mode). Never tracked.
- `dotfiles/`: sources for the template and merge entries.

## Entry modes

- **`mode = "track"`**: the live file is the source. Edit it in place, or let the application rewrite it. Most files use this mode.
    - A directory entry with `include` tracks only the listed files.
    - `variants = [{ os = "linux" }]` keeps the path off other platforms.
- **`mode = "template"`**: `~/.zshrc`, `~/.gitconfig`, `~/.kube/config`, `~/.kube/get-token.sh` and `~/.aws/config`, rendered from Tera sources in `dotfiles/`. Never edit the target: `mise dot apply` overwrites it.
- **Merge edits** (`"<target>/<id>"` keys): `~/.codex/config.toml` and `~/.config/starship.toml`. mise owns only the keys present in the source, and the application owns the rest of the file.
    - `merge = true`: the source wins. A value the application changed is reverted on the next apply.
    - `merge = "missing"`: the source only fills keys the target lacks.

## Commands

```bash
mise dot status              # entries, unsaved changes, origin and watcher state
mise dot diff                # what `mise dot apply` would change
mise dot apply               # render templates and apply merge edits
mise dot edit ~/.zshrc       # open the source of a template entry
mise dot track <path>        # start tracking a file or directory
mise dot save -d "<text>"    # save a checkpoint now
mise dot history             # list checkpoints
mise dot sync                # push checkpoints to the origin and fetch
mise dot pull                # write fetched changes to the tracked files
mise bootstrap --dry-run     # preview packages, services, hooks and dotfiles
```

## History and repository

- The `dev.mise.mise-history` user service saves a checkpoint a few seconds after a tracked file changes. History is a Git repository in `~/.local/state/mise/history`.
- The origin is the `main` branch of `roziscoding/dotfiles`, a public repository. Sync mode is `sync`: the watcher pushes within 5 minutes of a save, fetches every 15 minutes, and writes incoming changes when there is no conflict. Every edit to a tracked file ends up public without a review step.
- mise writes that branch. Tracked paths are stored under `home/`, `home@linux/` and `config/`.
- Never rebase, squash or force-push it. mise matches machines by commit ancestry and refuses to sync with a rewritten history.
- A file changed on two machines in the same lines is a conflict and pauses sync for every file. Inspect it with `mise dot conflicts`, then resolve with `mise dot pull --keep-local <path>` or `--take-remote <path>`.

## Templates

- Sources are Tera, not Go templates. OS branches use `{% if os() == "macos" %}` and `{% if os() == "linux" %}`.
- The sequences `{{`, `{%` and `{#` are Tera syntax. Shell text that contains one (for example `${#array[@]}`) must go inside `{% raw %}`.
- `exec()` runs on every `mise dot status`, `diff` and `apply`. A failing command aborts the whole apply, so commands that can fail end in `|| true`.
- `dotfiles/gitconfig.tera` picks the signing key from a local `~/.ssh/id_ed25519` first, then from 1Password through `op-ssh-sign`. When neither resolves, signing is rendered broken on purpose. The commit email comes from the key comment, else from the `email` var (`mise vars prompt email`).
- After editing a source, run `mise dot diff` before `mise dot apply`.

## Secrets

- The repository is public. Never write a secret into a tracked file or a source.
- `dotfiles/codex-managed.toml.tera` reads the Context7 key from 1Password with `exec()` and a one-day cache. The value is empty when `op` is signed out, and the empty value is cached too: after signing in, run `rm -rf ~/.cache/mise/exec && mise dot apply`.
- `dotfiles/eks-*.tera` render `~/.kube/config`, `~/.kube/get-token.sh` and `~/.aws/config` from the "EKS Config Files" item in the team's 1Password (`telateam` account), without a cache, so every `mise dot status`, `diff` and `apply` calls `op`. When `op` is signed out, the current file is kept. To change one of these files, upload the new version to the 1Password item, then run `mise dot apply`.
- `~/.envs.sh` holds `op://` references, not values.
- `mise dot sync` refuses to push lines that look like secrets. Treat a refusal as a real finding.

## Bootstrap

- Packages are declared in `[bootstrap.packages]` of `config.linux.toml` with a `pacman:` or `aur:` prefix. CLI tools and runtimes go in `[tools]` of `config.toml`.
- The `pre-dotfiles` hook generates `~/.ssh/id_ed25519` when missing, before the gitconfig template renders.
- The `final` hook in `config.linux.toml` enables the systemd user units.
- Hooks run on every `mise bootstrap`, so they must be idempotent.
- A new machine starts with `mise bootstrap --adopt roziscoding/dotfiles`.

## Notable config

- **Hyprland uses Lua, not `hyprland.conf`.** `~/.config/hypr/*.lua` configure it through the `hl.*` API, with `hyprland.lua` as the entry point. `.luarc.json` points the Lua LSP at `/usr/share/hypr/stubs`. API reference: https://alejandrominaya.github.io/hyprland-lua-docs/
- **Noctalia rewrites `[palettes.noctalia]`** in `~/.config/starship.toml` between its own markers. A new table added through the starship merge source is appended at the end of the file and can land inside that block: check where it landed after the first apply.
- **zsh** uses zinit, starship, atuin, and the mise, direnv, zoxide and fzf hooks. Tools such as the Tela CLI append marker-delimited blocks to `~/.zshrc`: copy a new block into `dotfiles/zshrc.tera`, or the next apply removes it.
- **nvim** is a LazyVim setup. Only the files in the entry's `include` list are tracked; `lazy-lock.json` and generated theme files are left out.
- **`~/.claude/settings.json`** is tracked whole, so changes Claude Code writes to it are saved.

## When editing

- Add a file with `mise dot track <path>`. Use `--os linux` for Linux-only paths, and preview a directory with `--dry-run` first: a tracked directory saves every file in it.
- Keep application-owned state (caches, session files, lock files) out of history with `include` or `exclude`.
- Don't hand-edit files under `~/.local/state/mise/history`.
