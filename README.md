# settings

Personal dotfiles + Mac setup. Bootstrap a fresh Mac and keep multiple machines in sync.

## Prerequisites

The repo is designed to work even if it was downloaded as a zip rather than cloned —
so neither Homebrew nor git needs to be installed beforehand:

- **Homebrew** is installed by `bootstrap.sh` if missing.
- **git** is installed by `setup_001_install_apps.sh`.
- An **SSH key** added to GitHub is still on you if you want to push from this machine
  (https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

`$SETTINGS_FOLDER` is resolved from the script location at runtime, so the repo path
doesn't matter.

## Quick start

```
./bootstrap.sh
```

Installs Homebrew if missing, then runs all five setup scripts in order, prompting
before each. Every script is idempotent, so it's safe to re-run.

## Running scripts individually

### 1. Install apps & CLI utilities
```
./setup_scripts/setup_001_install_apps.sh
```
- Requires Homebrew (run `./bootstrap.sh` first if you don't have it).
- Installs `git` + `git-recent` first, then iTerm, browsers, VS Code (stable + Insiders),
  `bat`, `ag`, `fzf`, GNU `coreutils`, `gnupg`, `blueutil`, Rectangle, Slack, Fork, etc.
- Prompts before installing the Microsoft Office casks.
- Add new broadly-applicable apps here.

### 2. Configure git
```
./setup_scripts/setup_002_configure_git.sh
```
- Prompts for name/email.
- Sets ~25 `git config --global` values — this script is the source of truth.
- Change global git config here rather than running ad-hoc `git config` commands.

### 3. Set up dotfiles
```
./setup_scripts/setup_003_setup_dot_files.sh
```
- Resolves `$SETTINGS_FOLDER` from the script location.
- Creates empty `work_aliases.sh` / `env_variables.sh` (both gitignored).
- Appends a fenced `source` block to `~/.zshrc`. The fenced marker
  (`# >>> settings repo (setup_003) >>>`) prevents duplicate appends.

What `~/.zshrc` ends up sourcing:
- `my_extensions.sh` — aliases, functions, non-sensitive env vars
- `mac_settings.sh` — Mac-only zsh options, Rectangle aliases, Bluetooth helpers
- `work_aliases.sh` — gitignored, machine-specific
- `env_variables.sh` — gitignored, secrets / per-machine env vars
- `prompt.sh` — `PROMPT` definition

Machine-specific tweaks (custom PATH, etc.) belong directly in `~/.zshrc`, not this repo.

### 4. App preferences
```
./setup_scripts/setup_004_app_preferences.sh
```
- Symlinks `vscode/settings.json` + `vscode/keybindings.json` into both VS Code
  and VS Code Insiders' `Application Support` folders.
- iTerm and Rectangle preferences are imported via their GUIs (see below).

**For Rectangle:** in the app GUI, _Import Settings_ from `rectangle_preferences/`.
**For iTerm:** in the app GUI, under General / Settings, choose _Load Settings from
a custom folder or URL_ and select `iterm_preferences/`.

### 5. Dev runtimes
```
./setup_scripts/setup_005_dev_stuff.sh
```
- Prompts for a PostgreSQL major version (default `18`, or `skip`), then brew-installs `postgresql@<version>`, `redis`, `mise`.
- Appends `mise activate` to `~/.zshrc` (fenced, so re-runs don't duplicate).
- Starts the Postgres and Redis services.
