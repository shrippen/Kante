# Kante proposals

Design reviews and proposals for Kante, kept as standalone HTML pages. They are not part of the published stylesheet; nothing here is loaded by a landing page or an app.

| Folder | Content |
|---|---|
| [`2026-09-stil/`](2026-09-stil/) | Style audit against the original premise (19.08.) and the Cyberpunk 2077 reference, with eight proposals (colour roles and the new cyan, icon rule, docs, cut corners and brackets, HUD labels, interaction, cream as paper, amber glow and Leinen yellow). `bauteile.html`: every element in the aligned style (buttons, inputs, navigation, display, feedback, surfaces, dark and Leinen) and a motion lab with 22 interaction ideas to rate. `luecken.html`: gap report of the other repos (Andon in detail), 14 missing components as live sketches and five motion ideas for live data. `ergaenzungen.html`: evaluation and decisions after the integration into Andon, Kader, Plasmai, Kurrent and FrameWidge (fixes, 33 new elements, what stays local, what is deferred) |
| [`2026-10-gold/`](2026-10-gold/) | Kante Gold, the noble variant for Kintsugi: principles, palette with contrast values, type, and the Kante 1.10 elements live in Gold (thread, steps with state, page titles, wrapping chips, shimmer, gilded edges, dialog fix), plus two Kintsugi screenshots. A full page (`data-kante="gold"`); rebuild by inlining `docs/v1/shrippen.css` and `shrippen.js` |

The pages were first published as claude.ai artifacts, which add the HTML skeleton themselves. `wrap.py` turns the artifact sources into the standalone files here.
