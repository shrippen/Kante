# Rule for every shrippen project: GUIs come from Kante

This is the one rule about GUIs that applies to **all** shrippen repositories. Copy the block below into each project's `agent.md` (or `CLAUDE.md`). The source of truth is this file in [shrippen.github.io](https://github.com/shrippen/shrippen.github.io/blob/main/kante/AGENT-RULE.md); if the two differ, this file wins.

```markdown
## GUI rule

- Every GUI of this project is generated from Kante, not inspired by it: landing pages,
  web apps, Qt Quick / Kirigami apps, Plasma widgets, dialogs, e-mail and print layouts.
  Source: https://github.com/shrippen/shrippen.github.io (`kante/`).
  Web: link `https://shrippen.github.io/v1/shrippen.css` and `shrippen.js`, or vendor them
  unchanged. Apps: copy `kante/qml/Kante` (and `KantePlasma` for Plasma widgets) unchanged.
- Use Kante's tokens, roles, components, classes, QML components and motion as they are.
  No own colours, fonts, sizes, radii, cuts, shadows, animation timings, no own copy or
  variant of a component that Kante has. Raw values (`#hex`, `px` for controls) are a bug;
  use roles (`--primary`, `--focus`, `--warn`, `KanteStyle.*`).
- A missing element is added to Kante first (CSS or QML, docs, catalogue), then used here.
  Never solve it locally in this project and never wait with a "temporary" copy.
- Exception: Kimai plugins take their GUI from Knust (`shrippen/kimai-knust-bundle`), the
  Kante spinoff that adapts Kante to Kimai's look. The same rule applies to Knust: use it
  as it is, and add missing elements to Knust.
- Exception: Kintsugi (`shrippen/kintsugi`) uses Kante Gold (`<html data-kante="gold">`),
  the noble variant defined in Kante itself. The same rule applies: use it as it is, and
  add a missing element or Gold detail to Kante (its Gold block) first. No other project
  uses Kante Gold without a decision recorded here.
- A project without a GUI (library, CLI, scripts) has nothing to do here.
```

## Notes

- **"Generated" means taken over.** Changing how something looks is a change to Kante (then every project gets it), not to the project.
- **Knust** stays a spinoff: it follows Kante's shapes, sizes, roles and motion where Kimai's own style allows and departs from them only to fit Kimai. Elements a Kimai plugin needs that Knust lacks are added to Knust. Where such an element would also help elsewhere, add it to Kante as well.
- **Kante Gold** is not a spinoff: it lives in Kante (tokens, one block in `components.css`) like Kante Light, so Kintsugi gets every Kante change. Gold details that other projects could use (the seam, the thread) are plain Kante components.
- **Checks.** `kante/tools/check-tokens.py` fails on raw colours and fonts in the design system itself; projects should run the same idea over their own CSS and QML (no hex values outside vendored Kante files).
