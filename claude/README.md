# Claude Code config

Shared Claude Code configuration, symlinked into `~/.claude/` on every machine.

**The whole model in one line:** everything here is identical on every machine except
*two symlinks*, which pick a **profile** (`work` or `home`).

---

## What's in here

| File | Linked to | Shared? |
|---|---|---|
| `CLAUDE.md` | `~/.claude/CLAUDE.md` | Yes — global instructions, every session |
| `settings.json` | `~/.claude/settings.json` | Yes — permissions, hooks, statusLine, plugins, theme |
| `skills/*` | `~/.claude/skills/<name>` | Yes — one symlink per skill |
| `context-work.md`<br>`context-home.md` | `~/.claude/machine.md` | **Profile picks one** |
| `overlay-work.json`<br>`overlay-home.json` | `~/.claude/overlay.json` | **Profile picks one** |

> **`context-work.md` is gitignored.** This repo is public and that file holds internal
> team and project names — same rule as `work_aliases.sh`. It won't be in a fresh clone;
> `setup_006` creates an empty one so the `@~/.claude/machine.md` import never dangles.
> Nothing is lost for syncing, because the home machine reads `context-home.md` anyway.

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
diff ~/.claude/settings.json  claude/settings.json
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

## Day to day

**Expect `git status` here to show `claude/settings.json` modified. That is normal.**

Claude Code writes user-scope settings *back* to `~/.claude/settings.json`, which is a
symlink into this repo. Approving a permission with "don't ask again", changing the theme,
toggling a plugin — all land here as a working-tree change. That's a feature: permission
approvals end up version-controlled and reviewable in `git diff`. Review and commit them
periodically.

Two things to watch for in that diff:

- **`model` or `effortLevel` appearing in `settings.json`.** Using `/model` or `/effort`
  in a session writes the choice to the *base*, not the overlay. Left there, it would
  propagate to the other machine on the next pull — a work machine's Opus choice landing
  on the home Pro plan. **Delete those keys from `settings.json`**; the overlays own them.
  (The home overlay pins its model precisely so a leak like this can't bite, but tidy it
  up anyway.)
- **Wholesale key reordering.** The app normalises key order when it rewrites the file, so
  the first diff after a change may look bigger than it is. Content-wise it's a no-op.

---

## Verifying it worked

```sh
# 1. All five links point into the settings repo
ls -la ~/.claude/{CLAUDE.md,settings.json,machine.md,overlay.json}
ls -la ~/.claude/skills/

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
- **The Orca hooks hardcode `/Users/john.coote/`.** They're generated by Orca, and every
  one guards with `-f`/`-r`/`-x` before running, so on a machine with a different
  username they simply no-op — no error, but also no hooks and no statusLine. If Orca is
  installed on this machine and the statusLine is missing, that's why: re-run Orca's own
  setup so it rewrites the paths, or make them `$HOME`-relative (note they're
  single-quoted, so `$HOME` needs double quotes to expand).
- **`~/.claude.json` (no slash) is not this.** It's machine state — project registry,
  onboarding, MCP config. Never synced.
- **`~/.claude/plugins/` is a cache**, not config. It rehydrates from
  `extraKnownMarketplaces` + `enabledPlugins` in `settings.json`. Don't commit it. `npx
  skills update` overwrites everything under `plugins/cache/` anyway.
- **Connectors (Figma, Linear, Slack, Gmail…) are account-scoped**, not file config. They
  travel with the claude.ai account, so they can't be synced from here — and equally can't
  leak between machines signed into different accounts. Audit them per account.
- **Skills are linked one by one, not as a directory.** `claude plugin init <name>`
  scaffolds into `~/.claude/skills/<name>/`; if the whole directory were a link, every new
  skill would be forced into this repo. To share a new skill, move it into `claude/skills/`
  and re-run `setup_006`.

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
