# Read-only probe for the Herdr "fleet" mod. Run on the orchestration machine as
#   python3 -c <this file> <root>
# where <root> is the orchestration repo (it holds papaclaude/ and scripts/).
# Prints one JSON object; changes nothing.
import json, os, glob, subprocess, re, sys
ROOT = (sys.argv[1] if len(sys.argv) > 1 else os.getcwd()).rstrip("/")
R = ROOT + "/papaclaude"
out = {}
try:
    d = json.load(open(R + "/alert-digest/latest.json"))
    recs = d.get("records", [])
    live = lambda r: r.get("still_open") and not r.get("accepted")
    out["alerts"] = {
        "generated": d.get("generated"), "partial": d.get("partial"), "count": len(recs),
        "open": sum(1 for r in recs if live(r)),
        "sources": [{"name": k, "status": v.get("status"), "records": v.get("records"),
                     "open": sum(1 for r in recs if r.get("source") == k and live(r))}
                    for k, v in d.get("sources", {}).items()],
    }
except Exception as e:
    out["alerts"] = {"error": str(e)}
try:
    p = R + "/pwn-watch/state.json"
    out["cve"] = {"incidents": len(json.load(open(p)).get("incidents", {})), "mtime": os.path.getmtime(p)}
except Exception as e:
    out["cve"] = {"error": str(e)}
try:
    sessions = json.load(open(R + "/.state/campaign-sessions.json"))
except Exception:
    sessions = {}
# Claude Code keeps transcripts per project folder, named after its path with / as -.
proj = os.path.expanduser("~/.claude/projects/" + ROOT.replace("/", "-") + "/")
camps = []
for f in glob.glob(R + "/campaigns/*.md"):
    st = desc = None
    with open(f, errors="replace") as h:
        if h.readline().strip() == "---":
            for line in h:
                if line.strip() == "---":
                    break
                if line.startswith("status:"):
                    st = line[7:].split("#")[0].strip()
                elif line.startswith("description:"):
                    desc = line[12:].strip()
    if st in ("active", "deferred"):
        name = os.path.basename(f)[:-3]
        sid = sessions.get(name)
        if isinstance(sid, dict):
            sid = sid.get("session")
        if not (isinstance(sid, str) and re.fullmatch(r"[0-9a-f-]{36}", sid) and os.path.exists(proj + sid + ".jsonl")):
            sid = None
        camps.append({"name": name, "status": st, "description": desc or "", "mtime": os.path.getmtime(f), "session": sid})
camps.sort(key=lambda c: -c["mtime"])
out["campaigns"] = camps
try:
    r = subprocess.run([ROOT + "/scripts/stack-worktree", "list"], capture_output=True, text=True, timeout=60)
    wt = []
    for line in r.stdout.splitlines():
        m = re.match(r"(\S+)\s+ahead=(\d+)\s+(\S+)\s+\[(.*)\]", line)
        if m and (m.group(1) != "clean" or int(m.group(2)) > 0):
            wt.append({"state": m.group(1), "ahead": int(m.group(2)),
                       "path": m.group(3).replace(ROOT + "/temp/worktrees/", ""), "branch": m.group(4)})
    out["worktrees"] = wt
    if r.returncode != 0:
        out["worktrees_error"] = (r.stderr or "exit %d" % r.returncode).strip()[:200]
except Exception as e:
    out["worktrees"] = []
    out["worktrees_error"] = str(e)
try:
    r = subprocess.run(["git", "--no-optional-locks", "status", "--porcelain=v1", "--untracked-files=normal"],
                       cwd=ROOT, capture_output=True, text=True, timeout=30)
    out["root_dirty"] = len([l for l in r.stdout.splitlines() if l.strip()]) if r.returncode == 0 else None
except Exception:
    out["root_dirty"] = None
# hc templates on this machine: name, description, and the instructions (body) of each.
tpls = []
for f in sorted(glob.glob(os.path.expanduser("~/.config/herdr-core/templates/*.md"))):
    try:
        text = open(f, errors="replace").read()
        if not text.startswith("---"):
            continue
        head, body = text[3:].split("\n---", 1)
        meta = {}
        for line in head.splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip()
        name = meta.get("name") or os.path.basename(f)[:-3]
        tpls.append({"name": name, "description": meta.get("description", ""), "body": body.strip()})
    except Exception:
        continue
out["templates"] = tpls
print(json.dumps(out))
