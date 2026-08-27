#!/usr/bin/env python3
"""Extract usage evidence from Claude Code transcripts.

Emits JSON on stdout for a coaching agent to critique. Counts only; no prompt
text is included except short interrupt/correction excerpts, which are capped.

Usage:
  claude-usage-stats.py --days 7                 # all projects
  claude-usage-stats.py --session <path.jsonl>   # one session
  claude-usage-stats.py --current                # newest session for $PWD
"""
import argparse, json, os, glob, time, collections, re

CORRECTION = re.compile(r"\b(no,|nope|actually,|that's wrong|not what i|don't|stop|undo|revert|i said)\b", re.I)

def iter_lines(path):
    with open(path, errors="replace") as fh:
        for line in fh:
            try:
                yield json.loads(line)
            except Exception:
                continue

def text_of(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        return " ".join(b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text")
    return ""

def analyse(paths):
    s = {
        "sessions": 0, "user_turns": 0, "assistant_turns": 0,
        "tools": collections.Counter(), "skills": collections.Counter(),
        "subagent_types": collections.Counter(), "permission_modes": collections.Counter(),
        "bash_verbs": collections.Counter(), "mcp_servers": collections.Counter(),
        "models": collections.Counter(), "efforts": collections.Counter(),
        "projects": collections.Counter(), "branches": collections.Counter(),
        "interrupts": 0, "compactions": 0, "corrections": 0,
        "sidechain_msgs": 0, "long_sessions": 0, "session_summaries": [],
    }
    for p in paths:
        rows = list(iter_lines(p))
        if not rows:
            continue
        s["sessions"] += 1
        first = last = None
        per = collections.Counter()
        title = None
        for d in rows:
            t = d.get("type")
            ts = d.get("timestamp")
            if ts:
                first = first or ts
                last = ts
            if t == "ai-title":
                title = d.get("aiTitle")
            if t == "permission-mode":
                s["permission_modes"][d.get("permissionMode")] += 1
            if d.get("isSidechain"):
                s["sidechain_msgs"] += 1
            if d.get("cwd"):
                s["projects"][d["cwd"]] += 1
            if d.get("gitBranch"):
                s["branches"][d["gitBranch"]] += 1
            if t == "user":
                s["user_turns"] += 1
                txt = text_of(d.get("message", {}))
                if "[Request interrupted" in txt:
                    s["interrupts"] += 1
                elif txt and CORRECTION.search(txt[:400]):
                    s["corrections"] += 1
            elif t == "assistant":
                s["assistant_turns"] += 1
                m = d.get("message", {})
                if m.get("model"):
                    s["models"][m["model"]] += 1
                if d.get("effort"):
                    s["efforts"][d["effort"]] += 1
                for b in m.get("content", []) or []:
                    if not isinstance(b, dict) or b.get("type") != "tool_use":
                        continue
                    name = b.get("name", "?")
                    s["tools"][name] += 1
                    per[name] += 1
                    inp = b.get("input", {}) or {}
                    if name == "Skill":
                        s["skills"][inp.get("skill", "?")] += 1
                    elif name == "Agent":
                        s["subagent_types"][inp.get("subagent_type", "(default)")] += 1
                    elif name == "Bash":
                        cmd = (inp.get("command") or "").strip().split()
                        if cmd:
                            s["bash_verbs"][cmd[0]] += 1
                    elif name.startswith("mcp__"):
                        s["mcp_servers"][name.split("__")[1] if "__" in name else name] += 1
            elif t == "system":
                if "compact" in json.dumps(d)[:2000].lower():
                    s["compactions"] += 1
        if len(rows) > 400:
            s["long_sessions"] += 1
        s["session_summaries"].append({
            "file": os.path.basename(p), "title": title, "rows": len(rows),
            "start": first, "end": last, "top_tools": per.most_common(6),
        })
    return s

def current_session(root):
    """Newest transcript for $PWD. Claude Code sanitises the cwd by replacing
    every non-alphanumeric character with a hyphen."""
    slug = re.sub(r"[^A-Za-z0-9]", "-", os.getcwd())
    d = os.path.join(root, slug)
    files = glob.glob(os.path.join(d, "*.jsonl"))
    return max(files, key=os.path.getmtime) if files else None

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--days", type=float, default=7)
    ap.add_argument("--session")
    ap.add_argument("--current", action="store_true",
                    help="newest transcript for the current working directory")
    ap.add_argument("--root", default=os.path.expanduser("~/.claude/projects"))
    a = ap.parse_args()
    if a.current:
        p = current_session(a.root)
        if not p:
            print(json.dumps({"error": "no transcript found for cwd", "cwd": os.getcwd()}))
            return
        paths = [p]
    elif a.session:
        paths = [a.session]
    else:
        cutoff = time.time() - a.days * 86400
        paths = [p for p in glob.glob(os.path.join(a.root, "**", "*.jsonl"), recursive=True)
                 if os.path.getmtime(p) >= cutoff]
    s = analyse(sorted(paths))
    out = {k: (dict(v.most_common(30)) if isinstance(v, collections.Counter) else v) for k, v in s.items()}
    out["window_days"] = a.days
    out["files_scanned"] = len(paths)
    out["session_summaries"] = sorted(s["session_summaries"], key=lambda r: r["rows"], reverse=True)[:15]
    print(json.dumps(out, indent=2, default=str))

if __name__ == "__main__":
    main()
