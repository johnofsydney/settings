echo
echo Setup Claude Code Config Starting...
echo

# Wires this repo's claude/ directory into ~/.claude/ via symlinks, and picks the
# machine profile (work or home). See claude/README.md for the full picture.
#
# Only three paths in ~/.claude/ are config; the rest of that directory is session
# state, caches, transcripts and telemetry. We link the individual paths and never
# the directory itself.
#
# Idempotent: re-running relinks the same targets and re-uses the profile already in
# place. A pre-existing REGULAR file/dir is moved aside to <name>.pre-settings-repo.bak
# rather than clobbered.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" == */setup_scripts ]]; then
  SETTINGS_FOLDER="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  read -p "Enter folder for personal settings and config, eg Projects/John/settings (inside your home directory): " FOLDER
  SETTINGS_FOLDER="$HOME/$FOLDER"
fi

CLAUDE_SRC="$SETTINGS_FOLDER/claude"
CLAUDE_DIR="$HOME/.claude"

if [ ! -d "$CLAUDE_SRC" ]; then
  echo "ERROR: $CLAUDE_SRC not found — is SETTINGS_FOLDER correct?" >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR"

# context-work.md is gitignored (internal team/project names, and this repo is public),
# so a fresh clone won't have it. Create an empty one rather than leave the
# @~/.claude/machine.md import in CLAUDE.md pointing at nothing — same reason setup_003
# touches work_aliases.sh and env_variables.sh.
if [ ! -e "$CLAUDE_SRC/context-work.md" ]; then
  printf '# Work machine\n\nGitignored — this file is local to this machine. See claude/README.md.\n' \
    > "$CLAUDE_SRC/context-work.md"
  echo "Created an empty claude/context-work.md (gitignored, not in the clone)."
fi

# ---------------------------------------------------------------------------
# Profile: work or home. Default to whatever is already linked, so re-running
# never silently flips a machine over.
# ---------------------------------------------------------------------------
CURRENT_PROFILE=""
if [ -L "$CLAUDE_DIR/machine.md" ]; then
  case "$(readlink "$CLAUDE_DIR/machine.md")" in
    *context-work.md) CURRENT_PROFILE="work" ;;
    *context-home.md) CURRENT_PROFILE="home" ;;
  esac
fi

if [ -n "$CURRENT_PROFILE" ]; then
  echo "Current profile: $CURRENT_PROFILE"
  read -p "Profile for this machine [work/home] (Enter to keep '$CURRENT_PROFILE'): " PROFILE
  PROFILE="${PROFILE:-$CURRENT_PROFILE}"
else
  echo "Which machine is this?"
  echo "  work — full work context (comms workflow), Opus"
  echo "  home — minimal context, Sonnet + low effort (personal Pro plan)"
  read -p "Profile [work/home]: " PROFILE
fi

case "$PROFILE" in
  work | home) ;;
  *) echo "ERROR: profile must be 'work' or 'home' (got '$PROFILE')" >&2; exit 1 ;;
esac

# ---------------------------------------------------------------------------
# link <source> <destination>
#   Moves an existing regular file/dir aside first. Leaves existing symlinks to be
#   overwritten by ln -sfn (relinking is the whole point of re-running).
# ---------------------------------------------------------------------------
link() {
  local src="$1" dst="$2"
  if [ ! -e "$src" ]; then
    echo "  SKIP $(basename "$dst") — no $src"
    return 0
  fi
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="$dst.pre-settings-repo.bak"
    if [ -e "$backup" ]; then
      backup="$backup.$(date +%Y%m%d%H%M%S)"
    fi
    mv "$dst" "$backup"
    echo "  BACKED UP existing $(basename "$dst") -> $(basename "$backup")"
  fi
  ln -sfn "$src" "$dst"
  echo "  LINKED $(basename "$dst") -> ${src#"$HOME/"}"
}

echo
echo "Linking into $CLAUDE_DIR (profile: $PROFILE)"
link "$CLAUDE_SRC/CLAUDE.md"                "$CLAUDE_DIR/CLAUDE.md"
link "$CLAUDE_SRC/context-$PROFILE.md"      "$CLAUDE_DIR/machine.md"
link "$CLAUDE_SRC/overlay-$PROFILE.json"    "$CLAUDE_DIR/overlay.json"

# Skills are linked ONE BY ONE into a real ~/.claude/skills directory, rather than
# symlinking the directory itself. Two reasons:
#   - `claude plugin init <name>` scaffolds into ~/.claude/skills/<name>/. If the
#     whole directory were a link, every new skill would be forced into this repo.
#   - A machine can then keep a local-only skill alongside the shared ones.
# Anything already in ~/.claude/skills that isn't in the repo is left untouched.
mkdir -p "$CLAUDE_DIR/skills"
if [ -d "$CLAUDE_SRC/skills" ]; then
  for skill in "$CLAUDE_SRC"/skills/*/; do
    [ -d "$skill" ] || continue
    link "${skill%/}" "$CLAUDE_DIR/skills/$(basename "$skill")"
  done
fi

echo
echo "Verify with:"
echo "  ls -la $CLAUDE_DIR/{CLAUDE.md,skills,machine.md,overlay.json}"
echo "settings.json is no longer synced — it's a real, machine-local file now."
echo "Then open a new shell (the claude() wrapper lives in my_extensions.sh) and run"
echo "/context in a session to confirm the machine.md import resolved."

echo
echo Setup Claude Code Config Complete
echo
