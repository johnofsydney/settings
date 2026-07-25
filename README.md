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

What `~/.zshrc` ends up sourcing (in order):
- `env_variables.sh` — gitignored, secrets / per-machine env vars
- `my_extensions.sh` — aliases, functions, non-sensitive env vars
- `mac_settings.sh` — macOS-only (self-guards): zsh options, Rectangle aliases
- `work_aliases.sh` — gitignored, machine-specific
- `personal_aliases.sh` — committed but personal: folder / SSH / Bluetooth aliases
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

## Global commands (`bin/`)

`bin/` is on `PATH` (via `my_extensions.sh`), so these run bare from any git repo.
They're project-agnostic — repo name, db, and port are derived from the current toplevel.

- `worktree new|ls|rm` — spin up / tear down isolated per-ticket git worktrees.
- `dcop [base]` — rubocop the Ruby files changed vs the auto-detected base branch.
- `dspec [base] [rspec args]` — rspec the specs affected by branch changes.
- `backup-local-db [db_name]` — `pg_dump` the local `<dir>_development` db to a timestamped file in `tmp/`.
- `delete-finished-branches` — review and delete finished branches, safely.

### delete-finished-branches

Dry-run by default: classifies every branch (merged into main? has a remote? open/merged
PR? local-only commits?), prints a colour-coded table, and deletes nothing until asked.
Protected mainlines, the current branch, and worktree-checked-out branches are always skipped.
Every deletion is logged to `.git/deleted-branches.log` with a paste-to-undo restore command.

```
delete-finished-branches            # dry-run: show the table, do nothing
delete-finished-branches --merged   # delete the clearly-merged branches locally (one confirm)
delete-finished-branches -i         # interactive: decide each branch
```

Remote (`origin/<branch>`) deletion happens **only** in interactive mode, and **only when the
remote copy is yours** — ownership is the PR author if a PR exists, otherwise every commit unique
to the branch being yours. After a successful local delete, `-i` prompts before removing your
origin copy; a remote that isn't yours is kept and reported. Override the protected mainlines with
`PROTECTED_BRANCHES` (pipe-separated regex; default `main|master|staging|qa|develop`).
