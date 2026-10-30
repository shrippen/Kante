#!/usr/bin/env python3
"""Checks the release list `#changes` of the landing pages (agent.md, release steps).

  - At most three entries in view; the older ones in one `details.changelog-more`, not two
    (a merge of two release branches once left a second one inside the first).
  - The footer names the newest entry's version.
  - Each release on the page says what its CHANGELOG section says, lead for lead and point
    for point, both ways (markup, code ticks and pictures aside): the two once drifted apart
    when a fix changed only one of them. The newest release of the CHANGELOG is on the page.

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


def sections(log: Path) -> dict[str, tuple[set[str], set[str]]]:
    """Per version of the CHANGELOG: its points and its leads."""
    found: dict[str, tuple[set[str], set[str]]] = {}
    points: set[str] = set()
    leads: set[str] = set()
    for line in log.read_text(encoding="utf-8").splitlines():
        head = re.match(r"## \[([0-9.]+)\]", line)
        if head:
            points, leads = set(), set()
            found[head.group(1)] = (points, leads)
        elif not found or not line.strip() or line.startswith(("#", "!", "All changes", "Alle Änderungen")):
            continue
        elif line.startswith("- "):
            points.add(plain(line[2:]))
        else:
            leads.add(plain(line))
    return found


def drift(html: str, log: Path) -> list[str]:
    """Where a release on the page and its CHANGELOG section say different things, both ways."""
    logged = sections(log)
    found = []
    # The newest release of the log is on the page (older ones may be told in the README).
    newest = next(iter(logged), None)
    if newest and f'id="v{newest}"' not in html:
        found.append(f"v{newest}, the newest in {log.name}, is not on the page")
    entries = re.finditer(
        r'<li class="release" id="v([0-9.]+)">(.*?)</li>\s*(?=<li class="release"|</ol>)', html, re.S
    )
    for entry in entries:
        version, body = entry.groups()
        if version not in logged:
            found.append(f"v{version}: no section in {log.name}")
            continue
        points, leads = logged[version]
        shown_points = {plain(p) for p in re.findall(r"<li>(.*?)</li>", body, re.S)}
        shown_leads = {plain(p) for p in re.findall(r'<p class="release-lead"[^>]*>(.*?)</p>', body, re.S)}
        for point in sorted(shown_points - points):
            found.append(f"v{version}: not in {log.name}: {point[:70]}")
        for point in sorted(points - shown_points):
            found.append(f"v{version}: not on the page: {point[:70]}")
        for lead in sorted(shown_leads - leads):
            found.append(f"v{version}: lead not in {log.name}: {lead[:70]}")
        for lead in sorted(leads - shown_leads):
            found.append(f"v{version}: lead not on the page: {lead[:70]}")
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
    else:
        found.append("no CHANGELOG known for this page: its text is not compared")
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
