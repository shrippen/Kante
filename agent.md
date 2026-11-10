# Working rules for this repository

The rules for all shrippen repositories are in `RULES.md` (writing, code, commits, bug
fixes, repository, GUI). It is a synced copy from the rules repository; do not edit it
here. This file holds only what is particular to this repository. A Claude Code session on
the owner's machine has the rules through the global `CLAUDE.md` already and reads
`RULES.md` only for its GUI rule, before work on a user interface.

Kante holds the shrippen design system and its Kimai parts:

| Folder | What |
|---|---|
| `/` (tokens, css, js, fonts, qml, templates, tools) | **Kante** and its variants Kante Light and Kante Gold ([README.md](README.md)) |
| `kimai/knust/` | **Knust**, Kante's spinoff for Kimai, a Kimai plugin ([README](kimai/knust/README.md), [PLUGINS.md](kimai/knust/PLUGINS.md)) |
| `kimai/kit/` | **Kimai plugin UI kit** (`kpu-*`), vendored into every Kimai plugin ([README](kimai/kit/README.md), [GUIDELINES.md](kimai/kit/GUIDELINES.md), [agent.md](kimai/kit/agent.md)) |
| `docs/` | GitHub Pages: `docs/index.html` (Kante), `docs/knust/` (Knust), `docs/v1/` (the build every landing page links via `https://shrippen.github.io/v1/`) |

## GUI (this project)

- Kante is the source of every shrippen GUI. Every project generates its GUI from Kante, not inspired by it; see [`AGENT-RULE.md`](AGENT-RULE.md) for the rule as it goes into each project's `agent.md`.
- A missing element is added here first (CSS or QML, README, catalogue in `proposals/`), then used by the projects. Do not let a project solve it locally.
- Kimai plugins are the exception: they use Knust (`kimai/knust/`), Kante's spinoff, and the kit (`kimai/kit/`). Keep Knust's tokens, shapes and roles in step with Kante.
- Kintsugi is the second exception: it uses Kante Gold (`data-kante="gold"`), a variant inside Kante. Gold changes go into the Gold tokens in `tokens/` and the "Kante Gold" block of `css/components.css`.
- No raw colours or fonts in `css/`; `tools/check-tokens.py` enforces it.

## Working here

- Run `./build.sh` after every change and commit the generated files: `docs/v1/`, `qml/Kante/` (`KantePalette.qml`, `qmldir`, `KantePlasmaButton.qml`), `tokens/palette.qml` and `kimai/knust/Resources/public/css/knust-palette.css`. It also runs every check (tokens, QML tests, Knust palette, kit lint) and writes `dist/KnustBundle-<version>.zip`.
- `shrippen.github.io` copies `docs/v1/` in its own build; after a change here run its `./build.sh` too, so `https://shrippen.github.io/v1/` follows.
- Tokens live in `tokens/palette.json` and `variables.css`; they must match (`check-tokens.py`).
- New motion goes into the `prefers-reduced-motion: no-preference` block at the end of `components.css` and follows `KanteStyle.motion` in QML.
- Every new QML component gets a test in `qml/tests` and an entry in `qml/demo/Gallery.qml`.
- QML lint: `tools/qmllint.sh` (also in CI, reports without blocking). Fix a finding here first, then the apps take Kante over.
- **`var` in blocks (review when you touch a file):** Qt 6.12's qmllint reports every `var` inside a block (`block-scope-var-declaration`, about 260 in Kante, October 2026); the rule is off in `tools/qmllint.sh`. The code works as written, so there was no blind switch. When you change a file anyway, switch its `var`s to `let`/`const` there, but check each one first: if the variable is read after its block (or in a closure that relies on the function scope), `let` breaks it at runtime only. Run the QML tests and look at the component in the gallery afterwards. To list a file's cases: `/usr/lib/qt6/bin/qmllint -I qml --json - <file>`.
- Kit changes: `kimai/kit/bin/sync.sh <plugin>` copies the kit into a plugin; `tools/check-kit.sh` lists the plugins next to this repo that are not on the current kit.

## Release

Release steps: `RELEASE.md`. Before a release, load the skill `release-changelog`. A release
is published, so the owner confirms it in words.

## Repository (this project)

- CI runs on the GitHub mirror (`.github/workflows/qml.yml`, since 16.10.2026) and reports back to Gitea as the commit status `github / test`.
- The merge waits for: CI is green on the PR's latest commit: every CI check that runs on each push (such as `github / test` from the GitHub mirror) shows success there. No status there yet means wait, not merge; if it never comes, check the mirror or ask the owner. PR-Agent's status does not count here. Without CI, the local checks count.
- Claude may merge its own PRs on Gitea once CI is green (the QML workflow), `./build.sh` ran clean locally (decision G-07 in Kaiwa) and the review leaves no **Wichtig** open (see the skill `pr-review`).
- Everything else: `RULES.md` (Repository) and the skill `pr-review`.
