---
name: retro
description: Critique how this session was driven and name the Claude Code technique that would have gone better — grounded in the session's own transcript, not in generic advice. Use when the user is wrapping up, asks how they could have used Claude better, asks what features they are missing, or types /retro.
---

# Session retro

A coaching pass on **how the session was driven**, not on the code it produced. The user is
trying to get better at operating Claude Code; the job is to tell them the specific thing they
did the slow way and what would have been faster.

The failure mode is a listicle of plausible tips. Guard against it: **every finding must cite a
real moment in this session.** If the evidence does not support a finding, report fewer
findings. Three good ones beat eight generic ones, and "nothing much — this session was driven
well" is a valid, useful answer.

## 1. Gather evidence before forming an opinion

Read the session before judging it. Run these first:

```bash
python3 ~/Projects/John/settings/claude/bin/claude-usage-stats.py --current
```

That resolves the newest transcript for the current working directory and reports tool counts,
skills invoked, subagent use, permission modes, corrections, interrupts and compactions.

Then take the inventory of what was actually available — never coach from memory about what
Claude Code can do, because that knowledge has a cutoff and the install moves:

```bash
ls ~/.claude/skills/ .claude/skills/ .claude/commands/ 2>/dev/null
claude plugin marketplace list 2>/dev/null
claude plugin list 2>/dev/null
```

The skills and agent types offered to this session are listed in its own system prompt — that
listing is authoritative for what could have been reached, and it is broader than what the user
has installed by hand.

Where the counts suggest something but do not prove it, go and read the transcript. It is
JSONL; grep it.

## 2. What to look for

Read the numbers as symptoms, then confirm the cause in the transcript.

| Signal | What it often means |
| --- | --- |
| High `corrections` or `interrupts` | The opening prompt under-specified the task; plan mode or a clarifying question would have cost less than the rework |
| `compactions` > 0, long sessions | Work that should have been delegated to a subagent, or a `/clear` boundary that was never taken |
| A skill exists that fits the work but was never invoked | Discovery gap — name the skill and the moment it applied |
| Repeated near-identical Bash calls | A loop, a script, or a fan-out that was done by hand |
| `permission_modes` stuck in one mode | Plan mode for design work, auto for grinding — mismatch costs either safety or speed |
| Many sessions on one ticket | Context lost between sessions that a design record or a memory would have carried |

Two traps to avoid:

- **Tool counts reflect the harness, not the user.** Auto mode instructs Bash-first, so a high
  Bash-to-Read ratio is the configuration working as intended — not a finding.
- **A feature the user deliberately declined is not a gap.** Check memory and `CLAUDE.md`
  before recommending something they already rejected; say so if you are re-raising it anyway.

## 3. Also look outward, not just inward

The user wants to hear about capability they do not yet know exists — that is the point of the
exercise. Once per retro, name at most **one** thing that was never reachable from this session:
an uninstalled plugin, a marketplace skill, a harness feature they have never used. Say plainly
that it is a suggestion to evaluate rather than something you saw fail, and give the command to
install or try it.

If you are not confident it exists in the current version, say that instead of asserting it.
A fabricated feature costs more trust than a missed tip.

## 4. Report

Keep it short enough to read while closing the laptop.

- **What went well** — one line. Genuine, or omitted entirely; do not manufacture praise.
- **Findings** — at most three. Each one: what happened, the evidence, what to do instead.
- **One thing to try next time** — a single concrete change, not a menu.
- **Worth installing** — the outward suggestion, if there is one.

Then offer, without doing it unprompted, to persist whatever the user accepts: a memory for a
durable working preference, a line in `CLAUDE.md` for a project rule, a permission-rule change
if prompts were the friction. Wait for their answer — a retro that rewrites config on its own
is a retro they will stop running.
