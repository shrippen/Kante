#!/usr/bin/env python3
"""Checks the release list `#changes` of the landing pages (agent.md, release steps).

  - At most three entries in view; the older ones in one `details.changelog-more`, not two
    (a merge of two release branches once left a second one inside the first).
  - The footer names the newest entry's version.

Usage: python3 tools/check-changes.py [page.html ...]   (default: docs/index.html,
docs/knust/index.html; build.sh runs it). Exits 1 on any finding.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAGES = [ROOT / "docs/index.html", ROOT / "docs/knust/index.html"]
IN_VIEW = 3


def check(page: Path) -> list[str]:
    html = page.read_text(encoding="utf-8")
    found = []
    folds = html.count('class="changelog-more"')
    if folds > 1:
        found.append(f"{folds} details.changelog-more, one is enough")
    first_fold = html.find('class="changelog-more"')
    shown = html[: first_fold if first_fold >= 0 else len(html)]
    versions = re.findall(r'<li class="release" id="v([0-9.]+)"', html)
    in_view = len(re.findall(r'<li class="release" id=', shown))
    if in_view > IN_VIEW:
        found.append(f"{in_view} entries in view, at most {IN_VIEW}")
    footer = re.search(r'class="foot-meta">.*?v([0-9.]+)', html)
    if versions and footer and footer.group(1) != versions[0]:
        found.append(f"footer says v{footer.group(1)}, the newest entry is v{versions[0]}")
    return [f"{page.relative_to(ROOT) if page.is_relative_to(ROOT) else page}: {f}" for f in found]


def main() -> int:
    pages = [Path(p).resolve() for p in sys.argv[1:]] or PAGES
    findings = [f for page in pages for f in check(page)]
    for finding in findings:
        print(finding)
    if not findings:
        print(f"check-changes: {len(pages)} pages ok")
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
