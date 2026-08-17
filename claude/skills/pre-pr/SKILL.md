---
name: pre-pr
description: Run every pre-PR gate before opening a PR for review — temp-file removal, N+1 audit, formatter, test suite, and design-record check — and report a single pass/fail checklist. Use when the user says they are raising, opening, or creating a PR, asks to run `gh pr create`, or otherwise signals the work is review-ready.
---

# Pre-PR gate

A single checklist run before any PR goes up for review, so the standing obligations are one
invocation instead of several things to independently remember.

Run **every** check even if an early one fails — the user wants the full picture in one pass,
not a stop at the first problem. Report a checklist, then a short list of what to fix.

Detect the repo's tooling rather than assuming it. Skip a check that genuinely does not apply
and say so explicitly; never silently drop one.

## 1. Temp scaffolding removed

Investigation scaffolding (profilers, repro harnesses, synthetic seeders, debug
instrumentation) carries a marker in its header by convention:

```bash
grep -rlE "TEMP [^ ]+ DELETE THIS FILE BEFORE OPENING THE PR" --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git .
grep -rn "DEBUG-" --exclude-dir=node_modules --exclude-dir=vendor --exclude-dir=.git . | grep -vE "^\S+\.(md|lock)"
```

The first pattern is a regex with `[^ ]+` standing in for the marker's em dash **on purpose**.
Written as the literal string, this file would itself contain the marker, and every scan — the
`temp-marker-guard.sh` hook's included — would report this skill as a temp file needing deletion.
`[^ ]+` also can't match its own source text (the class contains a space), so the pattern doesn't
flag this file either. Keep any copy of the marker in documentation non-literal for both reasons.

Both must come back empty. List any hits with full paths.

`rm` is denied by the user's permission rules — **hand over the exact command** rather than
attempting deletion. Design records under `docs/<ticket>/` are keepers: they are committed
deliberately and are not temp.

A `PreToolUse` hook (`claude/hooks/temp-marker-guard.sh`) independently blocks
`gh pr create` and asks on `git push` while marked files remain. This check exists so the
problem is found before that point, not as a duplicate.

## 2. N+1 query audit

The standing obligation is to find and fix N+1s proactively, not let a reviewer catch them.

Scan the diff for: `.each`/`.map` touching associations per record, partials rendered per
collection item that hit the DB, missing `includes`/`preload`/`eager_load`, and
`.count`/`.exists?` inside iterations.

**Green specs do not prove absence.** Where a detector only logs rather than raises, a
passing suite is no evidence. The reliable check is a targeted guard spec that measures only
the request/render with detection escalated to a failure — and prove the guard bites by
temporarily removing the eager-load and confirming it goes red.

Report: what was scanned, what was found, what was fixed, and how absence was verified.

## 3. Formatter and linter clean

Detect and run the repo's formatter over the changed files (not the whole tree). Report the
command used and its result.

## 4. Tests

Run the suite the project's CI would run. Note any known-excluded categories and why — for
example, browser/system specs that contend locally and are authoritative only in CI. If a
category is skipped locally, say so plainly rather than implying full coverage.

## 5. Design record present

Substantial work should leave a committed record under `docs/<ticket>/` — the plan, the
measurements, and any diagnosis worth keeping. Check it exists and is up to date with what
actually shipped, including anywhere the original plan turned out to be wrong. A plan that
still asserts a since-falsified claim is worse than no plan.

## 6. Diff review

Read the diff as a reviewer would. Flag: leftover commented-out code, stray debugging,
unrelated changes riding along, and anything that adds a second path to an existing outcome
without explaining why one path was not enough (pre-empt that question in a code comment
before a reviewer asks it).

## Output

A checklist with an explicit verdict per item:

```
Pre-PR gate — <branch>
  [PASS] Temp scaffolding removed
  [FAIL] N+1 audit          — 2 unverified; see below
  [PASS] Formatter clean
  [SKIP] Tests              — system specs excluded locally (CI authoritative)
  [PASS] Design record
  [WARN] Diff review        — 1 item worth a comment
```

Then the specifics, then a plain statement of whether this is ready to open. Do not open the
PR as part of this skill — report, let the user decide, and if anything failed say what to
fix first.
