# shrippen landing-page design system

Dark-first, Gruvbox-derived CSS system for single-page project landing pages. There is **no JavaScript component library and no CSS framework**: you write plain HTML using the class names below, styled by one stylesheet.

## Setup

Link `styles.css` (it carries all tokens and components) and load the heading font before it. Never inline a copy of the CSS and never invent new hex values.

```html
<link rel="stylesheet" href="styles.css">
<body>
  <section class="hero">…</section>
  <footer>…</footer>
</body>
```

`styles.css` sets the page background, text color, and resets margins, so no wrapper element is needed. Headings use `var(--font-heading)` (Rajdhani, bundled in `fonts/`); body text uses the system sans stack.

## Styling idiom: CSS custom properties + named component classes

Use tokens via `var(--*)` for any glue styling, never raw colors:

- Surfaces: `--bg-hard` (code, hero depth), `--bg0` (page), `--bg1` (cards), `--bg2` (borders)
- Text: `--fg0` (headings only), `--fg1` (body), `--fg2` (secondary), `--fg3` (footer, placeholders)
- Brand: `--accent` (warm cream, icons and numerals)
- Semantic: `--blue` (links, primary action), `--aqua` success, `--green`, `--yellow` warning, `--orange`, `--red` error, `--purple`; neutral variants end in `-n` (`--blue-n`)
- Shape: `--radius` (12px), `--max-w` (860px content width)
- Type: `--font-heading`, `--font-sans`, `--font-mono`

There is no light mode. Emojis are not used as icons; use inline SVG (24×24, `stroke="currentColor"`, class `feat-icon` inside feature cards).

## Components (class vocabulary)

| Component | Classes |
|---|---|
| Nav (optional) | `nav > .nav-inner > a.nav-brand + .nav-links` |
| Hero | `section.hero > img.hero-icon, h1, p.tagline, .badges, .install-card, .install-links` |
| Badges | `.badges` containing shields.io `<img>` (labelColor 1c1c20; value e8dcc4 version, 83a598 tech, a89984 license) |
| Install card | `.install-card > label, .cmd-row > .cmd-box + button.copy-btn, p.install-note` (add `.copied` to the button for 1.5s on success) |
| Buttons | `.btn.btn-primary`, `.btn.btn-ghost`, wrapped in `.install-links` |
| Screenshot | `.screenshot-wrap > img` |
| Feature grid | `.features > .feat > svg.feat-icon?, h3, p` |
| Prose section | `.section > h2, p, ul` |
| Steps | `ol.steps > li` (numbers are automatic) |
| Table | `.table-wrap > table.table` |
| Code block | `.codeblock` (spans `.c` comment, `.k` keyword) |
| Callout | `.callout`, plus `.callout-warn`, `.callout-danger`, `.callout-ok` |
| Footer | bare `<footer>` |

Page order: nav (optional), hero, screenshot, features, sections (prerequisites, steps, tables), footer. Content is centered in an 860px column; layout glue of your own should use `max-width:var(--max-w);margin:0 auto;padding:0 1.5rem`.

## Where the truth lives

Read `styles.css` before styling: it holds every token and component rule. Each component folder under `components/` has a `.prompt.md` with usage notes and a rendered `.html` example to copy from.

## Example

```html
<section class="hero">
  <img class="hero-icon" src="icon.svg" alt="">
  <h1>Kurrent</h1>
  <p class="tagline">A KDE Plasma 6 task manager</p>
  <div class="install-links">
    <a class="btn btn-primary" href="#">Download</a>
    <a class="btn btn-ghost" href="#">GitHub</a>
  </div>
</section>
<section class="features">
  <div class="feat"><h3>Fast</h3><p>Opens instantly.</p></div>
</section>
<footer><p>GPL-3.0 · Made by shrippen</p></footer>
```
