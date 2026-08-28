# Claude Code config

Shared Claude Code configuration, symlinked into `~/.claude/` on every machine.

**The whole model in one line:** everything here is identical on every machine except
*two symlinks*, which pick a **profile** (`work` or `home`).

---

## What's in here

| File | Linked to | Shared? |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Yes — global instructions, every session |
| `hooks/` | (referenced by path) | Yes — general-purpose hooks, called from each machine's settings |
| — | `~/.claude/settings.json` | **No — local to the machine** |
| — | `~/.claude/skills/`, `~/.claude/bin/`, `~/.claude/hooks/` | **No — local to the machine that wrote them** |
| `context-work.md`<br>`context-home.md` | `~/.claude/machine.md` | **Profile picks one** |
| `overlay-work.json`<br>`overlay-home.json` | `~/.claude/overlay.json` | **Profile picks one** |

> **`context-work.md` is gitignored.** This repo is public and that file holds internal
> team and project names — same rule as `work_aliases.sh`. It won't be in a fresh clone;
> `setup_006` creates an empty one so the `@~/.claude/machine.md` import never dangles.
> Nothing is lost for syncing, because the home machine reads `context-home.md` anyway.

> **Skills, and `settings.json`, are not in this repo.** A skill spells out the internal
> workflow it automates — repo names, hostnames, ticket conventions, the shape of a
> team's board — so it falls under the `context-work.md` rule rather than the
> `CLAUDE.md` one. They live only in `~/.claude/skills/` on the machine that wrote them.
> `setup_006` creates that directory and touches nothing inside it. That covers a skill's
> machinery too — its helper scripts in `~/.claude/bin/` and any hook that exists only to
> serve it, which live beside it rather than here.
>
> **`settings.json` is local for a different reason: two machines want different answers.**
> Permissions, plugins and hooks accumulate per machine, and syncing them meant every
> approval on one laptop landed on the other. Each machine now owns its own
> `~/.claude/settings.json` as a real file. What that costs is under *Day to day*.
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

Those two are what the *profile* picks. Beyond them, each machine's `settings.json` is
simply its own — permissions, plugins and hooks are no longer expected to match.

---

## Setting up a machine

### If the machine already has a `~/.claude/` (the usual case)

It will have its own real `CLAUDE.md`. Don't just run the script — look at what you'd be
displacing first. (`settings.json` is never touched: the script no longer links it.)

```sh
cd "$SETTINGS_FOLDER"
git pull

# 1. See what this machine has that the repo doesn't.
diff ~/.claude/CLAUDE.md      claude/CLAUDE.md
```

2. Anything machine-specific worth keeping goes into that profile's files —
   `context-home.md` for instructions, `overlay-home.json` for model/effort. Anything
   that should apply everywhere goes into `CLAUDE.md`.

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

## Day to day

**`git status` here should be quiet.** Claude Code writes user-scope settings back to
`~/.claude/settings.json` constantly — every "don't ask again", theme change and plugin
toggle — and that file is now a real local file, so none of it reaches this repo.

**The cost, stated plainly: permissions are no longer version-controlled, reviewable in a
diff, or recoverable from a clone.** Nothing off this machine holds a copy of what it is
allowed to do. If that matters, back the file up somewhere the repo isn't.

Still worth knowing: **`/model` and `/effort` write to `settings.json`, not the overlay.**
Harmless now that nothing propagates, but the overlay is what a profile is supposed to
own — delete those keys when you spot them.

---

## Verifying it worked

```sh
# 1. Three links point into the settings repo — and settings.json is NOT one of them
ls -la ~/.claude/{CLAUDE.md,machine.md,overlay.json,settings.json}

# ...and nothing local is linked. Every entry should be a real file or directory.
find ~/.claude/skills ~/.claude/bin ~/.claude/hooks -maxdepth 1 -type l

# 2. Permissions survived the move (should match what's committed)
python3 -c "import json;p=json.load(open('$HOME/.claude/settings.json'))['permissions'];\
print({k:(len(v) if isinstance(v,list) else v) for k,v in p.items()})"

# 3. The overlay actually changes the model
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
  with `/Users/<you>/` hardcoded; they've been rewritten to `"$HOME/..."` so this file
  is portable and carries no username into a public repo. The double quotes are
  load-bearing — inside single quotes the shell won't expand `$HOME`, and every hook
  would silently no-op.
  **Re-running Orca's setup (or letting it update itself) rewrites `settings.json` and
  restores the absolute paths.** Nothing catches that now that the file is local and
  unversioned, so check for `/Users/` in it by hand after Orca updates.
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
- **Never move a skill, or a skill's machinery, into this repo.** `claude plugin init
  <name>` scaffolds into `~/.claude/skills/<name>/`, and that is where a skill stays. This
  repo is public, and a skill is a written description of an internal workflow — the
  `context-work.md` rule, not the `CLAUDE.md` one. The same goes for the scripts and hooks
  a skill calls: they belong in `~/.claude/bin/` and `~/.claude/hooks/` beside it.
  `setup_006` creates those directories and does nothing else to them, so nothing written
  there is ever copied, linked or published.

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
