# Knust

shrippen-Theme für Kimai (`shrippen/kimai-knust-bundle`). Knust ist das Endstück vom Brot: abgeschnittenes Eck, warme Kruste.

Kimai-2.67-Plugin: shrippen Design Default (Gruvbox dunkel, „Leinen“ hell) über Tabler. Nur CSS-Variablen und wenige Komponentenregeln, Kimais Markup bleibt unverändert. Plugins, die `var(--tblr-*)` nutzen (kpu-Kit), übernehmen das Theme automatisch.

## Installation

```bash
cp -r . /opt/kimai/var/plugins/KnustBundle
bin/console kimai:reload
bin/console kimai:bundle:knust:install   # kopiert CSS + Schriften nach public/bundles/knust/
```

Einstellung: System → Einstellungen → „Knust“ → Akzentfarbe (Blau, Gelb, Orange, Aqua).
Hell/Dunkel wählt jeder Benutzer selbst (Profil → Einstellungen → Theme).
Logo: shrippen-Bildmarke mit Wortmarke „KIMAI“ als Standard; `theme.branding.company` oder `theme.branding.logo` haben Vorrang.

## Für Plugins

Plugins kennzeichnen, was ein Element ist (`kpu-num`, `kpu-tier`, `kpu-mark` aus kimai-plugin-ui 0.4), und nutzen
`--knust-*`-Variablen nur mit Rückfallwert. Sie fragen nicht ab, ob Knust installiert ist; Exporte bleiben neutral.
Regeln und Variablen: [PLUGINS.md](PLUGINS.md).

## Aufbau

```
Request ──► ThemeOptionsSubscriber (KernelEvents::CONTROLLER, nach Kimai)
              setThemeRadius(0), setThemePrimary(<Akzent>), setLogoUrl(<knust-logo.svg>)
              → <html data-bs-theme-radius="0" data-bs-theme-primary="yellow">

Seite  ──► StylesheetSubscriber (ThemeEvent::STYLESHEET, auch Login)
              <link href="bundles/knust/css/knust.css">
                ├─ --shr-*   Palette je data-bs-theme (light = Leinen, dark = Gruvbox)
                ├─ --tblr-*  Tabler-Mapping (Flächen, Text, Farbskala, *-rgb, *-lt)
                ├─ Akzent    data-bs-theme-primary → --tblr-primary
                ├─ Regeln    Abschrägung, Schriften, Sidebar, Tabellen, Formulare,
                │            feste Hex-Werte aus Kimais app.css
                └─ Screens   Kopfzeile, Werkzeugleiste, Timer, laufender Eintrag,
                             Dashboard-Zähler, Modal, Login, kpu-Kit

Container ─► KnustExtension::prepend
              kimai.theme.color_choices = shrippen-Palette (Kunden/Projekte/Tätigkeiten)
```

## Abgleich mit Kante

Knust ist Kantes Ableger für Kimai (Regel in `shrippen.github.io/kante/AGENT-RULE.md`). Stand: Kante 1.7.

| Kante | Knust |
|---|---|
| Palette, Leinen hell | `--shr-*`, gleiche Werte |
| Cyan `#5ccfc4` / `#0f6b66` für Fokus, Link, Info, Daten, Auswahl | `--tblr-info`, `--tblr-cyan`, `--tblr-link-color`, `--tblr-active-bg`; `--knust-focus`, `--knust-hl` |
| `--warn` orange | Alerts und Toasts „warning“ orange; `--tblr-warning` bleibt gelb (Kit: „beantragt“ gelb, „Warnung“ orange) |
| `--tint-*`, `--d1…d6`, `--scrim`, `--cyan-tint` | `--knust-*` gleichen Namens; Scrim als Modal-Hintergrund |
| Kante oben rechts, 4-px-Zustandsbalken, eckige Marker | Karten, Kacheln, Modal, Alerts, Toasts, `kpu-tier`, `kpu-mark`, Badges |
| Fokus: cyan, 2 px, außen mit Abstand | Buttons, Links, Checkboxen, Seitenzahlen; Menüeinträge innen (Grund + Balken) |
| Feld: 2-px-Unterkante, bei Fokus cyan mit `--cyan-tint` | `.form-control`, `.form-select`, Tom Select |
| Ausgewählte Zeile | Zeilen mit angehakter `multiCheckbox` (cyan); der laufende Eintrag hat ein eigenes gelbes Signal |
| `.pill` | `kpu-status` (Umriss, Marker je Zustand) |
| `.kpi`, `.kpi-row` | `kpu-kpi` (Wert skaliert mit der Kachel), `kpu-kpis` |
| `.bulk-bar` | `kpu-bulk-bar` |
| `.table .num`, `.group-row`, `tfoot` | `kpu-num`, `kpu-group-row`, `.table tfoot` |
| `.callout`, `.toast` | `.alert`, `.toast` |
| `.chip`, `.chip.is-filter` | Tom-Select-Einträge (ausgewählt = cyan) |

Nicht übernommen:

- Schnitt an Buttons, Reitern und Menüs (`--cut-m`, `--cut-s`): `clip-path` schneidet Kimais Dropdowns und den
  Fokusring ab. Buttons bleiben eckig.
- Steuerhöhen 32/40/48 px: Kimais Formulare und Tabellen sind dichter gebaut.
- Bewegung (`--dur-*`, A01–A22, L1–L5): Kimai bringt eigene Übergänge; Knust ändert kein Markup und kein JS.
- `--primary` gelb: Die Akzentfarbe wählt der Admin (Blau, Gelb, Orange, Aqua), sie füllt Hauptschaltflächen.
- `.delta`, `.swatch[data-src]` (Herkunftsring), `.setting`, `.chip-pick`, `.fold`, `.modebar`, `.hint-card` und die
  übrigen App-Bausteine: Das Kit hat dafür keine Kennzeichnung und Kimai kein passendes Markup. Braucht ein Plugin eins,
  kommt erst die Kennzeichnung ins Kit, dann die Gestaltung nach Knust.
- Diagramme: Chart.js färbt per JavaScript; Plugins lesen `--knust-d1…d6` zur Laufzeit.
- Kante Light (Breeze): gilt für Apps neben KDE, nicht für Kimai.

## Grenzen

- Die Seitenleiste bleibt dunkel: Kimai setzt dort immer `data-bs-theme="dark"`.
- Abschrägung (oben rechts) nur auf `.card`, als Dreieck in Hintergrundfarbe; `clip-path` würde die „…“-Menüs abschneiden. Modals bleiben eckig.
- Abschnitt 9 im CSS überschreibt feste Farben aus Kimais kompiliertem `app.css`. Nach Kimai-Updates prüfen:
  `grep -oE '#[0-9a-f]{6}' public/build/app.*.css | sort | uniq -c`.
- Diagramme (Chart.js) färben per JavaScript und sind nicht angepasst.
- Dashboard-Zähler färben ihren Balken, angehakte Tabellenzeilen ihre Fläche über `:has()` (Chrome 105+, Firefox 121+, Safari 15.4+).
- Login im Hell-Modus tauscht das Logo per `content: url()`; wo das nicht greift, bleibt das cremefarbene Logo für dunklen Grund.

## Repository

Entwicklung: <https://git.arianw.de/shrippen/kimai-knust-bundle>
Öffentlicher Spiegel: <https://github.com/shrippen/kimai-knust-bundle> (Gitea pusht automatisch dorthin, dort nichts direkt ändern)

## Lizenz

GPL-3.0-or-later, siehe [LICENSE](LICENSE).
Schriften: Rajdhani, JetBrains Mono (SIL Open Font License 1.1), auf Latin reduziert, woff2.
Logo (shrippen-Bildmarke, Wortmarke „KIMAI“ in Rajdhani 700) und Palette: shrippen Design Default.
