# Personal instructions — John Coote

These apply in every project, wherever I'm working.

## Reviewing my own PRs

**Review in a session that didn't write the code. Annotate in the session that did.**

The two jobs need opposite things. A reviewer who knows why a decision was made will rationalise it
instead of attacking it; an annotator who doesn't know will write generic comments. So:

- **`/code-review`** — if the current session wrote (or helped write) the code, start a **new
  session in the same directory** and run it there. Same repo, same branch, fresh context. If the
  session didn't write the code, just run it where you are; a new window is pointless overhead.
- **`/annotate-pr`** — run it in the session that holds the design rationale, whatever directory
  that session is rooted in. It reads and posts by absolute path, so the working directory is
  irrelevant.
- **Order:** review → fix → push → annotate. Annotating before a review risks defending a bug, and
  a push invalidates any approval anyway, so annotations land right before the re-read.

Don't encode any of this by editing the mattpocock skills under
`~/.claude/plugins/cache/mattpocock/` — `npx skills update` overwrites them.

## Dotfiles / shell config

My shell config lives in a **version-controlled settings repo — not in `~/.zshrc` directly.** When adding or changing shell config, put it in the right file in that repo (and source it), don't inline it into `~/.zshrc`.

- **Repo:** `~/Projects/John/settings` (exported as `$SETTINGS_FOLDER`). Remote `github.com:johnofsydney/settings`. `~/.zshrc` stays minimal and just sources the repo's files (the `setup_003` block).
- **Where things go (pick by: secret-or-not, work-vs-personal-vs-general, macOS-specific-or-not):**
  - `my_extensions.sh` — *committed.* Non-sensitive env vars, shell options, core + git aliases, PATH additions (incl. `bin/`). **Non-secret `export`s go here** (e.g. `COREPACK_ENABLE_AUTO_PIN=0`).
  - `mac_settings.sh` — *committed.* macOS-only settings (early-returns on non-Mac).
  - `personal_aliases.sh` — *committed.* Personal, non-work aliases + folder/ssh shortcuts.
  - `prompt.sh` — *committed.* Prompt.
  - `env_variables.sh` — **gitignored.** Secret / sensitive env vars. Never commit.
  - `work_aliases.sh` — **gitignored.** Work-specific aliases. Never commit.
  - `bin/` — scripts on PATH (e.g. the `worktree` helper).
  - `claude/` — *committed.* Claude Code config, symlinked into `~/.claude/`. See `claude/README.md`.
- **Intent:** everything shareable is committed and split by concern; anything secret or work-specific is gitignored and must never be committed. After editing, `source ~/.zshrc` (or open a new terminal) to apply.

@~/.claude/machine.md
