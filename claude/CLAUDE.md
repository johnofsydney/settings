# Personal instructions — John Coote

These apply in every project, wherever I'm working.

## Code Comments

Write code so it doesn't need comments. A comment earns its place only by stating a constraint the code cannot show — a security invariant, a non-obvious external behaviour, a required ordering. These rules apply to ALL code you write or modify, and they OVERRIDE "match the surrounding comment style": a heavily-commented file is not a licence to add more.

- **The test.** Delete the comment. If nothing is lost that a reader can't get from the code, the tests, or `git log`, leave it deleted.
- **Present tense only.** Describe the code as it is — never how it was ("previously", "used to"), how it got here ("probing showed", "a review found"), or how it will be ("will be replaced", "for now"). Corrections and history go in the commit message.
- **No ticket or issue references** in source comments (JIRA/Linear/GitHub IDs). Docs and commit messages may reference tickets; code never.
- **No TODOs or FIXMEs.** Unfinished work goes in the PR description or the tracker, where someone will actually see it.
- **Circumspect in the extreme.** 1–3 lines maximum. No rationale essays, no restating what the next lines do, no narrating alternatives you rejected.
- **Never comment out code.** Delete it; git has it.
- **Keep comments true.** If your change makes an existing comment wrong, fix or delet it in the same change. Otherwise leave existing comments alone — no drive-by sweeps of unrelated ones.

Not covered by the above, because they are documentation rather than commentary: docstrings and module or class headers stating what a thing is for and what its contract is; public API docs; licence headers, generated-code markers, and tooling directives (`eslint-disable`, `rubocop:disable`, `ts-expect-error`, `# type: ignore`) — those still carry the one-line reason the tool requires.

Good: `// Stripe returns 200 with an error body; status alone is not success.`
Bad:  `// Increment the retry counter`

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
