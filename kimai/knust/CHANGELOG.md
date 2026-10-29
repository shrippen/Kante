# Changelog

## [1.5.0] — 2026-10-29

### English

The theme survives Kimai updates: after a new container its files come back on their own. Also new: the send results of kit 0.9, weekends and map credits that stay readable, and a help button that no longer covers amounts.

#### New
- Send results from kit 0.9: “Sent” with a tick and “Failed” with a cross, like approved and rejected (Drehzettel's mail log).
#### Improved
- Palette from Kante: a red for text (`--shr-red-text`) that reaches 4.5:1 on every ground, and a darker green for positive values in the light palette “Leinen”, which now reaches 4.5:1 on every ground too.
#### Fixed
- In Kimai's Docker image `public/` is no volume, so every Kimai update started without `public/bundles/knust/`, and Kimai ran without the theme until someone ran `kimai:bundle:knust:install`. Knust now copies its stylesheets, fonts and logo back on every cache warmup (`kimai:reload`, which the image runs at each start) when they are missing or from another version, never on a page load, and never through a link.
- Weekends in calendar days (`kpu-day`, the absence calendar) are tinted instead of dimmed; in the dark palette they were hard to tell from weekdays.
- Kimai's floating help button stays faint until hovered or focused; it covered right-aligned amounts (Drehzettel's week, mileage).
- The credits on maps stay readable: Leaflet's white background stayed under the light text.
#### Note
- Update as usual (unzip, `bin/console kimai:reload`). After a Kimai update `kimai:bundle:knust:install` is no longer needed.

All changes: https://github.com/shrippen/Kante/compare/knust-v1.2.0...knust-v1.5.0

### Deutsch

Das Theme übersteht Kimai-Updates: Nach einem neuen Container kommen seine Dateien von selbst zurück. Dazu die Versandergebnisse aus Kit 0.9, Wochenenden und Kartenhinweise, die lesbar bleiben, und ein Hilfe-Knopf, der keine Beträge mehr verdeckt.

#### Neu
- Versandergebnisse aus Kit 0.9: „Gesendet“ mit Haken, „Fehlgeschlagen“ mit Kreuz, wie genehmigt und abgelehnt (Versandprotokoll im Drehzettel).
#### Verbessert
- Palette aus Kante: ein Rot für Schrift (`--shr-red-text`), das auf jedem Grund 4,5:1 erreicht, und ein dunkleres Grün für positive Werte in der hellen Palette „Leinen“, das jetzt ebenfalls auf jedem Grund 4,5:1 erreicht.
#### Behoben
- Im Docker-Image von Kimai liegt `public/` auf keinem Volume, darum startete jedes Kimai-Update ohne `public/bundles/knust/`, und Kimai lief ohne Theme, bis jemand `kimai:bundle:knust:install` aufrief. Knust kopiert Stylesheets, Schriften und Logo jetzt bei jedem Cache-Aufwärmen zurück (`kimai:reload`, das das Image bei jedem Start ausführt), wenn sie fehlen oder zu einer anderen Version gehören; nie bei einem Seitenaufruf und nie über einen Link.
- Wochenenden in Kalendertagen (`kpu-day`, Abwesenheitskalender) sind getönt statt abgesenkt; in der dunklen Palette waren sie kaum von Werktagen zu unterscheiden.
- Kimais schwebender Hilfe-Knopf bleibt blass, bis man darüberfährt oder ihn fokussiert; er lag über rechtsbündigen Beträgen (Drehzettel-Woche, Fahrtkosten).
- Die Quellenangabe auf Karten bleibt lesbar: Unter der hellen Schrift blieb Leaflets weißer Hintergrund.
#### Hinweis
- Update wie gewohnt (entpacken, `bin/console kimai:reload`). Nach einem Kimai-Update ist `kimai:bundle:knust:install` nicht mehr nötig.

Alle Änderungen: https://github.com/shrippen/Kante/compare/knust-v1.2.0...knust-v1.5.0

## [1.4.0] — 2026-09-30

Farben aus Kante, Kit 0.6/0.7 gestaltet, Abgleich mit Kante 1.9.

- Palette: `knust-palette.css` wird von Kante generiert (`kante/tools/build-knust.py`) und unverändert übernommen
  (`bin/sync-palette.sh`); `knust.css` enthält keine Hex-Farben mehr. `bin/check-palette.sh` prüft das, auch im
  Release-Workflow. Text auf Zustandsflächen im Dunkeln ist Kantes `on-state` (`#141312`).
- Kit-Kennzeichnungen nach Kante: Herkunftsring (`kpu-mark[data-kpu-src]`), Veränderung mit Polarität (`kpu-delta`,
  `data-kpu-good`), Einstellungszeile, Auswahl-Chip, aufklappbarer Abschnitt, Modusleiste, Hinweiskarten.
- Kalendertag `kpu-day` (heute, Feiertag, Abwesenheit, Wochenende, ausgewählt, Entität lila), Feldgruppe
  `kpu-field-group` (lila), Kartenmarker `kpu-map-pin`.
- „Abgerechnet“ grün mit gefülltem Haken statt Blau (lag in Leinen fast auf dem Cyan der Auswahl).
- Status-Pillen unter 576 px schmaler, damit Tabellen in ihre Karte passen.
- Kimais Tagesrollen (`--kimai-public-holiday`, `-holiday`, `-sickness`, `-time-off`, `-other`, `-weekend-bg`):
  Feiertag oranger, Abwesenheit cyan Balken statt Fläche, Wochenende abgesenkt.
- Neue Variablen `--knust-map-route` (gelb), `--knust-map-marker` (cyan); Leaflet-Zoom, Quellenangabe, Tooltips und
  Popups hell und dunkel.
- Ausgewählte Zeilen auch über die Kit-Checkbox `kpu-select`, nicht nur `td.multiCheckbox`.

## [1.3.0] — 2026-09-30

Abgleich mit Kante 1.7.

- Cyan (`#5ccfc4` dunkel, `#0f6b66` hell) für Fokus, Links, Info und Auswahl, unabhängig von der Akzentfarbe. Fokus
  ist ein 2-px-Ring statt Tablers Schein und des gelben Rahmens; Felder haben eine 2-px-Unterkante und werden bei
  Fokus cyan.
- Warn-Alerts und -Toasts orange (Kantes `--warn`); Tablers `warning` bleibt gelb.
- Aktiver Menüpunkt und angehakte Tabellenzeilen: cyan Balken und Tönung. Laufender Eintrag: gelber Balken, gelbe Tönung und Dauer statt Orange, damit er sich von ausgewählten Zeilen abhebt.
- Neue öffentliche Variablen: `--knust-focus`, `--knust-hl`, `--knust-warn`, `--knust-cyan-tint`, `--knust-tint-*`,
  `--knust-d1` bis `-d6`, `--knust-scrim` (siehe `PLUGINS.md`).
- Kit: Status als Umriss-Pille mit Marker je Zustand, Kennzahl skaliert mit der Kachel, Sammelleiste mit cyan Kante,
  Gruppenzeilen mit gelbem Balken, Summenzeile (`tfoot`) wie in Kante.
- Modal-Hintergrund mit Kantes Scrim.

## [1.2.0] — 2026-09-26

- Kennzahl-Kacheln (`kit.kpi_bar`, kimai-plugin-ui ab 0.5) können jetzt eine eskalierende Bedeutung tragen: das
  optionale `tier`-Feld je Kachel oder je Aufschlüsselungs-Eintrag färbt Balken/Beschriftung bzw. den Wert, statt dass
  wie bisher nur eine einzige Kachel pro Reihe (`highlight`) Farbe bekam. Siehe `PLUGINS.md`, Abschnitt 2.

## [1.1.2] — 2026-09-26

- Logo: shrippen-Bildmarke mit der Wortmarke „KIMAI“ statt „SHRIPPEN“ (Rajdhani 700 als Pfade, wie bisher). Dateien
  heißen jetzt `knust-logo.svg` und `knust-logo-light.svg`.

## [1.1.1] — 2026-09-26

- Login: Der SSO-Button (SAML, z. B. „Anmelden via Authentik“) ist jetzt so breit wie die Karte und umrandet wie die
  übrigen Umriss-Buttons. Vorher ragte der Text in Großbuchstaben aus dem halb so breiten Button heraus.

## [1.1.0] — 2026-09-26

Schnittstelle für Plugins.

- Öffentliche Variablen `--knust-font-num`, `--knust-font-display`, `--knust-mark-radius`, `--knust-tier-0` bis `-3`,
  `--knust-map-filter` (Kartenkacheln im Dunkelmodus)
- Gestaltung der Kit-Kennzeichnungen aus kimai-plugin-ui 0.4: `kpu-num` in Monospace, `kpu-tier` als Band mit
  Stufenbalken, `kpu-mark` eckig
- `PLUGINS.md`: Regeln für bestehende und künftige Plugins

## [1.0.0] — 2026-09-26

Erste Veröffentlichung für Kimai 2.67.

- shrippen-Palette für Tabler: Gruvbox dunkel, „Leinen“ hell, je Benutzer wählbar
- Akzentfarbe (Blau, Gelb, Orange, Aqua) unter System → Einstellungen → Knust
- Eckige Formen, abgeschrägte Karten, Rajdhani und JetBrains Mono
- Angepasste Screens: Kopfzeile, Timer, laufender Eintrag, Tabellen, Dashboard-Zähler, Modal, Login, Mobil
- kpu-Kit der shrippen-Plugins (Kennzahlen, Sammelaktionen, Meldungen)
- shrippen-Logo und Farbauswahl für Kunden, Projekte und Tätigkeiten
