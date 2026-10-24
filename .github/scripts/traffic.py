#!/usr/bin/env python3
"""Merge GitHub's 14-day traffic windows into a running history (see traffic.yml)."""
import json, os, sys, urllib.request
from datetime import date, timedelta

token, repo, path = os.environ.get("TRAFFIC_TOKEN"), os.environ["REPO"], sys.argv[1]
if not token:
    sys.exit("TRAFFIC_TOKEN is not set: add a fine-grained PAT with Administration: read as a repository secret")

def api(kind):
    req = urllib.request.Request(f"https://api.github.com/repos/{repo}/traffic/{kind}",
                                 headers={"Authorization": f"Bearer {token}", "Accept": "application/vnd.github+json",
                                          "X-GitHub-Api-Version": "2022-11-28", "User-Agent": "traffic-badge"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)

try:
    data = json.load(open(path))
except (FileNotFoundError, ValueError):
    data = {}
history = data.setdefault("history", {"views": {}, "clones": {}})

for kind in ("views", "clones"):
    for day in api(kind)[kind]:
        # the current day is still counting; keep whichever observation is higher
        d = day["timestamp"][:10]
        prev = history[kind].get(d, {"count": 0, "uniques": 0})
        history[kind][d] = {"count": max(prev["count"], day["count"]), "uniques": max(prev["uniques"], day["uniques"])}

cutoff = (date.today() - timedelta(days=14)).isoformat()
for kind in ("views", "clones"):
    days = history[kind]
    data[f"{kind}_total"] = sum(v["count"] for v in days.values())
    data[f"{kind}_14d"] = sum(v["count"] for d, v in days.items() if d >= cutoff)
    data[f"unique_{kind}_14d"] = sum(v["uniques"] for d, v in days.items() if d >= cutoff)
data["since"] = min(history["views"] or [date.today().isoformat()])
data["updated"] = date.today().isoformat()
json.dump(data, open(path, "w"), indent=1, sort_keys=True)
print({k: v for k, v in data.items() if k != "history"})
