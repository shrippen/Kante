# Working rules for this repository

## GUI rule

- This folder (`kimai/kit/` in Kante) is the UI kit of the shrippen Kimai plugins (Drehzettel, Holiday, Abrechnung,
  Anfahrten, …). Kimai plugins take their GUI from Knust (`kimai/knust/` in this repo), the
  Kante spinoff that adapts Kante to Kimai's look. Rule text:
  [`AGENT-RULE.md`](../../AGENT-RULE.md)
- The kit says *what* an element is (`kpu-*` markers, macros); Knust decides how it looks
  (Knust `PLUGINS.md`). Use Knust and the kit as they are: no own colours, fonts, sizes, radii,
  shadows, no own copy or variant of a component that Knust or Kante has.
- Kit CSS is a neutral base form: Tabler variables (`var(--tblr-…)`), Knust variables only with
  a fallback (`var(--knust-focus, var(--tblr-primary))`). Raw values (`#hex`, `rgb()`) are a bug;
  `bin/lint.sh` enforces it.
- A missing element is added here first (marker, macro, example, docs), then its look to Knust,
  then it is used in the plugin. Never solve it locally in a plugin and never wait with a
  "temporary" copy. Where it would also help outside Kimai, add it to Kante as well.

## Repository rule

- See the repository rule in [`agent.md`](../../agent.md) at the root of Kante.
