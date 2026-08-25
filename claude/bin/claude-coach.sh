#!/usr/bin/env bash
#
# Weekly coaching digest: how the last seven days of Claude Code were driven, and what to do
# differently. Run by the ai.labflow.claude-coach launchd agent; safe to run by hand.
#
# Runs LOCALLY on purpose. The evidence is ~/.claude/projects/**/*.jsonl, which exists only on
# this machine — a cloud routine has no way to read it.
#
# Headless `claude -p` does not load the claude.ai MCP connectors, so Slack is not reachable the
# way it is in an interactive session. Delivery is therefore: a file always, a macOS notification
# always, and a Slack post only when CLAUDE_COACH_SLACK_WEBHOOK is set in the environment.
#
set -uo pipefail

# launchd does not source a shell, so the gitignored secrets file is read explicitly.
# shellcheck source=/dev/null
[ -f "$HOME/Projects/John/settings/env_variables.sh" ] && . "$HOME/Projects/John/settings/env_variables.sh" 2>/dev/null

CLAUDE_BIN="${CLAUDE_BIN:-$HOME/.local/bin/claude}"
STATS="$HOME/Projects/John/settings/claude/bin/claude-usage-stats.py"
OUT_DIR="$HOME/.claude/coaching"
DAYS="${CLAUDE_COACH_DAYS:-7}"

command -v "$CLAUDE_BIN" >/dev/null 2>&1 || CLAUDE_BIN=$(command -v claude) || {
  echo "claude binary not found" >&2; exit 1;
}

mkdir -p "$OUT_DIR"
stamp=$(date +%F)
digest="$OUT_DIR/$stamp.md"
evidence=$(mktemp -t claude-coach-stats)
trap 'rm -f "$evidence"' EXIT

python3 "$STATS" --days "$DAYS" > "$evidence" 2>/dev/null || {
  echo "stats extraction failed" >&2; exit 1;
}

read -r -d '' PROMPT <<PROMPT_EOF
You are writing John's weekly Claude Code coaching digest. He wants a regular, honest push to
improve how he drives the tool. Be direct; he is technically confident and does not need
softening.

Evidence for the last $DAYS days is at: $evidence
It is JSON: tool counts, skills invoked, subagent types, permission modes, corrections,
interrupts, compactions, and per-session summaries. Read it first.

Take the inventory of what was actually available before you recommend anything:
  ls ~/.claude/skills/ ~/.claude/plugins/cache/ 2>/dev/null
  $CLAUDE_BIN plugin list 2>/dev/null
  $CLAUDE_BIN plugin marketplace list 2>/dev/null
Never coach from memory about what Claude Code can do — your knowledge has a cutoff and this
install moves. If you are not sure a feature exists in the current version, say so rather than
asserting it.

Where a number only hints at something, go and read the transcript to confirm it. The files are
JSONL under ~/.claude/projects/ and you may grep them.

Rules that decide whether this digest is worth reading:
- Every finding cites real evidence — a count, a session, a moment. No generic advice.
- At most three findings. Fewer is fine. "Nothing much changed this week" is a valid answer.
- Auto mode instructs Bash-first, so a high Bash-to-Read ratio is configuration, not a finding.
- Do not re-recommend something he has deliberately declined; check ~/.claude/CLAUDE.md and the
  memory directory first.

Write Markdown, under 400 words, in this shape:
  # Week to $stamp
  **The numbers** - three or four lines of the figures that actually matter, with the change
  worth noticing called out.
  **Findings** - at most three. Each: what happened, the evidence, what to do instead.
  **Try this week** - one concrete change, not a menu.
  **Worth a look** - at most one capability he has never used, with the command to try it, and
  an explicit note that it is a suggestion rather than something you saw fail.

Print ONLY the Markdown. No preamble, no sign-off, no offer to help further.
PROMPT_EOF

"$CLAUDE_BIN" -p "$PROMPT" \
  --model claude-opus-5 \
  --allowedTools Bash Read Glob Grep \
  < /dev/null > "$digest" 2>"$OUT_DIR/.last-run.log"

if [ ! -s "$digest" ]; then
  echo "coach produced nothing; see $OUT_DIR/.last-run.log" >&2
  exit 1
fi

if [ -n "${CLAUDE_COACH_SLACK_WEBHOOK:-}" ]; then
  jq -Rs '{text: .}' < "$digest" \
    | curl -sS -X POST -H 'Content-type: application/json' \
           --data @- "$CLAUDE_COACH_SLACK_WEBHOOK" >/dev/null 2>&1
fi

osascript -e "display notification \"Weekly Claude technique digest is ready\" with title \"Claude coach\" subtitle \"$digest\"" >/dev/null 2>&1

echo "$digest"
