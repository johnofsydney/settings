# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Personal dotfiles + Mac setup repo. Bootstrap a fresh Mac and keep multiple machines in sync. Not a library — there is no build, no tests. "Running" here means executing the numbered setup scripts on a clean machine, then opening a new shell.

## Prerequisites

The repo is designed to work even when downloaded as a zip (not cloned), so neither Homebrew nor git is treated as a hard prerequisite:

- **Homebrew** — `bootstrap.sh` installs it if missing, via the official `https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh` script. It also persists `eval "$(brew shellenv)"` into `~/.zprofile` (fenced with `# >>> homebrew shellenv (bootstrap) >>>`) so future shells have brew on PATH.
- **git** — installed by `setup_001_install_apps.sh` (first thing after the brew pre-flight check).

`setup_001` still does a `command -v brew` pre-flight check so it fails fast if someone runs it standalone without ever running bootstrap. Don't change that to auto-install brew — that's bootstrap's job, not setup_001's.

This is the *current* rule. Earlier iterations had brew and git as strict prerequisites; that's been relaxed.

## Setup script flow

`bootstrap.sh` at the repo root runs all five numbered scripts in order, prompting before each. The scripts can also be run individually. They are idempotent:
- `setup_003` guards its `~/.zshrc` append with a fenced marker (`# >>> settings repo (setup_003) >>>`).
- `setup_005` guards its `mise activate` append with `# >>> mise activate (setup_005) >>>`.

So re-running the bootstrap (or any single script) is safe.

- `setup_001_install_apps.sh` — pre-flight check for brew, then installs `git` + `git-recent` first (so `setup_002` can run), then the rest of the apps + CLI utilities. Prompts before installing the Microsoft Office casks.
- `setup_002_configure_git.sh` — prompts for name/email, then sets ~25 `git config --global` values. The repo treats this script as the source of truth for global git config — change it here rather than running ad-hoc `git config` commands. Does not install git itself anymore (that's setup_001's job).
- `setup_003_setup_dot_files.sh` — the orchestrator. Resolves `$SETTINGS_FOLDER` from its own location (one level up from `setup_scripts/`), exports it, creates empty `work_aliases.sh` / `env_variables.sh`, then appends a fenced `source` block to `~/.zshrc` pointing back into this repo. Note: it does **not** modify `~/.gitignore_global` — that's purely the repo's `.gitignore` job now.
- `setup_004_app_preferences.sh` — symlinks `vscode/settings.json` and `vscode/keybindings.json` into both VS Code and VS Code Insiders' `Application Support` folders. iTerm and Rectangle preferences must be imported through their GUIs (see README).
- `setup_005_dev_stuff.sh` — prompts for a PostgreSQL major version (default `18`; enter `skip` to skip Postgres entirely), then installs `postgresql@<version>`, `redis`, and `mise`. Appends `mise activate` to `~/.zshrc` (fenced). Starts both services.

## Runtime architecture: how a shell session loads

`setup_003` writes the contract into `~/.zshrc`:

```
export SETTINGS_FOLDER="<repo path>"
source "$SETTINGS_FOLDER/env_variables.sh"    # gitignored
source "$SETTINGS_FOLDER/my_extensions.sh"
source "$SETTINGS_FOLDER/mac_settings.sh"     # self-guards to macOS
source "$SETTINGS_FOLDER/work_aliases.sh"     # gitignored
source "$SETTINGS_FOLDER/personal_aliases.sh"
source "$SETTINGS_FOLDER/prompt.sh"
```

So at shell startup, `.zshrc` reaches into this repo via `$SETTINGS_FOLDER`. That env var is the seam that makes the repo location-independent (any clone path works). When adding new shell config, the choice is:

- **Committed, cross-machine, general**: add it to `my_extensions.sh` / `mac_settings.sh` / `prompt.sh`, or create a new file and add a `source` line both here in `setup_003` *and* in the user's existing `~/.zshrc`.
- **Committed but personal** (own-projects folder shortcuts, personal SSH/Bluetooth aliases — not work, not secret): put it in `personal_aliases.sh`. It's committed (so it syncs across the user's machines) but of no use to anyone else.
- **Machine-specific or secret** (work API keys, work-only aliases, work hostnames): put it in `work_aliases.sh` or `env_variables.sh` — both are gitignored and created empty by `setup_003`.

Some SSH aliases in `personal_aliases.sh` reference `$LESTER_REMOTE_DB_HOST` etc. — those env vars live in the gitignored `env_variables.sh`.

### What each sourced file owns

- `my_extensions.sh` — the bulk of cross-machine config: env vars (`LS_COLORS`, `EDITOR`, history settings), aliases (the `settings` folder shortcut, git, rspec/bundler), and shell functions (`gac`, `hh`, `mkcd`, `gch`, `delete_finished_branches`, etc.). It also sources `zsh-syntax-highlighting` (guarded, via `$HOMEBREW_PREFIX`). `ls` is aliased to `gls` (GNU coreutils) — the BSD `ls` shipped with macOS doesn't honor `LS_COLORS`. History append uses zsh-native `setopt INC_APPEND_HISTORY` / `SHARE_HISTORY`, not the bash-only `PROMPT_COMMAND`. It also prepends `$SETTINGS_FOLDER/bin` to `PATH` so standalone executables in `bin/` are callable from anywhere.
- `bin/` — standalone executable scripts (not sourced — run directly, so they carry their own `#!/usr/bin/env bash` + `set -euo pipefail` and parse args). On `PATH` via the export in `my_extensions.sh`, and named without a `.sh` extension so they invoke bare. `bin/worktree` spins up / tears down isolated per-ticket git worktrees (`worktree new|ls|rm`); it's project-agnostic and derives repo name / db / port from the current git toplevel. To add a new global command, drop an executable in `bin/` — no other wiring needed.
- `mac_settings.sh` — macOS-only (bails early via a `[[ "$OSTYPE" == darwin* ]] || return` guard so it's safe to source anywhere): zsh options (autocorrect tweaks, `auto_pushd`), the `d`/`dirs` recent-directories helper with `1`–`9` aliases, Rectangle window-manager URL aliases (`83`, `99`, etc.), and the `~/.fzf.zsh` source.
- `personal_aliases.sh` — committed but personal: own-projects folder shortcuts (`notes`, `john`, `lester`, …), SSH aliases (`ssh_lester_*`, referencing `$LESTER_*` env vars from `env_variables.sh`), and Bluetooth device aliases via `blueutil` (`pxc_on`/`pxc_off`, `connect_peripherals`). Syncs across the user's machines but isn't useful to anyone else.
- `prompt.sh` — defines `PROMPT` directly with zsh `%`-escapes and three helpers: `parse_git_branch_status`, `parse_mise_ruby_version`, `parse_mise_node_version`.
- `old_spinup_functions.sh` — archive of larger iTerm/AppleScript helper functions (`spinup_real`, `spinup_lester`) that were trimmed out of `my_extensions.sh` to keep it focused. Not sourced. Restore from here if you want them back.

## VS Code settings

Both stable and Insiders point at the same `vscode/settings.json` via symlink, so any edit applies to both editors after a reload.

## Rectangle preferences

The exported preferences live in `rectangle_preferences/`. Older versions of this repo had a single `RectangleConfig.json` at the root — that's been removed in favour of the directory.

## Conventions

- Shell scripts use `#!/usr/bin/env bash` or no shebang and rely on the user's shell; they're invoked explicitly (`./bootstrap.sh` or `./setup_scripts/...`) rather than via PATH.
- `echo` banners at the top/bottom of each setup script are intentional — they're the user-visible progress for an otherwise quiet `brew install` run.
- Idempotency convention: any append to `~/.zshrc` or `~/.zprofile` (or other long-lived dotfile) must be guarded by a fenced `# >>> ... >>>` / `# <<< ... <<<` marker pair and a `grep -qF` check. `bootstrap.sh` (brew shellenv → `~/.zprofile`), `setup_003` (settings sources → `~/.zshrc`), and `setup_005` (mise activate → `~/.zshrc`) all follow this pattern.
- Auto-install policy: brew is installed by `bootstrap.sh` if missing; git is installed by `setup_001`. Don't move those installs around or add duplicate "install if missing" paths elsewhere.
- Don't add real secrets to any committed file. Anything sensitive belongs in `env_variables.sh` (gitignored).
