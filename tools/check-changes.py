#!/usr/bin/env python3
"""Checks the release list `#changes` of the landing pages (agent.md, release steps).

  - At most three entries in view; the older ones in one `details.changelog-more`, not two
    (a merge of two release branches once left a second one inside the first).
  - The footer names the newest entry's version.
  - Every lead and point says what its CHANGELOG says (markup, code ticks and pictures aside):
    the two once drifted apart when a fix changed only one of them.

Usage: python3 tools/check-changes.py [page.html ...]   (default: docs/index.html,
docs/knust/index.html; build.sh runs it). Exits 1 on any finding.
"""
import html as entities
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAGES = [ROOT / "docs/index.html", ROOT / "docs/knust/index.html"]
LOGS = {
    ROOT / "docs/index.html": ROOT / "CHANGELOG.md",
    ROOT / "docs/knust/index.html": ROOT / "kimai/knust/CHANGELOG.md",
}
IN_VIEW = 3


def plain(text: str) -> str:
    """Text without HTML or Markdown markup, for comparing the two."""
    text = entities.unescape(re.sub(r"<[^>]+>", "", text))
    text = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", text)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = text.replace("`", "").replace("**", "").replace("\u2019", "'")  # the page sets ’
    return re.sub(r"\s+", " ", text).strip()


def drift(html: str, log: Path) -> list[str]:
    """Leads and points of the page that its CHANGELOG does not say so."""
    lines = log.read_text(encoding="utf-8").splitlines()
    points = {plain(line[2:]) for line in lines if line.startswith("- ")}
    leads = {plain(line) for line in lines if line and not line.startswith(("#", "-", "!"))}
    found = []
    entries = re.finditer(
        r'<li class="release" id="v([0-9.]+)">(.*?)</li>\s*(?=<li class="release"|</ol>)', html, re.S
    )
    for entry in entries:
        version, body = entry.groups()
        for point in re.findall(r"<li>(.*?)</li>", body, re.S):
            if plain(point) not in points:
                found.append(f"v{version}: not in {log.name}: {plain(point)[:70]}")
        for lead in re.findall(r'<p class="release-lead"[^>]*>(.*?)</p>', body, re.S):
            if plain(lead) not in leads:
                found.append(f"v{version}: lead not in {log.name}: {plain(lead)[:70]}")
    return found


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
    log = LOGS.get(page)
    if log is not None:
        found += drift(html, log)
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
