# Review guide

Every PR is reviewed before it is merged (rule in `agent.md`): by PR-Agent
(owner, 22.10.2026), and by a new Claude agent when PR-Agent fails. The
reviewer knows nothing of the session that wrote the change: it gets the
PR's intent, its diff and the repository, and this file. The owner does not read code; this review is the second reader.

## What failure looks like here

Kante is the design system every shrippen GUI is generated from: landing
pages link `https://shrippen.github.io/v1/`, apps copy `qml/Kante`, Kimai
plugins take Knust and the kit. A bug here shows up in every project:

- **Looks wrong everywhere:** a role with the wrong colour or too little
  contrast, a lost cut corner, a focus ring that disappears, text that
  overflows or is cut, a layout that breaks on mobile, Leinen, Kante
  Light or Gold drifting from dark Kante.
- **Breaks the apps:** a QML component that no longer loads, a renamed or
  removed property, class or token that projects use, `KanteStyle` kind
  System no longer looking like plain Kirigami/Plasma, `let` where a `var`
  was read after its block (fails only at runtime).
- **Breaks Kimai:** Knust or the kit out of step with Kante, a raw colour
  in kit CSS, the demo in the Knust zip.
- **Moves without asking:** motion outside the `prefers-reduced-motion:
  no-preference` block, or timings apart from `KanteStyle.motion`.
- **Lies:** README, changelog (`#changes` in `docs/index.html`, every
  language), catalogue or comments that say something the code does not do.

## What to check in particular

- No raw colours or fonts in `css/` (`tools/check-tokens.py`).
- Generated files are committed with their source (`./build.sh`):
  `docs/v1/`, `qml/Kante/KantePalette.qml`, `qml/Kante/qmldir`,
  `qml/KantePlasma/KantePlasmaButton.qml` (from `KanteButton.qml`),
  `tokens/palette.qml`, `kimai/knust/Resources/public/css/knust-palette.css`
  and `kimai/kit/kit/templates/_kit/assets.html.twig` (from kit.css/kit.js).
  A source change without them is a bug.
- New QML component: test in `qml/tests`, `qml/demo/Gallery.qml`, README.
- Release: Kante's version in `docs/index.html`, README section,
  changelog entry with lead, groups and a screenshot or diagram per
  visible change. Knust: tag `knust-v<version>` equal to
  `kimai/knust/composer.json`, `kimai/knust/CHANGELOG.md`, the changelog on
  `docs/knust/index.html`. Kit: `kimai/kit/VERSION`, `kimai/kit/CHANGELOG.md`.
- Bug fixes: does the fix remove the cause, with a test that failed before?

## What the owner confirms here

"What is published" (rule in `agent.md`) means here: a release (Kante
version, a `knust-v*` tag, a kit version), a change to the release
workflows, a new public page under `docs/`. A `docs/v1/` rebuilt from the
sources does not count: it is checked as code like any other change.

## Skip

- `docs/v1/`, the generated files above, `union/colors/`, `union/styles/`
  (check only that they match their source); screenshots, images, fonts.
- `proposals/` catalogue pages, unless the PR is about them.

## How to report

- Every finding names file and line and the concrete input or state that
  goes wrong. No guess without evidence; if unsure, say so.
- Each finding gets one label: **Wichtig** (a bug from the list above,
  must be fixed or answered before the merge), **Kleinigkeit** (optional,
  at most five) or **Bestand** (the bug was there before this PR; not
  blocking).
- The report starts with the count, e.g. "2 Wichtig, 1 Kleinigkeit" (the
  session puts the heading above it). The count of **Wichtig** holds every
  one still open, also from an earlier round, e.g. "1 Wichtig (offen aus
  Runde 1)". Only when none is open it says plainly: "Nichts zu beheben."
- In a later round: say for each open **Wichtig** of the last round whether
  it is fixed, or whether its answer is accepted, with the reason. PR-Agent
  sees no earlier round: it reports only its own findings with their labels,
  and a new Claude agent closes the open ones (`agent.md`).
- Findings in German, code names as they are.
