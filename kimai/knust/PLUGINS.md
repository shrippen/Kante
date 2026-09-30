# Plugins und Knust

Regeln für Kimai-Plugins, die mit Knust gut aussehen sollen, ohne von Knust abzuhängen. Gilt für Drehzettel, Holiday,
Abrechnung, Anfahrten, Farbdifferenzierung und jedes künftige Plugin.

**Grundsatz:** Ein Plugin sagt, *was* ein Element ist. Wie es aussieht, entscheidet Knust. Ohne Knust sieht das Plugin
aus wie ein normales Kimai-Plugin. Das Design-System lebt nur an einer Stelle, in `Resources/public/css/knust.css`.

## Vier Stufen, in dieser Reihenfolge

Die erste Stufe, die reicht, ist die richtige.

### 1. Tabler und Kimai

Farben, Flächen, Rahmen, Ecken und Schriften kommen aus Tabler-Klassen (`bg-yellow-lt`, `text-secondary`, `card`,
`btn`) und `var(--tblr-…)`. Knust setzt diese Variablen auf die shrippen-Palette, also stimmt damit schon fast alles.

- Keine festen Farben (`#fff`, `rgb()`, `white`) in Plugin-CSS oder Templates. Ausnahmen: Entitätsfarben aus Kimai
  (`colorize`, `widgets.label_dot`) und Druckansichten.
- Keine festen Rundungen (`border-radius: 4px`), sondern `var(--tblr-border-radius)`. Knust setzt sie auf 0.
- Tabellen über Kimais `datatable_column_class('<tabelle>', '<spalte>')`. Knust setzt die Kimai-Spalten `col_date`,
  `col_starttime`, `col_endtime`, `col_duration` und `col_rate` von selbst in Monospace.

### 2. Kennzeichnungen aus dem UI-Kit (ab kimai-plugin-ui 0.4)

| Kennzeichnung | Wofür | Was Knust daraus macht |
|---|---|---|
| `kpu-num` | Zahl, Zeit, Datum, Betrag, Dauer (Zelle oder Inline-Element) | JetBrains Mono, in Tabellen 13 px |
| `kpu-tier` + `data-kpu-tier="0–3"` | Stufe: `0` Grundstufe, `1`–`3` steigend | Band wie im Design-System: getönte Fläche, 4-px-Balken oben, Text in der Stufenfarbe (grau, gelb, orange, rot) |
| `kpu-mark` | Farbpunkt von Kunde, Projekt, Tätigkeit | eckig statt rund |

- Die Kennzeichnung kommt **zusätzlich** zu den Tabler-Klassen: `class="bg-orange text-orange-fg kpu-tier" data-kpu-tier="2"`.
  Ohne Knust bleibt die Tabler-Fläche.
- Kimai-Spalten `col_date` usw. brauchen kein `kpu-num`, eigene Spalten schon (`col_distance`, Wochenraster, Summenzeilen).
- Die Makros des Kits setzen `kpu-num` selbst (Zeitraum, Kennzahl-Details, Gruppensummen). Die Bausteine des Kits
  (`kpu-kpi`, `kpu-bulk-bar`, `kpu-status`, `kpu-toast`) gestaltet Knust ebenfalls.
- `kit.kpi_bar()` setzt `tier` (ab kimai-plugin-ui 0.5) selbst als `kpu-tier`/`data-kpu-tier`, auf der Kachel wie im
  `details`-Eintrag: `{label: '…', value: '…', tier: 2}`. Auf der Kachel bleibt die Fläche neutral, nur Balken und
  Beschriftung tragen die Stufenfarbe, wie bei Kimais eigenen farbigen Dashboard-Kacheln; im `details`-Eintrag färbt
  sich nur der Wert. `tier` ist für Bedeutung, die eskaliert (eine Fehlerklasse, eine Zuschlagsstufe); für „die eine
  wichtige Zahl“ bleibt `highlight` zuständig, beide zusammen an einer Kachel ergeben keinen Sinn.

### 3. Knust-Variablen mit Rückfallwert

Für eigenes Plugin-CSS, das keine Kennzeichnung abdeckt. Immer mit Rückfallwert, damit das Plugin ohne Knust
funktioniert:

```css
.cd-swatch { border-radius: var(--knust-mark-radius, 50%); }
.mileage-map .leaflet-tile-pane { filter: var(--knust-map-filter, none); }
.dz-total { font-family: var(--knust-font-num, inherit); }
```

| Variable | Hell | Dunkel | Wofür |
|---|---|---|---|
| `--knust-font-num` | JetBrains Mono | JetBrains Mono | Zahlen, Zeiten, Beträge |
| `--knust-font-display` | Rajdhani | Rajdhani | große Einzelwerte, Überschriften |
| `--knust-mark-radius` | `0` | `0` | Farbpunkte, Swatches |
| `--knust-tier-0` … `--knust-tier-3` | fg3, gelb, orange, rot (Leinen) | fg3, gelb, orange, rot (Gruvbox) | Stufenfarben ohne `kpu-tier` (z. B. SVG, Diagramme) |
| `--knust-map-filter` | `none` | invertiert, warm | Kartenkacheln (Leaflet, OSM) |
| `--knust-focus`, `--knust-hl` | Cyan `#0f6b66` | Cyan `#5ccfc4` | Fokusring, aktuelle Auswahl (ab 1.3) |
| `--knust-cyan-tint` | `#d9ebe4` | `#1e2b2a` | Grund einer ausgewählten Zeile, eines fokussierten Felds |
| `--knust-warn` | Orange | Orange | Warnhinweis (Callout, Banner); Tablers `warning` bleibt gelb |
| `--knust-tint-1`, `--knust-tint-2` | Text 8 %, 16 % | Text 8 %, 16 % | Hover, gedrückt, Ablageziel |
| `--knust-tint-hl`, `--knust-tint-hl-2`, `--knust-tint-warn` | Cyan 12 %, 25 %, Orange 14 % | dito | Auswahl, Hervorhebung, Warnung als Fläche |
| `--knust-d1` … `--knust-d6` | Cyan, Gelb, Lila, Aqua, Orange, fg3 | dito | Datenreihen in Diagrammen, in dieser Reihenfolge (Rot bleibt Fehler) |
| `--knust-scrim` | `#282828` 50 % | `#141312` 62 % | Abdunklung hinter eigenen Overlays |

Die Namen ab 1.3 sind Kantes Rollen mit Präfix (`--focus` → `--knust-focus`, `--d1` → `--knust-d1`). Links und
Info brauchen keine eigene Variable: `var(--tblr-link-color)` und `var(--tblr-info)` sind in Knust schon cyan.

Die Variablen sind die Schnittstelle von Knust: Umbenennen oder Entfernen erfordert eine neue Hauptversion. Die
internen `--shr-*` können sich jederzeit ändern; Plugins nutzen sie nicht.

JavaScript, das Farben braucht (Diagramme, Canvas), liest die Variablen zur Laufzeit statt Farben fest einzutragen:
`getComputedStyle(element).getPropertyValue('--knust-tier-2').trim() || fallback`.

### 4. Abfragen, ob Knust installiert ist

Nur für Ausgaben, die **in Kimai** angezeigt werden und die CSS nicht erreicht, z. B. ein Bild, das der Server
rendert. Stand 1.1 braucht das kein Plugin. So geht es:

```php
public function __construct(#[Autowire('%kernel.bundles%')] private readonly array $bundles) {}

private function knustInstalled(): bool
{
    return \array_key_exists('KnustBundle', $this->bundles);
}
```

**Nie für Exporte.** PDF, Mail, ICS, CSV und Ausdrucke verlassen Kimai und bleiben neutral, egal ob Knust installiert
ist. Beispiel: Der Drehzettel-PDF-Stundenzettel geht an die Produktion und trägt kein shrippen-Design.

## Was ein Plugin nicht tut

- Knust-Klassen oder `--shr-*` direkt benutzen.
- Selektoren schreiben, die Knust überstimmen sollen (`!important`, hohe Spezifität gegen das Theme).
- Eigene Schriften, Logos oder Palettenfarben ausliefern.
- Den Dunkelmodus selbst erkennen: Kimai setzt `data-bs-theme`, Tabler und Knust reagieren darauf.

## Prüfen

1. Seite ohne Knust ansehen: sieht aus wie Kimai, nichts fehlt, keine Lücken durch fehlende Variablen.
2. Mit Knust hell und dunkel ansehen, dazu 390 px Breite.
3. `grep -nE '#[0-9a-fA-F]{3,8}\b|rgba?\(' Resources/views -r` findet nur Druckansichten und Rückfallwerte.
4. Neue Kennzeichnung oder Variable nötig? Erst in Knust (und bei Kennzeichnungen im UI-Kit) ergänzen, dann im Plugin
   benutzen. Nicht im Plugin nachbauen.
