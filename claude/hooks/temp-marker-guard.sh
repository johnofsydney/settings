#!/usr/bin/env bash
#
# PreToolUse guard: stop TEMP-marked scaffolding reaching a PR.
#
# Investigation work (profilers, repro harnesses, synthetic seeders, debug instrumentation)
# leaves files that must never ship. The convention is that each one carries this marker in
# its header:
#
#   <TICKET-ID> TEMP — DELETE THIS FILE BEFORE OPENING THE PR.
#
# Only the text from "TEMP —" onward is matched (see MARKER below), so the ticket prefix is
# free-form and any project's ID scheme works.
#
# This hook greps for that marker and intervenes when a publishing action is attempted, so
# removal does not depend on anyone remembering.
#
# Graduated on purpose, because an obstructive hook is one you end up disabling:
#   git commit    -> silent. WIP commits with scaffolding present are normal and expected.
#   git push      -> ask.    Shows the file list; wave it through for a genuine WIP push.
#   gh pr create  -> deny.   Never legitimate with temp files still in the tree.
#
# Reads the PreToolUse payload on stdin, emits a PreToolUse decision on stdout.
#
set -uo pipefail

MARKER='TEMP — DELETE THIS FILE BEFORE OPENING THE PR'

payload=$(cat)
cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

# Classify the action. Matching anywhere in the string (rather than as a prefix) so that
# `git add . && git push` is caught too.
decision=""
if [[ "$cmd" =~ gh[[:space:]]+pr[[:space:]]+create ]]; then
  decision="deny"
elif [[ "$cmd" =~ git[[:space:]]+push ]]; then
  decision="ask"
else
  exit 0
fi

root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -n "$root" ] || exit 0

# Only files, and only the marker — deliberately NOT grepping for `DEBUG-` tags, which
# appear in plenty of legitimate code and would make this noisy enough to get switched off.
hits=$(cd "$root" && grep -rlF --binary-files=without-match \
  --exclude="$(basename "${BASH_SOURCE[0]}")" \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=vendor \
  --exclude-dir=tmp \
  --exclude-dir=log \
  --exclude-dir=coverage \
  "$MARKER" . 2>/dev/null | sed 's|^\./||' | sort)

[ -n "$hits" ] || exit 0

count=$(printf '%s\n' "$hits" | grep -c . )
list=$(printf '%s\n' "$hits" | sed 's/^/  - /')

reason="${count} file(s) still carry the TEMP marker and must be deleted before this reaches a PR:

${list}

Delete them and retry. Note: design records under docs/ are keepers — only marked files are temp.
Also worth a look before the PR: inline debug tags (grep for 'DEBUG-') and the N+1 audit."

jq -n --arg r "$reason" --arg d "$decision" '
  {hookSpecificOutput: {
     hookEventName: "PreToolUse",
     permissionDecision: $d,
     permissionDecisionReason: $r
  }}'
exit 0
