# Release steps

Three kinds of release, each in this order. The release log format (all three): a section `## [X.Y.Z] — YYYY-MM-DD` at the top of the CHANGELOG, written before the release; for Kante and Knust with `### English` and `### Deutsch`, each a lead (what the release is about, one or two sentences), the groups New, Improved, Fixed and Note as `####` (Neu, Verbessert, Behoben, Hinweis; breaking changes, steps the user must take; empty groups left out), screenshots or diagrams, and the link to all changes. Each point says what changed for the user and why, not which code moved. CI checks the headings of all three CHANGELOGs on every push (`tools/release-notes.sh --check <file>`).

**Kante version** (no tag, no Gitea or GitHub release, not in `versions.json`):

1. Version `X.Y` (CHANGELOG `X.Y.0`, footer `vX.Y.0`): a README section `### Added in Kante X.Y`, new QML components with their test (`qml/tests/tst_kanteXY.qml`) and gallery entry.
2. Release log in `CHANGELOG.md`; the link to all changes is the README section (`All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-XY`). Read it with `tools/release-notes.sh X.Y.0`.
3. Landing page `docs/index.html`: the same text as a new entry at the top of `#changes` (from the fourth entry on, the oldest move into `details.changelog-more`); bump the footer version. `tools/check-changes.py` (in build.sh and CI) checks both: the entries in view, the footer, and that each lead and point is in the CHANGELOG. Graphics: a screenshot of the changed element (gallery or `tools/specimen.html`) as `docs/shots/release-X.Y-<name>.png`, a diagram for changes inside.
4. `./build.sh`, commit the generated files; PR, review as the skill `pr-review` says; the owner confirms the version in words (it publishes, `REVIEW.md`); CI green; merge on Gitea.
5. `shrippen.github.io`: run its `./build.sh` (copies `docs/v1/`) and merge that via a PR there, so `https://shrippen.github.io/v1/` follows.
6. Done when https://shrippen.github.io/Kante/ shows the version in `#changes` and the footer, and `/v1/` serves the new build. The projects take Kante over in their own PRs.

**Knust** (tag `knust-vX.Y.Z`):

1. Version `X.Y.Z` in `kimai/knust/composer.json` (`version`; the release workflow stops if the tag differs).
2. Release log in `kimai/knust/CHANGELOG.md`. Check it with `tools/release-notes.sh --check kimai/knust/CHANGELOG.md`, read it with `tools/release-notes.sh X.Y.Z kimai/knust/CHANGELOG.md`.
3. Landing page `docs/knust/index.html`: the same text as a new entry at the top of `#changes` (`details.changelog-more` from the fourth entry on), bump the footer version. Screenshots of visible changes from the demo world: `../shrippen.github.io/demo/tools/.venv/bin/python ../shrippen.github.io/demo/tools/screenshots.py kimai-knust` (`kimai/knust/demo/shots.json`, the shared Kimai demo instance); they land in `kimai/knust/docs/shots/`, the page takes them from `docs/knust/shots/` as `release-X.Y.Z-<name>-<lang>.webp`. Screenshots are taken only now, for a tagged release.
4. `./build.sh` (builds `dist/KnustBundle-X.Y.Z.zip`; `tools/knust-zip.sh` aborts if the demo would go in); PR, review, the owner confirms the release in words, CI green, merge on Gitea.
5. Tag the merge commit and push the tag to Gitea only: `git tag -a knust-vX.Y.Z -m "Knust X.Y.Z" <merge commit> && git push origin knust-vX.Y.Z`.
6. Gitea release, notes only, no files: `tools/release-notes.sh X.Y.Z kimai/knust/CHANGELOG.md > notes.md && gt release create knust-vX.Y.Z --repo shrippen/Kante --title "Knust X.Y.Z" --notes-file notes.md --no-input`.
7. GitHub: the tag starts `.github/workflows/knust-release.yml` (version check, PHP lint, palette check, zip, release with the same notes, `KnustBundle-X.Y.Z.zip` attached). Check the run (`gh run list -R shrippen/Kante -w knust-release.yml`) and the zip on the release.
8. No `versions.json` entry: `build-versions.py` skips `knust-v*` tags and pages inside another repo.
9. Live Kimai (regis.lan): deploy `kimai/knust/` as `KnustBundle/` the way the skill `kimai-deploy` (`../regeln/skills/kimai-deploy/SKILL.md`) says, with its excludes, rights, console as `www-data` (`kimai:reload -n`, `kimai:bundle:knust:install`) and checks.
10. Done when https://shrippen.github.io/Kante/knust/ shows the release in `#changes` and the footer, and the live Kimai runs it.

**Kit version** (no tag, no release, no landing page):

1. Version `X.Y.Z` in `kimai/kit/VERSION`.
2. Release log in `kimai/kit/CHANGELOG.md`, German like its other sections (Neu, Geändert, Behoben; `Migration A → B` for what the plugins must change).
3. `./build.sh` (regenerates `kimai/kit/kit/templates/_kit/assets.html.twig`, kit lint); PR, review, the owner confirms the kit version in words, CI green, merge on Gitea.
4. The plugins take it over in their own PRs: `kimai/kit/bin/sync.sh <plugin>`; `tools/check-kit.sh` lists those not on the current kit. Where Knust styles a new marker, Knust gets a release too.
5. Done when merged; the kit is out once `tools/check-kit.sh` shows every plugin on it.

**Release-notes script:** `tools/release-notes.sh` reads release notes from a CHANGELOG (`tools/release-notes.sh X.Y.Z [file]`) and checks its headings (`--check`). Change it only here, with its test `tools/release-notes.test.sh`, then `tools/sync-release-notes.sh --all` (copies it as `scripts/release-notes.sh` into every project next to this repo; `--all --check` shows stale copies) and commit the copies in each project.
