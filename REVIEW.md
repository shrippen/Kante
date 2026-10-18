# Review guide

Every PR is reviewed by a new Claude agent before it is merged (rule in
`agent.md`, owner 18.10.2026). The agent knows nothing of the session that
wrote the change: it gets the PR's intent, its diff and the repository, and
this file. The owner does not read code; this review is the second reader.

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
- Generated files are committed with their source: `./build.sh` output in
  `docs/v1/`, `qml/Kante/KantePalette.qml`, `qmldir`, `tokens/palette.qml`,
  `knust-palette.css`. A source change without them is a bug.
- New QML component: test in `qml/tests`, `qml/demo/Gallery.qml`, README.
- Release: version in `docs/index.html`, README section, changelog entry
  with lead, groups and a screenshot or diagram per visible change.
- Bug fixes: does the fix remove the cause, with a test that failed before?

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
  it is fixed, or whether its answer is accepted, with the reason.
- Findings in German, code names as they are.
