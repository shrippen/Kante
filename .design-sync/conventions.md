# shrippen landing-page design system

Dark, Gruvbox-derived CSS system for single-page project landing pages. There is **no JavaScript component library and no CSS framework**: write plain HTML with the class names below, styled by one stylesheet plus one tiny script.

## Setup

Link `styles.css` (all tokens and components), load `shrippen.js` **synchronously in `<head>`** (language switch, nav reveal, copy button), and start from `<html lang="en">`. Never inline a copy of the CSS and never invent hex values.

```html
<html lang="en">
<head>
  <link rel="stylesheet" href="styles.css">
  <script src="shrippen.js"></script>
  <script defer src="https://um.arianw.de/script.js" data-website-id="056d39ee-6a9d-4b14-9902-5a1ac399df08"></script>
</head>
```

**Every landing page carries the Umami tracker line above**, identical on all pages. Never remove it or change the website ID.

`styles.css` paints the page ground (`--bg-void`) and resets margins; no wrapper is needed. Headings use Rajdhani, code and labels JetBrains Mono, body text the system sans (fonts are bundled in `fonts/`).

## Language: English by default, DE switch

Every visible text exists twice, as paired elements: `<p lang="en">…</p><p lang="de">…</p>` (inline: `<span lang="en">`). CSS hides the inactive one. Put the switch in the nav: `.lang > button[data-lang="en"|"de"]`. The choice is stored in `localStorage`. Never write single-language copy.

## Styling idiom: tokens + named component classes

Use tokens via `var(--*)` for glue styling, never raw colors:

- Surfaces: `--bg-void` (page), `--bg-panel` (cards), `--bg-hard` (code), `--bg1`, `--bg2` (borders)
- Text: `--fg0` (headings), `--fg1` (body), `--fg2` (secondary), `--fg3` (labels, footer)
- Accent: `--yellow` (install box, highlights, active states), `--accent` (cream, icons)
- Priority tiers: `--red`, `--yellow`, `--blue`. Also `--aqua` (success), `--green`, `--orange`, `--purple`
- Shape: `--chamfer` (16px). **Boxes have only the top-right corner cut** and no border radius; buttons are square.
- Layout: `--max-w-wide` (1280px), `--max-w` (860px prose), `--gutter`
- Type: `--font-heading`, `--font-sans`, `--font-mono`

Headings are uppercase Rajdhani 700. Labels are small uppercase mono with letter-spacing. Each project's logo is `icon.svg` (cream, yellow accent) with a fully monochrome twin `icon-mono.svg`, both in the project's `docs/` folder. Icons are inline SVG (24×24, `stroke="currentColor"`), never emojis. No light mode.

## Components

| Component | Classes |
|---|---|
| Nav | `nav.nav > .nav-inner > a.nav-brand + .nav-links`. The brand fades in when the hero leaves the viewport (`.brand-on`, set by the script). `.nav-links` holds `a`, `a.nav-hl` (yellow) and `.lang` |
| Hero | `header.hero > img.hero-wm (watermark: icon-mono.svg, alt="") + .hero-main (h1, p.tagline) + .hero-side (.install-card, .hero-shot)`. The watermark is faint, scrolls with the page, is never fixed and may bleed below a short hero (the content after the hero paints above it). The h1 is the bare project name, uppercase; on desktop split the name with `<br class="split">` (keep a space before it when splitting between words, e.g. `Kimai <br class="split">Abrechnung`). The split is removed on tablet and phone, where the name is written out and sized to the width; set `--title-size-narrow` (about `154/longest-word-length` vw) and, for very long names, `--title-size` |
| Install box | `.install-card > label, .cmd-row > .cmd-box + button.copy-btn, p.install-note, .install-links` (yellow; the script handles copying) |
| Buttons | `.btn.btn-primary` and `.btn.btn-ghost` inside the yellow box; `.btn.btn-accent` on the dark page |
| Screenshot | `.hero-shot > img`, same width as the install box |
| Feature boxes | `.features > .feat[data-tier="red|yellow|blue"] > span.feat-tag, h3, p` (colour bar on top) |
| Prose section | `.section > h2, p, ul` |
| Steps | `ol.steps > li` |
| Table | `.table-wrap > table.table` |
| Code block | `.codeblock` (`.c` comment, `.k` keyword) |
| Banner | `.banner` > `.banner-inner` > `.banner-title` + `.banner-text`, `.banner-danger`. Full-width status notice, the first element of `<body>` above the nav, for pages that are not ready yet |
| Callout | `.callout` + `.callout-warn`, `.callout-danger`, `.callout-ok`. A project notice (vibe-coded, experimental, unofficial) is one `.callout-warn` inside `<div class="section">`, always the first element in `<main>`, before the facts strip and the features |
| Facts | `section.facts > .fact > b + span` (3–4 true figures, e.g. counts of views, languages, backends) |
| Showcase | `section.showcase > .showcase-text (span.showcase-tag, h2, p, ul) + figure (img, figcaption)`; `.rev` flips the row, `figure.native` keeps small crops at natural size |
| Flow | `.flow > .flow-node (b, span) + span.flow-arrow + …`; `.hl` on the node the user touches |
| Tokens | `.tokens > .tok[data-k="text\|date\|prio\|tag\|project"] > code + small` for input syntax |
| FAQ | `.faq > details > summary + div > p` (inside a `.section`) |
| Key cap | `<kbd>` |
| Badges | `.badges` with shields.io images (optional) |
| Footer | `footer.foot > .foot-inner (.foot-brand: img icon.svg (colour logo) + .foot-name + .foot-tag; nav.foot-cols with two `div` columns of `h4` + links) + .foot-meta > p` (license · author · version; the short yellow line is drawn by CSS) |

Page order: nav, hero, facts (optional), feature boxes, showcases, sections (steps, tables, install, config, FAQ, roadmap), footer. Rich pages alternate `.showcase` and `.showcase.rev` rows, each pairing one pixelated screenshot with a short text. The hero puts the name first with no sentence above it; the tagline sits directly under the name.

## Where the truth lives

Read `styles.css` before styling: it holds every token and rule. Each component folder has a `.prompt.md` and a rendered `.html` example to copy from.

## Example

```html
<header class="hero">
  <div class="hero-main">
    <h1>Kur<br class="split">rent</h1>
    <p class="tagline" lang="en">Tasks in the Plasma panel.</p>
    <p class="tagline" lang="de">Aufgaben im Plasma-Panel.</p>
  </div>
  <div class="hero-side">
    <div class="install-card"><label>Installation</label>
      <div class="cmd-row"><div class="cmd-box">[INSTALL COMMAND]</div></div>
      <div class="install-links"><a class="btn btn-primary" href="#">Download</a><a class="btn btn-ghost" href="#">GitHub</a></div>
    </div>
  </div>
</header>
<section class="features">
  <div class="feat" data-tier="red"><span class="feat-tag">Tier red</span><h3>Priority</h3><p>Short text.</p></div>
</section>
```
