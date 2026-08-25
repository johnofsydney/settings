#!/usr/bin/env bash
#
# Stop hook: a once-a-day reminder that /retro exists.
#
# Improving how Claude Code is driven only happens if something asks for it. Stop is the only
# event that can put a line in front of the user at the end of a turn — SessionEnd runs after
# the model has stopped, so nothing it emits is ever seen.
#
# Stop fires on EVERY turn, so two gates keep this from becoming the thing you switch off:
#
#   once per day     -> a date stamp in $STAMP, checked before any other work
#   substantive work -> at least $MIN_ROWS transcript rows, so a one-question session is spared
#
# Reads the Stop payload on stdin, emits {"systemMessage": ...} on stdout. Silent on every
# failure path: a broken nudge must never interrupt a turn.
#
set -uo pipefail

STAMP="$HOME/.claude/.retro-nudge-stamp"
MIN_ROWS=150

payload=$(cat 2>/dev/null) || exit 0

today=$(date +%F)
[ "$(cat "$STAMP" 2>/dev/null)" = "$today" ] && exit 0

transcript=$(printf '%s' "$payload" | jq -r '.transcript_path // ""' 2>/dev/null)
if [ -z "$transcript" ] || [ ! -f "$transcript" ]; then
  slug=$(printf '%s' "$PWD" | sed 's/[^A-Za-z0-9]/-/g')
  transcript=$(ls -t "$HOME/.claude/projects/$slug"/*.jsonl 2>/dev/null | head -1)
fi
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

rows=$(wc -l < "$transcript" 2>/dev/null | tr -d ' ')
[ -n "$rows" ] && [ "$rows" -ge "$MIN_ROWS" ] 2>/dev/null || exit 0

printf '%s' "$today" > "$STAMP" 2>/dev/null || exit 0

jq -n '{systemMessage: "Worth a /retro before you close this one — it reads the session back and names what could have been driven better."}'
exit 0
