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
- QML lint: `tools/qmllint.sh` (also in CI, reports without blocking). Fix a finding here first, then the apps take Kante over.
- **`var` in blocks (review when you touch a file):** Qt 6.12's qmllint reports every `var` inside a block (`block-scope-var-declaration`, about 260 in Kante, October 2026); the rule is off in `tools/qmllint.sh`. The code works as written, so there was no blind switch. When you change a file anyway, switch its `var`s to `let`/`const` there, but check each one first: if the variable is read after its block (or in a closure that relies on the function scope), `let` breaks it at runtime only. Run the QML tests and look at the component in the gallery afterwards. To list a file's cases: `/usr/lib/qt6/bin/qmllint -I qml --json - <file>`.
- Kit changes: `kimai/kit/bin/sync.sh <plugin>` copies the kit into a plugin; `tools/check-kit.sh` lists the plugins next to this repo that are not on the current kit.
- Releases: Knust with a tag `knust-v<version>` (equal to `kimai/knust/composer.json`); the workflow attaches the zip. The demo (`kimai/knust/demo/`) never goes into the zip; `tools/knust-zip.sh` aborts if it would.

## Repository rule

- This repository lives on Gitea (`git.arianw.de`). GitHub is only a push mirror of it.
- CI runs on the GitHub mirror (`.github/workflows/qml.yml`, since 16.10.2026) and reports back to Gitea as the commit status `github / test`.
- Changes arrive as pull requests: work on a branch, open a PR, merge it on Gitea (the mirror follows).
- Never merge a PR, push to `main` (or any default branch), push tags or publish releases on GitHub. A merge there is overwritten by the next Gitea push.
- Never force-push a branch that someone else's PR depends on.
- Claude may merge its own PRs on Gitea once CI is green (the QML workflow), `./build.sh` ran clean locally (decision G-07 in Kaiwa) and the review leaves no **Wichtig** open (see below).
- Review (all shrippen repositories, owner 18.10. and 22.10.2026): every PR is reviewed before it is merged. The owner does not read code, so this is the second reader.
  - PR-Agent first (owner, 22.10.2026): where `.gitea/workflows/pr-agent.yml` is set up, the session comments `/review` on the PR for each round with new code or a new base (the first one included; a rebase, a merge of the base or a change of the base branch, see below) and waits for PR-Agent's comment. That comment reviews the whole diff and covers the commit that was the PR's head when `/review` was posted. PR-Agent labels its findings as `REVIEW.md` says; a finding without a label counts as **Wichtig**. A run cancelled by a newer `/review` on the same PR (the concurrency group holds the PR number) is replaced, not failed.
  - If PR-Agent fails (the run fails or ends without a review comment, reports a key or cost limit, or no run is created within 10 minutes), the session posts `/review` once more. If that fails too, a new Claude agent reviews the round as below, and the session says in the PR why. Where PR-Agent is not set up, the new Claude agent always reviews.
  - The Claude agent: the session that wrote the PR starts a new agent (Agent tool, no shared context) and gives it only the PR's title and body, the diff against its base (`git diff <base>...HEAD`), the repository and `REVIEW.md`. It does not tell it what it thinks of its own change. The agent checks every finding it would post against the code (file, line, the input that goes wrong) and drops what it cannot show. It reports as `REVIEW.md` says: count first, labels **Wichtig**, **Kleinigkeit**, **Bestand**. The session posts the report unchanged as a PR comment on Gitea. Above it goes the heading `## Claude-Review (neuer Agent) zu <commit>`, below it the footer `---` and `_Generated by [Claude Code](https://claude.ai/code)_`.
  - Each **Wichtig** is fixed, or answered in the PR with a reason.
  - PR-Agent sees no earlier round. So when an earlier round had a **Wichtig** (open or closed), after PR-Agent's comment (or with answers only, alone) a new Claude agent closes the round: it gets the PR's title and body, the repository, `REVIEW.md`, the open **Wichtig** with the answers, PR-Agent's findings of this round, the closed **Wichtig** and how they were closed, and the new commits (`git diff <last reviewed commit>..HEAD`; without new commits, the code at HEAD). It says for each open **Wichtig** whether it is fixed or its answer is accepted, and whether a **Wichtig** PR-Agent raises again is one already closed (fixed, answer accepted or decided by the owner; it stays closed unless the agent shows it is not fixed). Its count holds every **Wichtig** still open, PR-Agent's new ones included. It posts like a review, heading `## Claude-Review (offene Wichtig) zu <commit>`. An answer it does not accept goes to the owner, who decides in words. With the fallback, one new agent does both: the review of the new commits and the open **Wichtig**.
  - After a rebase, a merge of the base or a change of the PR's base branch a new round is due, also without a new commit, against the new base; a Claude agent of that round (closing or fallback) gets the whole diff against the new base (`git diff <base>...HEAD`) in place of the new commits. Every round counts, also one with answers only: after three rounds that still leave a **Wichtig** open, stop and rethink the approach with the owner.
  - Merge only when the last round covers the PR's latest commit against its current base branch (the branch by name; the base moving on alone needs no new round) and leaves no **Wichtig** open (its closing agent's count, or PR-Agent's comment when no earlier round had a **Wichtig**), and CI is green on the PR's latest commit: every CI check that runs on each push (such as `github / test` from the GitHub mirror) shows success there. No status there yet means wait, not merge; if it never comes, check the mirror or ask the owner. PR-Agent's status does not count here. Where CI runs only for some paths, the repository rule says which commits need it. Without CI, the local checks of the merging rule count.
  - Before the merge, the owner confirms in words, not by reading code, a PR that changes CI or release workflows (`.gitea/`, `.github/`, `packaging/`), this review rule (`agent.md`, `REVIEW.md`), secrets or what is published (a release, a tag, a new public page, site or package; rebuilding what is already published does not count).
  - `REVIEW.md` in the repository root says what failure looks like here, what to check in particular, what to skip and how to report. A repository without one gets it in its next PR.
- PR-Agent's status is not a CI check. The owner may post `/review` at any time (PR-Agent takes no other command here); the merge waits for that run and handles its findings like a round's. Owner and session post from the same account, so a run that fails is handled the same whoever posted `/review`: as above, once more, then the fallback.
