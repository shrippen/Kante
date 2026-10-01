# Working rules for this repository

Kante holds the shrippen design system and its Kimai parts:

| Folder | What |
|---|---|
| `/` (tokens, css, js, fonts, qml, templates, tools) | **Kante** and its variants Kante Light and Kante Gold ([README.md](README.md)) |
| `kimai/knust/` | **Knust**, Kante's spinoff for Kimai, a Kimai plugin ([README](kimai/knust/README.md), [PLUGINS.md](kimai/knust/PLUGINS.md)) |
| `kimai/kit/` | **Kimai plugin UI kit** (`kpu-*`), vendored into every Kimai plugin ([README](kimai/kit/README.md), [GUIDELINES.md](kimai/kit/GUIDELINES.md), [agent.md](kimai/kit/agent.md)) |
| `docs/` | GitHub Pages: `docs/index.html` (Kante), `docs/knust/` (Knust), `docs/v1/` (the build every landing page links via `https://shrippen.github.io/v1/`) |

## GUI rule

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
- Kit changes: `kimai/kit/bin/sync.sh <plugin>` copies the kit into a plugin; `tools/check-kit.sh` lists the plugins next to this repo that are not on the current kit.
- Releases: Knust with a tag `knust-v<version>` (equal to `kimai/knust/composer.json`); the workflow attaches the zip. The demo (`kimai/knust/demo/`) never goes into the zip; `tools/knust-zip.sh` aborts if it would.

## Repository rule

- This repository lives on Gitea (`git.arianw.de`). GitHub is only a push mirror of it.
- Changes arrive as pull requests only: work on a branch, open a PR, leave the merge to the owner (who merges on Gitea; the mirror follows).
- Never merge a PR, push to `main` (or any default branch), push tags or publish releases on GitHub. A merge there is overwritten by the next Gitea push.
- Never force-push a branch that someone else's PR depends on.
