#!/usr/bin/env python3
"""Builds ds-bundle/ (Claude Design upload layout) from docs/v1/shrippen.css. build.sh runs it as its last step."""
import os, shutil, re
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B = os.path.join(R, 'ds-bundle')
shutil.rmtree(B, ignore_errors=True)

def w(path, s):
    p = os.path.join(B, path); os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w').write(s)

# fonts + styles + script
os.makedirs(B + '/fonts')
FACES = [('Rajdhani', 500), ('Rajdhani', 600), ('Rajdhani', 700), ('JetBrainsMono', 400), ('JetBrainsMono', 500)]
ff = ''
for fam, wt in FACES:
    shutil.copy(f'{R}/fonts/{fam}-{wt}.ttf', f'{B}/fonts/{fam}-{wt}.ttf')
    name = 'JetBrains Mono' if fam == 'JetBrainsMono' else fam
    ff += f"@font-face{{font-family:'{name}';font-weight:{wt};font-display:swap;src:url(fonts/{fam}-{wt}.ttf) format('truetype')}}\n"
css = open(f'{R}/docs/v1/shrippen.css').read()
w('styles.css', ff + css)
shutil.copy(f'{R}/docs/v1/shrippen.js', f'{B}/shrippen.js')
MARK_UNUSED=None
# tokens
shutil.copytree(f'{R}/tokens', f'{B}/tokens', ignore=shutil.ignore_patterns('*.qml'))

# components: (group, name, html, prompt)
MARK = '<svg viewBox="4 4 40 40" width="96" height="96" fill="none"><g transform="scale(2) translate(1 1)"><path d="M 5.879 9.379 L 8.5 12 L 16.121 4.379 L 17.535 5.793 L 8.5 14.828 L 4.465 10.793 Z" fill="#E8DCC4"/><path fill="#FABD2F" d="M 2 15 C 4.5 13 6.5 17 9 15 C 11.5 13 13.5 17 16 15 C 18.5 13 20 17 22 15 V 17 C 20 19 18.5 15 16 17 C 13.5 19 11.5 15 9 17 C 6.5 19 4.5 15 2 17 Z"/></g></svg>'
ICON = '<svg class="feat-icon" viewBox="0 0 24 24"><path d="M13 2L3 14h9l-1 8 10-12h-9z"/></svg>'
BADGE = lambda l, v, c: f'<img alt="{l}" src="https://img.shields.io/badge/{l}-{v}-{c}?labelColor=1c1c20">'
MOCK = '<div style="padding:16px 20px;display:flex;flex-direction:column;gap:10px">' + ''.join(f'<div style="display:flex;gap:12px"><div style="width:5px;background:{c}"></div><div style="font-size:15px;color:var(--fg1)">{t}</div></div>' for t, c in [('Release notes schreiben', 'var(--red)'), ('Pull Request 42 prüfen', 'var(--yellow)'), ('Papierrollen nachbestellen', 'var(--blue)')]) + '</div>'
INSTALL = '<div class="install-card"><label>Installation</label><div class="cmd-row"><div class="cmd-box">[INSTALL COMMAND]</div><button class="copy-btn" type="button" aria-label="Copy"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button></div><p class="install-note" lang="en">Requires Plasma 6.</p><p class="install-note" lang="de">Benötigt Plasma 6.</p><div class="install-links"><a class="btn btn-primary" href="#">Download</a><a class="btn btn-ghost" href="#">GitHub</a></div></div>'
LANG = '<div class="lang" role="group" aria-label="Language"><button type="button" data-lang="en" aria-pressed="true">EN</button><button type="button" data-lang="de" aria-pressed="false">DE</button></div>'

# ── App components (Companion-UI) ──
NEG = '<svg viewBox="0 0 300 200" preserveAspectRatio="xMidYMid slice" aria-hidden="true"><rect width="300" height="200" style="fill:var(--bg-hard)"/><rect x="24" y="16" width="252" height="168" style="fill:var(--bg1)"/><path d="M24 152 L92 94 L142 134 L192 72 L276 152 V184 H24Z" style="fill:var(--bg2)"/><circle cx="214" cy="52" r="14" style="fill:var(--fg3)"/></svg>'
CHK = '<svg viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5" stroke-linecap="square"/></svg>'
MID = '<svg viewBox="0 0 24 24"><path d="M5 12h14" stroke-linecap="square"/></svg>'
BAD = '<svg viewBox="0 0 24 24"><path d="M12 5v9M12 18.5v.5" stroke-linecap="square"/></svg>'
def TILE(tier, name, conf, sub, ic, inset='8%', sel=False, sm=False):
    meta = f'<span class="tile-meta"><span class="tile-name">{name}</span><span class="tile-conf">{ic}{conf}</span><span class="tile-sub">{sub}</span></span>'
    return f'<button class="tile{" tile-sm" if sm else ""}" data-tier="{tier}" aria-selected="{str(sel).lower()}"><span class="tile-img">{NEG}<span class="tile-crop" style="--in:{inset}"></span><span class="tile-check">{CHK}</span></span>{meta}</button>'
TILES = '<div class="tiles">' + TILE('green','20250414_0164.arw','0.91','edge · hough',CHK) + TILE('yellow','20250414_0171.arw','0.62','strategies disagree',MID,'5% 13% 10% 6%',True) + TILE('red','20250414_0183.arw','0.31','border too dark',BAD,'2% 30% 2% 3%') + '</div>'
SEG = lambda items, on: '<div class="seg" role="group">' + ''.join(f'<button type="button" aria-pressed="{str(i==on).lower()}">{t}</button>' for i, t in enumerate(items)) + '</div>'
HANDLES = ''.join(f'<i class="handle" data-h="{h}"></i>' for h in ['nw','n','ne','w','e','sw','s','se'])
EDITOR = ('<div class="toolbar"><span class="toolbar-label">Aspect</span>' + SEG(['Free','6:6','3:2','Original'],1) + '<span class="toolbar-sep"></span><span class="toolbar-label">Candidates</span>' + SEG(['A edge','B hough','C flood'],0) + '</div>'
  '<div class="stage" style="margin-top:12px">' + NEG.replace('<svg ','<svg style="position:absolute;inset:0;width:100%;height:100%" ') +
  '<div class="cand" style="--l:7%;--t:9%;--r:8%;--b:7%;--c:var(--blue)"><span class="cand-tag">A · 0.82</span></div>'
  '<div class="cand" style="--l:10%;--t:8%;--r:5%;--b:10%;--c:var(--purple)"><span class="cand-tag is-right">B · 0.74</span></div>'
  f'<div class="cropbox" style="--l:8%;--t:8%;--r:8%;--b:8%">{HANDLES}</div><span class="readout">3612 × 3612 px · 6:6</span></div>'
  '<div class="strip" style="margin-top:12px">' + ''.join(f'<button data-tier="{t}"{" aria-current=\"true\"" if i==2 else ""}>{NEG}</button>' for i, t in enumerate(['green','green','yellow','green','red'])) + '</div>')
def BAND(tier, label, items):
    return f'<div class="band" data-tier="{tier}"><div class="band-head"><span>{label}</span><span>{len(items)}</span></div>' + ''.join(TILE(tier, 'x', c, '', ic, sm=True, sel=(i==0 and tier=="yellow")) for i, (c, ic) in enumerate(items)) + '</div>'
BANDS = '<div class="bands">' + BAND('green','Green',[('0.91',CHK),('0.88',CHK)]) + BAND('yellow','Yellow',[('0.62',MID),('0.58',MID)]).replace('class="band" data-tier="yellow"','class="band is-over" data-tier="yellow"') + BAND('red','Red',[('0.31',BAD)]) + '</div>'
CONTROLS = ('<div class="panel-grid" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:18px 24px">'
  '<div class="field"><span class="field-label">Format</span>' + SEG(['Auto','6×6','6×7','35 mm'],1) + '</div>'
  '<div class="field"><label for="ds-film">Film border level</label><input class="input" id="ds-film" type="number" value="34"><span class="field-hint">0–255, empty = automatic</span></div>'
  '<div class="field range" style="grid-column:1/-1;--zones:linear-gradient(90deg,var(--red) 0 45%,var(--yellow) 45% 70%,var(--aqua) 70% 100%)"><label for="ds-thr">Confidence threshold</label><div class="range-row"><input id="ds-thr" type="range" min="0" max="100" value="70"><output class="range-out">0.70</output></div></div>'
  '<div class="field"><label for="ds-strat">Strategy</label><select class="select" id="ds-strat"><option>All, merged</option><option>Edges only</option></select></div>'
  '<div class="field"><span class="field-label">Options</span><button class="switch" role="switch" aria-checked="true" type="button"><span class="switch-track"></span>Aspect penalty</button><button class="switch" role="switch" aria-checked="false" type="button"><span class="switch-track"></span>Skip refine</button></div></div>')
STATUS = ('<div style="display:flex;flex-wrap:wrap;gap:8px"><span class="pill" data-state="analyzing">Analyzing</span><span class="pill" data-state="reviewing">Reviewing</span><span class="pill" data-state="locked">Locked</span><span class="pill" data-state="applied">Applied</span><span class="pill" data-state="failed">Failed</span></div>'
  '<div class="progress" style="margin-top:16px"><div class="progress-head"><span>Export from darktable</span><span>92 / 148</span></div><div class="progress-bar"><i style="--p:62%"></i></div></div>'
  '<div class="progress" style="margin-top:16px"><div class="progress-head"><span>Result</span><span>112 green · 24 yellow · 12 red</span></div><div class="progress-bar"><i data-tier="green" style="--p:75.7%"></i><i data-tier="yellow" style="--p:16.2%"></i><i data-tier="red" style="--p:8.1%"></i></div></div>'
  '<div style="display:flex;flex-wrap:wrap;gap:12px;margin-top:16px"><div class="toast">Re-detected: 6 images</div><div class="toast" data-kind="ok">Plan saved</div><div class="toast" data-kind="error">Export failed: 0183</div></div>')
DIALOG = ('<div style="position:relative;min-height:480px;background:var(--bg-void);border:1px solid var(--bg1)"><div class="scrim"><div class="dialog" role="dialog" aria-modal="true" aria-labelledby="dlg-h"><h3 id="dlg-h">Finish review?</h3>'
  '<div class="dialog-facts"><div class="fact"><b>136</b><span>Apply</span></div><div class="fact"><b style="color:var(--red)">12</b><span>Flagged red</span></div><div class="fact"><b style="color:var(--fg3)">0</b><span>Skipped</span></div></div>'
  '<div class="callout callout-warn"><strong>Locks this session.</strong> Continue in darktable. You can reopen the review from here if you are not happy there.</div>'
  '<div class="dialog-actions"><button class="btn btn-outline" type="button">Back</button><button class="btn btn-accent" type="button">Finish</button></div></div></div></div>')
C = [
 ('Layout', 'Nav', f'<nav class="nav brand-on"><div class="nav-inner"><a class="nav-brand" href="#">Kurrent</a><div class="nav-links"><a href="#"><span lang="en">Features</span><span lang="de">Funktionen</span></a><a href="#">Roadmap</a><a class="nav-hl" href="#">GitHub</a>{LANG}</div></div></nav>',
  'Sticky top bar. The project name (`.nav-brand`) is hidden while the hero is visible and fades in once the hero leaves the viewport; the class `.brand-on` is toggled by `shrippen.js` (shown here in its revealed state). Links are mono uppercase, the GitHub link uses `.nav-hl` (yellow). The language switch `.lang` sits last.'),
 ('Layout', 'Hero', f'<header class="hero"><div class="hero-main"><h1>Kur<br class="split">rent</h1><p class="tagline" lang="en">Tasks in the Plasma panel.</p><p class="tagline" lang="de">Aufgaben im Plasma-Panel.</p></div><div class="hero-side">{INSTALL}<div class="hero-shot">{MOCK}</div></div></header>',
  'Optional first child `img.hero-wm` (the monochrome logo, `alt=""`) is a faint watermark that scrolls with the page and may bleed below a short hero (later content paints above it). Two columns: `.hero-main` holds the giant uppercase project name (`h1`, no sentence above it) with the tagline directly beneath; `.hero-side` holds the yellow `.install-card` on top and the `.hero-shot` below, both the same width. Stacks to one column under 900px. On desktop the name may be split with `<br class="split">` (keep a space before it when splitting between words). Under 900px the split is dropped and the name is written out in full, sized by `--title-size-narrow` (about `154/longest-word-length` vw; default `22vw`). Very long names also get `--title-size` for desktop.'),
 ('Layout', 'Section', '<section class="section"><h2 lang="en">Prerequisites</h2><h2 lang="de">Voraussetzungen</h2><ul lang="en"><li><strong>Plasma 6</strong> or newer</li><li>Qt 6.6</li></ul><ul lang="de"><li><strong>Plasma 6</strong> oder neuer</li><li>Qt 6.6</li></ul></section>',
  'Prose block: uppercase `h2`, `p`, `ul`. Text exists in both languages as paired `lang="en"` / `lang="de"` elements.'),
 ('Layout', 'Footer', f'<footer class="foot"><div class="foot-inner"><div class="foot-brand">'+MARK+'<div><span class="foot-name">Kurrent</span><span class="foot-tag">A KDE Plasma 6 task manager</span></div></div><nav class="foot-cols"><div><h4>Project</h4><a href="#">Features</a><a href="#">Roadmap</a></div><div><h4>Source</h4><a href="#">GitHub</a><a href="#">Issues</a></div></nav></div><div class="foot-meta"><p>GPL-3.0-or-later · shrippen · v0.3.1</p></div></footer>',
  '`footer.foot`: signature footer. `.foot-brand` holds the colour logo (`icon.svg`, 96px), the project name (`.foot-name`, spaced uppercase Rajdhani) and a short tagline (`.foot-tag`). `nav.foot-cols` has two columns (Project, Source) with an `h4` and links each. `.foot-meta > p` carries license · author · version; a short yellow line left of it is drawn by CSS. Every visible text is bilingual (paired `lang` elements).'),
 ('Actions', 'Button', '<div style="display:flex;gap:16px;flex-wrap:wrap"><div class="install-card" style="padding:16px"><div class="install-links"><a class="btn btn-primary" href="#">Download</a><a class="btn btn-ghost" href="#">GitHub</a></div></div><a class="btn btn-accent" href="#">On dark page</a></div>',
  'Square uppercase heading-font buttons. `.btn-primary` (dark) and `.btn-ghost` (outline) are for use inside the yellow install box; `.btn-accent` (yellow) is for the dark page.'),
 ('Actions', 'InstallCard', INSTALL,
  'The yellow install box with top-right chamfer: `label`, `.cmd-row` with `.cmd-box` and `button.copy-btn`, optional `.install-note`, then `.install-links`. `shrippen.js` copies the `.cmd-box` text and flashes `.copied` for 1.5s.'),
 ('Actions', 'LanguageSwitch', LANG,
  'EN/DE toggle `.lang` with two `button[data-lang]`. English is the default; `shrippen.js` sets `<html lang>` and stores the choice. Place it last inside `.nav-links`.'),
 ('Content', 'Badges', f'<div class="badges">{BADGE("version","1.0.0","e8dcc4")}{BADGE("Plasma","6","83a598")}{BADGE("license","GPL--3.0","a89984")}</div>',
  'Optional shields.io badges, always `labelColor=1c1c20`. Value colors: version `e8dcc4`, tech `83a598`, license `a89984`. The hero itself does not use badges; the footer carries license and version.'),
 ('Content', 'Screenshot', f'<div class="hero-shot" style="max-width:520px">{MOCK}</div>',
  '`.hero-shot > img`, chamfered box below the install box in `.hero-side`; always the same width as the install box.'),
 ('Content', 'FeatureGrid', '<div class="features" style="padding:0">' + ''.join(f'<div class="feat" data-tier="{t}"><span class="feat-tag"><span lang="en">Tier {t}</span><span lang="de">Stufe {d}</span></span><h3 lang="en">Feature {i}</h3><h3 lang="de">Funktion {i}</h3><p lang="en">Short description of what it does.</p><p lang="de">Kurze Beschreibung der Funktion.</p></div>' for i, t, d in [(1, 'red', 'rot'), (2, 'yellow', 'gelb'), (3, 'blue', 'blau')]) + '</div>',
  'Auto-fit grid of `.feat` boxes. `data-tier="red|yellow|blue"` sets the colour bar on top and the `.feat-tag` colour (same colours as the priority bands). Only the top-right corner is cut. Headings are uppercase Rajdhani.'),
 ('Content', 'Steps', '<div class="section" style="padding:0"><ol class="steps"><li>Download the release.</li><li>Run the install command.</li><li>Add the widget to your panel.</li></ol></div>',
  '`ol.steps` with automatic numbered squares in yellow. Pair with a `.codeblock` for commands.'),
 ('Content', 'Table', '<div class="table-wrap"><table class="table"><tr><th>Display</th><th>Status</th></tr><tr><td><code>epd2in7</code></td><td>Supported</td></tr><tr><td><code>epd4in2</code></td><td>Supported</td></tr></table></div>',
  '`.table-wrap > table.table` for compatibility matrices. The wrapper scrolls horizontally on narrow screens and has the top-right chamfer.'),
 ('Content', 'CodeBlock', '<div class="codeblock"><span class="c"># install</span>\n<span class="k">git</span> clone https://github.com/shrippen/Kurrent</div>',
  'Multi-line monospace block on `--bg-hard`. `.c` spans for comments, `.k` for commands.'),
 ('Content', 'Callout', '<div class="callout"><strong>Note:</strong> Neutral hint.</div><div class="callout callout-warn"><strong>Heads up:</strong> Partly AI-assisted.</div><div class="callout callout-danger"><strong>Danger:</strong> Destructive.</div><div class="callout callout-ok"><strong>Done:</strong> Success.</div>',
  'Boxed note with a colour bar on top. Default blue; `.callout-warn` yellow (disclaimers), `.callout-danger` red, `.callout-ok` aqua.'),
 ('Content', 'Banner', '<div class="banner" role="note" style="margin:0"><div class="banner-inner"><div class="banner-title">Not ready for primetime</div><p class="banner-text">Work in progress. The detection is not reliable yet.</p></div></div>',
  'Full-width status notice with hazard stripes on its top and bottom edge, big uppercase title and a mono line. It is the very first element of `<body>`, above the nav, for pages whose project is not ready yet. Yellow by default, `.banner-danger` is red. Remove it once the project is ready.'),
 ('Content', 'Facts', '<section class="facts" style="padding:0"><div class="fact"><b>6</b><span>View modes</span></div><div class="fact"><b>6</b><span>Languages</span></div><div class="fact"><b>0</b><span>Extra logins</span></div><div class="fact"><b>GPL-3</b><span>Open source</span></div></section>',
  '`section.facts` with three or four `.fact` items: a big yellow figure in `b` and a mono label in `span`. Only use figures that are true and checkable (counts of features, languages, backends), never marketing numbers.'),
 ('Content', 'Showcase', '<section class="showcase" style="padding:0"><div class="showcase-text"><span class="showcase-tag">Kanban</span><h2>Move work along</h2><p>Short paragraph about the feature.</p><ul><li>First point</li><li>Second point</li></ul></div><figure><div style="height:200px;background:var(--bg-hard)"></div><figcaption>Kanban view</figcaption></figure></section>',
  'Text beside one screenshot: `section.showcase > .showcase-text (span.showcase-tag, h2, p, ul) + figure (img, figcaption)`. Add `.rev` to put the figure on the left, and `figure.native` for small crops that should not be enlarged. Tall screenshots are cropped from the top (max 30rem). Stacks to one column under 900px. Only use pixelated screenshots when they show personal data.'),
 ('Content', 'Flow', '<div class="flow"><div class="flow-node hl"><b>Widget</b><span>What it is</span></div><span class="flow-arrow"></span><div class="flow-node"><b>Plugin</b><span>What it does</span></div><span class="flow-arrow"></span><div class="flow-node"><b>Service</b><span>Where data lives</span></div></div>',
  'An architecture in one line: `.flow` with `.flow-node` boxes (`b` title, `span` text) joined by `span.flow-arrow`. `.hl` marks the box the user touches. Arrows turn downwards and the boxes stack on narrow screens.'),
 ('Content', 'Tokens', '<div class="tokens"><div class="tok" data-k="text"><code>Send invoice</code><small>Title</small></div><div class="tok" data-k="date"><code>tomorrow 18:00</code><small>Date</small></div><div class="tok" data-k="prio"><code>!high</code><small>Priority</small></div><div class="tok" data-k="tag"><code>#tag</code><small>Label</small></div><div class="tok" data-k="project"><code>@project</code><small>Project</small></div></div>',
  'An input syntax split into parts, each with a coloured top edge and a label below: `.tokens > .tok[data-k="text|date|prio|tag|project"] > code + small`. Use for command lines and quick-add syntax.'),
 ('Content', 'Faq', '<div class="faq"><details open><summary>A question?</summary><div><p>The answer.</p></div></details><details><summary>Another question?</summary><div><p>Another answer.</p></div></details></div>',
  'Native `details`/`summary` accordion in `.faq`. Put it in a `.section` under an `h2`. The open item gets a yellow top edge. Every question and answer exists in both languages (paired `lang` elements).'),
 ('App', 'Tile', TILES,
  'Image tile for galleries: a preview with the detected crop drawn on it (`.tile-crop`, inset set by `--in`), file name (`.tile-name`), confidence (`.tile-conf`, with an icon: check / dash / exclamation) and a short hint (`.tile-sub`). The group is `data-tier="green|yellow|red"` and shows as a colour bar on top, like `.feat`. Green is `--aqua` (not `--green`, which is too close to yellow). Status is never colour alone: bar + icon + number. `aria-selected="true"` gives the selection frame (`--hl`) and a check square; keyboard focus is a yellow inner frame (inner, so the chamfer never clips it). `.tile-sm` is the compact variant (image + confidence only). The preview area is dark in both themes. Wrap tiles in `.tiles` (auto-fill grid).'),
 ('App', 'CropEditor', EDITOR,
  'Large crop view. `.stage` is intentionally **rectangular** (no chamfer): the eight `.handle[data-h=nw|n|ne|w|e|sw|s|se]` must reach every corner. `.cropbox` takes its edges from `--l/--t/--r/--b`, dims everything outside with `--scrim` and shows a thirds grid. `.cand` are dashed candidate overlays (colour via `--c`, label in `.cand-tag`). `.readout` shows size and ratio. The stage is dark in both themes. Around it: `.toolbar` (with `.seg` controls) and `.strip`, a filmstrip of neighbours whose current item has `aria-current="true"`. Dragging and keyboard nudging are the app\'s job.'),
 ('App', 'Bands', BANDS,
  'Three group bands (`.band[data-tier]`) for sorting by drag-and-drop; the head shows the group name and count. While dragging: the target band gets `.is-over` (dashed frame in the group colour, lighter ground), dragged tiles get `.is-dragging` (40 % opacity). When several selected tiles are dragged together, show the number in a `.drag-badge`. Collapses to one column under 640px.'),
 ('App', 'Controls', CONTROLS,
  'Form controls, all square with mono labels: `.field` (label + control + `.field-hint`), `.input`, `.select`, `.seg` (segmented buttons; same look as the language switch `.lang`, `aria-pressed` marks the active one), `.range` (slider; set `--zones` to a gradient to tint the track, e.g. group thresholds; `.range-out` shows the value in `--score`) and `.switch` (`role="switch"`, `aria-checked`; state shows by position and colour). Fields use `--field`, so they follow the theme. Keyboard focus is a yellow outline.'),
 ('App', 'Status', STATUS,
  '`.pill[data-state=analyzing|reviewing|locked|applied|failed]`: session phase with a distinct shape per state (pulsing dot, ring, square, check, cross), not colour alone; the pulse stops under `prefers-reduced-motion`. `.progress` (`.progress-head` + `.progress-bar > i`): one yellow segment for progress, or several `i[data-tier]` segments for a distribution; width via `--p`. `.toast[data-kind=ok|error]`: short feedback, colour bar on top.'),
 ('App', 'Dialog', DIALOG,
  '`.scrim` (dimmed layer, `position:absolute` inside a `position:relative` container; `.scrim.is-fixed` for the whole window) with a `.dialog`: chamfered box, yellow bar, `h3`, `.dialog-facts` (three `.fact` figures), an optional `.callout` and `.dialog-actions` (`.btn-outline` + `.btn-accent`; `.btn-ghost` is only for the yellow install box, and `button.btn` needs no extra reset). To lock a screen after a confirmed step, put `.is-locked` on its container: tiles and bands stop reacting, images desaturate, and every element marked `data-lockable` is dimmed and disabled; show a `.callout-ok` with the next step. Locking is reversible in the app (a "Reopen" action).'),
]
for g, n, html, prompt in C:
    d = f'components/{g}/{n}/'
    w(d + n + '.html', f'<!-- @dsCard group="{g}" -->\n<!doctype html><html lang="en"><head><meta charset="utf-8"><link rel="stylesheet" href="../../../styles.css"><script src="../../../shrippen.js"></script><style>body{{padding:24px}}</style></head><body>\n{html}\n</body></html>\n')
    w(d + n + '.prompt.md', f'# {n}\n\n{prompt}\n\n```html\n{html}\n```\n')

readme = open(f'{R}/.design-sync/conventions.md').read()
readme += '\n\n## Component index\n\n' + '\n'.join(f'- **{n}** ({g}) — `components/{g}/{n}/{n}.prompt.md`' for g, n, _, _ in C) + '\n'
w('README.md', readme)
print('ds-bundle:', sum(len(f) for _, _, f in os.walk(B)), 'files')
