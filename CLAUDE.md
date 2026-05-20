# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Personal dotfiles + Mac setup repo. Bootstrap a fresh Mac and keep multiple machines in sync. Not a library — there is no build, no tests. "Running" here means executing the numbered setup scripts on a clean machine, then opening a new shell.

## Prerequisites (never auto-installed)

Homebrew and git must already be installed before any script runs. `setup_001` does a pre-flight `command -v` check and exits with an error if either is missing — it does **not** install them. The user wants this because git is needed to clone the repo in the first place, and brew is treated as a hand-installed prerequisite. Don't add a `curl …install.sh` step.

## Setup script flow

`bootstrap.sh` at the repo root runs all five numbered scripts in order, prompting before each. The scripts can also be run individually. They are idempotent:
- `setup_003` guards its `~/.zshrc` append with a fenced marker (`# >>> settings repo (setup_003) >>>`).
- `setup_005` guards its `mise activate` append with `# >>> mise activate (setup_005) >>>`.

So re-running the bootstrap (or any single script) is safe.

- `setup_001_install_apps.sh` — pre-flight check for brew/git, then `brew install` of apps + CLI utilities. Prompts before installing the Microsoft Office casks.
- `setup_002_configure_git.sh` — prompts for name/email, then sets ~25 `git config --global` values. The repo treats this script as the source of truth for global git config — change it here rather than running ad-hoc `git config` commands.
- `setup_003_setup_dot_files.sh` — the orchestrator. Resolves `$SETTINGS_FOLDER` from its own location (one level up from `setup_scripts/`), exports it, creates empty `work_aliases.sh` / `env_variables.sh`, then appends a fenced `source` block to `~/.zshrc` pointing back into this repo. Note: it does **not** modify `~/.gitignore_global` — that's purely the repo's `.gitignore` job now.
- `setup_004_app_preferences.sh` — symlinks `vscode/settings.json` and `vscode/keybindings.json` into both VS Code and VS Code Insiders' `Application Support` folders. iTerm and Rectangle preferences must be imported through their GUIs (see README).
- `setup_005_dev_stuff.sh` — installs `postgresql@16`, `redis`, and `mise`. Appends `mise activate` to `~/.zshrc` (fenced). Starts both services.

## Runtime architecture: how a shell session loads

`setup_003` writes the contract into `~/.zshrc`:

```
export SETTINGS_FOLDER="<repo path>"
source "$SETTINGS_FOLDER/my_extensions.sh"
source "$SETTINGS_FOLDER/mac_settings.sh"
source "$SETTINGS_FOLDER/work_aliases.sh"   # gitignored
source "$SETTINGS_FOLDER/env_variables.sh"  # gitignored
source "$SETTINGS_FOLDER/prompt.sh"
```

So at shell startup, `.zshrc` reaches into this repo via `$SETTINGS_FOLDER`. That env var is the seam that makes the repo location-independent (any clone path works). When adding new shell config, the choice is:

- **Committed, cross-machine**: add it to one of `my_extensions.sh` / `mac_settings.sh` / `prompt.sh`, or create a new file and add a `source` line both here in `setup_003` *and* in the user's existing `~/.zshrc`.
- **Machine-specific or secret** (work API keys, work-only aliases, work hostnames): put it in `work_aliases.sh` or `env_variables.sh` — both are gitignored and created empty by `setup_003`.

Some example aliases in `my_extensions.sh` reference `$LESTER_REMOTE_DB_HOST` etc. — those env vars live in the gitignored `env_variables.sh`.

### What each sourced file owns

- `my_extensions.sh` — the bulk of personal config: env vars (`LS_COLORS`, `EDITOR`, history settings), aliases (folder shortcuts, git, rspec/bundler, ssh), and shell functions (`gac`, `hh`, `mkcd`, `gch`, `delete_finished_branches`, etc.). `ls` is aliased to `gls` (GNU coreutils) — the BSD `ls` shipped with macOS doesn't honor `LS_COLORS`. History append uses zsh-native `setopt INC_APPEND_HISTORY` / `SHARE_HISTORY`, not the bash-only `PROMPT_COMMAND`.
- `mac_settings.sh` — Mac-only zsh options (autocorrect tweaks, `auto_pushd`), the `d`/`dirs` recent-directories helper with `1`–`9` aliases, Rectangle window-manager URL aliases (`83`, `99`, etc.), and Bluetooth device aliases via `blueutil` (`pxc_on/off`, `kvm_home`).
- `prompt.sh` — defines `PROMPT` directly with zsh `%`-escapes and three helpers: `parse_git_branch_status`, `parse_mise_ruby_version`, `parse_mise_node_version`.
- `old_spinup_functions.sh` — archive of larger iTerm/AppleScript helper functions (`spinup_real`, `spinup_lester`, `chat`, `goog`) that were trimmed out of `my_extensions.sh` to keep it focused. Not sourced. Restore from here if you want them back.

## VS Code settings

Both stable and Insiders point at the same `vscode/settings.json` via symlink, so any edit applies to both editors after a reload.

## Rectangle preferences

The exported preferences live in `rectangle_preferences/`. Older versions of this repo had a single `RectangleConfig.json` at the root — that's been removed in favour of the directory.

## Conventions

- Shell scripts use `#!/usr/bin/env bash` or no shebang and rely on the user's shell; they're invoked explicitly (`./bootstrap.sh` or `./setup_scripts/...`) rather than via PATH.
- `echo` banners at the top/bottom of each setup script are intentional — they're the user-visible progress for an otherwise quiet `brew install` run.
- Idempotency convention: any append to `~/.zshrc` (or other long-lived dotfile) must be guarded by a fenced `# >>> ... >>>` / `# <<< ... <<<` marker pair and a `grep -qF` check. Both `setup_003` and `setup_005` follow this pattern.
- Never auto-install Homebrew or git from a script — pre-flight check + clear error message only.
- Don't add real secrets to any committed file. Anything sensitive belongs in `env_variables.sh` (gitignored).
