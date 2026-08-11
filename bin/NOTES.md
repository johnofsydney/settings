# bin/ notes & review

## Intent

**Every script in `bin/` should be standalone and shareable.** I should be able to
hand any single file to a colleague and have it work without them needing any of
the others (no sourcing/calling a sibling script, no dependency on this repo's
`$SETTINGS_FOLDER` or sourced shell functions). Keep it that way when adding or
editing commands — duplicate a small helper (e.g. `resolve_base`) inline rather
than factoring it into a shared file.

**Accepted exception: `update-brews`.** It runs
`setup_scripts/setup_001_install_apps.sh` from this repo, so it cannot be standalone
— being a short, memorable name for that longer path is the entire reason it exists.
Not a defect, and not to be "fixed". It fails with an explanatory message (what it
looked for, where, and why it might be missing) rather than a bare error, which is
all that is wanted here. No other command in `bin/` may depend on a sibling or on
the repo.

---

## `delete-finished-branches` — safe branch cleanup (rewritten 2026-07-20)

Replaced the old "force-delete every non-protected branch (local + remote)" script
after it deleted in-progress and unmerged branches. The rewrite is **safe by default**.

**Usage:**

```
delete-finished-branches                    # dry-run: print status table, delete NOTHING
delete-finished-branches --merged           # delete only clearly-merged branches (one confirm)
delete-finished-branches -i                 # interactive: decide each branch
delete-finished-branches --merged --include-remote   # also delete the origin copy (yours only)
delete-finished-branches -y                 # skip the confirm prompt (for --merged)
PROTECTED_BRANCHES='main|master|develop' delete-finished-branches   # override protected set
```

**Safety model:**

- **Dry-run is the default** — nothing is deleted until you pass `--merged` or `-i`.
- Classifies each branch: merged into main / PR-merged (squash) / pushed-but-unmerged /
  open PR / unmerged-local-only. Colour-coded, with a recommendation per branch.
- **Never silently force-deletes** a branch with an open PR or with commits that exist
  nowhere but locally — those require typing the branch name to confirm.
- **Remote deletion only for branches that are yours** — ownership = PR author (`gh`),
  or, with no PR, all unique commits authored by your `git config user.email`. Someone
  else's branch: local delete allowed, remote kept (shown as `theirs`).
- Always skips protected mainlines, the current branch, and worktree-checked-out branches.
- Every deletion is logged to `.git/deleted-branches.log` with the tip SHA **and the
  command that undoes it** (updated 2026-08-05 — previously the log held only name +
  sha, and remote deletions were not logged at all, so the `git push` undo existed
  only in the terminal scrollback). Local and remote deletions get a line each:

  ```
  <date>  <branch>  <sha>  local   git branch <branch> <sha>
  <date>  <branch>  <sha>  remote  git push origin <sha>:refs/heads/<branch>
  ```

  The undo sits on the same line as the branch name deliberately, because retrieval
  is `grep <branch> .git/deleted-branches.log` and grep returns lines. The first
  three fields match the older format, so historical lines still align.

**Dependencies:** pure git for the core; **`gh` (optional)** enriches merge/open-PR
detection and branch ownership. Without `gh` it still runs — it just falls back to
"merged into main" (via `git merge-base`) and commit-author ownership. (This updates the
2026-07-08 review note below, which predates the `gh` dependency.)

---

## `compact-watch` — is Claude Code's auto-compact setting actually firing? (added 2026-08-05)

Added after an audit found that ~99.5% of Claude Code token usage is *input*, and
96.5% of that is cache reads — i.e. re-sending the same conversation on every turn.
Context size × turns is the whole bill, so `autoCompactWindow` (which caps how large
the context gets before it is summarised) is the highest-leverage setting there is.

The problem it solves: changing that setting gives you no feedback. Nothing tells you
whether it took. This reads the answer out of the local session transcripts.

**Usage:**

```
compact-watch                 # last 20 compactions, newest first
compact-watch 50              # last 50
compact-watch --auto          # auto-triggered only (hide manual /compact runs)
```

**How it works:** every compaction writes a `compact_boundary` record into
`~/.claude/projects/**/*.jsonl` with `preTokens` (context size when it fired),
`postTokens` (what survived), and `durationMs`. The script prints those next to the
currently-configured window.

**Reading the verdict:** it only compares against auto compactions that happened
*after* `~/.claude/settings.json` was last modified — an earlier one says nothing
about the current setting. Until one occurs it says "nothing to verify against"
rather than falsely reporting a mismatch. Uses the settings file's mtime, so editing
the file for an unrelated reason resets the comparison; fine for the question it
answers ("I just changed this — has it taken effect?").

**Where to change the setting** — printed in the script's own output, deliberately,
so it doubles as the reminder:

```
~/.claude/settings.json  →  "autoCompactWindow"  (integer, 100000–1000000)
```

Lower = compact sooner = fewer tokens re-sent per turn. Raise toward 300000–400000
if you lose context you still needed, or if the pauses interrupt: each compaction
takes ~2 minutes and drops the conversation to a ~15k-token summary. Baseline before
tuning: four auto compactions between 8 and 23 July all fired at ~1,000,000, the
schema ceiling.

**Dependencies:** `python3` only. Read-only — it opens transcripts and the settings
file, writes nothing, sends nothing.

---

## `scripts` — what's in here, and what each one does (added 2026-08-05)

An index of this directory, so no command gets forgotten about.

**Usage:**

```
scripts              # one line per command
scripts -l           # also show each command's Usage block
scripts <name>       # the full header comment for one command
```

**How it works:** it does not hold a list. It globs the executables sitting next to
itself and reads each one's description straight out of its header — the
`# <name> — <what it does>.` line on line 3 that every command here already carries.
Drop a new script in and it appears; edit a header and the listing follows. There is
no second place to update and nothing to keep in sync.

**The one convention it relies on:** that line-3 header. A command without one is
still listed, but flagged in yellow as undocumented with a count in the footer — so
the failure mode is a visible nag, not a silent omission.

**Dependencies:** bash, `fold`, `sed`, `tput`. Self-contained: resolves its own
directory through symlinks via `BASH_SOURCE`, reads no sibling script and nothing
from `$SETTINGS_FOLDER`. Read-only.

---

## Review findings (2026-07-08)

### 1. Self-containment: PASS

No script invokes or sources another at runtime. Each carries its own copy of
`resolve_base`; none depends on `$SETTINGS_FOLDER`, sourced functions, or a
sibling script. Any one file runs standalone.

**Cosmetic caveat** — two scripts mention siblings *in comments only* (harmless,
but a dangling reference if that file is handed over alone):

- `dcop:5` — `# ...auto-detected (mirrors `worktree`):`
- `dspec:14` — `# ...auto-detected (mirrors `dcop`/`worktree`):`

Possible follow-up: reword these two so each file is fully self-explanatory.

### 2. Project-specific references

**No hardcoded project names** — grepped for every repo and org name these scripts
get run against: zero hits. Everything is derived dynamically (`basename $PWD`,
git toplevel, `origin/HEAD`).

**Stack-/environment-specific assumptions** a colleague on a different setup
would trip on (most-coupled first):

| File | Assumption | Location | Overridable? |
|---|---|---|---|
| **worktree** | `overmind` process manager (socket hashing + `overmind quit`) | `:78`, `:151` | ❌ hardcoded |
| **worktree** | `md5` binary — **macOS only** (Linux is `md5sum`) | `:78` | ❌ hardcoded |
| **worktree** | `yarn` specifically (not npm/pnpm) | `:118` | ❌ hardcoded |
| **worktree** | `bin/dev` run command | `:19,36` | ✅ `WORKTREE_RUN_CMD` |
| **worktree** | `DEV_DATABASE_NAME` db env var | `:18,35` | ✅ `WORKTREE_DB_ENV_VAR` |
| **worktree** | Rails (`bin/rails db:prepare/drop`), `dotenv-rails`, `lsof` | `:121-123`, `:70` | ❌ (guarded by file existence) |
| **backup-local-db** | Postgres via `postgres` role on localhost | `:23` | ❌ (db name is `$1`) |
| **backup-local-db** | `<dir>_development` Rails db naming | `:5,17` | ✅ arg |
| **dspec** | `bundle exec rspec`, Rails `app/`/`lib/`/`spec/` layout | throughout | ❌ (inherent to purpose) |
| **dspec** | `spec/system/**` excluded *because "they trigger asset precompilation"* — that rationale came from **one particular app's `before(:suite)` hook**, not a universal truth; the skip itself is a fine general default | `:17,63` | — |
| **dcop** | `bundle exec rubocop` | `:37` | ❌ (inherent) |
| **delete-finished-branches** | core is pure git; **`gh` (optional)** enriches PR/merge/ownership detection — degrades gracefully without it (see section above; rewritten 2026-07-20) | — | — |

**Bottom line:** Ruby-tooling assumptions (`bundle exec rspec/rubocop`,
`pg_dump`, Rails layout) are inherent to what the tools do — not defects. The
genuinely non-portable, "would surprise a colleague" items are all in
**`worktree`**: `overmind`, `md5` (macOS-only), and `yarn` are hardcoded with no
override. `delete-finished-branches` is the only fully universal one. The only
spot where a *specific project's* behavior leaked into a comment is `dspec:17`
(the asset-precompilation rationale) — the behavior is a sound default anywhere;
only the justification is project-specific.

### Possible follow-ups (not yet done)

- [ ] Reword the two sibling-mentioning comments (`dcop:5`, `dspec:14`).
- [ ] Generalize the `dspec:17` asset-precompilation comment.
- [ ] Add env-var overrides for `worktree`'s `overmind`/`yarn`, and an
      `md5`→`md5sum` fallback for Linux.
