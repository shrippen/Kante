# Kante

*Paths in this document are relative to the repo root; `./build.sh` builds everything. This repo also holds Knust, Kante's spinoff for Kimai ([`kimai/knust/`](kimai/knust/README.md)), and the Kimai plugin UI kit ([`kimai/kit/`](kimai/kit/README.md)); [`agent.md`](agent.md) has the map. The overview page and the demo data live in [shrippen.github.io](https://github.com/shrippen/shrippen.github.io) (`overview/`, `demo/`), which also serves this repo's `docs/v1/` at `https://shrippen.github.io/v1/`.*

Shared design language for [shrippen](https://github.com/shrippen) projects, **one style for the web and for apps**: the same palette, type, shapes and roles on landing pages (CSS) and in Qt Quick / Kirigami apps and Plasma widgets (QML). The name is the signature shape: every box has its top-right corner cut (*Kante*, edge).

This document defines the **palette, typographic rules, icon style, landing-page layout and app foundation** that make the family feel cohesive. `tokens/palette.json` is the single source for both sides; see [Kante in apps](#kante-in-apps-qt-quick--kirigami).

Gruvbox-inspired, warm, dark-first.

> **Rule for every project.** The GUIs of all shrippen projects are generated from Kante, not inspired by it; a missing element is added to Kante first. Only the Kimai plugins are different: they use Knust, Kante's spinoff for Kimai. The rule text for the projects' `agent.md` is in [`AGENT-RULE.md`](AGENT-RULE.md).

---

## Quick reference

| Token | Hex | Role |
|---|---|---|
| `bg-hard` | `#1d2021` | Deepest background (hero, code blocks) |
| `bg0` | `#282828` | Page / widget background |
| `bg1` | `#3c3836` | Cards, elevated surfaces |
| `bg2` | `#504945` | Borders, dividers, subtle outlines |
| `fg0` | `#fbf1c7` | Primary heading text (sparingly) |
| `fg1` | `#ebdbb2` | Body text |
| `fg2` | `#d5c4a1` | Secondary / muted text |
| `fg3` | `#a89984` | Placeholder, disabled, footer |
| `accent` | `#e8dcc4` | Brand warm-cream (icon fills, hero emphasis) |
| `yellow` | `#fabd2f` | Brand, primary action, selection fill, score |
| `cyan` | `#5ccfc4` | Technical layer: focus, links, data, brackets, info (lines and text, never large fills) |
| `blue` | `#83a598` | Kept for existing assets; roles moved to `cyan` |
| `aqua` | `#8ec07c` | Success, confirm, online |
| `green` | `#b8bb26` | Positive diff, badges |
| `orange` | `#fe8019` | Warning (callout, banner, middle state) |
| `red` | `#fb4934` | Error, destructive, high priority |
| `purple` | `#d3869b` | Tags, categories, decorative |

Use the **neutral** variant (e.g. `#458588` instead of `#83a598`) when the bright version is too loud on dark surfaces. Use the **faded** variant for disabled / pressed states.

See [`tokens/`](tokens/) for CSS custom-properties, QML, and SVG exports.

---

## Palette philosophy

The palette is a **warm-shifted Gruvbox Dark** subset.

- **Background** is Gruvbox `dark0` (`#282828`), not pure black. `bg-hard` (`#1d2021`) is reserved for maximum-depth areas (hero gradients, code blocks).
- **Foreground** is Gruvbox `light1` (`#ebdbb2`) for body and `light0` (`#fbf1c7`) for headings. Never pure white.
- **Brand accent** is `#e8dcc4` — the cream tone already used in the Kurrent icon mark and badges. This is the family's signature: monochrome icon fills and version badges use it.
- **Primary action** is yellow (`--primary`), a fill with dark ink. In Plasma widgets the native `Kirigami.Theme.highlightColor` takes over.
- **Cyan** (`#5ccfc4`) is amber's counterpart and the only colour Kante adds to Gruvbox. Its lightness (59 %) matches yellow (58 %) and red (59 %). Yellow is surface and action, cyan is line, bracket, counter, link and focus. Rough proportion on a page: 80 % warm neutrals, up to 15 % yellow, up to 5 % cyan. Cyan never fills a large area and never glows.
- **One task per colour**, as roles in `tokens/variables.css`: `--primary` (yellow), `--focus`, `--link`, `--info`, `--hl` (cyan), `--warn` (orange), `--danger` (red), aqua for success, purple for tags. Components use the roles, not the colour names.

### Light theme ("Leinen")

Opt-in for apps (not landing pages) via `<html data-theme="light">`, defined in [`tokens/variables.css`](tokens/variables.css). Token names describe **roles, not lightness**: `--bg-void` is always the page ground, `--bg-panel` the cards, `--bg2` the borders, `--fg1` the body text. Switching the theme only swaps values.

| Token | Dark | Light | Role |
|---|---|---|---|
| `bg-void` | `#141312` | `#f0e9d6` | Page ground |
| `bg-panel` | `#2a2826` | `#f7f2e4` | Cards, panels |
| `bg1` | `#3c3836` | `#fbf8ee` | Elevated / fields |
| `bg-hard` | `#1d2021` | `#e6dec6` | Sunk areas, tracks |
| `bg2` | `#504945` | `#d3c8ac` | Borders |
| `fg1` | `#ebdbb2` | `#3c3836` | Body text |
| `fg2` | `#d5c4a1` | `#665c54` | Secondary text |
| `cyan` | `#5ccfc4` | `#0f6b66` | Focus, links, data |
| `primary` | `#fabd2f` | `#fabd2f` | Primary fill (ink `#141312` on both) |
| `aqua` | `#8ec07c` | `#3a6e4e` | Success, bars (Leinen until 2026-10-12 `#427b58`, 4.12:1; now 4.92:1 on the ground, 4.62:1 on sunken areas) |
| `yellow` | `#fabd2f` | `#8a5a00` | Score, warnings |
| `orange` | `#fe8019` | `#af3a03` | Active / highlight |
| `red` | `#fb4934` | `#9d0006` | Error |

The ground sits between Gruvbox `light0` (`#fbf1c7`, too yellow) and `#f5f1e8` (too bright); cards are one step lighter than the ground but never white. **Sand** (`#ebe3cf` ground, `#f4eedd` cards) is the darker alternative. Semantic colors are the darkened counterparts, so all text pairs reach WCAG AA. The role tokens `--field`, `--score` (yellow) and `--hl` (orange) follow the theme. Icon: on light grounds use a dark square (`#3c3836`) with the yellow marks.

### App components (`.tile`, `.stage`, `.band`, `.field`, `.pill`, `.dialog`, …)

Landing pages do not need them; apps do (used by the Kader companion UI). They follow the theme roles (`--field`, `--score`, `--hl`, `--scrim`; in QML also `KanteStyle.tagColor` for topics and tags and `KanteStyle.warningColor` for mild warnings), so they work in the dark default and in the light theme. Image stages stay dark in both themes on purpose (judging colour on a beige ground is misleading); in QML `KanteStyle.stageColor`. Tiers (`data-tier`): green `--aqua`, yellow `--warn` (orange, since 1.13), red `--red`. Colour labels (`data-label="green|yellow|red|blue|purple"` on `.tile`, `.band`, `.strip button`, `.fact`, `.progress-bar > i`) show a named colour that is the data itself, e.g. Kader's groups, which become darktable / Lightroom colour labels: yellow stays yellow. Status is never colour alone. Reference cards live in `ds-bundle/components/App/`. Behaviour (dragging, handles, locking) is the app's job.

### Local theme override rule

> Plasmoids **never hardcode** these hex values for interactive UI. Body text, highlight, selection, buttons, and scrollbars come from `Kirigami.Theme.*`. The shared palette is for **accent elements that survive a theme switch** — icon color fills, priority bands, project/label hashes, and the brand mark in the About/config header.

Landing pages, README badges, social-preview images, and documentation use the full shared palette directly.

> **Exception: the opt-in Kante style in apps.** When a widget or app offers Kante as a style and the user picks it, colours come from `KanteStyle` (`qml/Kante`), generated from the same tokens — never hardcoded in the app. The platform theme stays the default.

---

## Typography

| Context | Stack | Weight | Size guidance |
|---|---|---|---|
| Landing hero heading | `'Rajdhani', var(--font-sans)` | 700 | `clamp(2.2rem, 5vw, 3.4rem)` |
| Section headings (h2, h3) | `'Rajdhani', var(--font-sans)` | 600 | `1.3rem` / `1rem` |
| Feature card headings | `'Rajdhani', var(--font-sans)` | 600 | `1rem` |
| Body | System sans (`-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif`) | 400 | `1rem` / `16px`, line-height `1.6` |
| Code / commands | `'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace` | 400 | `0.85rem` |
| Plasma widget | `Kirigami.Theme.defaultFont` | — | Let Plasma decide |

[Rajdhani](https://fonts.google.com/specimen/Rajdhani) is the shared heading typeface — squared, condensed, slightly futuristic. It loads via Google Fonts (`wght@600;700`) on landing pages. Body text stays on the system sans stack for readability and zero FOUT. Plasma widgets ignore Rajdhani entirely and use `Kirigami.Theme.defaultFont`.

---

## Icon language

All shrippen icons share these constraints:

| Rule | Detail |
|---|---|
| Viewbox | `0 0 24 24` (matches Breeze and most Plasma icon themes) |
| Fill color | `#E8DCC4` (accent cream) for the monochrome "mark" variant |
| Stroke | None for mark variants; if a bicolor icon is needed, stroke `currentColor` with `stroke-width="2"` and `stroke-linecap="round"` / `stroke-linejoin="round"` |
| Shape language | Rounded corners, soft geometry. No sharp 90° intersections unless depicting a clear UI metaphor (checkbox, grid). This is on purpose: **soft signs in hard frames**. Frames, boxes and buttons are sharp with the cut; the icons inside stay soft and make the style friendly. |
| Themed variant | A second SVG that uses `class="ColorScheme-Text"` + `fill="currentColor"` so Plasma icon themes recolor it |

The "mark" (cream on transparent) is for landing pages, social previews, and About sections. The themed variant is the panel/tray icon.

### Naming convention

```
icons/<project>-mark.svg     # fixed cream fill, for web & branding
icons/<project>.svg           # themed, for Plasma icon themes
```

---

## Landing page template

Every project landing page follows the same vertical rhythm:

```
┌──────────────────────────────┐
│         Icon (88px)          │
│        Project Name          │
│     One-line tagline         │
│   [version] [tech] [license] │
│                              │
│  ┌────────────────────────┐  │
│  │  Install one-liner     │  │
│  │  [copy] [download]     │  │
│  └────────────────────────┘  │
│   [Primary CTA] [GitHub]     │
├──────────────────────────────┤
│       Screenshot / demo      │
├──────────────────────────────┤
│   Feature grid (2–3 cols)    │
├──────────────────────────────┤
│   Prerequisites / How it     │
│   works (prose list)         │
├──────────────────────────────┤
│   Changelog (#changes, 1.17) │
├──────────────────────────────┤
│         Footer               │
│  license · author · issues   │
└──────────────────────────────┘
```

### Rule: website material lives in `docs/`

Every project keeps **all screenshots and other material used by its landing page in the `docs/` folder of its own repository**, next to `docs/index.html`. That includes a version of the logo:

```
<project>/docs/
├── index.html
├── icon.svg        ← logo, cream with a yellow accent; used in the nav and as favicon
├── icon-mono.svg   ← the same logo in one colour only (cream)
├── screenshot.jpg  ← screenshots, referenced with relative paths
└── social.png      ← optional social preview (og:image)
```

Every logo comes in two versions: `icon.svg` (cream with the yellow accent) and `icon-mono.svg` (a fully monochrome version, one colour). Recolour the mono file for light backgrounds or print. The pages are served from `docs/` on GitHub Pages, so pages never reference files outside it. If a project has no screenshot yet, the hero shows only the install box.

### CSS variables (shared)

Every landing page imports these variables (or copies them):

```css
:root {
  /* Backgrounds */
  --bg-hard:  #1d2021;
  --bg0:      #282828;
  --bg1:      #3c3836;
  --bg2:      #504945;

  /* Foregrounds */
  --fg0:      #fbf1c7;
  --fg1:      #ebdbb2;
  --fg2:      #d5c4a1;
  --fg3:      #a89984;

  /* Accent */
  --accent:   #e8dcc4;

  /* Semantic */
  --blue:     #83a598;
  --aqua:     #8ec07c;
  --green:    #b8bb26;
  --yellow:   #fabd2f;
  --orange:   #fe8019;
  --red:      #fb4934;
  --purple:   #d3869b;

  /* Layout */
  --max-w:    860px;

  /* Type */
  --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen,
               Ubuntu, Cantarell, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', Consolas, monospace;
}
```

### Rules

- **Background**: `--bg0` for the page, `--bg1` for cards/elevated, `--bg-hard` for hero gradient or code blocks.
- **Text**: `--fg1` body, `--fg0` hero heading only, `--fg2` secondary, `--fg3` footer/placeholders.
- **Links**: `--link` (cyan). **Primary buttons**: `--primary` (yellow) with ink; hover one step lighter (`--yellow-hi`), pressed `--yellow-lo`.
- **Install card**: `--bg1` surface, `--bg2` border, `--bg-hard` inner code box, command text in `--blue`.
- **Copy button**: `--bg2` bg, on success flash `--aqua` border + text for 1.5 s.
- **Icons in feature cards**: inline SVG (`.feat-icon`, 24×24, stroke `currentColor`) — no emojis.
- **Feature grid**: `--bg1` cards, `--bg2` border, `1.2rem` gap, `auto-fit minmax(240px, 1fr)`.
- **Screenshot**: cut corner, `1px --bg1` border, no shadow (`clip-path` would cut it off).
- **Badges**: shields.io with `labelColor=1c1c20` and value color `fabd2f` (version), `5ccfc4` (tech tag), `a89984` (license); on pages prefer `.sticker`.
- **OG image**: dark card on `--bg-hard`, project icon centered, name below in `--fg0`, tagline in `--fg2`.
- **Max content width**: `--max-w` (`860px`). Centered with `margin: 0 auto`.
- **No light mode** for landing pages (matches the dark-first palette). Apps may opt in to the Light theme below; Plasma widgets use whatever the user's Plasma theme provides.
- **Changelog**: every release adds an entry at the top of `#changes` (`.changelog`, 1.17), in every language of the page: a lead, the changes grouped as new, improved, fixed and note (and breaking), and a screenshot or diagram per visible change. Older entries go into `details.changelog-more`.
- **Mobile**: Install command box font shrinks to `0.75rem`, hero padding reduces. Feature grid collapses to 1 col.

---

## Shape, sizes and motion (Kante 1.4)

| Rule | Detail |
|---|---|
| Heights | `--h-s` 32, `--h-m` 40, `--h-l` 48 px for every control (buttons, fields, tabs, segments); below that only `--h-xs` 24 (chips, pills, stickers, inline buttons, toast actions; `--h-s` on touch) and `--h-mark` 20 (counters, hint counts, the help "?") |
| Cut | `--chamfer` 16 px on surfaces, `--cut-m` 10 px on buttons, tiles, tabs, menus, `--cut-s` 6 px on small parts. A second cut bottom-left only on primary and danger buttons, the dialog and the install box |
| Holes | Fields are sunk into the surface and stay rectangular, with a 2 px bottom edge; on focus the edge turns cyan and the field gets `--cyan-tint` |
| Bars | 4 px for state and tier on every surface and bar (edit bar, bulk bar), 2 px for lines, underlines and popups (menu, combo list, help), 1 px for borders |
| Focus | Cyan, 2 px. Outside with a small gap, or inside on cut shapes (`clip-path` cuts an outer ring). Tiles and linked cards show four cyan brackets |
| Markers | Square: pill dots are squares, the radio is a diamond. Round are only icons |
| Titles | `--title-s` (cards, rows, tiles, bars), `--title-m` (blocks, sheets, dialogs, login), `--title-l` (app page); Rajdhani 700 uppercase, `--title-track` |
| Tiers | `green` aqua, `yellow` = warning = `--warn` (orange), `red` danger, `blue`/`cyan` info. The same on every app element: tile, band, strip, progress, tier and hint card, timeline, launch counts, status, callout, toast. In an app yellow is never a warning: it is the primary action; a card or hint that is only emphasised (the main thing on a page, the main kind of hint) is `data-tier="primary"` on `.tier-card` / `.hint-card`. A colour that is the data itself (a colour label) is `data-label`, not a tier. Landing pages: `.feat` and `.fact` tiers are the priority-band rotation (red, yellow, blue), decoration without a state, so their yellow stays yellow |
| Chosen vs marked | **Yellow (`--primary`) is the chosen value of a control**: one of a few (tab, segment, page, radio, ring mark). **Cyan marks entries**: filters, multi-select, list rows, edit mode (mode bar, filter chips, chip pick, option cards, selected rows). Fills that mean "active" use `--primary` with `--on-primary`, never `--yellow` (`tools/check-tokens.py` fails on it) |
| One primary per view | At most one filled primary button per view or dialog. Actions repeated per list item (hint cards, rows) are outline or quiet buttons |
| Buttons | `.btn-accent` (primary), `.btn-outline`, `.btn-danger`, `.btn-data` (cyan, mono), `.btn-quiet`; `.btn-primary` / `.btn-ghost` inside the yellow box; sizes `.btn-sm` / `.btn-lg`, `.btn-icon`, `.btn-group`, `.is-busy` |

**Motion** is warm and mechanical, modelled on devices (keys, tubes, counters, tabs, lamps), never glitch. It lives in one block at the end of `css/components.css` under `prefers-reduced-motion: no-preference`; entrances also need `html.motion`, which `shrippen.js` sets, so without the script nothing is hidden. Durations `--dur-fast` 120, `--dur` 200, `--dur-slow` 450 ms; easings `--ease-out`, `--ease-snap`.

| Idea | Where | How |
|---|---|---|
| Cut grows (A01) | every `.btn` | automatic on hover |
| Stanze (A02) | a big action | wrap in `<span class="press">` |
| Brackets lock on (A03) | `.tile`, `a.feat` | automatic on keyboard focus |
| Scan (A04) | `.hero-shot`, `.showcase figure`, `.shots figure` | automatic when scrolled into view |
| Value changes (L1) | `[data-live]` text, or `Kante.tick(el, text)` | a cyan strip fades behind it, whole numbers count up |
| Fresh data (L2) | `[data-live-tile]` after an htmx swap, or `Kante.fresh(el)` | a 2 px cyan line runs along the **bottom** edge of the tile once |
| Stale data (L3) | `Kante.stale(el, true, "12 min")` (class `.is-stale`) | the tile dims, warning stripes sit on the **bottom** edge with the age above; a state, no motion |
| Edit mode (L4) | `Kante.edit(box, on)` (class `.is-editing`) on a grid of `.tile`, `.feat` or `[data-editable]` | tier bars turn cyan, brackets appear one after the other |
| Drop settles (L5) | `.is-picked`, `.drop-gap`, `.drop-cell`, then `Kante.settle(el, fromRect)` | the dropped element glides into its cell with a small overshoot |
| Segment display (A10) | `.progress-segs > i` (`.on` lights a segment, `--i` staggers them, `data-tier`) | automatic |
| Bar loads (A05) | `.feat` | automatic |
| Counter (A06) | `.fact b` with a number | automatic |
| Teleprinter (A07) | mono labels | add `data-type` |
| Hazard stripes run (A08) | `.banner`, `.btn.is-busy`, `.progress-bar.is-indeterminate` | automatic |
| Tube warms up (A09) | one button per page | wrap in `<span class="tube">` |
| Tab slides (A11) | `.tabs` with `role="tab"` | automatic |
| Toast slides in (A14) | `.toast`, remaining time `.toast-life` (`--life`) | automatic |
| Tick draws (A15) | `.check` with `.check-box` / `.check-dia` | automatic |
| Status lamp (A16) | `.pill[data-state="analyzing"]` breathes; `.led[data-rhythm="puls\|atem\|takt"]` | automatic |
| Cascade (A17) | `.features`, `.tiles` | automatic |
| Switch snaps (A18) | `.switch` | automatic |
| Card lifts the cut (A19) | a whole card as link: `a.feat` | automatic |
| Scroll meter (A20) | cyan line under `.nav` | automatic |
| Running light (A21) | a surface that is working | add `<span class="runner" aria-hidden="true"></span>` |
| Header snaps in (A22) | `.nav-brand` gets a yellow bar | automatic |

The component catalogue and the motion lab with every idea live in [`proposals/2026-09-stil/bauteile.html`](proposals/2026-09-stil/bauteile.html).

---

## Plasma widget rules

A Plasma widget follows the **user's Plasma theme by default**: surfaces, text, buttons, selection and scrollbars come from `Kirigami.Theme.*`, and the shared palette is only for brand elements:

| Element | Source |
|---|---|
| Project/label accent hashes | Deterministic HSL from key (same algorithm), `saturation: 0.62`, `lightness: 0.46` |
| Priority bands | Red / yellow-amber / blue at fixed HSL (see Kurrent `colors.js`) |
| Icon mark fill in About/header | `#E8DCC4` |
| Badge backgrounds (version label) | `#E8DCC4` on `#1c1c20` |
| `PluginMissing` / onboarding | Layout follows landing page install-card pattern (copy button, monospace command, link to GitHub) |

A widget may offer **Kante or Kante Light as opt-in styles** (a "Style: System / Kante / Kante Light" setting, System stays the default). Then it uses the QML module below: with System it looks exactly like a plain Plasma widget, with Kante it breaks with Breeze on purpose. Plasmai is the reference.

---

## Kante in apps (Qt Quick / Kirigami)

`qml/Kante` is the app side of Kante, taken from Plasmai (Plasma widget and Kirigami app for Android / Plasma Mobile). Copy the folder into the project (a Plasma Store package cannot use import paths) or add it to the app's qrc, then `import Kante` (or `import "Kante"`).

`qml/KantePlasma` holds the Plasma widget variants of the wrappers that sit on PlasmaComponents3 instead of QQC2 (`KantePlasmaButton`, `KantePlasmaToolButton`, `KantePlasmaHeading`). They import `"../Kante"`, so copy both folders side by side.

Import the module one way only in a project (all directory imports, or all `import Kante`): Qt registers a directory import and a module import as different types, and `KanteStyle` would exist twice.

```qml
import Kante

Binding { target: KanteStyle; property: "kind"; value: settings.visualStyle }   // 0 System, 1 Kante
KanteScope { target: root.contentItem }          // Kante colours for every Kirigami/QQC2 control below
KanteButton { text: i18n("Stop"); emphasis: KanteButton.Emphasis.Destructive }
QQC2.CheckBox { KanteCheckSkin { control: parent } }
QQC2.RadioButton { KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Radio } }
```

### What the module has

| Part | Purpose |
|---|---|
| `KanteStyle` | Singleton: all colour, font and shape roles. `kind` System and KanteLight forward `Kirigami.Theme` colours; Kante reads `KantePalette` (dark, or "Leinen" when the platform theme is light; `preferDark` forces dark, e.g. Android Material Dark) |
| `KantePalette` | Generated from `tokens/palette.json` (`tools/build-qml.py`), never edited by hand |
| `KanteFocusFollow` | Keeps the keyboard focus in view in a Flickable (1.49) |
| `KanteScope` | Hands the Kante colours to an item's `Kirigami.Theme`, so plain controls below follow. Popups need their own |
| `KanteCard` | Card with the cut corner and an optional accent bar (`chamfer`, `barColor`) |
| `KanteButton`, `KanteToolButton`, `KanteTextField`, `KanteHeading`, `KanteDialog` | Wrappers: the platform control in System; in Kante square, uppercase Rajdhani, sunken fields, accent-filled primary (`emphasis`) |
| `KanteCheckSkin`, `KanteFieldSkin`, `KanteSliderSkin`, `KantePopupSkin`, `KanteMessageSkin`, `KanteDialogSkin`, `KantePageTitle` | Skins placed *inside* an existing control (check box, radio button, switch, combo/spin box, text area, slider, menu, `Kirigami.InlineMessage`, Kirigami dialog, page header). `KanteSliderSkin` follows the slider's `orientation`: with `Qt.Vertical` (a fader) the track runs along the height, filled from the bottom |
| `KantePullToRefresh` | Pull to refresh for a `Kirigami.Page` with a `QQC2.ScrollView` |
| `../KantePlasma` | `KantePlasmaButton`, `KantePlasmaToolButton`, `KantePlasmaHeading`: the same wrappers on PlasmaComponents3 / PlasmaExtras for Plasma widgets |
| `fonts/` | Rajdhani 600/700, JetBrains Mono 400/500 (SIL OFL), loaded by `KanteStyle`, never installed; Bravura (SIL OFL, `OFL-Bravura.txt`), loaded only by the notation components (1.23) |

### Components added in Kante 1.4

Everything from the web catalogue that makes sense in an app, with the same shapes, sizes (32 / 40 / 48 px), 4 px bars, cyan focus and the chosen motion. Pure-drawn components (pill, counter, tab bar, …) draw in every kind with the `KanteStyle` roles, so in System they follow the platform colours and have no cuts and no motion; wrappers and skins still show the platform control in System. `demo/Gallery.qml` shows all of them (`qml -I qml qml/demo/Gallery.qml`); `KantePlasmaButton` is generated from `KanteButton` by `tools/build-qml.py`.

| Component | Purpose | Motion (web idea) |
|---|---|---|
| `KanteButton` | `emphasis` Normal / Primary / Destructive / Data / Quiet, `size` Small / Medium / Large, `busy`, `raised` | cut opens on hover (A01), press 1 px in, `raised` presses into a hard shadow (A02) |
| `KantePolygon`, `KanteCard` | cut shapes; card with `chamferBottom` (double cut) and `interactive` (link card) | card lifts and opens its cut on hover (A19) |
| `KanteBrackets` | four cyan corners that lock onto a target | focus of `KanteTile` (A03) |
| `KanteTextField`, `KanteFieldSkin` | 2 px bottom edge, cyan on focus, `invalid` | colour change |
| `KanteCheckSkin` | box with a drawn tick, diamond with snapping core, snapping switch | A15, A18 |
| `KanteTabBar`, `KanteSegmented`, `KanteSteps` | notched tabs with counters, segmented control, process steps | yellow tab slides (A11) |
| `KantePill`, `KanteCounter`, `KanteSticker`, `KanteLamp`, `KanteHud` | status, counts, paper labels, status lamp, HUD line | breathing / ticking lamp (A16), teleprinter (A07) |
| `KanteOdometer` | mechanical counter | reels roll (A06) |
| `KanteProgressBar`, `KanteLoader`, `KanteSkeleton`, `KanteHazard` | bar, segment display, indeterminate stripes, three squares, placeholder | marching stripes (A08), segments switch on like lamps (A10) |
| `KanteCallout`, `KanteToast`, `KanteBanner`, `KanteEmptyState` | notes, toasts, status banner, empty / offline / plugin-missing state | toast slides in with a life line (A14) |
| `KanteTile`, `KanteRunner` | image tile with tier bar, selection, focus brackets; running light around a working surface | A21 |
| `KanteReveal`, `KanteAppear`, `KanteTube`, `KanteScrollMeter` | scan reveal, lamp-style entrance (cascade), tube glow, scroll meter | A04, A17, A09, A20 |
| `KanteLiveText`, `KanteLiveLine`, `KanteDropZone`, `KanteSettle` | live value with change strip and count-up, the bottom-edge line for fresh and stale data, drag placeholders (gap, cell), drop settle; `KanteTile` gets `fresh()`, `stale`, `editing`, `picked` | L1 to L5 |

Not in QML: the sliding nav brand bar (A22) and the web-only catalogue parts (nav, footer, showcase, faq, code, flow). All motion follows `KanteStyle.motion` (bind it to the app's animation setting) and the platform's animation speed; `KanteStyle.animate` is false in System.

Colours: cyan is `focusColor` and `infoColor`; `selectionColor` is the ground of a selected row or focused field; `accentHoverColor` / `accentPressedColor` step the primary fill; `onStateColor` is the text on a state fill. Leinen now has the same yellow primary fill (ink `#141312`) as the dark theme.

### Added in Kante 1.5 (from the project integrations)

Everything Andon, Kader, Plasmai, Kurrent and FrameWidge had kept locally because Kante lacked it, plus the bugs the integrations found. The evaluation with every decision (built, stays local, deferred) is [`proposals/2026-09-stil/ergaenzungen.html`](proposals/2026-09-stil/ergaenzungen.html).

**Fixes.** Entrances hide only elements that `shrippen.js` marked at load (`data-entrance`), never later inserts; `data-own-lang` on `<html>` switches Kante's language handling off; native `<dialog class="dialog">` is hidden while closed; `.ground-yellow` gives buttons the focus ring of the install box; the nav ground follows the theme; `fonts.css` + `fonts/` for offline apps; QML: `KanteDialogSkin` is a QtObject (no dialog content), non-editable combo boxes are read-only, spin box arrows are drawn, `KanteStyle.scrimColor`.

**Tokens.** `--tint-1/-2/-hl/-hl-2/-warn` (translucent steps for hover, drop targets, selection), `--d1…--d6` (data palette in chart order), `--paper` / `--on-paper`; QML `tint1Color … tintWarnColor`, `dataColor(i)`.

| Element | Web | QML |
|---|---|---|
| Chip (entity, filter) | `.chip`, `.chip-x`, `.chips-row` | `KanteChip` |
| Swatch with origin ring | `.swatch[data-src]`, `.swatch-grid` | `KanteSwatch` |
| Table: numbers, group row, total | `.table .num`, `.group-row`, `tfoot` | – |
| Charts | `.chart`, `.spark`, `.uptime`, `.legend`, `.heat` | `KanteBarChart`, `KanteLineChart`, `KanteSparkline`, `KanteHeatmap` |
| Month grid | `.cal` | `KanteCalendarGrid` |
| KPI with change | `.kpi`, `.delta` | `KanteKpi` |
| Wide KPI with spark line | `.kpi` > `.spark` from 24rem content width on (container query on the `.kpi`): figures left, the line right; the value stays on one line | – |
| Bulk bar | `.bulk-bar` | `KanteBulkBar` |
| Sheet | `.sheet` | `KanteSheetSkin` |
| Drawer over a dialog | `.sheet.is-drawer` in a positioned parent, a `.scrim` right before it; inset on the right, one surface step raised (`--bg1`), cut top left; slides in, `.is-leaving` slides it out | `KanteSheetSkin` with `drawer: true` |
| Setting row | `.setting` | `KanteSettingRow` |
| Day strip | `.day-strip` | `KanteDayStrip` |
| Status light | `.status[data-state]`; `button.status` opens its entry (`aria-pressed="true"` the open one); `a.status` chooses one (`aria-current`, 1.46), `.status-row` lines them up | `KanteStatusLight` |
| Board editor parts | `.tile-add`, `.grip`, `.tile-strip` | – |
| Clock | `.clock` (SVG classes) | `KanteClock` |
| Command palette, link tile | `.palette`, `a.link-tile` | – |
| List row | `.list-row` | `KanteListRow` |
| Map frame and pin | `.map-frame`, `.map-pin` (`[data-state]` ok, warn, bad); a vector map with `js/kante-map.js`: `.map-frame[data-map][data-map-source]` (see below) | – |
| Command line with copy | `.cmd-row.is-plain` | `KanteCommandBox` |
| Toggle button, inline button | `.btn[aria-pressed]`, `.btn-inline` | – |
| Option card, dropdown, toast stack | `.option`, `details.dropdown`, `.toast-stack` | – |
| File input, wrapping label, section label | `.input[type=file]`, `label.field`, `.h-label` | – |
| Dismissible callout with actions | `.callout.has-x` + `.callout-x` | `KanteCallout.dismissible`, `actions` |
| Flow node done, fact tier | `.flow-node.done`, `.fact[data-tier]` | – |
| Pill over an image | `.pill.is-solid` | – |
| Tabs: icons, scrolling, counter kinds | – | `KanteTabBar` (`icons`, `countKinds`, `badges`) |
| Segments: icons, tooltips | – | `KanteSegmented` (`icons`, `tooltips`) |
| Segments in one row over the full width (narrow panels) | `.seg.seg-fill` | `KanteSegmented` (`Layout.fillWidth`) |
| Empty state as a card | – | `KanteEmptyState.barColor` |

Not built: pie charts (use stacked or segment bars), an editing bar on yellow (editing is selection, so cyan). Sun and moon in the day strip came in 1.8.

### Added in Kante 1.6

| Element | Web | QML |
|---|---|---|
| Curve editor (draggable square points, e.g. a fan curve) | `svg.curve[data-editable]` with `.frame .line .pt` (drag or arrow keys, fires `change`) | `KanteCurveEditor` (`points`, `xMin…yMax`, `step`, `monotonic`; double tap adds, Delete removes, `[` `]` pick) |
| Band editor (thresholds with a colour each) | `.band-editor` (`.row`, `.strip`) | `KanteBandEditor` (`bands`, `colors`, `min`, `max`) |
| Hover read-out in the line chart | `.chart-wrap[data-readout]` + `.readout` | `KanteLineChart` (`readout`, `labels`, `unit`, `hoverIndex`) |
| Week view | `.week` (`.col .ev .hr`) | `KanteWeekView` |
| Agenda | `.agenda` (`h4`, `.item`) | `KanteAgenda` |

Not built: a compact segmented menu variant.

### Added in Kante 1.7

Web only, the Andon elements that were missing. Tokens only; the cut corner on boxes; motion in the `prefers-reduced-motion: no-preference` block. Tier names are the ones of `.feat` and `.tile`: `green`, `yellow`, `red`, `blue`/`cyan`.

| Element | Web | QML |
|---|---|---|
| Checkbox chip (multi-select filter) | `label.chip-pick` > `input[type=checkbox]` + `span` (+ `small` count); hollow square off, cyan on | – |
| Collapsible section with title and count | `details.fold` > `summary` (+ `.count`) + `.body`; no script | – |
| Feed (title, source, relative age) | `ul.feed` > `li` > `a`, `.src`, `time`; `.is-compact` for one line | – |
| Tag / mode bar with counts | `.modebar` > `button` or `a` (+ `small`), `aria-pressed` or `aria-current`; scrolls sideways | – |
| Hint with tier, source, "why", actions | `.hint-card[data-tier]` > `header` (`.tier`, source), `.title`, `.due`, `details`, `.actions`; tier = icon shape + text + colour | – |
| Card with tier bar, no click behaviour | `.tier-card[data-tier]` (`h3`, `small`) | – |
| Date block, multi-line dates | `time.date-tile` > `b` (day) + month, weekday | – |
| Deadlines | `ol.timeline` > `li[data-tier]` > `.date-tile`, `.what`, `.state` (state also as text) | – |
| Edit mode bar (save, discard, history) | `.editbar` (`.mode`, `.grow`, buttons); `.is-sticky` top, `.is-fixed` bottom; cyan | – |
| Share dialog rows | `.share` > `.row` (`.subject[data-kind]`, `select`, remove), `.callout-warn`, `.add` | – |
| Login, setup, second factor | `.login-wrap` > `.login` (`.brand`, `h1`, `form`, `.links`, `.is-wide`), `.login-secret`, `input.login-code` (one input drawn as six digit boxes) | – |
| Contrast read-out | `.contrast[data-level=aaa\|aa\|fail]` > `.sample`, `.ratio`, `.badge` | – |
| KPI grid | `.kpi-row` (auto-fit); `.kpi` value size follows the tile width | – |

The KPI value now scales with the tile (`container-type: inline-size`, 1.6 to 2.8 rem), so long amounts fit small tiles. `.table th` stays on one line and the table scrolls inside `.table-wrap`. Fixed edit bars lift the toast stack like `.bulk-bar.is-fixed` (`--bar-h`).

**QML additions (1.7).** `KanteDialogSkin` also replaces the dialog's title strip (uppercase title) and its standard buttons, as `KanteDialog` does; before, the platform's light title strip stayed on the dark card. `KanteCurveEditor`: axis labels at 0, 25, 50, 75 and 100 %, `markers` (`{x, label, color}`, live readings drawn as a rule and a mark on the curve, `valueAt(x)`), and handles in text colour (no data colour, so they never read as a chart series beside the editor). `KanteLineChart`: `axis` labels the scale on the left. `KanteBandEditor`: `pick` opens the `colors` as a row of swatches under the band instead of cycling. `KanteTabBar`: tabs scrolled out of view draw no shape (the software renderer ignores the clip for a `Shape` outside a clipped `Flickable`).

Small additions (1.7): `.chip.is-filter` (cyan instead of purple, for filters), `--login-min-h` (height of `.login-wrap` under an app header), `.editbar.has-menu` (no clip so popovers show).

### Added in Kante 1.8

What Andon, Kurrent, Plasmai and the Kimai plugins still solved locally: a day against daylight and work hours, hours as charts, date / time / search / tag inputs, the tile tool band, stored fold state, and denser rows. Pie charts stay out (use stacked bars).

| Element | Web | QML |
|---|---|---|
| Day strip: segment colour | `.day-strip > i` with `--c` | `KanteDayStrip` `segments[].color` |
| Day strip: all-day events | `.day-allday` right before the `.day-strip`, one `span` per event (name; `--c` replaces cyan) | `KanteDayStrip` `allDay` ({title, color}) |
| Day strip: daylight, sun and moon, work hours | `.day-strip.has-sky` > `.day` (first child), `.sun`, `.moon`; `.has-work` > `.work` | `sunrise`, `sunset`, `workFrom`, `workTo`; roles `daylightColor`, `sunColor`, `moonColor`, `workBandColor` |
| Stacked bars with own colours, hours axis | `.chart .c` (`--c`), `.chart .axis` (labels as h:mm) | `KanteBarChart` `stackColors`, `axis`, `valueFormat: KanteBarChart.ValueFormat.Hours`, `formatter`, `unit` |
| Week of hours (days as rows over 0–24 h) | `.week-line` > `.scale`, `b` (`.today`), `.track` > `i` (`--from`, `--to`, `--c`) + `.now` (`--at`), `small` (sum, `.is-zero`) | `KanteWeekTimeline` (`entries` {day, start, end, color, title}, `totals`, `today`, `now`, `entryClicked`, `readout`, `hoverIndex`: hover read-out with title, span and duration) |
| Date and time input | `input.input.date-field` (`type=date` / `time`, native picker) | `KanteDateField` (`date`, `format`, `dateEdited`), `KanteTimeField` (`hour`, `minute`, `minuteStep`, `timeEdited`): typed input and a popup picker (`KanteCalendarGrid`, hour and minute cells) |
| Filterable combo | `.combo-search` (`.has-colors`) > `input.input[role=combobox][aria-expanded]` + `ul[role=listbox]` > `li[role=option]` (`aria-selected`, `--c`, `.is-new`) | `KanteSearchCombo` (`model`, `textRole`, `colorRole`, `allowNew`, `exclude`, `activated`, `newEntered`) |
| Tags as chips with search | – (chips + `.combo-search`) | `KanteTagPicker` (`tags`, `suggestions` as strings or {name, color}, `allowNew`, `edited(tags)`; Backspace removes the last) |
| Tile tool strip in edit mode | `.has-tools` (the slot, reserves the band) > `.tile-tools` (`.grip`, `small`, `.gap`, buttons, `[aria-pressed]`, `.is-danger`); shows on hover / focus / `.is-active` / `.is-floating`, always on touch (40 px); only its buttons and links take the pointer, the rest lets it through so the tile can be dragged by its band | – |
| Stored fold state | `details.fold[data-key]` + `data-open`: `shrippen.js` sets the fold from `data-open` (load, htmx swaps) and fires `kante:fold` {key, open} on every change; `Kante.folds(root)` re-applies | – |
| Toasts under a covered bar | `[data-covers-bar]` on an overlay or sheet: while present and not `[hidden]` (a `<dialog>` only while open) the fixed bars no longer lift the toast stack | – |
| Map and entity roles | `--map-marker`, `--map-route`, `--entity-fallback` | `mapMarkerColor`, `mapRouteColor`, `entityFallbackColor` |
| Chip: dark colours, icon, compact, narrow, touch | – | `KanteChip` `nearGround` (a #202020 chip keeps a visible frame and ink), `iconName`, `compact` (colour square + tooltip), a narrow chip elides and then drops the name, the × has a 32-unit target and an accessible name (`removeText`) |
| Swatch sizes | – | `KanteSwatch` `size`: `Dense` 10, `Small` 14, `Normal` 18 |
| List row: two lines, time, badge, states | – | `KanteListRow` `subtitle`, `leadingText` / `leadingWidth`, `count` (cyan when selected), `density` (Compact / Normal / Comfortable = 32 / 40 / 48), `rule`, `focusOnClick`, `dropTarget`, `pressed`, `disabledReason` (a second line: a disabled item gets no hover, so no tooltip), `activate()` |
| Setting row: narrow, shared column, section | – | `KanteSettingRow` `narrow` (default below 360 units), `titleWidth` + `implicitTitleWidth` (one column line, like `Kirigami.FormLayout`), `section` |

Fixes (1.8): `KanteCallout` gives no room to an action row whose actions are all hidden (`hasActions`). `KanteSearchCombo` selects the text on focus, so typing replaces the entry.

In System the new inputs stay platform text fields and tool buttons; popups keep the platform ground, the cells and rows draw in the `KanteStyle` roles. Not built: a separate `KanteListRowSkin` for existing delegates (the row covers the cases), a web tag picker (chips plus `.combo-search`), hover tooltips on disabled rows.

### Added in Kante 1.9

What the apps reported after 1.8: popups that left the window, a 12-hour clock, grouped project lists, read-outs on bar charts, list rows inside delegates, filter chips as links, stretched charts, daily goals in the heat map, Andon's start page parts (launch tiles, search, clock, weather, drop tray, legend marks) and a few phone fixes.

| Element | Web | QML |
|---|---|---|
| Popups stay inside the window | – | `KanteStyle.popupPlace(anchor, w, h, above)` → {x, y, above, room}: below the field, above when there is no room below, shifted left at the right edge. Used by `KanteDateField`, `KanteTimeField`, `KanteSearchCombo`, `KanteTagPicker`; `popupAbove` (undefined = choose, true / false force) |
| Open and close from code | – | `KanteDateField` / `KanteTimeField` `open()`, `close()`; `KanteSearchCombo` `openList()`, `close()` (ends the filter) |
| 12-hour clock | – | `KanteTimeField` `twelveHour` (default: the locale's short time format has AM/PM), `amText`, `pmText`; shows "9:30 PM", 12 hour cells with an AM / PM switch; reads "9:30 pm", "9p", "12 am", and 24 h times in either mode |
| Grouped combo list | – | `KanteSearchCombo` `sectionRole` (a heading over the first row of each section, kept while filtering), `popupAnchor` (the item the list opens above or below; a tag picker hands its whole box), the list height capped to the free room |
| Tag suggestions in colour | – | `KanteTagPicker` suggestions show their colour square; the field fills the rest of the chips' line |
| Bar chart read-out | – | `KanteBarChart` `readout` (default on), `hoverIndex`, `hoverPart`, `partNames`: a band behind the bar, the part framed cyan, a box with the label, every part and the total (Σ); the lines in the text colour, each with a square in its part's colour (also in the `KanteLineChart` read-out) |
| List row: error count, trailing items, inside a delegate | – | `KanteListRow` `countKind: KanteListRow.CountKind.Error` (red badge), `trailing` (e.g. a chevron `Kirigami.Icon`); the tap is seen passively, so an `ItemDelegate` or `MouseArea` below still gets `clicked` |
| Chips as links, filter tiers | `a.chip` (never underlined), `.chip.is-filter[data-tier="critical"]` red, `[data-tier="warn"]` orange | – |
| Stretched charts | `preserveAspectRatio="none"`: `.chart .line`, `.grid`, `.goal`, `.spark path` keep their width (`vector-effect`); spark end mark as `<path class="end" d="M x y h0">` stays square; `--chart-text` sets the label size in viewBox units | – |
| Last period, limit line | `.chart .bar.is-prev` (dashed outline, no fill; the series colour if it has one), `.chart .goal.is-danger` (red) | – |
| Heat map goals, legend, columns | `.heat i.met` (aqua bar: goal reached), `i.under` (orange: missed); `.heat[style="--rows:7"]` fills column by column; `.heat-legend` > `span`, `i[data-l]`, `i.met`, `i.under` | – |
| Colour input | `input[type=color]`: a square swatch in the field frame | – |
| Page head | `.page-head` (title with its actions, space before the first card); `main > h1 + .card`/`.panel`/… also get the space | – |
| Launch tile | `.launch` > `.launch-icon` (`img`, `img.is-glyph`, `.emoji`, `.monogram`), `.launch-body` > `.launch-title` (`small` host), `.launch-desc`, `.launch-tags`, `.launch-live` > `.launch-state[data-state=ok\|warn\|bad\|off]`, `.launch-info` (`.is-error`), `.launch-hints[data-tier=yellow\|red]`; `.launch-key` (kbd); `.is-first` (Enter opens it); `--c` tints bar and monogram. `data-size="small"` (one line) or `"large"` (icon tile) on the tile or its `.launch-grid` (`--cols`, else fills by `--tile`). Shares its surface with `a.link-tile`, the short form | – |
| Search field | `label.search` > `input`, `span.engine` (shown while typing: where Enter goes), `kbd` hotkey (hidden while focused and on phones); `.search-empty` | – |
| Clock and weather | `.clock-zones` > `.clock-zone` (`small` place, `strong` time, `span` date; a `.clock` face goes left), `.weather` (`b` temperature, `span` condition, `small` place, optional icon), `ol.weather-days`, `.rain-cols > i[style="--h:40%"]`; Rajdhani with tabular digits | – |
| Legend marks, chart labels | `.legend i.prev` (dashed outline), `i.goal` (`.is-danger`), `i.window` (a highlighted span, `--c`), `i.now`; in the chart `.window`, `.now`, `text.bar-value` above a bar (`.is-in` inside it) | – |
| Drop tray | `.dropzone` (items wrap inside; `.hint` only while empty), `.is-armed` while a drag runs, `.is-over` under the pointer; `.drop` stays the file drop, `.drop-gap`/`.drop-cell` the placeholders (QML `KanteDropZone`) | – |
| Change with a direction of good | `.delta[data-good="down"]` (costs, errors: rising red, falling aqua), `[data-good="none"]` (arrow only, no colour); default stays up = good | `KanteKpi.good` (1 up, -1 down, 0 none) |
| Knust palette (Kimai theme) | `v1/knust-palette.css`: Kante's colours, roles, tints, data palette, map roles and the grey scale as Knust's `--shr-*` (+ `-rgb`), dark on `[data-bs-theme=dark]`, Leinen on `[data-bs-theme=light]`; generated by `tools/build-knust.py`, `build.sh` copies it into `kimai/knust/` | – |

Fixes (1.9): check box, radio and switch labels take the Kante text colour through `KanteCheckSkin` (Kante dark on a Breeze Light desktop drew near-black labels on the dark ground). `KanteHeading { pageTitle: true }` sizes itself for the Rajdhani title (it was elided to "KA…" under the Plasma style). `KanteSticker` keeps dark ink on the cream paper off Kante on a dark scheme. Web: `.toast-stack` adds `env(safe-area-inset-bottom)`; `.share > .add` wraps its field onto its own line when narrow; pills in `.tile` and `.tile-badges` end with an ellipsis; `.date-tile` never breaks (the year stays on the line). The `hidden` attribute wins over every Kante display rule (`[hidden]{display:none!important}` in `base.css`); `.feed`, `.timeline`, `.agenda`, `.legend`, `.menu` and `.steps` reset their own list margin and padding; a floating `.tile-tools` outside `.has-tools` gets a band height (32 px, 40 px on touch).

Tested with the real Plasma style (`org.kde.desktop`, Breeze Light and Breeze Dark) as well as plain Kirigami. The Gallery sits in a `KanteScope`, as an app does.

### Kante 1.9.1 (readability review)

| Change | Web | QML |
|---|---|---|
| Red as small text reads at 4.5:1 on every ground | `--danger-text` (`--red-text`: `#ff7d6b` dark, red on Leinen); critical `.hint-card .tier` and critical filter chips use it | – |
| Launch tile counters by shape | `.launch-hints` with a marker: square info, diamond warning, triangle critical | – |
| Fold state by shape, not only colour | `.fold` closed: outlined marker; open: filled cyan | – |
| Hero watermark never widens the page | `.hero:has(>.hero-wm){overflow-x:clip}` | – |
| Accent text on the platform colours | – | `KanteStyle.accentTextColor` in System / Kante Light lifts the system accent's lightness until it reads at 4.5:1 (`readable()`, `contrastOf()`) |
| Empty check box, radio and switch edge | – | `KanteCheckSkin` draws it in `mutedTextColor` (was `frameColor`, 1.5:1) |
| Line chart axis | – | `KanteLineChart` with `axis` rounds the scale to 1-2-5 steps and formats with `Qt.locale()` |
| Dense list rows | – | `KanteListRow.Density.Dense` (24 px): opt-in for long navigation lists only, below the control heights |
| Checked segment in a Plasma widget | – | `KantePlasmaToolButton` checked: sunken tint plus a 3 px accent bar (the accent fill needed dark text that Plasma's runtime did not pass to the label) |

Fixes: no binding loop in `KanteFieldSkin` (spin box text colour).

### Added in Kante 1.10

What Kintsugi and Hansei needed for their conversations, setup and app pages, plus Kante Gold. Catalogue: [`proposals/2026-10-gold/`](proposals/2026-10-gold/).

| Element | Web | QML |
|---|---|---|
| Conversation | `.thread` > `.msg[data-from="ai"\|"me"]` > `header` (who, time) + text; the other side left with an info bar, the reader right with the primary bar | `KanteMessage` (`from` Other / Own / System, `author`, `time`, `text`, `head` items, children under the text, `ownIndent`) |
| App page titles | `h1.page-title`, `h2.block-title` (Rajdhani, in Gold Spectral) | `KantePageTitle` |
| Steps with state | `.steps > li.is-done` (ticked), `li[aria-current="step"]`; `.steps.is-row` in one line (setup wizards) | – |
| Current page in the nav | `.nav-links a[aria-current="page"]` (primary underline) | – |
| Long chips | `.chip` never wider than its row; `.chip.is-wrap` breaks onto more lines | – |
| Seam | `.seam` (a drawn gold line that mends a break), `.seam.is-short` under titles, `.nav > .seam` under the nav | – |
| Control font | `--font-control` (buttons, file button); equals `--font-heading` except in Gold | – |
| Section label | `.h-label` | `KanteSectionLabel` (`rule` adds the line) |
| Bar sparkline | – | `KanteBarChart.compact` (no grid or labels, read-out above) |
| Stacked progress | several `.progress-bar > i` | `KanteProgressBar.parts` ([{value, color}]) |
| Chip as a label, own tooltip | – | `KanteChip.interactive: false`, `toolTip`, `hovered` |

Fixes (1.10): `KanteDialogSkin` no longer elides the title (with Kirigami 6.24 an elided title made a binding loop on the dialog size; a title wider than the dialog is clipped); in Gold the sliding tab indicator is the 2 px underline; `dialog.dialog` keeps its top bar (`border:0` removed it); `.kpi-row` tiles go down to 150 px, so four figures sit two by two on a phone.

### Added in Kante 1.11

What the Leuchtfeuer web interface needed to become friendlier (fewer free-text fields, one save bar, phone use). Catalogue: [`proposals/2026-10-leuchtfeuer/`](proposals/2026-10-leuchtfeuer/).

| Element | Web | QML |
|---|---|---|
| App bar for phones | `.bottom-nav` > `a`/`button` (icon + label), `[aria-current="page"]`; only below 640 px, a last `details.dropdown` > `.menu` opens more pages; moves `.toast-stack` and `.editbar.is-fixed` above itself | – |
| Help | `details.help` > `summary` ("?", with `aria-label`) + `.help-text`; `.is-right` opens to the left | – |
| Toast with an action | `.toast` > `.toast-action` (e.g. Undo) | – |
| Screen-reader only | `.sr-only` | – |
| Ring picker | `.ring-pick` (`--n` marks, default 12, `--r` radius) > `button[role="radio"][aria-checked][style="--i:k"]`, mark 0 on top, clockwise; `.ring-pick-n` in the middle | – |

The save bar of an app with many settings is the existing `.editbar` (`.mode` text, `.grow`, Discard, Save) with `.is-fixed`; advanced settings fold away in the existing `details.fold`.

Fixes (1.11): `.seg button` and `.switch` show the cyan focus ring on keyboard focus (they had none); on touch screens (`pointer: coarse`) `.chip` takes the small control height `--h-s`.

### Added in Kante 1.12

What Andon's boards needed: a fast uptime strip, and a detail dialog per link tile with its history. Catalogue: [`proposals/2026-10-andon/`](proposals/2026-10-andon/).

| Element | Web | QML |
|---|---|---|
| Uptime strip | `svg.uptime` (`viewBox="0 0 <days> 1"`, `preserveAspectRatio="none"`) > one `path[data-state="ok"\|"warn"\|"bad"\|"off"]` per state with a column `M<i> 0h.7v1h-.7z` per day; states as `.status`; summary in `aria-label`/`title` | – |
| Stacked check columns | `svg.uptime` with `viewBox="0 0 <days> 100"`: per day a `path[data-state="ok"]` column with `path[data-state="bad"]` on top | – |
| Day picker | `.chart-wrap` > chart + `.day-pick` > one `button[aria-pressed]` per day column (focus frame on the chosen day) | – |
| Detail button on a link tile | `.launch-live` > `.launch-trend` > `svg.uptime` + `.launch-detail` (icon, `role="button"`, `tabindex="0"`; a span, as the tile is a link) | – |
| Wide link tile | `.launch-live` > `.launch-wide` (`svg.spark`, `.launch-info`): the right half of a `.launch` from 24rem content width on (container query), hidden below; the text keeps the left half | – |

### Added in Kante 1.13 (coherence review)

The review after 1.5 to 1.12 found the shapes coherent and the meaning of colours drifting. Record: [`proposals/2026-10-kohaerenz/`](proposals/2026-10-kohaerenz/) (frozen with the 1.12 stylesheet). Every web element is on `tools/specimen.html`; `build.sh` renders it in dark, Leinen, Kante Light and Gold at 1200 and 390 px (`tools/shoot-specimen.py` → `dist/specimen/`, with `$KANTE_PY` or the shrippen.github.io demo venv). **A new element is done when it looks right in all four.**

| Change | Web | QML |
|---|---|---|
| Colour labels | `data-label` on `.tile`, `.band`, `.strip button`, `.fact`, `.progress-bar > i`: the named colour as data (Kader's green / yellow / red groups) | – |
| Warning is orange in every app element | `data-tier="yellow"` on `.tile`, `.band`, `.strip`, `.progress-bar > i`, `.tier-card`, `.hint-card`, `.timeline` → `--warn` (landing `.feat` / `.fact` bands stay yellow); `data-tier="primary"` on `.tier-card` / `.hint-card` for emphasis; `.pill[data-state="reviewing"]` → `--info` (a state, not a warning) | `KanteTile.Tier.Check` → `warningColor` |
| Active fills by role | `.tabs`, `.tabs-ind`, `.pager`, `.count`, `.loader`, `.runner`, typing cursor, `.lang` → `--primary` / `--on-primary` (in Leinen they were brown, in Kante Light orange) | – |
| One filter chip | `.chip.is-filter` reads like `.chip-pick`: hollow square when off (`aria-pressed="false"`, or a filter link), filled square on a tint when pressed (no full fill); chips without a state (actions, suggestions) keep the filled square | – |
| Sizes | tokens `--h-xs`, `--h-mark`; `.chip`, `.chip-pick`, `.pill`, `.sticker`, `.btn-inline`, `.toast-action` at 24, `.count`, `.launch-hints`, `.launch-detail`, `details.help` at 20; bulk and edit bar 4 px, menu, combo list and help 2 px; toast cut `--cut-m` | – |
| Title scale | tokens `--title-s/-m/-l`, `--title-track` for card, block, dialog, sheet, login and page titles | – |
| Option card frame | border plus drawn diagonal (as `.btn-outline`), follows the cut | – |
| Kante Light | the 1.5–1.12 parts too: card titles in the system font, tabs, mode bar, pager, chips, chip pick, toast action in the system font with a small radius, round help | – |
| Kante Gold | gilded cut and 2 px bars also on `.launch`, `a.link-tile`, `.option`, `.editbar`, `.bulk-bar`, `.toast`; 2 px timeline bar | – |

### Added in Kante 1.14

What Andon's detail views needed: one dialog frame for every tile, with layouts that come from what the body holds, so a new layout is a new combination and not a new component. Catalogue: [`proposals/2026-10-andon/detail.html`](proposals/2026-10-andon/detail.html).

```
dialog.dialog.detail
  header.detail-head      icon · .detail-name (h3 + .detail-sub) · .launch-state · actions · close
  div.detail-line         facts as one line (optional)
  div.detail-body         columns follow from the children:
    aside.detail-side + section.detail-main            record (facts left)
    nav.detail-list + section.detail-main              list and detail
    section.detail-main + aside.detail-side.is-end     large view
    section.detail-main                                timeline, grid, wall, tabs, tasks
```

| Element | Web | QML |
|---|---|---|
| Detail dialog | `dialog.dialog.detail` (wide, no padding, scrolls inside); `.detail-head` with `.launch-icon`, `.detail-name` > `h3` + `.detail-sub`, `.launch-state`, buttons, `.btn-icon` close | – |
| Facts line | `.detail-line` > `span` > `small` (label) + `b` (value) | – |
| Body and columns | `.detail-body` > `.detail-side` (start) / `.detail-list` (start, `.list-row`s; `button.list-row` when a row opens its entry) / `.detail-main` / `.detail-side.is-end`; one column below 60rem | – |
| Blocks | `.detail-block` > `.h-label.detail-label` (text left, meta right) + content; `.detail-facts` (row of `.fact`); `.detail-hero` (taller chart; a block's chart or `.chart-wrap` is 8rem, a hero's 13rem); `.detail-ticks`; `.detail-pair` (two columns) | – |
| Chosen day | `.sheet.detail-day` > `.detail-day-head` (`h3` + `.launch-state`) + `.kpi-row` | – |
| Rows | `.detail-rows`: name, `svg.uptime` or `.progress-bar`, value, three cells per row | – |
| Block label | `.detail-label` > `span` (label), `span` (meta) or `a` (a download, e.g. CSV) | – |
| Form in a block | `.detail-block` > `form` > `.field` (label + `.input` / `.select` / `textarea.input`) …, `.btn` | – |
| Wall of figures | `.detail-wall` > `.detail-card[data-tier]` > `span` (label), `b` (value), `svg.spark`, `small`; `--c` gives a card its own colour (a customer's) | – |
| Tasks | `.detail-progress` (`.progress-bar` + count), `.detail-tasks` > `.detail-task[.is-done]` > `.led`, `span` (text + `small`), action button | – |
| Heatmap of a year | `.heat.is-weeks`: one column per week, days in order, Monday on top | – |
| Reading text, picture, waiting | `.detail-read` (large view text: `h3`, paragraphs); `figure.detail-figure` > `img` or `iframe` (an embedded page, 70 % of the screen high) + `figcaption`; `.detail-thumbs` lays figures out as small thumbnails; `.detail-wait` > `.loader` while the content loads | – |
| Map | `.map-frame[data-map]` with `js/kante-map.js`: a Protomaps basemap drawn by MapLibre GL in Kante's colours (read from the tokens, so it follows the theme), route in `--map-route`, `.map-pin`s; `data-map-source` is a `.pmtiles` file, a TileJSON URL or a MapLibre style URL (Protomaps API; of a style only its vector source is used). The script loads `map/` (MapLibre, pmtiles, basemaps; BSD-3) on first use; glyphs and sprites come from protomaps.github.io. `Kante.map.mount(root)` for frames added later | – |
| Columns in a frame, cells in a state colour | `.chart-wrap > svg.uptime` fills the frame (stacked check columns); `.table td[data-state="ok"\|"warn"\|"bad"]` colours the text | – |
| Opening it | `.launch-detail` (1.12) opens the dialog from any tile: a span inside a link tile, a `button.launch-detail` in a card title | – |
| Settings with levels | `.settings` > `nav.settings-nav` (`.h-label` per group, `a` per page, `aria-current="page"`, a `.count` right) + `.settings-main`; nav sticky; below 48rem one column, the page above the nav | – |
| Before and after | `.table.diff`: one row per field, `td.was` (struck through), `td.now` (marked like `.is-changed`), `td.same` (`colspan="2"`, unchanged) | – |
| Record on a page | `.dialog.detail.is-page`: the detail frame in the page flow, full width, no own scroll (a settings record instead of a popup); `nav.tabs.detail-tabs` under the head, one `a` per tab with `aria-current="page"` | – |
| Row of buttons | `.btn-row`: buttons (and forms with one button each) on one line, centred; in a table cell the whole row centres vertically | – |
| Board card | `.board-grid` > `.board-card` (`.is-start` primary bar, `.is-off` dimmed) > `.grip`, `.plan` (one `div` per section, `--cols`; one `i` per tile, `--w`/`--h` its span, `data-tier` its state), `.board-body` > `.board-name` (`a` + `.pill`), `.board-meta` (`.is-warn`), `.board-foot` (switch, button, menu); `.board-add` is the dashed card that adds one | – |
| Topic icon | `span.topic-icon[data-topic]` before a group name: `overview`, `work`, `analysis`, `homelab`, `network`, `security`, `media`, `home`, `world`, `dev`, `links`; line icon in the text colour, sized by `font-size` | – |
| Field in a menu | `.menu .select` / `.menu .input`: full width with the menu's inset, e.g. a target picker above its button | – |
| Menu in a table row | `details.dropdown` in a `.table-wrap` cell: while it is open the frame drops its cut and scroll box, so the menu shows in full | – |


### Added in Kante 1.15

Readable charts: every chart has an axis or a legend, and in a popup a value on hover. Catalogue: [`proposals/2026-10-andon/charts.html`](proposals/2026-10-andon/charts.html).

| Element | Web | QML |
|---|---|---|
| Value axis beside a stretched chart | `.chart-frame` > `.chart-axis` (labels top to bottom, e.g. max, half, 0; a first `span.unit` names the unit) + `svg.chart` or `.chart-wrap`. HTML, because SVG text distorts under `preserveAspectRatio="none"`; in a `.detail-block` the frame takes the chart's height | `KanteLineChart.axis` (1.7) |
| Row labels | `.chart-axis.is-rows`: one label centred per row, e.g. the weekdays beside a `.heat` in a `.chart-frame` | – |
| Read-out of single elements | `data-tip="Label · value"` on any bar, cell or strip inside `.chart-wrap[data-readout]`; the `.readout` shows the label above the value | – |
| Read-out of path lines | `.chart-wrap[data-readout]` also reads `path.line` (`M`/`L` points), not only `polyline.line` | – |
| Values with decimal commas | `data-labels` / `data-values` split on `\|` when they contain one (`"1,5\|2,25"`), else on `,` | – |

The read-out is delegated: charts added after load (a dialog fetched by htmx) read out without a mount call.

### Added in Kante 1.16

| Element | Web | QML |
|---|---|---|
| Sub-links of a launch tile | `ul.launch-items` right after the `.launch` (not inside the link), `li` > `a` (optional `img` icon, then the title); indented to the tile title, mono, wraps | – |

### Added in Kante 1.17

A changelog on the landing page: every release with what it brought and pictures of it. Catalogue: [`proposals/2026-10-andon/changelog.html`](proposals/2026-10-andon/changelog.html).

| Element | Web | QML |
|---|---|---|
| Changelog | `ol.changelog` (in `section.section#changes`) > `li.release` (`id` = the version): a rail with one square per release, the newest yellow | – |
| Release head | `.release-head` > `b.release-version` + `time[datetime]`; left of the body, above it below 40rem | – |
| Release body | `.release-body` > `p.release-lead` (one or two sentences: what the release is about), `.release-group[data-kind]` (`new` aqua, `improved` cyan, `fixed` orange, `note` purple (1.26), `breaking` red) > `h3` + `ul`, `.release-shots` > `figure` (`img` or an inline `svg` diagram, `figcaption`), `a.release-notes` (the full notes on the forge) | – |
| Older releases | `details.changelog-more` > `summary` + `ol.changelog`: collapsed below the newest entries | – |
### Added in Kante 1.18

Fields show keyboard focus like every other control.

| Element | Web | QML |
|---|---|---|
| Field focus | `.input` and `.select` get the `--focus` ring (2px, offset 2px) on `:focus-visible`, on top of the cyan tint of `:focus`. The board search (`.search > .input`) had no visible focus on a light ground | – |

### Added in Kante 1.19

Phone layouts: below 640px a page starts with its content. Filters and navigation fold behind a button, table rows become cards. Catalogue: [`proposals/2026-10-andon/mobile.html`](proposals/2026-10-andon/mobile.html).

| Element | Web | QML |
|---|---|---|
| Filter side | `.filter-layout` > `aside.filter-side#id` (an optional `.search`, `.h-label` per axis, `ul.filter-list`) + `.filter-main` (`.filter-head`, then the list). Entries `a` or `button` with the count in `small`; the chosen one `aria-current="true"` (or `aria-pressed`): cyan tint, cyan text, inset bar. More values in `li > details > summary` ("show all 12") + a nested `ul.filter-list`; the summary hides once open | – |
| Filter button | `.filter-toggle[aria-controls][aria-expanded]` in the `.filter-head`, e.g. `btn btn-outline btn-sm` with "Filter (n)". Hidden above 640px; below, the side is hidden until the button is expanded and then opens as a panel under the head. shrippen.js flips `aria-expanded`, moves focus into the panel, Esc closes it | – |
| Segmented toggle | the existing `.seg` with `button[aria-pressed]`: the active segment is the primary fill (e.g. "Grouped / Single" above a list). A `form` around it keeps the choice on the server | – |
| Compact hint row | `.hint-card.is-row`: `.tier` with the word in `.sr-only` (the shape stays), `.row-main` > `.title` + `.meta` (source · age), `.actions` with one primary action. A `details` in `.actions` takes the full row while open | – |
| Nav drawer | `button.nav-burger[aria-controls][aria-expanded]` (three-line `svg`) + `dialog.nav-drawer#id` > `.nav-drawer-head` (brand, `[data-drawer-close]` button) and `nav.nav-drawer-list` (`.h-label` per section, `a` or `form > button` entries, `.count` right, `aria-current="page"` cyan tint and inset bar). A modal from the left with the scrim behind; shrippen.js opens it, closes it on Esc, scrim click or `[data-drawer-close]` and returns focus to the button. `.nav-wide` marks what it replaces: hidden below 640px, where the burger shows; `.nav-narrow` is the counterpart, shown only below 640px (e.g. a hint counter beside the brand) | – |
| Table as cards | `table.table.cards-sm` with `td[data-label]` (the column header). Below 640px each row is a card: the first cell (or `td[data-card="title"]`) the title, `td[data-card="key"]` (an amount) top right in mono, the other cells a label/value list; cells without `data-label` (actions) span the card, empty cells drop out. The header row stays for screen readers; `tr` with `th` in a `tbody` works too | – |
| Long buttons on phones | below 640px a `.btn` wraps its label and never gets wider than its column, so a long label ("Create draft for <client>") does not scroll the page sideways | – |

### Added in Kante 1.20

A wall display that shows a board one screen at a time: the tiles are packed into sets that fill the screen, and a transition switches from one set to the next. Catalogue: [`proposals/2026-10-andon/wall.html`](proposals/2026-10-andon/wall.html).

| Element | Web | QML |
|---|---|---|
| Stage | `.wall-stage` (`.is-screen`: fixed to the whole screen, no scrolling; `.is-preview`: a framed 16:9 preview) > `.wall-set` (one set, the next one after the shown one); `.wall-set.is-fit` scales its children by `--wall-scale` (a set taller than the stage); `[data-wall-off]` hides a tile or section outside the shown set | – |
| Time and place | `.wall-progress > i` runs over `--wall-time` (only with motion); `.wall-pager > i` one square per set, `.is-on` the shown one | – |
| Transitions | `js/kante-wall.js`: `Kante.wall.run(name, from, to, {easing, tiles, force})` → promise; `fade`, `cut` (yellow blade `.wall-blade` at the cut's angle, diagonal wipe), `stagger` (tile by tile), `flap` (split-flap, row by row), `shutter` (slides up), `scan` (`.wall-scan` line, wipe from the top); `Kante.wall.pick("rotate", n)` takes them in turn | – |
| Easing | `easing`: `standard` (each transition's own), `linear`, `quad`, `cubic`, `expo`, `soft`, `snap` (`--ease-snap`) or any CSS easing | – |
| Reduced motion | without `force` the sets switch at once; a preview the user starts passes `force` | – |
| Preview tiles | `.wall-tiles` > `.wall-tile` (`b` name, `small` kind, `--tier` bar) | – |

### Added in Kante 1.21

| Element | Web | QML |
|---|---|---|
| Card key label | In `table.cards-sm`, the `td[data-card="key"]` shows its `data-label` small above the value (mono, `--fg3`), so the figure top right of a card says what it is | – |

### Added in Kante 1.22

| Element | Web | QML |
|---|---|---|
| Update check | – (Kimai: `kit.update_hint`, kit 0.8) | `KanteUpdateCheck` (non-visual): asks `https://shrippen.github.io/versions.json` (no parameters) at most once per `interval` (a day), offers `available`, `latestVersion`, `latestUrl`, `dismiss()`; `memory` (JSON) to persist, so a restart does not ask again. Shows nothing itself: pair it with `KanteCallout`. Only in builds nothing else updates, off in demo mode. Format: `shrippen.github.io/overview/VERSIONS.md` |

### Added in Kante 1.23

The practice components for Kontra, the bass trainer: purely presentational, the data comes in through properties, every action goes out as a signal. Colour is never the only sign of a state (Kontra's persona Sam reads them with deuteranopia, at 200 %, by keyboard and screen reader): every note state has a shape, every toggle a lamp, every zone a word. All sizes come from `KanteStyle.unit` and the font, so they scale; all of them work in System, Kante and Kante Light. Catalogue with screenshots: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html).

| Element | Web | QML |
|---|---|---|
| Note states | – | `KanteStyle.noteStateColor(state)`, `noteStateName(state)` (words in `noteStateNames`, an app sets its translations once), `inkOn(fill)`; `KanteNoteMark` draws the sign: `hit` check, `wrong` cross, `missed` hollow dashed square, `early` arrow left, `late` arrow right, `offpitch` wave with its cents (1.27) (`badge` on a framed square). Also the key of a legend |
| Tab lane | – | `KanteTabLane`: one lane per string (`strings`, `stringNames`, `lowStringOnTop`, `stringColors`), `notes` [{time, duration, string, fret, state, label}] run from the right onto the play line (`position`, `pixelsPerSecond`, `playLine`), `bars`, loop range (`loopStart`, `loopEnd`) with bracket edges; `nextIndex`. The notes sit on one strip that moves with `position` (one binding per frame); their visuals are made asynchronously near the view. 3000 notes, about 300 in view: under 2 ms binding work per frame |
| Tablature | – | `KanteTabStaff`: tab lines with fret numbers, bar lines, repeat signs (`bars` as {time, repeatStart, repeatEnd}), rhythm below (stems, flags, beams within a beat, dots; `beats` per note), chords; pages line by line (`barsPerSystem`, `systems`), the current note on a selection band, `cursor` at `position` |
| Bass staff | – | `KanteBassStaff`: bass clef, one voice: `notes` [{time, beats, midi, state, tied}], `rests`, `bars` [{time, numerator, denominator}], `keyFifths`. Spelling in the key, accidentals that hold to the bar line, ledger lines, stems by staff position, beams within a beat (dotted quarter in compound time), flags, dots, ties, triplet 3. Glyphs from Bravura (below); `staffSpace` sizes it |
| Fretboard | – | `KanteFretboard`: `strings`, `frets`, `firstFret`, `stringNames`, `lowStringOnTop`, `leftHanded`, `evenFrets` (else the real 2^(−n/12) spacing), `inlays`; `markers` [{string, fret, role, label}] with a shape per role: `current` filled square, `next` hollow square, `root` diamond, `scale` round dot |
| Tuner | – | `KanteTunerGauge`: needle on −50..+50 cents, `noteName`, `octave`, `cents` ("−12 ct"), `active`, `inTuneCents` (3), `hint`; in tune shows as band, check mark, brackets and `inTuneText`, off-tune fills the triangle on its side |
| Level meter | – | `KanteLevelMeter`: `peakDb` (tick), `rmsDb` (bar), `clipped` (box with word and cross), `rangeDb` (60), zones `quietDb` / `loudDb` named below the track, the zone of the peak bold and underlined |
| Timing histogram | – | `KanteTimingHistogram` (`counts`, `firstBinMs`, `binMs`, `meanMs`): a configured `KanteBarChart` with the ms edges, a zero line, a dashed mean line and the key "◂ early / late ▸". `KanteBarChart` gained `edgeLabels`, `edgeUnit`, `markers` [{at, label, dashed}], `barFill` and `wholeSteps` for it |
| Transport | – | `KanteTransportBar`: rewind, play/pause, loop, speed (25..150 % in 5 % steps), metronome, count-in, position. State in (`playing`, `looping`, `speed`, `metronome`, `countIn`, `position`, `duration`), signals out (`playToggled`, `loopToggled`, `speedChangeRequested(real)`, `metronomeToggled`, `countInToggled`, `rewind`); a toggle shows only what the app sets. Keys K, L, M, C, Home, + / −; wraps when narrow |

**Bravura.** `fonts/Bravura.otf` (Steinberg, SMuFL, SIL OFL 1.1 with the reserved name "Bravura", licence in `fonts/OFL-Bravura.txt`) is vendored unchanged, so it keeps its name; `tools/build-qml.py` copies it with its licence into `qml/Kante/fonts/`. The music components load it themselves (an app that does not use them never loads it); it is not part of `fonts.css` and the web build.

### Added in Kante 1.24

Follow-up for Kontra: note states change one at a time, a quiet way to show them for a play mode without judgement (Kontra LH-MOD-01), and a font fix.

| Element | Web | QML |
|---|---|---|
| One note's state | – | `setNoteState(index, state)`, `resetStates()`, `stateOf(index)`, `stateRevision` on `KanteTabLane`, `KanteTabStaff` and `KanteBassStaff`: changes one note without reassigning `notes` (a new list resets them). Lane: about 0.03 ms per call for the bookkeeping and below 1 ms with the sign drawn in a running view, against 40–400 ms for a new list of 3000 notes. Staff: about 0.3 ms per call (it re-colours its page, the layout stays) |
| Quiet marks | – | `marks`: `Full` (default), `Quiet`, `Off` (`KanteTabLane.Marks`, `KanteTabStaff.Marks`, `KanteBassStaff.Marks`). Quiet: notes keep their string or text colour, no state fills, a small muted KanteNoteMark tells the state by shape (check, cross, dashed square, arrows). Off: no states |
| Small font | – | `KanteStyle.smallFont` is never larger than `defaultFont`: Kirigami's basic theme (no platform theme, e.g. Fusion) reports a small font larger than the default font, so `KanteSettingRow` hints and every label came out bigger than their titles. Then 85 % of the default font is used; `fontPixels(font)` compares sizes. `KanteSectionLabel` in System reads it too |

### Added in Kante 1.25

The conversation components for Kaiwa, the Japanese conversation trainer: you talk with a character, read along with furigana, see what the recogniser heard and get corrections. Presentational like the Kontra parts: data in through properties, actions out as signals. Every state has a word and a shape besides its colour; all of them work in System, Kante and Kante Light and in a Plasma widget (they draw themselves, no platform control). Decisions D-1 to D-7 and the shots: [`proposals/2026-10-kaiwa/`](proposals/2026-10-kaiwa/).

| Element | Web | QML |
|---|---|---|
| Ruby text | `.ruby[data-ruby="all\|new\|none"]` with `<ruby>`/`<rt>`, `ruby.is-new` | `KanteRubyText`: `segments` [{text, reading, isNew, word (1.33)}] or `markup` "{駅\|えき}までは{歩\|ある\|new}いて"; `density` All, New, None keeps the room for the readings, so lines never move; plain runs split per character, so Japanese wraps anywhere; a long reading reaches half a character over free neighbours instead of opening a gap; readings muted, new words too (D-1); `text` is the plain base |
| Heard as | `.heard`, `[data-state="unsure"]` | `KanteHeardLine` (D-2): `text`, `unsure` ("! unsicher" in the warning colour), the action "falsch erkannt" fires `misheard()` (keyboard and screen reader too); a child of your own `KanteMessage` |
| Talk button | `.talk[data-state]` | `KanteTalkButton`: `talkState` Ready (square), Listening (accent fill, `level` 0..1 as six segments), Thinking (diamond, running light), Speaking (breathing lamp, a click interrupts), Error (triangle, negative bar, the remedy as second line); `mode` Hold (press and release, Space held) or Toggle; signals `talkStarted`, `talkEnded`, `interruptRequested`, `errorActionRequested`; words in `titles` / `hints`, `hint` overrides; height `heightLarge` (D-3) |
| Diff | `.diff del`, `.diff ins` | `KanteDiffText`: `parts` [{text, kind: same\|removed\|added}]; removed struck through with a 2 px negative line, added on the focus tint with a 2 px underline; read out as "gestrichen を, neu が" |
| Hint card | `.hint-card` (1.13) | `KanteHintCard`, its QML twin: `tier` (None, Red triangle, Yellow diamond, Blue square, Green check, Primary), `tierText`, `meta`, `titleText` or `titleItem` (a KanteDiffText), `text`, actions as children; `compact` is the one-line row. Kaiwa's severities (D-4): blocks understanding Red, wrong Yellow, unnatural Blue, style None |
| Pitch curve | `svg.pitch` (`.grid`, `.target`, `.actual`, `.kernel`, `.miss`) | `KantePitchCurve`: `morae`, `target` (1 high, 0 low per mora), `kernel` (−1 flat), `actual` (the learner's pitch 0..1, any sample count; info colour, D-5), `missAt`; square markers; `summary` names the fall in words ("Abfall nach は, abweichend bei し") for the legend and screen readers |
| Learning path | `.path > .node[data-state]` | `KantePath` (D-6): `model` [{title, meta, state: done\|current\|open\|review\|locked}]: bar and sign per state (check, filled square, hollow square and "offen" for unlocked but not chosen, diamond indented as a side branch, none and "gesperrt"); unlocked nodes fire `activated(index)` by click, Enter or Space. `KanteSteps` stays for wizards |
| Goal meter | `.goalbar > i.on` | `KanteGoalMeter` (D-7): `value` 0..1 as `segments` (5) stacked bottom to top, `label` beside (the streak), sized for a panel (`stackHeight`) |

### Added in Kante 1.26

The fourth regular group of a release log: every shrippen release log groups its changes as New, Improved, Fixed and Note. Catalogue: [`proposals/2026-10-andon/changelog.html`](proposals/2026-10-andon/changelog.html), shots in Kante, Leinen, Kante Light and Gold: `proposals/2026-10-andon/changelog-note-*.png`.

| Element | Web | QML |
|---|---|---|
| Note group | `.release-group[data-kind="note"]` > `h3` + `ul`: what users should know without it being a change of its own (a changed default, a step after updating, a dropped platform). Its squares are `--purple`: Kante `#d3869b`, Leinen `#8f3f71`, Kante Light `#8e44ad` (dark `#b56fd0`), Kante Gold `#c497a8` (ume). Not `--info`: info is cyan in every theme, the colour of `improved`; not orange or red, which stay with `fixed` and `breaking`. The colour is only on the squares (at least 4.5:1 on ground and cards, 4.1:1 on Kante Light dark cards, as `breaking`), the text stays `--fg2`; the heading word carries the meaning | – |

### Added in Kante 1.27

Wishes from a QA round of Kontra, the bass trainer: platform controls that stayed light on a dark Kante page, a primary action that did not stand out in Kante Light, wizard steps told apart by colour only, and three things the notation lacked. All of it works in System, Kante and Kante Light; the API only grows, nothing changes for existing callers. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html) (`wishes-controls-*`, `offpitch-*`, `chords-keys-*`).

| Element | Web | QML |
|---|---|---|
| Switch | `.switch` | `KanteSwitch`: a `QQC2.Switch` with `KanteCheckSkin`'s switch shape (square track, square knob that snaps to its end; on and off differ by the knob's side). Same API as the Switch. Kante Light keeps the platform's switch, as every control there |
| Combo box | `select` | `KanteComboBox`: a `QQC2.ComboBox` with `KanteFieldSkin` and a Kante list: the popup on a cut card with a cyan bar (`KantePopupSkin`), rows drawn over the style's `ItemDelegate` (the row under pointer or keyboard on the cyan tint with a 3 px cyan edge, the chosen one in the strong text colour, medium weight), 40 px high; `invalid` for a red bottom edge. A plain `QQC2.ComboBox` with `KanteFieldSkin` keeps the style's list (a combo box deletes a delegate it replaces, so a skin cannot swap it back). `KanteFieldSkin` draws its arrow now (no icon theme needed) and keeps the value 8 px off the frame |
| Primary in Kante Light | – | `KanteButton` with `Emphasis.Primary` is drawn by Kante in Kante Light too (other emphases stay the platform's): filled in `KanteStyle.primaryColor`, cut at two corners, bold label. `primaryColor` / `primaryHoverColor` / `primaryPressedColor` / `primaryTextColor`: in Kante the accent as before; elsewhere the platform highlight moved in lightness (hue kept) until its label reads at 4.5:1 (Breeze `#3daee9` with white was 2.4:1; it becomes `#1478ac`, 4.7:1), hover and pressed one and two steps further from the label |
| Steps | `.steps` (already: tick, inset frame) | `KanteSteps`: a sign per state besides the colour (WCAG 1.4.1): done a check on a filled square and a 4 px bar, current its number on a filled primary square, a 2 px outline round the step and a 6 px bar, upcoming its number in a hollow square and a 2 px bar. Screen readers hear "Schritt 3 von 4: Pegel, aktuell" (`stepText`, `stateNames`). It grows with the label for large fonts |
| Note state "offpitch" | – | The right note, its pitch off by more than the app's cents limit. `KanteNoteMark` draws a wave (round, where check and cross are straight; level, where the arrows point), in the warning colour it shares with early / late (right note, not quite right). `cents` (NaN = none) shows "+32 ct" / "−18 ct" beside the sign (`showCents`; `centsWidth` for a legend's layout) and is read out ("Unsauber, +32 ct"). `KanteStyle`: `noteStateColor("offpitch")`, `noteStateNames.offpitch` ("Unsauber"), `noteStates` (every state with a sign, legend order), `centsText(c)`, `centsUnit` ("ct"). `KanteTabLane`, `KanteTabStaff`, `KanteBassStaff`: a note's `cents`, `setNoteState(index, state, cents)` (cents optional), `centsOf(index)`, `showCents` (Full marks only); the lane's summary counts it ("Unsauber 2"). `KanteFretboard` has roles, not states, and is unchanged |
| Chord symbols | – | `KanteBassStaff`: `chords` [{time, text}] and a `chord` per bar (at its start), above the staff, left-aligned over the note at their time; one that would run into the previous moves right. "#" shows as ♯, a "b" after a note letter or before a digit as ♭ ("Bb7" B♭7, "C7b9" C7♭9). The staff moves down by their row only when there are chord symbols. Screen readers hear "Akkord Am7" (`chordText`) |
| Key per bar | – | `KanteBassStaff`: `bars[i].keyFifths` (also read as `key_fifths`), the key from that bar on. Where it changes: a thin double bar line, then the new key; naturals stand only alone, for all of the old key when the change goes to C, never mixed with new signs; at the start of a line both show in the line's header. Notes are spelled and get accidentals in their bar's key. `keyFifths` stays the key of the first bar; without per-bar keys the layout is the old one |

### Added in Kante 1.28

Wishes from Kontra, the bass trainer (2): input choices that are not available yet, help next to a term, a number field and alternate endings in the tablature. All of it works in System, Kante and Kante Light; the API only grows, nothing changes for existing callers. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html) (`wishes2-controls-*`, `volta-*`).

| Element | Web | QML |
|---|---|---|
| Disabled segment | `.seg button:disabled` or `[aria-disabled="true"]`: muted, faded and struck through, `cursor: not-allowed`; a `title` can say why | `KanteSegmented.disabledIndexes` (list of indexes, e.g. `[1, 2]`): label and icon in the disabled colour, faded and struck through (not colour alone); no click, `select(i)` ignores them, Left / Right skip them; screen readers get the disabled state (the radio button part is `enabled: false`). The tooltip (`tooltips`) still shows on hover, so it can say why. `isDisabled(i)` |
| Info tip | `details.help` (1.11) | `KanteInfoTip`: a "?" `KanteToolButton` next to a term. `term`, `info` (tooltip and accessible description), `accessibleName` (plain text, default "Hilfe zu " + `term`; an app with its own translations sets it). The text shows on hover, on keyboard focus and on click or tap; a click keeps it open until a second click, Esc or leaving focus. A question mark, no icon: it shows with every icon theme |
| Spin box | `input.input` with `type="number"` (the text field) | `KanteSpinBox`: a `QQC2.SpinBox` with `KanteFieldSkin`, same API (`from`, `to`, `stepSize`, `value`, `editable`, `textFromValue`, `valueFromText`, `validator`, `valueModified()`, keys Up / Down), `invalid` for a red bottom edge, 40 px high in Kante. `KanteFieldSkin` (every spin box with it): + or − fades at its limit and when disabled (`atLimit(dir)`). Kante Light keeps the platform's spin box |
| Volta brackets | – | `KanteTabStaff`: `bars[i].endings`, the alternate endings a bar belongs to as written, e.g. `[1]`, `[2]` or `[1, 2]` (a number n reads as `[n]`; left out or `[]` for none). Bars in a row with the same endings share one bracket above the bar numbers, numbered "1." or "1., 2." at its start; closed on the right when its last bar has `repeatEnd`, else open (the last ending). A bracket that runs on to the next line goes on there without number and hook. With endings the staff moves down by the bracket row (`endingRow`), without them the layout is the old one. Screen readers hear "Volta 1" for the current bar (`endingText`, "Volta %1") |
| Written bar numbers | – | `KanteTabStaff`, `KanteBassStaff`, `KanteTabLane`: `bars[i].number`, the bar's label as the app sends it (a number or a string, e.g. the written bar number), so unrolled repeats read "5, 6, 5, 6" as in the score; left out, empty or `null`: index + 1 as before. The staffs' screen-reader text says it too ("Takt 5 von 32": %1 the label, %2 still the count of bars played). Bars the bass staff adds after the last given one count on from its number |
| String colours | – | The string palette moves from `KanteTabLane` into `KanteStyle` (owner's decision, Kontra round 8): `stringPalettes` ["kante", "mono", "bright"], `stringPalette` (the app's preset, default "kante", set once), `stringColor(s, preset)` (string 0 = lowest, repeats after six; `preset` defaults to `stringPalette`), `stringColors(count, preset)` (a list, count default 6). "kante": purple, cyan, yellow, strong text, muted, info (the lane's old palette); "mono": every string in the strong text colour; "bright": orange, info, yellow, purple, cyan, strong text. Roles only, no new tokens. `KanteTabLane`, `KanteTabStaff` and `KanteFretboard` share `stringColors` (list, 0 = lowest; a string it leaves out takes `KanteStyle.stringColor`), so an app passes one list, or sets `KanteStyle.stringPalette` and passes nothing. Tab staff: string lines and the fret numbers of pending notes (all notes in Quiet marks; in Full the state colour wins, the current note stays strong); fretboard: string lines (markers keep their role colours and shapes). Colour is never the only sign: strings keep their names and rows. Note: tab staff and fretboard drew their strings muted before; they now follow the palette |

### Added in Kante 1.29

Colour labels in apps, and an audio meter for mixers (lmix). `KanteLevelMeter` (1.23) stays the input check with zones in words; `KanteAudioMeter` is the console meter: one level, peak hold, scale, also vertical. Seven labels, the same on the web and in QML: red, orange, yellow, green (aqua), cyan, blue, purple.

| Element | Web | QML |
|---|---|---|
| Colour label | `data-label` also takes `orange` and `cyan` | `KanteStyle.labelColor(name)`, names in `KanteStyle.labels`; palette roles `labelRed` … `labelPurple`. A label is data, so it keeps its colour in System and Kante Light too (light or dark by the theme). Name the label beside the colour |
| Audio meter | – | `KanteAudioMeter`: `level` in dBFS (undefined: no signal), zones positive up to `warnAt` (−18), warning up to `dangerAt` (−6), negative above, from `floor` (−60); peak-hold mark (`holdMs`, 1500), `showScale` (1.45; before: `scale`) labels the floor, both limits and 0 (crowded labels drop out, floor and 0 stay), `vertical` fills bottom up; tooltip and accessible name give the value |

### Added in Kante 1.30

The keyboard view for Kontra's bass over MIDI (persona P5 Aylin, a keyboarder who plays bass lines with her left hand; journey J-E1): an instrument profile can be a key range instead of strings. Presentational like the other practice components; colour is never the only sign, every marker has a shape; nothing moves on its own (the lane follows `position`), so reduced motion has nothing to stop. No web twin: the practice components are QML only. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html) (`keyboard-*`).

| Element | Web | QML |
|---|---|---|
| Key geometry | – | `KanteKeyLayout` (non-visual, shared by keyboard and lane): `low`, `high` (MIDI, 60 = middle C), `width`; `noteNames` (12 names from C, default C, C♯, D, E♭, E, F, F♯, G, A♭, A, B♭, B; the app sets its language, e.g. German H for B), `middleCOctave` (4: MIDI 60 is C4). Piano proportions: white keys equally wide (`whiteWidth`), black keys 0.58 wide and 0.63 long, set off the boundary as on a real keyboard. `x(m)`, `keyWidth(m)`, `isBlack(m)`, `nameOf(m)` ("E1"), `keyAt(px, blackLevel)`, `count`. A range that starts or ends on a black key starts or ends at its edge |
| Keyboard | – | `KanteKeyboard`: keys `low`..`high`; `noteNames`, `middleCOctave`; `keyNames` CKeys (default: "C2" on every C), WhiteKeys, None; `markers` [{midi, role, label, cents}] with a shape per role as on `KanteFretboard` (`current` filled square and the key tinted, `next` hollow square, `root` diamond, `scale` round dot; `label` inside) and the note states `hit`, `wrong`, `missed`, `early`, `late`, `offpitch` as `KanteNoteMark` signs (offpitch with its cents); markers outside the range are left out. White keys in the lighter of ground and text colour, black keys in the darker, so it reads as a piano in dark and light. `interactive` (default false, a display like the other instrument components): Tab focus, Left / Right, Home / End move a cyan focus ring (`focusKey`), Enter / Space or a click fire `activated(midi)`. Screen readers hear the markers ("Aktuell: D2; Nächste: E2"; `roleNames`, `markerText`) |
| Key lane | – | `KanteKeyLane`: falling notes over the keys, `KanteTabLane`'s twin for keys: `notes` [{time, duration, midi, state, label, cents}] (the tab lane's notes with `midi` instead of string and fret), `position`, `pixelsPerSecond`, `playLine` (0..1 from the bottom, default 0.2 as the lane), `bars` (with `number`), `loopStart` / `loopEnd`, `marks` Full / Quiet / Off, `showCents`, `setNoteState(index, state[, cents])`, `resetStates()`, `stateOf(i)`, `centsOf(i)`, `stateRevision`, `nextIndex`. Same width, `low` and `high` as a `KanteKeyboard` below it: its columns stand over the keys. A note is a block in its key's column with a square head at its onset (key name or `label` on it, `names`), pending in `noteColor` (info), states by sign as on the lane. Black key columns tinted, a line at every C. Same speed design as the lane: one moving strip, note visuals made asynchronously near the view; signs only while their head is in view (the software renderer does not clip a Shape) |

### Added in Kante 1.49

From Kontra's QA night (27.10.2026): a keyboard-only player at 200 %, deuteranopia, a beamer.

| Element | Web | QML |
|---|---|---|
| Return presses buttons | – | `KanteButton`, `KanteToolButton` (and `KantePlasmaButton`): Return and Enter press a focused button like Space (Qt Quick Controls take only Space); a disabled one lets the key through. `KanteStyle.pressByKey(button, event)` for own buttons |
| Focus in view | – | `KanteFocusFollow { flickable: … }`: when the keyboard focus (not the mouse) moves to an item in the flickable's content, the view scrolls the least it can to show it plus `margin` (default 16 px); taller items show their top |
| Light or dark | – | `KanteStyle.scheme` Auto (default, follows the platform), Light (Leinen) or Dark, for Kante; Kante Light and System keep the platform's colours. `preferDark` still forces dark |
| Skipped step | – | `KanteSteps.skipped`: indexes of passed steps the user left out; a muted 4 px bar and a dash in a hollow square instead of the check, „übersprungen“ for screen readers (`stateNames.skipped`) |
| Axis title | – | `KanteBarChart.axisTitle`, written upwards left of the axis labels; `KanteTimingHistogram.axisTitle` (default „Noten“) |
| Wrong note | – | `KanteTabLane`, `KanteKeyLane`: a wrong note's head (marks Full) is framed in the strong text colour, so it differs from a string's colour by shape, not only by red |

### Added in Kante 1.48

The workbench (Andon's VAT check: open bank lines become finished expenses). A list to scan beside a desk for one entry; the entry being worked on is a selected row, so it is cyan.

| Element | Web | QML |
|---|---|---|
| Workbench | `.bench` > `.bench-list` + `.bench-desk`: the list in a column of 16 to 22rem, the desk beside it; below 60rem the desk goes under the list | – |
| List entry | `.bench-list` > `a.bench-entry` or `button.bench-entry`: `b` (name), amount, `small` (line), `small` (count), `.progress-segs` (how complete) in two lines and a bar; the current one `aria-current="true"`: cyan tint and bar, as `.list-row[aria-selected]`. An `.h-label` above, a `.legend` below | – |
| Desk | `.bench-desk` > `.bench-top` (`h3` and `p` left, `b` amount right), then `.bench-cols` > `.bench-col` (two columns, one when the desk is narrower than 38rem) and `.bench-pair` (two fields side by side, one when its column is narrower than 20rem); desk and columns are size containers | – |
| Field origin | `.field-label` > `.field-origin`: where a value came from ("last expense", "receipt"), lower case after a dot | – |
| Facts | `dl.kv`: term beside value, terms as small mono labels | – |
| Pick | `.picks` > `label.check.pick`: a radio (`.check-dia`) or check box (`.check-box`) per card, `.pick-thumb` (an `img`; empty, it draws the lines of a page), `.pick-text` (`b`, `small`), then a `.pill` or `.num`. Checked: cyan tint and bar. `.is-other`: a weaker candidate, its preview faded and its title in the secondary text colour | – |
| Sum bar | `.sumbar` > `.progress-bar` with one `i` per part (`--p` share, `--c` colour from the data palette) and `i.rest` (hatched), `.sumbar-line` (sum left, rest right; `data-state="ok"` or `"bad"` on the rest) and a `.legend` (`i.rest` hatched there too) | – |

### Added in Kante 1.47

Waiting feedback (Andon: every page change, form and fragment load). The page load bar, the pending light and a busy region show only after 150 ms, so a fast answer stays calm; that delay is in the CSS, the app only sets the states. `.loading`, `.btn-status` and `.step-time` show at once: put them in only where a wait is certain (a placeholder before a fragment, a line after 8 s).

| Element | Web | QML |
|---|---|---|
| Page load | `<div class="page-load" aria-hidden="true">` once per page; `.is-on` while a page change loads: marching stripes in a 3 px bar on top | – |
| Pending link | `.is-pending` on the clicked link, tab or card: a running light around it | – |
| Busy region | `aria-busy="true"` on a region (not `html`, `body`, a `dialog`, `.dialog`, `[role="dialog"]` or a button): its children dim to 40 %, except `.runner`, `.loading`, `.loader`, `.progress-bar`, `.btn-row` and `.btn-status` (direct children only: a busy form keeps its button and status line readable when they sit directly in it); the fade runs only without reduced motion | – |
| Loading word | `.loading` > `.loader` + text: squares and "Lädt …" in one line | – |
| Button status | `.btn-status` under a `.btn-row`: a reserved line for "Dauert länger …" or an error (`data-kind="error"`), so the row does not jump | – |
| Step time | `.steps > li > .step-time`: elapsed time of a live step | – |

### Added in Kante 1.46

Choosing a period by its state (Andon's VAT check: each quarter with its deadline and what it comes to). `button.status[aria-pressed]` marks an entry in cyan; a period is the chosen value of a control, so it is yellow.

| Element | Web | QML |
|---|---|---|
| Status as a choice | `a.status` (a link, like `button.status`); the chosen one `aria-current="page"`: tinted and a 4 px `--yellow` bar at the bottom (ochre on Kante Light, 5:1; the name keeps its colour: yellow text fails there), the focus ring stays on top of it; `aria-current="false"` is not chosen, the state's bar stays on top | – |
| Statuses in a row | `.status-row` > `.status` (or `a.status`): equal columns of at least 9rem, wrapping when narrow | – |

Fixed: a busy outlined button (`.btn-outline.is-busy`, also ghost and data) showed its stripes in one 28 px tile at the top right, moving and jumping back: the outline's cut is an unrepeated background image. Busy, the stripes now repeat over the whole button and march through it.

### Changed in Kante 1.45

qmllint (property-override): `KanteAudioMeter` declared `scale` as a bool and so hid Item's own `scale`, the size factor. Anything reading or animating the meter's `scale` got the bool instead.

| Element | Web | QML |
|---|---|---|
| Audio meter | – | `KanteAudioMeter.showScale` switches the labels; `scale` is Item's size factor again. Removed: the bool `scale`; a project that set it sets `showScale`. Old code: a literal `scale: true` or `scale: false` no longer loads ("Invalid property assignment: number expected": the file that holds it does not load); a binding such as `scale: showLabels` loads and goes wrong silently, as the size factor 1 (no labels) or 0 (the meter shrinks to nothing). Search for `scale:` on every `KanteAudioMeter` |

### Changed in Kante 1.44

Kontra's aim against the beat (DIDAKTIK I5): the summary said whether a run held laid-back (+10 to +30 ms), but the histogram did not show the band, so the player could not see how far the notes sat from it.

| Element | Web | QML |
|---|---|---|
| Bar chart | – | `KanteBarChart`: `ranges` [{from, to, label}] shade spans behind the bars, in columns like `markers`: a tint (`tint1Color`), dashed edges and the label in a box above the bars, one row below the marker labels; clipped to the chart. Not colour alone: edges and label carry it |
| Timing histogram | – | `KanteTimingHistogram`: `bandMinMs`, `bandMaxMs` (NaN: none) and `bandText` draw a target band, labelled "Ziel +10…+30 ms"; `rangeList()`; screen readers hear the band after the mean |

### Added in Kante 1.43

From lmix (QA of its Mix page, 25.10.2026): the page needs a size the operator drags (monitors over inputs, the audio column), menus with sections, icons, shortcuts and values instead of 18 flat entries, a "View" popover with segments and switches, colour tags as swatches in a menu row, a source chooser that shows every kind at once, and an undo in place of a confirmation. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-lmix/`](proposals/2026-10-lmix/).

| Element | Web | QML |
|---|---|---|
| Split handle | – | `KanteSplitHandle`: the grip between two panes. `orientation` (Qt.Vertical: a bar dragged up and down, sets a height; Qt.Horizontal: sets a width), `value` (px, the app binds and stores it), `from`, `to`, `defaultValue` (double click or Delete resets; NaN: none), `inverted` (a pane on the right or below grows against the drag), `step`; `moved(value)` within the limits. Three short lines on a 1 px rule, focus colour on hover, drag and keyboard focus; arrows, Page Up / Down, Home / End. A slider for screen readers (`accessibleName`) |
| Keycap | – | `KanteKeycap`: a key or shortcut as a cap (mono, sunken ground, frame with a 2 px bottom edge). `text` as given (the platform's native text) |
| Menu item | – | `KanteMenuItem`: a `QQC2.MenuItem` with icon (`icon.name`/`icon.source`, text colour), `valueText` (the current value of what it opens, mono, muted; also its accessible description), `shortcutText` (default: the action's shortcut) as a `KanteKeycap` in Kante and Kante Light, plain text in System, `destructive` (negative text colour), `iconRoom` (keeps the icon's room, texts line up). Indicator, arrow, highlight and background stay the platform's |
| Menu section | – | `KanteMenuSection`: a heading inside a `QQC2.Menu` (`text`, `rule` for the thin line above; off for the first). Keyboard and mouse pass over it; a heading for screen readers |
| Popover | – | `KantePopover`: a card at a button for a few settings that apply at once (no title bar, no buttons). `openAt(item)` opens it below the item, above when there is no room below, inside the window; `title`; content as children (a column). Esc or a click outside closes it. Uses `KantePopupSkin` |
| Swatch picker | – | `KanteSwatchPicker`: a row of `KanteSwatch`es to choose a colour. `colors`, `names` (screen readers, tooltips), `currentIndex` (-1 none), `noneText` (a struck-through "none" first), `size`; `picked(index)`. One tab stop, Left / Right, Space / Enter; radio buttons for screen readers |
| Table header | – | `KanteTableHeader`: column titles in label style over rows, with a rule. `columns` [{title, width (px, 0 = share the rest), align}], `spacing`; rows line up with `columnX(i)` and `columnWidth(i)`. Column headers for screen readers |
| Option tile | – | `KanteOptionTile`: one of several kinds as a tile (`icon`, `text`, `hint`), checkable and `autoExclusive`. Chosen: selection tint with a 2 px focus-colour frame; hover tint 1; keyboard focus ring; cut corner in Kante and Kante Light. Radio button with name and hint for screen readers |
| Toast action | `.toast` action (1.11) | `KanteToast.actionText` ("Undo") puts a button at the right; a click emits `actionTriggered()` and hides the toast. `actionShortcut` shows a `KanteKeycap` beside it (the app handles the key) |
| Dialog accept button | – | `KanteDialog.acceptText` names the accept button after what it does ("Add input" instead of OK), `acceptEnabled` locks it while the form is incomplete; both hold for the footer of every style, also after a switch at run time. `acceptButton()` returns the button shown now |

### Changed in Kante 1.43

`KanteSheetSkin` and `KanteMessageSkin` replaced `background` in Kante as the popup skin did before 1.42, so a sheet or an inline message lost its platform background after leaving Kante (hidden, unsized). Both now keep the platform background (opacity 0 while Kante is on) and draw their card (`kanteBackground`, the same property) behind the content.

| Element | Web | QML |
|---|---|---|
| Sheet and message skin | – | `KanteSheetSkin`, `KanteMessageSkin`: `popup.background` / `message.background` stay the platform's; in Kante the card is a child of the popup item / the message at z -0.5. A sheet without a background gets the card too |
| Toast | – | `KanteToast` stays while the pointer is over it or its action has keyboard focus, and then gets its full `life` again (every toast, with or without an action) |

### Changed in Kante 1.42

lmix in Kante Light (QA 25.10.): the File menu opened see-through, its items straight over the video. Kante Light starts from Kante for a moment (the saved style loads after the default); leaving Kante put the platform's menu background back, but Qt had hidden and unsized it when the Kante card replaced it.

| Element | Web | QML |
|---|---|---|
| Popup skin | – | `KantePopupSkin` no longer replaces `background`: in Kante it draws its card (`kanteCard`) behind the content and hides the platform background (opacity 0, at least as wide as the widest item); leaving Kante shows the platform background again, sized as before. A menu or combo list keeps the platform's size in every style. A popup without a background gets the card behind its content. Removed: the property `kanteBackground`; a project that read it or the card through `popup.background` uses `kanteCard` |

### Changed in Kante 1.40

Kontra logged `TypeError: Value is undefined` at `KanteTabStaff.qml:220` when it hid the staff by passing no notes while the position stood behind a note.

| Element | Web | QML |
|---|---|---|
| Tab staff, bass staff | – | `KanteTabStaff`, `KanteBassStaff`: the accessible description reads the current note only when it exists; emptied `notes` no longer log an error before `currentIndex` follows |

### Changed in Kante 1.39

Kontra's setup at half a laptop screen (700 px, QA 14.10.): five steps did not fit, the last label was cut ("LET'S").

| Element | Web | QML |
|---|---|---|
| Steps | – | `KanteSteps`: narrower than its labels need (a width set by a layout), only the current step keeps its label, the others show their sign alone (`compact`; `fullWidth`, measured from the labels themselves, so it follows a font change, also when the steps are created asynchronously, as in a `Loader`; `count`); screen readers still hear every step with its name. Its own size (`implicitWidth`) is always `fullWidth`, whatever it shows, so it is compact only under a width set from outside and gets its labels back when that width grows (a Row sizing itself could stay compact after a longer model or a layout that shrank it). `KanteSteps` is an `Item` with the steps in a `Row` now; `spacing` stays |

### Changed in Kante 1.38

The transport's toggles in Kontra (owner, 14.10.): metronome and count-in, both on by default, were filled accent buttons beside the play button, three buttons of the same weight. The lamp before the word already told the state.

| Element | Web | QML |
|---|---|---|
| Transport toggles | – | `KanteTransportBar`: loop, metronome and count-in show their state by the lamp alone (filled square on, hollow off), never as a filled button; screen readers get them as check boxes (`Accessible.checked`). They stay checkable and checked with the app's state, so Qt reports it when a screen reader starts after the app |
| Tool button without fill | – | `KanteToolButton.fillChecked` (default true): false keeps a checked button unfilled in Kante, for a toggle that shows its state itself; `filled` (read only) is `checked && fillChecked`. The platform style in System draws checked as it does |

### Changed in Kante 1.37

A ghost note in tab (Kontra, round 11, finding F8): the fret in parentheses and a sign "( )" above it read as "(0(0(0" in sixteenths. Printed tab writes only the parentheses.

| Element | Web | QML |
|---|---|---|
| Ghost note | – | `KanteTabLane`, `KanteTabStaff`: a ghost note shows its fret in parentheses and no other sign; a `techniqueResult` frames the parenthesized fret (head on the lane) with the result's shape. `KanteTechniqueMark.signVisible` (default true): false draws only the result's frame and stroke, and only with a result |

### Added in Kante 1.36

KanteKpi for screen readers (Kontra's start page, persona P7): Orca read the figure and its label as two loose texts ("7 MIN", "PRACTISED").

| Element | Web | QML |
|---|---|---|
| KPI name | – | `KanteKpi`: `Accessible.name` is "label: value" (only the value without a label), `Accessible.description` the change (`delta`); the texts inside are ignored by screen readers |

### Added in Kante 1.35

The loop range in tablature and bass staff for Kontra (QA 13.10., persona P2): the workshop mode loops bars 3 and 4, the tab lane showed it, tab and notes did not. Same properties, roles and shape as on `KanteTabLane`. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html) (`loop-*`).

From lmix (a broadcast and show app on Kante), which had kept them locally until its review sent them here: a page bar for apps with a few large pages (Inputs, Audio, Outputs, Setup), a ground for picture areas that stays dark in Leinen too, and vertical sliders for its faders.

| Element | Web | QML |
|---|---|---|
| Loop in tab and staff | – | `KanteTabStaff` and `KanteBassStaff`: `loopStart`, `loopEnd` (seconds, -1 for none, as on the lane): a `tintHighlightColor` tint with `focusColor` bracket edges ([ and ]), as high as the cursor, behind the staff. One part per line (`loopParts` [{x, w, sys, left, right}]); a loop that runs on to the next line is open at the line end and goes on there without bracket. An edge on a bar start or end sits on the bar line, else at the time's x. In tablature the fret grounds inside the loop carry the tint |
| Page bar | – | `KantePageBar`: the bar at the foot of an app window that switches pages (as DaVinci Resolve's page bar). `model` (labels, mono uppercase as Kante labels), `currentIndex`, `activated(index)` (fires on every change made in the bar, not for the current page again), `tooltips` (optional hints). The current tab is raised on `cardColor` (cut top right) with a marker line in `focusColor` along its top edge; hover is `tint1Color`; the ground is `sunkenColor` with a `ruleColor` line on top. `busy` (list of bools) puts a dot on a tab, something runs on that page; `busyKinds` (`KantePageBar.Kind` Normal, Info, Warning, Error) colours it (accent text, info, warning, negative), Warning and Error draw a diamond instead of a round dot, so the kind is not colour alone; screen readers hear `kindNames` (German by default, the app sets its translations) as the tab's description. Items declared inside the bar sit at its right end (`trailing`, the default property: a program picture, a panic button), `leading` takes items for the left end. Tabs scroll sideways when they do not fit and keep the current one in view. Tab focus, Left / Right, Home / End; a focus frame around the current tab. Each tab is an `Accessible.PageTab` (name, selected), the bar a `PageTabList`. System: no cuts, no motion, platform colours |
| Picture areas | `.stage` (dark in both themes) | `KanteStyle.stageColor` (`#282828`, Gruvbox bg0) and `stageTextColor` (`#ebdbb2`, for a "No signal" label or a safe-area frame): the ground of monitors, video previews and image stages, dark in every kind and scheme, Leinen, Kante Light and a light platform theme in System included, because colour is judged there. Opaque; roles `stage` and `stageText` in `palette.json` (`app.dark` and `app.light`) |
| Vertical slider | – | `KanteSliderSkin` follows `control.orientation`: with `Qt.Vertical` (a fader) the sunken track runs along `availableHeight`, the accent fill grows from the bottom to the value and the square handle moves in y. Horizontal sliders are unchanged; `vertical` (read only) on the skin |

### Fixed in Kante 1.34.1

Two-digit years in `KanteDateField` (found in Plasmai): with a short format such as "dd.MM.yy" or "M/d/yy" the field shows "26", and leaving it read its own text back as 1926 (`Date.fromLocaleString`). Plasmai saved a running entry's start 100 years back, and Kimai refused a stopped one as too long.

| Change | Web | QML |
|---|---|---|
| Two-digit years in this century | – | `KanteDateField`: a two-digit year is the year in the century around today, at most `twoDigitYearsAhead` (20) ahead: "26" is 2026, "99" is 1999. `fullYear(twoDigits)`. Applies to the field's `format` and the typed fallback ("1.10.26") |

### Added in Kante 1.34

A Japanese face for Japanese text in pieces (found in Kaiwa): `KanteRubyText` lays out one `Text` per character, `KantePitchCurve` one per mora, `KanteDiffText` one per part. A lone 来 or 。 gives Qt no context, so under a non-Japanese locale (de_DE) its font fallback took a Chinese face: other glyph forms (Han unification), kanji on a lower baseline than the kana around them, 。 centred instead of in the corner. Whole lines in one `Text` were not affected.

| Element | Web | QML |
|---|---|---|
| Japanese family | – (the page sets `lang="ja"`) | `KanteStyle.japaneseFamilies` (preference list: Noto Sans CJK JP, Source Han Sans JP, Hiragino Sans, Yu Gothic, Meiryo, BIZ UDPGothic, IPAexGothic, …), `japaneseFamily` (the first installed, else the default font's family), `japaneseFont(base)` (`base` or the default font in that family, same size and weight). Default `font` of `KanteRubyText` and `KanteDiffText`, and the morae of `KantePitchCurve`. An app with its own Japanese `Text` pieces takes `KanteStyle.japaneseFont()` too |

### Added in Kante 1.33

Words to look up in the ruby text, for Kaiwa's word lookup (/LF112/): a click on a word in the character's line shows its reading, meaning and accent. The text stays one `KanteRubyText`; the app groups its segments into words and opens its own popup (`KantePopupSkin`) at `wordRect`.

| Element | Web | QML |
|---|---|---|
| Words in ruby text | – | `KanteRubyText`: a segment may carry `word` (a number ≥ 0; segments with the same number are one word, 歩 + いて). `interactive` (default false): a word underlines on hover (muted line) and fires `wordActivated(word)` on a click; Tab focuses the text, Left / Right, Home / End move the focused word (`focusWord`, a 2 px line in the focus colour), Enter / Space activate it. `words` (the numbers in order), `wordText(word)`, `wordRect(word)` (the box in the item, to anchor a popup), `wordAt(x, y)`. Screen readers hear the text, then the focused word and `wordHint` ("Eingabe: nachschlagen"). Without `interactive` nothing changes |

### Added in Kante 1.32

The dead note for Kontra (LH-BEW-06, round 10, personas P2 and P3): a note muted without pitch, written x in tab (Guitar Pro's dead note). Kontra judges it as a technique; a ghost note "( )" keeps its pitch and only shows its sign.

| Element | Web | QML |
|---|---|---|
| Dead note | – | `KanteTechniqueMark`: `technique` "dead" draws x, with results as every technique. `KanteStyle.techniqueNames.dead` ("Dead Note"). `KanteTabLane` and `KanteTabStaff`: a dead note's fret reads x instead of the number; `KanteBassStaff` shows the sign |

### Added in Kante 1.31

Technique marks for Kontra (LH-BEW-06, personas P3 and P4): the score says how a note is played, the app says how it was played. Tab signs as written in bass tab, the result by shape, never by colour alone. Presentational like the other practice components. Catalogue with shots in Kante and Kante Light: [`proposals/2026-10-kontra/bauteile.html`](proposals/2026-10-kontra/bauteile.html) (`techniques-*`).

| Element | Web | QML |
|---|---|---|
| Technique mark | – | `KanteTechniqueMark`: `technique` "slide" (sl), "hammer" (h), "pull" (p), "slap" (S), "pop" (P), "ghost" (( )); unknown keys draw nothing (`drawn`). `result` "" (the sign alone, muted), "played" (solid frame), "other" (solid frame, sign struck through), "unheard" (dashed frame, struck through); `color` defaults to `resultColor` (played as a hit, other as a wrong note, unheard as a missed one). Set the height, `implicitWidth` follows the sign. Accessible name: technique and result |
| Technique names | – | `KanteStyle.techniqueNames` {slide, hammer, pull, slap, pop, ghost} and `techniqueResultNames` {played, other, unheard}, German by default; an app sets its translations once, like `noteStateNames`. `techniqueName(key)`, `techniqueResultName(r)` ("" for unknown), `techniqueCountsText(counts)` ("Technik gespielt 3, Andere Technik 1") |
| Techniques in tab, lane and staff | – | `KanteTabLane`, `KanteTabStaff`, `KanteBassStaff`: notes take `technique` and `techniqueResult`; `setTechniqueResult(index, result)` changes one without reassigning `notes` (as `setNoteState`), `techniqueResultOf(i)`, `resetStates()` clears them too. Lane: the sign above the head, left of the state badge; tab staff: above right of the fret number; bass staff: above the staff under the state sign. A ghost note's fret reads "(5)" in lane and tab. Marks Off: signs without results; Quiet: muted, the result still told by the frame. The screen-reader description adds the counts by result |

### Kante Gold

The noble variant, opt-in via `<html data-kante="gold">`, **only for Kintsugi** (see [`AGENT-RULE.md`](AGENT-RULE.md)). Kante is the workshop; Kante Gold is the lacquer and the gold leaf on it: the same components, classes, sizes and roles, finer executed. Kintsugi mends breaks with gold, Kante is named after its break, the cut corner: in Gold **the cut is gilded**. Dark only.

| | Kante | Kante Gold |
|---|---|---|
| Ground, cards, text | Gruvbox `#141312`, `#2a2826`, `#ebdbb2` | urushi `#14110f`, lacquer `#1c1815`, paper `#efe8d8` |
| Primary | yellow `#fabd2f` | gold `#d4a640` (8.4:1); pale gold `#e8d4a6` as `--accent` |
| Focus, links, info | cyan `#5ccfc4` | patina `#8fb8aa` (verdigris, gold's counterpart on metal) |
| Success, warning, error, tags | aqua, orange, red, purple | jade `#97ad7a`, copper `#d08a55`, cinnabar `#d0705a`, ume `#c497a8` |
| Titles and figures | Rajdhani 700, uppercase | Spectral 500, uppercase, +0.06 em; figures lining and tabular |
| Controls | Rajdhani | Rajdhani 600 (`--font-control`) |
| Cut edges | cut | cut with a 1.6 px gold line (`--gild`) on `.ch`, `.feat`, `.callout`, `.codeblock`, `.table-wrap`, cards, dialogs, `.login` |
| Bars, frames | 4 px, `--bg2` | 2 px (`--bar`), gold hairlines (`--gold-line`, gold at 32 %) |
| Tabs | yellow fill | gold text with a 2 px gold underline |
| Busy | marching hazard stripes | slow gold shimmer (2.6 s) |
| Motion | 120 / 200 / 450 ms, snap with overshoot | 160 / 280 / 700 ms, glide without overshoot |
| Ground | plain | crackle ground behind the page (gold at 5 %, drifting 160 s; still without motion) |

All text colours reach 4.5:1 on ground, cards and fields (ash `#a39885` 5.7:1 on `--bg1`, cinnabar as text `--red-text` 6.3:1). Gold is precious: up to 10 % of a view and one gold fill per view (the primary action); gold is line and type, not surface. Spectral (SIL OFL) comes with `fonts.css` as woff2 (Latin subset). Tokens in `tokens/variables.css` (`:root[data-kante="gold"]`) and `palette.json` (`gold`), the details in the "Kante Gold" block of `css/components.css`. No QML yet: Kintsugi is web only; `KanteStyle.Kind.Gold` comes with the first app that needs it.

### Kante Light

The quieter variant for apps that should sit next to Breeze / Kirigami apps and still read as Kante. **Every color comes from the platform:** in Qt `KanteStyle` forwards `Kirigami.Theme` live (any color scheme, light or dark, switched at runtime); on the web the Breeze palette follows `prefers-color-scheme`. Kante contributes shape and type only:

| From the platform | From Kante |
|---|---|
| All colors (text, surfaces, highlight, positive/neutral/negative) | Top-right cut corner and accent bar (in the highlight color) on cards and tiles |
| Buttons (but the primary one: Kante fills it in the highlight at 4.5:1 to its label, 1.27), fields, check boxes, switches, menus, dialogs | Page and app titles in uppercase Rajdhani (`titleFont`, `KantePageTitle`, `KanteHeading { pageTitle: true }`) |
| Body text and card headings (system font) | Figures (times, durations, counts) and section labels in JetBrains Mono, sections with a thin rule |
| Other headings (`KanteHeading` without `pageTitle`) | The Kante layouts an app offers (tiles, time lines) |

- Qt: `KanteStyle.kind = KanteStyle.Kind.KanteLight`. `KanteStyle.active` is true for Kante and Kante Light (shapes, type, layouts); `KanteStyle.themed` only for Kante (palette, control skins). Views branch on `active` for layout and read colors from the roles, which stay the theme's in Kante Light. Control wrappers and skins only draw in `themed`.
- Web: `<html data-kante="light">` with the regular stylesheet. Tokens in `tokens/variables.css` (Breeze light, and dark under `prefers-color-scheme: dark`), shape and type rules in the "Kante Light" block of `css/components.css`. App CSS uses the roles (`--primary`, `--on-primary`, `--hl`, `--bg-panel`, …), never `--yellow` for "active".
- Kante Light has no palette of its own in `palette.json`: there is nothing to keep in sync, the platform owns the colors.

### Web ↔ app

Both sides use the same palette values (`tools/check-tokens.py` fails if `palette.json` and `variables.css` drift apart). Apps add alpha to surfaces, because a translucent or blurred platform ground sits behind them.

| Role | Web (CSS) | App (`KanteStyle`) | Dark | Light (Leinen) |
|---|---|---|---|---|
| Page ground | `--bg-void` / `--bg0` | `backgroundColor` | `#1d2021` | `#f0e9d6` |
| Card | `--bg-panel` | `cardColor` | `--bg1` at 60 % | `--bg1` at 70 % |
| Sunken (fields, tracks) | `--field` / `--bg-hard` | `sunkenColor` | `--bg-void` at 50 % | `--bg-hard` at 60 % |
| Border | `--bg2` | `frameColor` | `--fg1` at 16 % | `--fg1` at 18 % |
| Body text | `--fg1` | `textColor` | `#ebdbb2` | `#3c3836` |
| Headings | `--fg0` | `strongTextColor` | `#fbf1c7` | `#282828` |
| Secondary text | `--fg2` / `--fg3` | `mutedTextColor` | `#bdae93` (on glass) | `--fg2` |
| Accent (primary, active) | `--yellow` | `accentColor` / `accentTextColor` | `#fabd2f` | fill `#d79921`, text `#8a5a00` |
| Success / warning / error | `--aqua` / `--orange` / `--red` | `positive…` / `neutral…` / `negativeTextColor` | bright | darkened |
| Links, info | `--cyan` (`--link`, `--info`) | `infoColor` | `#5ccfc4` | `#0f6b66` |
| Picture areas (monitors, previews) | `.stage` | `stageColor` / `stageTextColor` (every kind) | `#282828` / `#ebdbb2` | the same: stays dark |
| Cut corner | `--chamfer` (16px) | `chamfer`, `chamferSmall` | 16 / 10 px at a grid unit of 18 | same |
| Headings font | `--font-heading`, uppercase | `headingFont(size)` | Rajdhani 700, +0.08em | same |
| Labels | small uppercase mono | `labelFont()` | JetBrains Mono, +0.14em | same |
| Figures | `--font-mono` | `monoFont(size, bold)` | JetBrains Mono | same |

### Rules for apps

- **System is the default and stays pixel-identical.** Every Kante change is a `Binding { when: KanteStyle.active }` (shapes, type, layouts) or `when: KanteStyle.themed` (palette, controls) or a part that is only visible in Kante; nothing is assigned once. Switching back restores the platform look.
- **Draw over, do not mutate.** Wrappers and skins hide the platform part (opacity) and draw their own frame, text or indicator. Rebinding a control's `font` or `color` does not restore reliably when the app starts in Kante.
- **Tint, do not paint.** Kante never paints the window or popup ground of a translucent host (Plasma blur); surfaces are tints (card 60 %, sunken 50 %, dialog 97 %). Colour only in small opaque areas: project bars, chart segments, the accent timer, primary buttons.
- **Muted text one step lighter on glass** (`#bdae93`), 4.5:1 against the darkest tint.
- **Shape:** square controls, cut top-right corner on cards and dialogs only, accent bar on top of active cards and dialogs.
- **Type:** titles and buttons uppercase Rajdhani, figures and small labels JetBrains Mono, body text stays the platform font.
- **Brightness follows the platform theme** (dark Gruvbox / light Leinen); an app that forces a dark platform style sets `preferDark`.
- **Material style (Android):** set `KanteStyle.materialStyle`. Kirigami then takes its colors from the Material attached properties, so hand Kante's colors to those on the window; `KanteScope` stays off, because Kirigami's Material bridge would pin `Material.theme` Light and fixed colors on every item whose Kirigami colors change.
- **Restore, do not freeze:** a `Binding` restores a color as a fixed value. For theme colors that must follow the platform again (`Kirigami.Theme` in `KanteScope`), assign `undefined` to reset them.
- **Test both kinds:** `tools/check-qml.sh` loads every component in System and Kante and checks that switching back restores the heading.

---

## Badge format

For shields.io badges in READMEs and landing pages:

```
https://img.shields.io/badge/<label>-<value>-<valueColor>?labelColor=1c1c20
```

| Badge | Value color | Example |
|---|---|---|
| Version | `fabd2f` | `version-0.2.0-fabd2f?labelColor=1c1c20` |
| Tech/platform | `5ccfc4` | `Plasma-6-5ccfc4?labelColor=1c1c20` |
| License | `a89984` | `license-GPL--3.0-a89984?labelColor=1c1c20` |

---

## Social preview / OG image

`docs/social-preview.png` in every project, referenced by `og:image` (plus `og:image:width/height` and `twitter:card=summary_large_image`). Generated, not hand-made: `python3 overview/tools/make-social.py [id ...]` (from the repo root) renders it from the project's `docs/icon.svg` (needs chromium). Run it again after a logo change. Also upload it under Settings → Social preview of the GitHub repo.

- **Size**: 1280×640 px
- **Background**: `--bg-hard` (`#1d2021`)
- **Logo**: colour version (`icon.svg`), centered, 144 px
- **Title**: project name in Rajdhani 700, uppercase, spaced, `--fg0`, up to 76 px (shrinks for long names)
- **Tagline**: `--fg2`, 26 px, system sans
- **Bottom strip**: `--bg2` line at 580 px, then `--fg3` mono line `github.com/shrippen/<repo>`

---

## Using in another project

**Landing page**: link the central stylesheet — no copy, changes propagate to every page:

```html
<link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://shrippen.github.io/v1/shrippen.css">
<script src="https://shrippen.github.io/v1/shrippen.js"></script>  <!-- in <head>, not deferred -->
```

`shrippen.js` handles the language switch, the nav brand reveal and the copy button. Pages are **English by default** with a DE switch: every visible text exists twice (`lang="en"` / `lang="de"`), the choice is stored in `localStorage`. The project name in the nav fades in once the hero has left the viewport. The hero carries a **watermark**: `<img class="hero-wm" src="icon-mono.svg" alt="" aria-hidden="true">` as the first child of `header.hero` (huge, 7 % opacity, bleeding off the right edge and, on a short hero, below it; scrolls with the page, never fixed). The page ends with a **signature footer** (`footer.foot`): the colour logo (`icon.svg`), project name and tagline, two link columns (Project / Source) and, under a short yellow line, license · author · version. A project that is not ready yet puts a full-width **banner** (`.banner` with `.banner-inner`, `.banner-title`, `.banner-text`; `.banner-danger` for red) as the very first element of `<body>`, above the nav. Hazard stripes on its top and bottom edge come from the component itself. A vibe-coded, experimental or unofficial project shows one notice as `<div class="section"><div class="callout callout-warn">` that is always the **first element in `<main>`**, before the facts strip and the features. A project built on or forked from another one adds “based on” or “fork of” to that line, and the name is always a link to the upstream repository (in both languages, for example `<span lang="en">based on <a href="…">name</a></span><span lang="de">basiert auf <a href="…">name</a></span>`). On tablet and phone (≤900px) the hero is one column: `<br class="split">` line breaks in the name are dropped, so the name is written out in full, and its size follows the width (`--title-size-narrow`, about `154/longest-word-length` vw). The Rajdhani font link now also loads JetBrains Mono (see the template).

**Every landing page carries the Umami tracker** in its `<head>`, the same tag with the same website ID on all pages (`<script defer src="https://um.arianw.de/script.js" data-website-id="056d39ee-6a9d-4b14-9902-5a1ac399df08"></script>`); it is already in the template, so do not remove or change it. The local preview strips the script, so visits there are not counted. Start from `templates/landing.html`. Components: nav (with `.lang` switch), facts strip (`.facts`), showcase rows (`.showcase`, screenshot beside text), architecture flow (`.flow`), input-syntax tokens (`.tokens`), FAQ (`.faq`), `<kbd>`, hero (big name left, yellow install box and screenshot right, both the same width), buttons, feature boxes with a colour bar on top (`data-tier="red|yellow|blue"`), prose section, steps, table, codeblock, callout, footer with a short yellow line. All boxes have only the top-right corner cut (`--chamfer`). Page ground is `--bg-void`, cards are `--bg-panel`. Breaking changes ship as `/v2/`; `/v1/` stays stable.

**Kimai (Knust)**: the theme `shrippen/kimai-knust-bundle` takes its colours from `https://shrippen.github.io/v1/knust-palette.css` (vendored, never edited there); only its Tabler mapping is written by hand. A colour changes in `tokens/palette.json`, `./build.sh`, then `bin/sync-palette.sh` in Knust.

**Plasma widget / Kirigami app**: follow the platform theme by default and use the shared accent (`#E8DCC4`) only for brand elements; for the opt-in Kante style use `qml/Kante` (see [Kante in apps](#kante-in-apps-qt-quick--kirigami)). Do not import CSS.

**README badges**: use the badge format above.

**Icons**: follow the icon language (24×24 viewbox, cream mark, themed variant).

---

*Palette derived from [Gruvbox](https://github.com/morhetz/gruvbox) by morhetz (MIT). Adapted with a warm-cream brand accent for the shrippen project family.*

## License

MIT, see [LICENSE](LICENSE). Exceptions: `kimai/knust` and `kimai/kit` are GPL-3.0-or-later, the fonts are under the SIL Open Font License 1.1.
