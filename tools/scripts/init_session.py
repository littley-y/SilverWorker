#!/usr/bin/env python3
"""SessionStart hook — injects AGENTS.md + REVIEWER_PROMPT.md context."""
import os
import sys

sys.stdout.reconfigure(encoding="utf-8")
sys.stderr.reconfigure(encoding="utf-8")

FILES = ["AGENTS.md", "REVIEWER_PROMPT.md"]

for f in FILES:
    if os.path.isfile(f):
        with open(f, "r", encoding="utf-8") as fh:
            print(fh.read())
    else:
        print(f"# {f} not found", file=sys.stderr)
