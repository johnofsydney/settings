---
name: annotate-pr
description: Annotate and defend your own open PR by leaving a small number of inline review comments, each anchored to a diff line and each pre-empting a specific objection a reviewer is likely to raise. Predicts the question before answering it, stays silent where the source already explains itself, and always pauses for approval before posting. Use when the user wants to annotate, defend, explain, or pre-empt review on a PR they authored, or asks to "get this ready for reviewers".
---

Leave inline comments on your own PR that answer the questions a reviewer is about to ask.

This is **not** a review. `code-review` asks *"is this wrong?"*. This asks *"what will someone
object to, and what's the answer?"* — and it runs on code you already believe is correct.

## Prerequisite

**Review before you defend.** An annotation that argues for broken code costs more credibility
than it buys, and a reviewer who finds a bug under a paragraph explaining why it's fine trusts
nothing else on the page.

If no review has run on this diff, say so and offer to stop. If the user wants to proceed anyway,
that's their call — proceed, and don't raise it again.

## The two rules

Everything below is machinery. These are the skill.

### 1. Write the reviewer's question first

For every candidate site, write the question a reviewer would ask, *then* answer it.
**If you cannot write a plausible question, there is no comment.**

This is the filter that separates a useful annotation from a restatement of the diff. "This
function converts the value to an angle" is not an annotation. "Why 0.2 and 0.6 rather than
splitting evenly?" is a question, and it has an answer worth writing down.

### 2. Permanent goes in the source; review-only goes on the PR

- Will the explanation still matter in a year, to someone reading the file with no memory of this
  PR? → It belongs in a **code comment**. Add it to the source. The PR comment, if any, just says
  you did.
- Is it only interesting *relative to `main`* — "this is the third attempt", "this looks half-done
  because the rest is in the follow-up ticket", "start with this file"? → It belongs **on the PR**
  and nowhere else. It would be noise in the source once merged.

This split is what stops the skill inflating source files with review chatter.

## Process

### 1. Resolve the PR

```bash
gh pr view --json number,title,headRefOid,isDraft,files,reviews
```

Or take a number/URL if the user gave one. If there's no PR for the current branch, stop and say
so — don't half-work against a bare diff.

Note `headRefOid`; you need it to post. If the PR is a **draft**, mention it — some orgs' required
review checks never pass on a draft-opened PR, and marking it ready afterwards doesn't clear them.

### 2. Read the diff *and* the surrounding source

```bash
gh pr diff <n>
```

Then read each changed file properly — **including its existing comments**. This step is the one
that prevents the most common failure, which is explaining on the PR something the code already
explains three lines up.

**Read, don't grep.** A comment explaining a line often sits well above it — above the enclosing
call, or at the top of the block — so a narrow `grep -B3` will miss it and you'll confidently
annotate something already documented. Open the file around every candidate site before deciding
it's undocumented.

Measure it: a file that is already 15–20% comments and reasons about its hard calls needs almost
nothing from you. A file with none may need several.

### 3. Generate candidates

Six categories earn a comment. Nothing else does.

| Category | The question it answers |
|---|---|
| **Rejected alternative** | "why not the obvious simpler thing?" |
| **Non-obvious constraint** | "where does this magic number come from?" |
| **Deliberate non-validation** | "you forgot to handle X" — pre-empt it as a choice, not an oversight |
| **Cross-repo contract** | "this line pairs with something you can't see from here" |
| **Scope boundary** | "this looks half-done" — because the rest is another ticket |
| **Reviewer shortcut** | "start here / this is generated / skim this" |

### 4. Filter hard

Drop a candidate if **any** of these is true:

- The source already answers it.
- You couldn't write the reviewer's question in rule 1.
- The honest answer is "that's a fair point, I should change it" → **fix it instead**. Annotation
  is not a substitute for a fix, and defending something you know is weak is how a reviewer learns
  to discount everything else you wrote.
- It's a general statement about the PR rather than a fact about *that line* → move it to the
  review body, or to the PR description.

Then apply the volume cap: **roughly one comment per 150 lines of diff, hard cap 12.** Signal dies
with density. A reviewer who sees a comment on every hunk reads none of them. If you're over,
keep the ones whose absence would most likely produce a wrong objection.

### 5. Draft

Each inline comment: the answer, in two to four sentences. Lead with the reason, not the
restatement. Link out rather than writing essays — a design doc, a ticket, a spec section.

Write one **review body** too. Its job is orientation, not summary — the PR description already
summarises. Good review bodies say things like "read `X.ts` first, the rest follows from it", or
"three of these comments are about the same decision; it's argued fully in `docs/…`".

### 6. Paste for approval

**Show the user every comment, with its file and line, plus the review body, and wait.** Never
post unprompted. Expect edits — the user knows things about their reviewers that you don't.

### 7. Post as one review

One review with all comments attached, so reviewers get a single notification rather than N.

Write the payload to a file (multi-line bodies and shell quoting don't mix):

```jsonc
{
  "commit_id": "<headRefOid>",
  "body": "<orientation>",
  "event": "COMMENT",
  "comments": [
    { "path": "src/components/Thing.ts", "line": 73, "side": "RIGHT", "body": "…" },
    { "path": "src/other.ts", "start_line": 20, "start_side": "RIGHT", "line": 28, "side": "RIGHT", "body": "…" }
  ]
}
```

```bash
gh api --method POST repos/{owner}/{repo}/pulls/{n}/reviews --input review.json
```

- `event` is always `COMMENT`. Never `APPROVE` — it's your own PR.
- `line` is the line number in the **head** version of the file, not a diff offset.
- `side: RIGHT` anchors to added and context lines; `LEFT` only for deleted lines.
- A comment on a line outside the diff's hunks is rejected — the whole request fails, so if you get
  a 422, check every anchor before retrying rather than resubmitting blind.

**Check whether your comments will block the merge.** Many orgs enforce
`required_review_thread_resolution`, which means every thread you open must be resolved before the
PR can merge — so annotating an already-approved PR can take it from mergeable to blocked:

```bash
gh api repos/{owner}/{repo}/rules/branches/{base} --jq '.[] | select(.type=="pull_request") | .parameters'
```

If it's on, say so before posting. It's usually still worth it, but it's the user's call, and it's
a nasty surprise to discover after the fact.

Report the review URL when it lands.

## Tone

Matter-of-fact. You are answering a question, not winning an argument.

**Leave genuinely open questions open.** If a decision could reasonably go the other way, say so
and say what would change your mind. A defence that forecloses discussion reads as pre-emptive
argument-winning, and reviewers disengage from PRs that feel already-settled.

### Anti-patterns

- Restating what a code comment already says.
- "This is intentional" with no reason attached — that's an assertion, not a defence.
- Apologising or hedging ("sorry this is a bit messy") — it invites the rewrite request you're
  trying to avoid.
- Long essays inline. Link the design doc.
- Commenting on every changed file.
- Defending something that should just be fixed.

## It's working if

- The comment count is well under the cap, and each one names a decision rather than describing code.
- Densely-commented files receive few or no annotations, and you can say why you skipped them.
- At least one comment concedes something — a limitation, an open question, a "happy to change this".
- Nothing is posted before the user has seen it.
