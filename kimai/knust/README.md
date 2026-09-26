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
Logo: shrippen-Wortmarke als Standard; `theme.branding.company` oder `theme.branding.logo` haben Vorrang.

## Für Plugins

Plugins kennzeichnen, was ein Element ist (`kpu-num`, `kpu-tier`, `kpu-mark` aus kimai-plugin-ui 0.4), und nutzen
`--knust-*`-Variablen nur mit Rückfallwert. Sie fragen nicht ab, ob Knust installiert ist; Exporte bleiben neutral.
Regeln und Variablen: [PLUGINS.md](PLUGINS.md).

## Aufbau

```
Request ──► ThemeOptionsSubscriber (KernelEvents::CONTROLLER, nach Kimai)
              setThemeRadius(0), setThemePrimary(<Akzent>), setLogoUrl(<shrippen-logo.svg>)
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

## Grenzen

- Die Seitenleiste bleibt dunkel: Kimai setzt dort immer `data-bs-theme="dark"`.
- Abschrägung (oben rechts) nur auf `.card`, als Dreieck in Hintergrundfarbe; `clip-path` würde die „…“-Menüs abschneiden. Modals bleiben eckig.
- Abschnitt 9 im CSS überschreibt feste Farben aus Kimais kompiliertem `app.css`. Nach Kimai-Updates prüfen:
  `grep -oE '#[0-9a-f]{6}' public/build/app.*.css | sort | uniq -c`.
- Diagramme (Chart.js) färben per JavaScript und sind nicht angepasst.
- Dashboard-Zähler färben ihren Balken über `:has()` (Chrome 105+, Firefox 121+, Safari 15.4+).
- Login im Hell-Modus tauscht das Logo per `content: url()`; wo das nicht greift, bleibt das cremefarbene Logo für dunklen Grund.

## Repository

Entwicklung: <https://git.arianw.de/shrippen/kimai-knust-bundle>
Öffentlicher Spiegel: <https://github.com/shrippen/kimai-knust-bundle> (Gitea pusht automatisch dorthin, dort nichts direkt ändern)

## Lizenz

GPL-3.0-or-later, siehe [LICENSE](LICENSE).
Schriften: Rajdhani, JetBrains Mono (SIL Open Font License 1.1), auf Latin reduziert, woff2.
Logo und Palette: shrippen Design Default.
