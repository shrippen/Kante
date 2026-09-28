# Kante

*Paths in this document are relative to `kante/`; `./build.sh` in the repo root builds everything. The overview page and the demo data live in [`../overview`](../overview) and [`../demo`](../demo).*

Shared design language for [shrippen](https://github.com/shrippen) projects, **one style for the web and for apps**: the same palette, type, shapes and roles on landing pages (CSS) and in Qt Quick / Kirigami apps and Plasma widgets (QML). The name is the signature shape: every box has its top-right corner cut (*Kante*, edge).

This document defines the **palette, typographic rules, icon style, landing-page layout and app foundation** that make the family feel cohesive. `tokens/palette.json` is the single source for both sides; see [Kante in apps](#kante-in-apps-qt-quick--kirigami).

Gruvbox-inspired, warm, dark-first.

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
| `blue` | `#83a598` | Primary action, links, interactive |
| `aqua` | `#8ec07c` | Success, confirm, online |
| `green` | `#b8bb26` | Positive diff, badges |
| `yellow` | `#fabd2f` | Warnings, attention |
| `orange` | `#fe8019` | Active / highlight |
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
- **Primary action** color is Gruvbox `bright_blue` (`#83a598`), not KDE's Breeze blue — but in Plasma widgets the native `Kirigami.Theme.highlightColor` takes over; the shared blue only applies to web pages and standalone assets.
- The remaining Gruvbox brights slot into semantic roles (aqua = success, orange = highlight, red = error, etc.) so every project draws from the same well without inventing one-off hues.

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
| `blue` | `#83a598` | `#076678` | Action, links |
| `aqua` | `#8ec07c` | `#427b58` | Success, bars |
| `yellow` | `#fabd2f` | `#8a5a00` | Score, warnings |
| `orange` | `#fe8019` | `#af3a03` | Active / highlight |
| `red` | `#fb4934` | `#9d0006` | Error |

The ground sits between Gruvbox `light0` (`#fbf1c7`, too yellow) and `#f5f1e8` (too bright); cards are one step lighter than the ground but never white. **Sand** (`#ebe3cf` ground, `#f4eedd` cards) is the darker alternative. Semantic colors are the darkened counterparts, so all text pairs reach WCAG AA. The role tokens `--field`, `--score` (yellow) and `--hl` (orange) follow the theme. Icon: on light grounds use a dark square (`#3c3836`) with the yellow marks.

### App components (`.tile`, `.stage`, `.band`, `.field`, `.pill`, `.dialog`, …)

Landing pages do not need them; apps do (used by the Kader companion UI). They follow the theme roles (`--field`, `--score`, `--hl`, `--scrim`; in QML also `KanteStyle.tagColor` for topics and tags and `KanteStyle.warningColor` for mild warnings), so they work in the dark default and in the light theme. Image stages stay dark in both themes on purpose (judging colour on a beige ground is misleading). Group colours: green `--aqua`, yellow `--yellow`, red `--red`; status is never colour alone. Reference cards live in `ds-bundle/components/App/`. Behaviour (dragging, handles, locking) is the app's job.

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
| Shape language | Rounded corners, soft geometry. No sharp 90° intersections unless depicting a clear UI metaphor (checkbox, grid). |
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
  --radius:   12px;
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
- **Links & primary buttons**: `--blue`. Hover darkens 10%.
- **Install card**: `--bg1` surface, `--bg2` border, `--bg-hard` inner code box, command text in `--blue`.
- **Copy button**: `--bg2` bg, on success flash `--aqua` border + text for 1.5 s.
- **Icons in feature cards**: inline SVG (`.feat-icon`, 24×24, stroke `currentColor`) — no emojis.
- **Feature grid**: `--bg1` cards, `--bg2` border, `1.2rem` gap, `auto-fit minmax(240px, 1fr)`.
- **Screenshot**: `--radius` corners, `1px --bg2` border, deep `box-shadow`.
- **Badges**: shields.io with `labelColor=1c1c20` and value color `e8dcc4` (version), `83a598` (tech tag), `a89984` (license).
- **OG image**: dark card on `--bg-hard`, project icon centered, name below in `--fg0`, tagline in `--fg2`.
- **Max content width**: `--max-w` (`860px`). Centered with `margin: 0 auto`.
- **No light mode** for landing pages (matches the dark-first palette). Apps may opt in to the Light theme below; Plasma widgets use whatever the user's Plasma theme provides.
- **Mobile**: Install command box font shrinks to `0.75rem`, hero padding reduces. Feature grid collapses to 1 col.

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
| `KanteScope` | Hands the Kante colours to an item's `Kirigami.Theme`, so plain controls below follow. Popups need their own |
| `KanteCard` | Card with the cut corner and an optional accent bar (`chamfer`, `barColor`) |
| `KanteButton`, `KanteToolButton`, `KanteTextField`, `KanteHeading`, `KanteDialog` | Wrappers: the platform control in System; in Kante square, uppercase Rajdhani, sunken fields, accent-filled primary (`emphasis`) |
| `KanteCheckSkin`, `KanteFieldSkin`, `KanteSliderSkin`, `KantePopupSkin`, `KanteMessageSkin`, `KanteDialogSkin`, `KantePageTitle` | Skins placed *inside* an existing control (check box, radio button, switch, combo/spin box, text area, slider, menu, `Kirigami.InlineMessage`, Kirigami dialog, page header) |
| `KantePullToRefresh` | Pull to refresh for a `Kirigami.Page` with a `QQC2.ScrollView` |
| `../KantePlasma` | `KantePlasmaButton`, `KantePlasmaToolButton`, `KantePlasmaHeading`: the same wrappers on PlasmaComponents3 / PlasmaExtras for Plasma widgets |
| `fonts/` | Rajdhani 600/700, JetBrains Mono 400/500 (SIL OFL), loaded by `KanteStyle`, never installed |

### Kante Light

The quieter variant for apps that should sit next to Breeze / Kirigami apps and still read as Kante. **Every color comes from the platform:** in Qt `KanteStyle` forwards `Kirigami.Theme` live (any color scheme, light or dark, switched at runtime); on the web the Breeze palette follows `prefers-color-scheme`. Kante contributes shape and type only:

| From the platform | From Kante |
|---|---|
| All colors (text, surfaces, highlight, positive/neutral/negative) | Top-right cut corner and accent bar (in the highlight color) on cards and tiles |
| Buttons, fields, check boxes, switches, menus, dialogs | Page and app titles in uppercase Rajdhani (`titleFont`, `KantePageTitle`, `KanteHeading { pageTitle: true }`) |
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
| Links, info | `--blue` | `infoColor` | `#83a598` | `#076678` |
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
| Version | `e8dcc4` | `version-0.2.0-e8dcc4?labelColor=1c1c20` |
| Tech/platform | `83a598` | `Plasma-6-83a598?labelColor=1c1c20` |
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

**Plasma widget / Kirigami app**: follow the platform theme by default and use the shared accent (`#E8DCC4`) only for brand elements; for the opt-in Kante style use `qml/Kante` (see [Kante in apps](#kante-in-apps-qt-quick--kirigami)). Do not import CSS.

**README badges**: use the badge format above.

**Icons**: follow the icon language (24×24 viewbox, cream mark, themed variant).

---

*Palette derived from [Gruvbox](https://github.com/morhetz/gruvbox) by morhetz (MIT). Adapted with a warm-cream brand accent for the shrippen project family.*

## License

All rights reserved. This design system is public for reference only and is not intended for public use. See [LICENSE](../LICENSE).
