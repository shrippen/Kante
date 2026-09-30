# Changelog

## 1.4.0

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

## 1.3.0

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

## 1.2.0

- Kennzahl-Kacheln (`kit.kpi_bar`, kimai-plugin-ui ab 0.5) können jetzt eine eskalierende Bedeutung tragen: das
  optionale `tier`-Feld je Kachel oder je Aufschlüsselungs-Eintrag färbt Balken/Beschriftung bzw. den Wert, statt dass
  wie bisher nur eine einzige Kachel pro Reihe (`highlight`) Farbe bekam. Siehe `PLUGINS.md`, Abschnitt 2.

## 1.1.2

- Logo: shrippen-Bildmarke mit der Wortmarke „KIMAI“ statt „SHRIPPEN“ (Rajdhani 700 als Pfade, wie bisher). Dateien
  heißen jetzt `knust-logo.svg` und `knust-logo-light.svg`.

## 1.1.1

- Login: Der SSO-Button (SAML, z. B. „Anmelden via Authentik“) ist jetzt so breit wie die Karte und umrandet wie die
  übrigen Umriss-Buttons. Vorher ragte der Text in Großbuchstaben aus dem halb so breiten Button heraus.

## 1.1.0

Schnittstelle für Plugins.

- Öffentliche Variablen `--knust-font-num`, `--knust-font-display`, `--knust-mark-radius`, `--knust-tier-0` bis `-3`,
  `--knust-map-filter` (Kartenkacheln im Dunkelmodus)
- Gestaltung der Kit-Kennzeichnungen aus kimai-plugin-ui 0.4: `kpu-num` in Monospace, `kpu-tier` als Band mit
  Stufenbalken, `kpu-mark` eckig
- `PLUGINS.md`: Regeln für bestehende und künftige Plugins

## 1.0.0

Erste Veröffentlichung für Kimai 2.67.

- shrippen-Palette für Tabler: Gruvbox dunkel, „Leinen“ hell, je Benutzer wählbar
- Akzentfarbe (Blau, Gelb, Orange, Aqua) unter System → Einstellungen → Knust
- Eckige Formen, abgeschrägte Karten, Rajdhani und JetBrains Mono
- Angepasste Screens: Kopfzeile, Timer, laufender Eintrag, Tabellen, Dashboard-Zähler, Modal, Login, Mobil
- kpu-Kit der shrippen-Plugins (Kennzahlen, Sammelaktionen, Meldungen)
- shrippen-Logo und Farbauswahl für Kunden, Projekte und Tätigkeiten
