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

## Gem APIs — documented and public only

**Build against the API a gem documents, not the one it happens to expose.** A method that is
`public` in Ruby but absent from the gem's README is an internal, and a method the gem marks
`private` is not mine to call or to override. Both move on a minor version bump without a
CHANGELOG entry, and the breakage lands in production rather than in CI.

The test is two questions, in order: **is it in the gem's own documentation, and is it public?**
`public` alone is not enough — attribute readers on internal objects are public by accident of
Ruby, not by intent.

- **Prefer the documented seam, even where it costs more.** A configuration option, a documented
  callback, a published query method. If the documented route is slower or more verbose, that is
  the price of a dependency that can be upgraded.
- **Shadowing a gem's method is the case to be most suspicious of**, because it keeps working right
  up until the signature changes, and then fails somewhere unrelated to the override.
- **Reaching through a chain is reaching deeper than it looks.** `thing.internals.collection[key]`
  depends on three objects, not one, and the undocumented link in the middle is the one that moves.

**If there is genuinely no documented route, it is an exception and it gets paid for — all four:**

1. A comment on the class saying the gem API is private or undocumented, and the version verified
   against.
2. A comment on the method stating the contract and what breaks if the gem changes.
3. **A boundary spec asserting the gem's side of the bargain** — the visibility, the signature, the
   default, the chain — so an upgrade is a red build naming the assumption, not a behaviour change
   nobody made.
4. The version constraint tightened far enough that the bump cannot arrive unnoticed.

An exception without the boundary spec is not an exception, it is a bet. Ask me before taking one.

## Never push — ask first

**No `git push` happens without me saying so, in any repository.** Ask, then wait for the
answer. Offering to push is welcome; pushing because it seemed like the moment is not.

CI starts over on every push, so a branch pushed four times burns four full runs on a shared
queue. Batch the commits locally and push once, when I say.

- **Committing needs no permission.** `git add` and `git commit` are allowed outright and must
  stay that way — run them without asking, as often as is useful. It is the push that costs.
- **A push is always its own Bash call.** Never `git add && git commit && git push` on one
  line: the ask rule matches the whole command, so a single prompt ends up covering the add
  and the commit too, and I cannot approve the commit without also approving the push. Run
  add and commit, say what they did, then ask about the push in a separate call.
- **This covers anything that pushes as a side effect.** `gh pr create` on a branch whose
  commits are not yet on the remote pushes it for you, and so does any script or skill step
  that ends in a push.
- **A refusal is not a reason to work around it.** If I say no or say nothing, the work sits
  on the local branch; it does not go out by another route.
- `~/.claude/settings.json` backs this with an `ask` rule on `Bash(git push)` so the prompt
  appears even when this instruction is missed. That rule is the floor, not the point.

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

## Every code review asks two questions beyond the diff

This applies to **any** review, whoever wrote the code and whatever tool is driving — `/code-review`,
`/deep-review`, `/explain-to-senior`, `/pre-pr`, or reading a diff by hand. The skills that
live in `~/.claude/skills/` carry it themselves; this section is what makes it bind on
`mattpocock-skills:code-review`, which I must not edit in the plugin cache.

Mutation testing asks whether the code is pinned. A spec review asks whether it matches the ticket.
A standards review asks whether it follows the rules. All three take the change's own frame as
given, so all three can agree with each other and still miss the same defect.

Ask both of these as well, and write the answer down even when it is "nothing to report":

1. **Who controls each input, and can an untrusted one outrank a trusted one?** List every
   identifier, parameter and field the change reads, and name who mints each — this system, the
   user, or a third party. Where several are matched in sequence or by precedence, check that a
   value an outsider controls cannot win over one this system minted.

2. **Where does control go when this code returns, and do its guarantees still hold there?** Follow
   every redirect, enqueue, callback, broadcast and hand-off past the edge of the diff. A permission
   checked here is not a permission checked there; a validation applied here is not applied after
   the hand-off. Answering this means reading code the diff does not touch.

**The ticket is not the oracle for either question.** A detailed ticket routinely blesses the exact
assumption that is wrong, and a review that defers to it inherits the blind spot rather than
covering it. Say so plainly when the answer contradicts what the ticket decided.

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
