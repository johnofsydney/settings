# Claude Code config

Shared Claude Code configuration, symlinked into `~/.claude/` on every machine.

**The whole model in one line:** everything here is identical on every machine except
*two symlinks*, which pick a **profile** (`work` or `home`) — plus `settings.json`,
which is deliberately **not** synced (see below).

---

## What's in here

| File | Linked to | Shared? |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Yes — global instructions, every session |
| — | `~/.claude/settings.json` | **No — real, machine-local file, not in this repo** |
| — | `~/.claude/skills/` | **No — skills are local to the machine that wrote them** |
| `context-work.md`<br>`context-home.md` | `~/.claude/machine.md` | **Profile picks one** |
| `overlay-work.json`<br>`overlay-home.json` | `~/.claude/overlay.json` | **Profile picks one** |

`~/.claude/settings.json` is a real, machine-local file — **not** linked from here. See
"Why settings.json isn't synced" below.

> **`context-work.md` is gitignored.** This repo is public and that file holds internal
> team and project names — same rule as `work_aliases.sh`. It won't be in a fresh clone;
> `setup_006` creates an empty one so the `@~/.claude/machine.md` import never dangles.
> Nothing is lost for syncing, because the home machine reads `context-home.md` anyway.

> **Skills are not in this repo, for the same reason.** A skill spells out the internal
> workflow it automates — repo names, hostnames, ticket conventions, the shape of a
> team's board — so it falls under the `context-work.md` rule rather than the
> `CLAUDE.md` one. They live only in `~/.claude/skills/` on the machine that wrote them.
> `setup_006` creates that directory and touches nothing inside it.
>
> **The cost, stated plainly: a fresh machine gets no skills, and a lost laptop loses
> them.** That is the accepted trade for now. Revisiting it means a *private* repo, not
> this one.

`CLAUDE.md` ends with `@~/.claude/machine.md`. That's a Claude Code import — it inlines
whichever context file the profile symlink points at. So the instructions are one shared
core plus one machine-specific tail.

The overlay is applied by a `claude()` shell function in `my_extensions.sh`, which passes
`--settings ~/.claude/overlay.json`. That loads as `flagSettings`, which outranks the
`userSettings` in `settings.json` — so the overlay always wins.

### What actually differs between profiles

| | work | home |
|---|---|---|
| Model | Opus | Sonnet |
| Effort | (default) | low |
| Context | full — incl. the "read comms" workflow | minimal |

**Everything else is deliberately identical**, permissions included. If you find yourself
wanting to diverge something else, put it in the overlay — don't fork `settings.json`.

---

## Setting up a machine

### If the machine already has a `~/.claude/` (the usual case)

It will have its own real `CLAUDE.md` and `settings.json`. Don't just run the script —
look at what you'd be displacing first.

```sh
cd "$SETTINGS_FOLDER"
git pull

# 1. See what this machine has that the repo doesn't.
diff ~/.claude/CLAUDE.md      claude/CLAUDE.md
```

2. Anything machine-specific worth keeping goes into that profile's files —
   `context-home.md` for instructions, `overlay-home.json` for model/effort. Anything
   that should apply everywhere goes into `CLAUDE.md` / `settings.json`.

3. Then run the setup script. It moves any existing **regular** file aside to
   `<name>.pre-settings-repo.bak` before linking, so nothing is destroyed:

```sh
bash setup_scripts/setup_006_claude_config.sh    # asks work or home
exec zsh                                          # pick up the claude() wrapper
```

### Fresh machine

`./bootstrap.sh` runs everything in order and includes `setup_006`. Or run
`setup_006_claude_config.sh` on its own.

### Switching a machine's profile later

Re-run `setup_006_claude_config.sh` and answer differently. It defaults to the profile
already in place, so re-running never silently flips a machine.

---

## Why settings.json isn't synced

Claude Code writes user-scope settings *back* to `~/.claude/settings.json` constantly:
permission approvals, theme changes, plugin toggles, and — the real culprit —
`autoMode`'s per-project learned environment data, plus Orca rewriting its hooks with
absolute paths on every run. That's all machine- and session-specific, mutable state, not
config anyone hand-authors. Syncing it via git meant every pull was a three-way merge
against noise, and conflicts became routine.

So as of the settings-sync rework, `claude/settings.json` and `claude/settings.json.bak`
are gitignored and **not** linked by `setup_006`. Each machine keeps its own real file,
seeded once from whatever was last synced, and the two are allowed to diverge freely.

If you want to carry an intentional change (a new permission rule, a new hook) from one
machine to the other, copy just that piece by hand — don't re-link the whole file.

Model/effort still diverge cleanly via the **overlay**, which is unaffected by this and
continues to work exactly as before (see above).

---

## Verifying it worked

```sh
# 1. The synced links point into the settings repo (settings.json is deliberately
#    NOT among them — it should be a real file, not a symlink)
ls -la ~/.claude/{CLAUDE.md,machine.md,overlay.json}
ls -la ~/.claude/skills/

# 2. The overlay actually changes the model
claude -p "reply with just: ok"
# then check the model recorded in the newest transcript under
# ~/.claude/projects/<slug>/*.jsonl  — look for "model":
```

4. In a session, run `/context` — the machine file's content should be present, and the
   global instructions should be the core plus that machine's tail.

---

## Gotchas

- **Never symlink `~/.claude` itself.** Only about three of its ~30 entries are config;
  the rest is sessions, transcripts, caches and telemetry. Link the individual paths.
- **The overlay only reaches Claude launched from an interactive shell.** A GUI-launched
  IDE extension or a cron job bypasses the `claude()` wrapper and gets the shared base.
  That's why the base pins *no* model — the bypass path falls through to the account
  default rather than to someone else's expensive choice.
- **The Orca hooks are `$HOME`-relative, and Orca will undo that.** Orca generates them
  with `/Users/<you>/` hardcoded rather than `$HOME`. Since `settings.json` is now a
  local, untracked file, this only matters on the machine itself — no public-repo leak
  risk anymore, but re-running Orca's setup will still overwrite any manual edits you
  made to its hook commands.
  Every hook still guards with `-f`/`-r`/`-x`, so on a machine with no Orca installed
  they no-op cleanly — no error, but also no hooks and no statusLine.
- **`~/.claude.json` (no slash) is not this.** It's machine state — project registry,
  onboarding, MCP config. Never synced.
- **`~/.claude/plugins/` is a cache**, not config. It rehydrates from
  `extraKnownMarketplaces` + `enabledPlugins` in `settings.json`. Don't commit it. `npx
  skills update` overwrites everything under `plugins/cache/` anyway.
- **Connectors (Figma, Linear, Slack, Gmail…) are account-scoped**, not file config. They
  travel with the claude.ai account, so they can't be synced from here — and equally can't
  leak between machines signed into different accounts. Audit them per account.
- **Never move a skill into this repo.** `claude plugin init <name>` scaffolds into
  `~/.claude/skills/<name>/`, and that is where a skill stays. This repo is public, and a
  skill is a written description of an internal workflow — the `context-work.md` rule, not
  the `CLAUDE.md` one. `setup_006` creates `~/.claude/skills/` and does nothing else to it,
  so a skill written here is never copied, linked or published anywhere.

## Worktrees

Claude Code resolves memory and local context **per directory**, so neither reaches a
sibling git worktree. `bin/worktree` handles this on `new`:

- `~/.claude/projects/<worktree-slug>/memory` is symlinked at the main checkout's memory
  dir, giving each repo one canonical memory that outlives its branches.
- Every path in `.git/info/exclude` (`CLAUDE.local.md`, `CONTEXT.md`, `docs/agents/`, …)
  is linked in from the main checkout.

`worktree rm` unlinks both before deleting the worktree. Directory entries are seeded as a
real directory of child symlinks rather than one directory symlink — a `docs/agents/`
ignore rule matches directories only, and a symlink would leave the path unignored and the
worktree looking dirty.
