"""Slow, persistent harvester for NQT puzzle metadata via PullPush.

PullPush enforces a small per-IP quota, so this runs at ~1 request/40s and
sleeps 5 minutes on 429, retrying each entry up to 8 times before moving on.
Idempotent: already-fetched entries are skipped, so it can be re-run freely.
"""
import json
import os
import sys
import time
import urllib.request

RAW = os.path.join(os.path.dirname(__file__), "..", "data", "puzzles", "raw")
UA = "botc-puzzle-research/0.1 (github alearcm/botc-puzzles; low-volume archive study)"


def fetch(pid: str):
    req = urllib.request.Request(
        f"https://api.pullpush.io/reddit/search/submission/?ids={pid}",
        headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r)


def main():
    entries = json.load(open(os.path.join(RAW, "index_links.json")))
    ok = 0
    for e in entries:
        path = os.path.join(RAW, f"meta_{e['id']}.json")
        if os.path.exists(path):
            ok += 1
            continue
        for attempt in range(8):
            try:
                d = fetch(e["id"])
                posts = d.get("data", [])
                if posts:
                    p = posts[0]
                    mm = p.get("media_metadata") or {}
                    gallery = [((v.get("s") or {}).get("u") or "").replace("&amp;", "&")
                               for v in mm.values()]
                    rec = {**e, "title": p.get("title"),
                           "selftext": p.get("selftext") or "",
                           "url": p.get("url"),
                           "gallery": [g for g in gallery if g],
                           "author": p.get("author"),
                           "created_utc": p.get("created_utc")}
                    json.dump(rec, open(path, "w"), indent=1)
                    ok += 1
                    print(f"ok {e['id']} {e['anchor'][:40]} ({ok})", flush=True)
                else:
                    print(f"empty {e['id']}", flush=True)
                break
            except Exception as ex:
                print(f"retry {e['id']} a{attempt}: {ex}", flush=True)
                time.sleep(300 if "429" in str(ex) else 60)
        time.sleep(40)
    print(f"DONE ok={ok}/{len(entries)}", flush=True)


if __name__ == "__main__":
    main()
