#!/usr/bin/env python3
"""Download free-exercise-db stretches and their images into www/data/."""
import json
import pathlib
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/"
OUT = pathlib.Path(__file__).resolve().parent / "www" / "data"


def get(path):
    with urllib.request.urlopen(BASE + urllib.parse.quote(path), timeout=60) as r:
        return r.read()


def save_image(path):
    root = (OUT / "images").resolve()
    target = (root / path).resolve()
    if not target.is_relative_to(root) or target.suffix.lower() != ".jpg":
        raise ValueError(f"unexpected image path: {path}")
    if not target.exists():
        data = get("exercises/" + path)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)


stretches = [e for e in json.loads(get("dist/exercises.json")) if e["category"] == "stretching"]
paths = [p for e in stretches for p in e["images"]]
OUT.mkdir(parents=True, exist_ok=True)
with ThreadPoolExecutor(16) as pool:
    list(pool.map(save_image, paths))
(OUT / "exercises.json").write_text(json.dumps(stretches, separators=(",", ":")))
print(f"{len(stretches)} exercises, {len(paths)} images")
