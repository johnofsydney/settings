# bin/ notes & review

## Intent

**Every script in `bin/` should be standalone and shareable.** I should be able to
hand any single file to a colleague and have it work without them needing any of
the others (no sourcing/calling a sibling script, no dependency on this repo's
`$SETTINGS_FOLDER` or sourced shell functions). Keep it that way when adding or
editing commands — duplicate a small helper (e.g. `resolve_base`) inline rather
than factoring it into a shared file.

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
- Every deletion is logged to `.git/deleted-branches.log` with the tip SHA, and a
  paste-to-restore `git branch <name> <sha>` line is printed — a mistake is one paste to undo.

**Dependencies:** pure git for the core; **`gh` (optional)** enriches merge/open-PR
detection and branch ownership. Without `gh` it still runs — it just falls back to
"merged into main" (via `git merge-base`) and commit-author ownership. (This updates the
2026-07-08 review note below, which predates the `gh` dependency.)

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

**No hardcoded project names** — grepped for `labmaster`, `lester`, `realhub`,
`labflow`, `labby`: zero hits. Everything is derived dynamically (`basename
$PWD`, git toplevel, `origin/HEAD`).

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
| **dspec** | `spec/system/**` excluded *because "they trigger asset precompilation"* — that rationale is **labmaster-derived** (its `before(:suite)` hook); the skip itself is a fine general default | `:17,63` | — |
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
