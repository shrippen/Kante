#!/usr/bin/env python3
"""Builds ds-bundle/ (Claude Design upload layout) from docs/v1/shrippen.css. Run ./build.sh first."""
import os, shutil, re
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
B = os.path.join(R, 'ds-bundle')
shutil.rmtree(B, ignore_errors=True)

def w(path, s):
    p = os.path.join(B, path); os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, 'w').write(s)

# fonts + styles
os.makedirs(B + '/fonts')
for f in ('Rajdhani-600.ttf', 'Rajdhani-700.ttf'):
    shutil.copy(f'{R}/fonts/{f}', f'{B}/fonts/{f}')
css = open(f'{R}/docs/v1/shrippen.css').read()
ff = ''.join(f"@font-face{{font-family:'Rajdhani';font-weight:{wt};font-display:swap;src:url(fonts/Rajdhani-{wt}.ttf) format('truetype')}}\n" for wt in (600, 700))
w('styles.css', ff + css)
# tokens
shutil.copytree(f'{R}/tokens', f'{B}/tokens', ignore=shutil.ignore_patterns('*.qml'))

# components: (group, name, html, prompt)
ICON = '<svg class="feat-icon" viewBox="0 0 24 24"><path d="M13 2L3 14h9l-1 8 10-12h-9z"/></svg>'
BADGE = lambda l, v, c: f'<img alt="{l}" src="https://img.shields.io/badge/{l}-{v}-{c}?labelColor=1c1c20">'
C = [
 ('Layout', 'Nav', '<nav class="nav"><div class="nav-inner"><a class="nav-brand" href="#">Kurrent</a><div class="nav-links"><a href="#">Features</a><a href="#">Setup</a><a href="#">GitHub</a></div></div></nav>',
  'Sticky top bar for multi-section pages. Brand (optional 24px `img` + name) left, links right. Use only when the page has several anchored sections.'),
 ('Layout', 'Hero', '<section class="hero"><h1>Kurrent</h1><p class="tagline">A KDE Plasma 6 task manager</p><div class="install-links"><a class="btn btn-primary" href="#">Download</a><a class="btn btn-ghost" href="#">GitHub</a></div></section>',
  'Centered top block: optional `img.hero-icon` (88px), `h1`, `p.tagline`, `.badges`, `.install-card`, `.install-links`. The only place `--fg0` heading size uses the large clamp scale.'),
 ('Layout', 'Section', '<section class="section"><h2>Prerequisites</h2><ul><li><strong>Plasma 6</strong> or newer</li><li>Qt 6.6</li></ul></section>',
  'Prose block in the 860px column: `h2`, `p`, `ul`. Use for prerequisites and how-it-works text.'),
 ('Layout', 'Footer', '<footer><p>GPL-3.0 · Made by <a href="#">shrippen</a> · <a href="#">Issues</a></p></footer>',
  'Bare `<footer>` at the page end: license, author, issues link, separated by " · ".'),
 ('Actions', 'Button', '<div class="install-links"><a class="btn btn-primary" href="#">Download v1.0</a><a class="btn btn-ghost" href="#">GitHub</a></div>',
  '`.btn.btn-primary` (blue, one per page) for the main call to action, `.btn.btn-ghost` for secondary links. Optional 18px inline SVG before the label.'),
 ('Actions', 'InstallCard', '<div class="install-card" style="margin:0"><label>Install with one command</label><div class="cmd-row"><div class="cmd-box">kpackagetool6 -t Plasma/Applet -i kurrent.plasmoid</div><button class="copy-btn" title="Copy"><svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg></button></div><p class="install-note">Requires <code>kpackagetool6</code>.</p></div>',
  'Copyable install command. `label`, `.cmd-row` with `.cmd-box` (monospace, blue) and `button.copy-btn`, optional `p.install-note`. On copy, add class `copied` to the button for 1.5s (needs a small clipboard script).'),
 ('Content', 'Badges', f'<div class="badges">{BADGE("version","1.0.0","e8dcc4")}{BADGE("Plasma","6","83a598")}{BADGE("license","GPL--3.0","a89984")}</div>',
  'shields.io badges, always `labelColor=1c1c20`. Value colors: version `e8dcc4`, tech/platform `83a598`, license `a89984`. Do not use other colors.'),
 ('Content', 'Screenshot', '<div class="screenshot-wrap" style="margin:0"><div style="height:160px;background:var(--bg-hard);border:1px solid var(--bg2);border-radius:var(--radius);box-shadow:0 12px 40px rgba(0,0,0,.45)"></div></div>',
  '`.screenshot-wrap > img` with rounded corners, 1px border and deep shadow. Full column width; use `loading="lazy"`.'),
 ('Content', 'FeatureGrid', f'<div class="features" style="margin:0">' + ''.join(f'<div class="feat">{ICON}<h3>Feature {i}</h3><p>Short description of what it does.</p></div>' for i in (1, 2, 3)) + '</div>',
  'Auto-fit grid (min 240px) of `.feat` cards: optional `svg.feat-icon` (24×24, stroke, cream), `h3`, `p`. Use inline SVG, never emojis.'),
 ('Content', 'Steps', '<div class="section" style="margin:0"><ol class="steps"><li>Download the release.</li><li>Run the install command.</li><li>Add the widget to your panel.</li></ol></div>',
  '`ol.steps` with automatic numbered circles. Pair with a `.codeblock` for the commands.'),
 ('Content', 'Table', '<div class="table-wrap"><table class="table"><tr><th>Display</th><th>Status</th></tr><tr><td><code>epd2in7</code></td><td>Supported</td></tr><tr><td><code>epd4in2</code></td><td>Supported</td></tr></table></div>',
  '`.table-wrap > table.table` for compatibility matrices. Wrapper scrolls horizontally on narrow screens. Header cells use the heading font.'),
 ('Content', 'CodeBlock', '<div class="codeblock"><span class="c"># install</span>\n<span class="k">git</span> clone https://github.com/shrippen/Kurrent</div>',
  'Multi-line monospace block on `--bg-hard`. `.c` spans for comments, `.k` for commands.'),
 ('Content', 'Callout', '<div class="callout"><strong>Note:</strong> Neutral hint.</div><div class="callout callout-warn"><strong>Heads up:</strong> Partly AI-assisted.</div><div class="callout callout-danger"><strong>Danger:</strong> Destructive.</div><div class="callout callout-ok"><strong>Done:</strong> Success.</div>',
  'Boxed note with a colored left border. Default blue; `.callout-warn` yellow (disclaimers), `.callout-danger` red, `.callout-ok` aqua.'),
]
for g, n, html, prompt in C:
    d = f'components/{g}/{n}/'
    w(d + n + '.html', f'<!-- @dsCard group="{g}" -->\n<!doctype html><html><head><meta charset="utf-8"><link rel="stylesheet" href="../../../styles.css"><style>body{{padding:24px}}</style></head><body>\n{html}\n</body></html>\n')
    w(d + n + '.prompt.md', f'# {n}\n\n{prompt}\n\n```html\n{html}\n```\n')

readme = open(f'{R}/.design-sync/conventions.md').read()
readme += '\n\n## Component index\n\n' + '\n'.join(f'- **{n}** ({g}) — `components/{g}/{n}/{n}.prompt.md`' for g, n, _, _ in C) + '\n'
w('README.md', readme)
print('ds-bundle:', sum(len(f) for _, _, f in os.walk(B)), 'files')
