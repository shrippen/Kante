#!/usr/bin/env python3
"""Builds ds-bundle/ (Claude Design upload layout) from docs/v1/shrippen.css. Run ./build.sh first."""
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
# tokens
shutil.copytree(f'{R}/tokens', f'{B}/tokens', ignore=shutil.ignore_patterns('*.qml'))

# components: (group, name, html, prompt)
ICON = '<svg class="feat-icon" viewBox="0 0 24 24"><path d="M13 2L3 14h9l-1 8 10-12h-9z"/></svg>'
BADGE = lambda l, v, c: f'<img alt="{l}" src="https://img.shields.io/badge/{l}-{v}-{c}?labelColor=1c1c20">'
MOCK = '<div style="padding:16px 20px;display:flex;flex-direction:column;gap:10px">' + ''.join(f'<div style="display:flex;gap:12px"><div style="width:5px;background:{c}"></div><div style="font-size:15px;color:var(--fg1)">{t}</div></div>' for t, c in [('Release notes schreiben', 'var(--red)'), ('Pull Request 42 prüfen', 'var(--yellow)'), ('Papierrollen nachbestellen', 'var(--blue)')]) + '</div>'
INSTALL = '<div class="install-card"><label>Installation</label><div class="cmd-row"><div class="cmd-box">[INSTALL COMMAND]</div><button class="copy-btn" type="button" aria-label="Copy"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button></div><p class="install-note" lang="en">Requires Plasma 6.</p><p class="install-note" lang="de">Benötigt Plasma 6.</p><div class="install-links"><a class="btn btn-primary" href="#">Download</a><a class="btn btn-ghost" href="#">GitHub</a></div></div>'
LANG = '<div class="lang" role="group" aria-label="Language"><button type="button" data-lang="en" aria-pressed="true">EN</button><button type="button" data-lang="de" aria-pressed="false">DE</button></div>'
C = [
 ('Layout', 'Nav', f'<nav class="nav brand-on"><div class="nav-inner"><a class="nav-brand" href="#">Kurrent</a><div class="nav-links"><a href="#"><span lang="en">Features</span><span lang="de">Funktionen</span></a><a href="#">Roadmap</a><a class="nav-hl" href="#">GitHub</a>{LANG}</div></div></nav>',
  'Sticky top bar. The project name (`.nav-brand`) is hidden while the hero is visible and fades in once the hero leaves the viewport; the class `.brand-on` is toggled by `shrippen.js` (shown here in its revealed state). Links are mono uppercase, the GitHub link uses `.nav-hl` (yellow). The language switch `.lang` sits last.'),
 ('Layout', 'Hero', f'<header class="hero"><div class="hero-main"><h1>Kur<br>rent</h1><p class="tagline" lang="en">Tasks in the Plasma panel.</p><p class="tagline" lang="de">Aufgaben im Plasma-Panel.</p></div><div class="hero-side">{INSTALL}<div class="hero-shot">{MOCK}</div></div></header>',
  'Two columns: `.hero-main` holds the giant uppercase project name (`h1`, no sentence above it) with the tagline directly beneath; `.hero-side` holds the yellow `.install-card` on top and the `.hero-shot` below, both the same width. Stacks to one column under 900px. Split long names with `<br>` or set `--title-size` on the h1.'),
 ('Layout', 'Section', '<section class="section"><h2 lang="en">Prerequisites</h2><h2 lang="de">Voraussetzungen</h2><ul lang="en"><li><strong>Plasma 6</strong> or newer</li><li>Qt 6.6</li></ul><ul lang="de"><li><strong>Plasma 6</strong> oder neuer</li><li>Qt 6.6</li></ul></section>',
  'Prose block: uppercase `h2`, `p`, `ul`. Text exists in both languages as paired `lang="en"` / `lang="de"` elements.'),
 ('Layout', 'Footer', '<footer><p>[LICENSE] · <a href="#">shrippen</a> · v[VERSION] · <a href="#">Issues</a></p></footer>',
  'Bare `<footer>`: a short yellow line on the left (drawn by CSS), one mono uppercase line on the right with license, author, version and issues link.'),
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
]
for g, n, html, prompt in C:
    d = f'components/{g}/{n}/'
    w(d + n + '.html', f'<!-- @dsCard group="{g}" -->\n<!doctype html><html lang="en"><head><meta charset="utf-8"><link rel="stylesheet" href="../../../styles.css"><script src="../../../shrippen.js"></script><style>body{{padding:24px}}</style></head><body>\n{html}\n</body></html>\n')
    w(d + n + '.prompt.md', f'# {n}\n\n{prompt}\n\n```html\n{html}\n```\n')

readme = open(f'{R}/.design-sync/conventions.md').read()
readme += '\n\n## Component index\n\n' + '\n'.join(f'- **{n}** ({g}) — `components/{g}/{n}/{n}.prompt.md`' for g, n, _, _ in C) + '\n'
w('README.md', readme)
print('ds-bundle:', sum(len(f) for _, _, f in os.walk(B)), 'files')
