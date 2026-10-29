# Changelog

The release notes of Kante, newest first. Each section is the text of its entry in `#changes` on
the landing page (`docs/index.html`). Releases before 1.27 are described in the README, one section
per version. Knust and the plugin kit keep their own logs: `kimai/knust/CHANGELOG.md`,
`kimai/kit/CHANGELOG.md`.

## [1.55.0] — 2026-10-30

### English

Dialogs come in three widths, and a destructive question is red.

#### New
- `KanteDialog` gets `size`: Small, Medium and Large, at most 90 % of the window.
- `KanteDialog` gets `destructive`: the bar and the accept button (Ok, or Yes of a yes/no question) in the negative colour, Cancel before it.

#### Fixed
- `KanteDialog`'s `acceptText` holds in every language: in German the button read „OK“, because the button box sets its standard texts again once the translations are in.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-155

### Deutsch

Dialoge gibt es in drei Breiten, und eine destruktive Frage ist rot.

#### Neu
- `KanteDialog` bekommt `size`: Small, Medium und Large, höchstens 90 % des Fensters.
- `KanteDialog` bekommt `destructive`: Balken und Bestätigungsknopf (Ok, oder Ja einer Ja/Nein-Frage) in der Warnfarbe, Abbrechen davor.

#### Behoben
- `acceptText` von `KanteDialog` hält in jeder Sprache: Auf Deutsch hieß der Knopf „OK“, weil die Knopfleiste ihre Standardtexte neu setzt, sobald die Übersetzungen geladen sind.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-155

## [1.54.0] — 2026-10-30

### English

The page bar can be lower, down to a coloured strip, and the month grid marks its days.

#### New
- `KantePageBar` gets `density`: Compact (lower, smaller labels; it grows for a small button at its end) and Band (one coloured segment per page, the name as tooltip). lmix's operators want the room for their inputs.
- `KanteCalendarGrid` marks days with up to three dots (`dots`) and tints a range of days (`rangeFrom`, `rangeTo`), as Kurrent's Agenda needs for appointments, tasks and the days a view shows.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-154

### Deutsch

Die Seitenleiste kann niedriger sein, bis hin zu einem Farbband, und das Monatsraster markiert seine Tage.

#### Neu
- `KantePageBar` bekommt `density`: Compact (niedriger, kleinere Schrift; wächst für einen kleinen Knopf am Ende) und Band (ein farbiger Abschnitt je Seite, der Name als Tooltip). Wer lmix bedient, braucht den Platz für die Inputs.
- `KanteCalendarGrid` markiert Tage mit bis zu drei Punkten (`dots`) und tönt einen Zeitraum (`rangeFrom`, `rangeTo`), wie ihn Kurrents Agenda für Termine, Aufgaben und die gezeigten Tage braucht.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-154

## [1.53.0] — 2026-10-29

### English

Every row of a list takes a click again.

#### Fixed
- `KanteListRow` in a scrolling list reacted only on its first row; a click on any other row did nothing (Qt 6.11).
- `KanteScope` no longer logs a script error when a page or dialog closes right after its content changed.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-153

### Deutsch

Jede Zeile einer Liste nimmt wieder einen Klick an.

#### Behoben
- `KanteListRow` in einer scrollbaren Liste reagierte nur in der ersten Zeile; ein Klick auf jede andere Zeile blieb ohne Wirkung (Qt 6.11).
- `KanteScope` meldet keinen Skriptfehler mehr, wenn eine Seite oder ein Dialog gleich nach einer Änderung ihres Inhalts schließt.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-153

## [1.52.0] — 2026-10-28

### English

The workbench desk stays in view beside a long list.

#### Fixed
- `.bench-desk` moves along while the list scrolls. Before, a click on an entry far down showed its desk at the top of the page, out of view. A desk taller than the window scrolls itself; on a phone nothing changes.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-152

### Deutsch

Die Arbeitsfläche der Werkbank bleibt neben einer langen Liste im Blick.

#### Behoben
- `.bench-desk` wandert mit, während die Liste scrollt. Vorher stand die Arbeitsfläche nach einem Klick auf einen Eintrag weit unten oben auf der Seite, außer Sicht. Ist sie höher als das Fenster, scrollt sie selbst; am Telefon ändert sich nichts.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-152

## [1.51.0] — 2026-10-28

### English

Kontra's QA of 28 October: a sidebar that stays dark in Kante on a light system, sheets that keep the keyboard, string colours that read at the beamer and tell apart with deuteranopia, and histogram bars a screen reader can read. For players at 200 % with a keyboard and a screen reader, for the teacher at the beamer and for beginners on a light desktop.

#### New
- `KanteFocusTrap`: while a sheet in the page is open, Tab and Shift+Tab stay inside it and the page behind takes no focus (or is hidden from screen readers too); closed, the focus goes back to the control the app names. Kontra's run summary let Tab run on into the sidebar.
- `KanteScope.popup`: a drawer's ground takes the Kante colours with its entries. A Kirigami sidebar was white below its entries, "close sidebar" at 1.4:1.

#### Improved
- String colours on a light ground (Leinen and Kante Light): raspberry, blue, ochre and strong text for the four bass strings, at least 4.5:1 and apart from each other with deuteranopia. The A string was 1.7:1 at the beamer, purple and cyan looked alike with deuteranopia. The tab draws its string lines in full colour there. Dark Kante keeps its colours; Kante Light on a dark system now takes the dark palette's string colours instead of the platform's.
- Screen readers hear every bar of the timing histogram with its range and count: "−20 bis −10 ms: 3 Noten" (`binText`, translatable). Before they heard only "early" and "late".

#### Fixed
- `KanteScope` reaches disabled items: Kirigami gave them the platform's colours, so in Kante on a light system a disabled sidebar entry stood at 1.7:1 and separators white. Kante Light and System keep the platform's look, and an item with colours of its own keeps them.
- `KanteCallout` with a title only draws no empty line under it (it was about 40 px too tall).
- `KanteListRow` with a "?" at its end: Tab reaches the row and then the "?", Shift+Tab from the "?" goes to its row. Once the "?" had the focus, the row was skipped both ways.

#### Note
- Apps that theme a drawer pass it as `popup`: `KanteScope { target: drawer.contentItem; popup: drawer }`. Leinen's string colours change for every app that shows strings.

![Before (left) and after (right): sidebar in Kante on a light system, callout with a title only, string colours in Kante Light](https://shrippen.github.io/Kante/shots/release-1.51-qa.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-151

### Deutsch

Kontras QA vom 28. Oktober: eine Seitenleiste, die in Kante auf hellem System dunkel bleibt, Blätter, die die Tastatur behalten, Saitenfarben, die am Beamer lesbar und mit Deuteranopie unterscheidbar sind, und Histogramm-Balken, die ein Screenreader vorliest. Für alle, die bei 200 % mit Tastatur und Screenreader spielen, für die Lehrkraft am Beamer und für Einsteiger auf einem hellen Desktop.

#### Neu
- `KanteFocusTrap`: Solange ein Blatt in der Seite offen ist, bleiben Tab und Umschalt+Tab darin, und die Seite dahinter nimmt keinen Fokus (oder ist auch für Screenreader ausgeblendet); geschlossen, geht der Fokus zu dem Bedienelement, das die App nennt. In Kontras Auswertung lief Tab weiter in die Seitenleiste.
- `KanteScope.popup`: Der Grund einer Seitenleiste nimmt mit ihren Einträgen die Kante-Farben. Eine Kirigami-Seitenleiste war unter den Einträgen weiß, „Seitenleiste schließen“ stand bei 1,4:1.

#### Verbessert
- Saitenfarben auf hellem Grund (Leinen und Kante Light): Himbeere, Blau, Ocker und starke Schrift für die vier Basssaiten, mindestens 4,5:1 und auch mit Deuteranopie voneinander unterscheidbar. Die A-Saite stand am Beamer bei 1,7:1, Lila und Cyan sahen mit Deuteranopie gleich aus. Die Tabulatur zeichnet ihre Saitenlinien dort in voller Farbe. Dunkles Kante behält seine Farben; Kante Light auf dunklem System nimmt jetzt die Saitenfarben der dunklen Palette statt der Plattform.
- Screenreader nennen jeden Balken des Timing-Histogramms mit Bereich und Anzahl: „−20 bis −10 ms: 3 Noten“ (`binText`, übersetzbar). Vorher hörten sie nur „früh“ und „spät“.

#### Behoben
- `KanteScope` erreicht gesperrte Elemente: Kirigami gab ihnen die Farben der Plattform, so stand in Kante auf hellem System ein gesperrter Eintrag der Seitenleiste bei 1,7:1 und Trennlinien weiß. Kante Light und System behalten das Aussehen der Plattform, und ein Element mit eigenen Farben behält sie.
- `KanteCallout` mit nur einem Titel zeichnet keine leere Zeile darunter (er war etwa 40 px zu hoch).
- `KanteListRow` mit einem „?“ am Ende: Tab erreicht die Zeile und dann das „?“, Umschalt+Tab vom „?“ geht zu seiner Zeile. Hatte das „?“ einmal den Fokus, wurde die Zeile in beide Richtungen übersprungen.

#### Hinweis
- Apps, die eine Seitenleiste einfärben, geben sie als `popup` mit: `KanteScope { target: drawer.contentItem; popup: drawer }`. Die Saitenfarben in Leinen ändern sich für jede App, die Saiten zeigt.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-151

## [1.50.0] — 2026-10-28

### English

Rehearsal marks: tab, notation and the lanes show where Intro, verse, chorus or part B begin, in a framed box over the first bar of each part. For players who find their way in a song by its parts, and for a teacher at the beamer saying "from the chorus".

#### New
- `KanteRehearsalMark`: the name of a part in a framed box, with the small cut in Kante and Kante Light, square in System. A long name is cut short with "…" instead of running into the next mark; screen readers hear all of it ("Teil Refrain · B").
- A bar's `section` in `KanteTabStaff`, `KanteBassStaff`, `KanteTabLane` and `KanteKeyLane` puts the mark over that bar. Several names of one bar are joined: "Refrain · B" (`KanteStyle.rehearsalText`).
- Screen readers hear the part being played along with the bar.

#### Note
- Only songs with sections change: tab, notation and the tab lane move down by the row of the marks (in the key lane the mark sits right of the bar number, nothing moves). Without `section` the layout stays as it was.

![Rehearsal marks in tab, notation and lane, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.50-probenzeichen.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-150

### Deutsch

Probenzeichen: Tabulatur, Noten und die Lanes zeigen, wo Intro, Strophe, Refrain oder Teil B beginnen, in einem gerahmten Kasten über dem ersten Takt jedes Teils. Für alle, die sich in einem Stück an seinen Teilen orientieren, und für die Lehrkraft am Beamer, die „ab dem Refrain“ sagt.

#### Neu
- `KanteRehearsalMark`: der Name eines Teils in einem gerahmten Kasten, mit der kleinen Schnittecke in Kante und Kante Light, eckig in System. Ein langer Name wird mit „…“ gekürzt, statt in das nächste Zeichen zu laufen; Screenreader hören ihn ganz („Teil Refrain · B“).
- Das Feld `section` eines Takts in `KanteTabStaff`, `KanteBassStaff`, `KanteTabLane` und `KanteKeyLane` setzt das Zeichen über diesen Takt. Mehrere Namen eines Takts werden zusammengefasst: „Refrain · B“ (`KanteStyle.rehearsalText`).
- Screenreader nennen mit dem Takt den Teil, der gerade läuft.

#### Hinweis
- Nur Stücke mit Teilen ändern sich: Tabulatur, Noten und die Tab-Lane rücken um die Zeile der Zeichen nach unten (in der Tasten-Lane steht das Zeichen rechts neben der Taktnummer, dort rückt nichts). Ohne `section` bleibt das Layout, wie es war.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-150

## [1.49.0] — 2026-10-28

### English

For players on the keyboard alone, at 200 % and with deuteranopia: Return presses buttons, the focus stays in view, a wrong note has a frame.

#### New
- `KanteFocusFollow` scrolls a long page so the focused control is in view.
- `KanteSteps.skipped`: a skipped step shows a dash, not the done check. Bar charts and the timing histogram name their value axis.

#### Fixed
- Return and Enter press a focused `KanteButton` or `KanteToolButton`; before, only Space did.
- A wrong note in the tab and key lanes is framed; with deuteranopia its red looked like the D string's ochre.

![Skipped step, framed wrong note, axis title, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.49-qa.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-149

### Deutsch

Für alle, die nur mit der Tastatur arbeiten, bei 200 % und mit Deuteranopie: Return drückt Knöpfe, der Fokus bleibt sichtbar, ein falscher Ton hat einen Rahmen.

#### Neu
- `KanteFocusFollow` scrollt eine lange Seite, sodass das fokussierte Element sichtbar ist.
- `KanteSteps.skipped`: Ein übersprungener Schritt zeigt einen Strich statt des Hakens. Balkendiagramme und das Timing-Histogramm beschriften ihre Werteachse.

#### Behoben
- Return und Enter drücken einen fokussierten `KanteButton` oder `KanteToolButton`; vorher ging nur die Leertaste.
- Ein falscher Ton in Tab- und Tasten-Lane hat einen Rahmen; mit Deuteranopie sah sein Rot wie das Ocker der D-Saite aus.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-149

## [1.48.0] — 2026-10-27

### English

A workbench: a list to scan beside a desk for one entry, receipts to pick, and a bar that shows what is left of an amount.

#### New
- `.bench` with `.bench-list` and `.bench-desk`. Each entry shows in two lines and a bar how complete it is; the current one is cyan. On a phone the desk goes under the list.
- `.pick`: a receipt card with a preview, a radio or check box and a score. `.field-origin` says where a value came from, `dl.kv` lists what was read.
- `.sumbar`: parts of an amount in their colours, the rest hatched, the rest in red or green.

![List and desk](https://shrippen.github.io/Kante/shots/release-1.48-bench.png)

![Pick and sum bar, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.48-parts.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-148

### Deutsch

Eine Werkbank: eine Liste zum Überfliegen neben einer Arbeitsfläche für einen Eintrag, Belege zum Auswählen und ein Balken, der zeigt, was von einem Betrag übrig ist.

#### Neu
- `.bench` mit `.bench-list` und `.bench-desk`. Jeder Eintrag zeigt in zwei Zeilen und einem Balken, wie vollständig er ist; der aktuelle ist cyan. Am Telefon steht die Arbeitsfläche unter der Liste.
- `.pick`: eine Belegkarte mit Vorschau, Radio oder Häkchen und Wertung. `.field-origin` sagt, woher ein Wert kommt, `dl.kv` listet, was gelesen wurde.
- `.sumbar`: die Teile eines Betrags in ihren Farben, der Rest schraffiert, der Rest in Rot oder Grün.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-148

## [1.47.0] — 2026-10-27

### English

Waiting gets one look: a bar on top, the clicked link runs a light, old content dims.

#### New
- `.page-load`, `.is-pending` and `aria-busy` regions. They show only after 150 ms, so fast answers stay calm.
- `.loading` (squares plus a word), `.btn-status` (a reserved line under buttons) and `.step-time` for live steps.

![Page load bar and pending link, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.47-page.png)

![Busy region, loading word, button status and step time](https://shrippen.github.io/Kante/shots/release-1.47-busy.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-147

### Deutsch

Warten sieht überall gleich aus: ein Balken oben, ein Lauflicht um den geklickten Link, alter Inhalt wird blass.

#### Neu
- `.page-load`, `.is-pending` und Bereiche mit `aria-busy`. Sie erscheinen erst nach 150 ms, schnelle Antworten bleiben ruhig.
- `.loading` (Quadrate und ein Wort), `.btn-status` (eine freigehaltene Zeile unter Knöpfen) und `.step-time` für laufende Schritte.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-147

## [1.46.0] — 2026-10-27

### English

Status cards can be a choice: a period picked by its state.

#### New
- `a.status` with `aria-current`: the chosen card is tinted with a yellow bar at the bottom; its state keeps the bar on top. `.status-row` lines the cards up and wraps them on a phone.

#### Fixed
- A busy outlined button showed its stripes in one small tile that jumped back; they now fill the whole button and march through it.

![Status cards as a choice, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.46-status-choice.png)

![Busy buttons: stripes across the whole button](https://shrippen.github.io/Kante/shots/release-1.46-busy.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-146

### Deutsch

Statuskarten können eine Auswahl sein: ein Zeitraum, gewählt nach seinem Stand.

#### Neu
- `a.status` mit `aria-current`: Die gewählte Karte ist getönt und hat unten einen gelben Balken; ihr Stand behält den Balken oben. `.status-row` reiht die Karten auf und bricht sie am Telefon um.

#### Behoben
- Ein beschäftigter umrandeter Knopf zeigte seine Streifen in einer kleinen Kachel, die zurücksprang; jetzt füllen sie den ganzen Knopf und wandern durch.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-146

## [1.45.0] — 2026-10-25

### English

The audio meter no longer hides its size factor.

#### Breaking
- `KanteAudioMeter`: the labels' switch is `showScale`; `scale` is the item's size factor again, as on every `Item`. Old code: a literal `scale: true` or `scale: false` no longer loads (number expected), nor does the page that holds it; a binding loads and goes wrong silently, at 0 the meter shrinks to nothing. Search for `scale:` on every `KanteAudioMeter`.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-145

### Deutsch

Der Pegelmesser verdeckt seinen Größenfaktor nicht mehr.

#### Inkompatibel
- `KanteAudioMeter`: Die Beschriftung schaltet jetzt `showScale`; `scale` ist wieder der Größenfaktor, wie bei jedem `Item`. Alter Code: Ein Literal `scale: true` oder `scale: false` lädt nicht mehr (Zahl erwartet), und mit ihm die ganze Seite; eine Bindung lädt und läuft still falsch, bei 0 schrumpft der Messer auf nichts. Nach `scale:` an jedem `KanteAudioMeter` suchen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-145

## [1.44.0] — 2026-10-25

### English

The timing histogram shows the target band.

#### New
- `KanteTimingHistogram`: a target band (for example laid-back, +10 to +30 ms) as a shaded range with dashed edges and a label, so you see where your notes sit against the aim.
- `KanteBarChart`: `ranges` shade any span behind the bars.

![Laid-back aim: the band from +10 to +30 ms (demo data)](https://shrippen.github.io/Kante/shots/release-1.44-band.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-144

### Deutsch

Das Timing-Histogramm zeigt das Ziel-Band.

#### Neu
- `KanteTimingHistogram`: ein Ziel-Band (etwa laid-back, +10 bis +30 ms) als getönter Bereich mit gestrichelten Rändern und Beschriftung; so siehst du, wo deine Töne gegenüber dem Ziel liegen.
- `KanteBarChart`: `ranges` tönen beliebige Bereiche hinter den Balken.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-144

## [1.43.0] — 2026-10-25

### English

Parts for a mixing desk: drag a pane's size, menus with sections and shortcuts, a popover, swatches, option tiles.

#### New
- `KanteSplitHandle`: the grip between two panes; drag, arrows or a double click to the default.
- `KanteMenuItem` and `KanteMenuSection`: menu items with icon, value and shortcut as `KanteKeycap`; headings that group them.
- `KantePopover`: a card at a button for settings that apply at once.
- `KanteSwatchPicker`, `KanteTableHeader`, `KanteOptionTile`; `KanteToast` gets an action (Undo); `KanteDialog` names its accept button (`acceptText`).

#### Fixed
- `KanteSheetSkin`, `KanteMessageSkin`: after leaving Kante a sheet or inline message kept a hidden platform background, as menus did before 1.42.
- `KanteToast` stays while the pointer is over it, then gets its full time again.

![The new parts in Kante (top) and Kante Light](https://shrippen.github.io/Kante/shots/release-1.43-lmix.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-143

### Deutsch

Bausteine für ein Mischpult: Größen ziehen, Menüs mit Abschnitten und Kürzeln, ein Popover, Farbfelder, Auswahlkacheln.

#### Neu
- `KanteSplitHandle`: der Griff zwischen zwei Bereichen; ziehen, Pfeiltasten oder Doppelklick zurück zum Standard.
- `KanteMenuItem` und `KanteMenuSection`: Menüeinträge mit Icon, Wert und Kürzel als `KanteKeycap`; Überschriften, die sie gruppieren.
- `KantePopover`: eine Karte am Knopf für Einstellungen, die sofort gelten.
- `KanteSwatchPicker`, `KanteTableHeader`, `KanteOptionTile`; `KanteToast` bekommt eine Aktion (Rückgängig); `KanteDialog` benennt seinen Bestätigen-Knopf (`acceptText`).

#### Behoben
- `KanteSheetSkin`, `KanteMessageSkin`: Nach dem Verlassen von Kante blieb der Plattform-Hintergrund eines Sheets oder einer Meldung verborgen, wie bei Menüs vor 1.42.
- `KanteToast` bleibt stehen, solange der Zeiger darauf liegt, und bekommt danach wieder seine volle Zeit.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-143

## [1.42.0] — 2026-10-25

### English

Menus stay opaque after leaving Kante.

#### Fixed
- `KantePopupSkin`: switching from Kante to Kante Light or System left menus see-through, their items straight over what lay below. The skin now keeps the platform background and draws its card behind the content; a popup without a background gets the card too.

#### Breaking
- `KantePopupSkin`: the property `kanteBackground` is gone, and in Kante `popup.background` is the hidden platform background; the card is `kanteCard`.

![The same menu after leaving Kante, before and after](https://shrippen.github.io/Kante/shots/release-1.42-menu.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-142

### Deutsch

Menüs bleiben deckend, nachdem Kante verlassen wurde.

#### Behoben
- `KantePopupSkin`: Nach dem Wechsel von Kante zu Kante Light oder System waren Menüs durchsichtig, die Einträge lagen direkt über dem Inhalt darunter. Der Skin behält jetzt den Plattform-Hintergrund und zeichnet seine Karte hinter den Inhalt; auch ein Popup ohne Hintergrund bekommt sie.

#### Inkompatibel
- `KantePopupSkin`: Die Property `kanteBackground` entfällt, und in Kante ist `popup.background` der ausgeblendete Plattform-Hintergrund; die Karte heißt `kanteCard`.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-142

## [1.40.0] — 2026-10-24

### English

Staves without notes stay quiet.

#### Fixed
- `KanteTabStaff`, `KanteBassStaff`: emptying the notes during playback logged a `TypeError`; the description for screen readers now waits for the current note.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-140

### Deutsch

Notenzeilen ohne Noten bleiben still.

#### Behoben
- `KanteTabStaff`, `KanteBassStaff`: Wurden die Noten während der Wiedergabe geleert, meldete die Konsole einen `TypeError`; die Beschreibung für Screenreader wartet jetzt auf den aktuellen Ton.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-140

## [1.39.0] — 2026-10-23

### English

Wizard steps fit narrow windows.

#### Improved
- `KanteSteps`: when the labels no longer fit, only the current step keeps its label; the others show their number or check. Screen readers still hear every step by name.

#### Note
- `KanteSteps` is now an `Item` with the steps in a `Row` (it was the `Row` itself); `model`, `current` and `spacing` stay. Its own width is always the width with every label, also when it is created asynchronously (a `Loader`), so it turns compact only under a width set by a layout.

![The same steps wide and narrow (demo data)](https://shrippen.github.io/Kante/shots/release-1.39-steps.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-139

### Deutsch

Schritte eines Assistenten passen auch in schmale Fenster.

#### Verbessert
- `KanteSteps`: passen die Beschriftungen nicht mehr, behält nur der aktuelle Schritt seine; die anderen zeigen Nummer oder Haken. Screenreader hören weiter jeden Schritt mit Namen.

#### Hinweis
- `KanteSteps` ist jetzt ein `Item` mit den Schritten in einer `Row` (bisher die `Row` selbst); `model`, `current` und `spacing` bleiben. Seine eigene Breite ist immer die mit allen Beschriftungen, auch wenn es asynchron entsteht (ein `Loader`); kompakt wird es nur unter einer Breite, die ein Layout setzt.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-139

## [1.38.0] — 2026-10-23

### English

One main button in the transport: play.

#### Improved
- `KanteTransportBar`: loop, metronome and count-in show on or off by the square before the word alone, no longer as filled buttons next to play. Screen readers hear them as check boxes.

![Metronome and count-in on, loop off: the lamp tells the state (Kante and Leinen)](https://shrippen.github.io/Kante/shots/release-1.38-transport.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-138

### Deutsch

Ein Hauptknopf in der Wiedergabe: Abspielen.

#### Verbessert
- `KanteTransportBar`: Schleife, Metronom und Einzähler zeigen an oder aus nur noch am Kästchen vor dem Wort, nicht mehr als gefüllte Knöpfe neben „Abspielen“. Screenreader lesen sie als Kontrollkästchen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-138

## [1.37.0] — 2026-10-23

### English

Ghost notes in tab as printed: the fret in parentheses, nothing more.

#### Improved
- `KanteTabLane` and `KanteTabStaff` no longer draw "( )" above a ghost note's parenthesized fret; in sixteenths the two ran together. A technique result frames the fret instead.

![Ghost notes in lane and tab: the fret in parentheses; a result frames it (demo data)](https://shrippen.github.io/Kante/shots/release-1.37-ghost.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-137

### Deutsch

Ghost Notes in der Tabulatur wie gedruckt: der Bund in Klammern, sonst nichts.

#### Verbessert
- `KanteTabLane` und `KanteTabStaff` zeichnen über dem geklammerten Bund einer Ghost Note kein „( )“ mehr; bei Sechzehnteln lief beides ineinander. Ein Technik-Ergebnis rahmt stattdessen den Bund.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#changed-in-kante-137

## [1.36.0] — 2026-10-23

### English

Key figures read as one: screen readers hear "Practised: 7 min".

#### Fixed
- `KanteKpi` has one accessible name of label and value, the change as description. Before, figure and label were read as two loose texts.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-136

### Deutsch

Kennzahlen am Stück: Screenreader hören „Geübt: 7 min“.

#### Behoben
- `KanteKpi` hat einen Namen aus Beschriftung und Wert, die Änderung als Beschreibung. Bisher wurden Zahl und Beschriftung als zwei lose Texte vorgelesen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-136

## [1.35.0] — 2026-10-23

### English

Loops in tab and notes: tablature and bass staff show the loop range the tab lane already showed. From lmix: a page bar, dark picture areas and vertical sliders.

#### New
- `KanteTabStaff` and `KanteBassStaff`: `loopStart` and `loopEnd` as on the tab lane, a tint with bracket edges, so a looped passage is visible in every view, not only by colour.
- A loop across a line break continues on the next line; brackets only where it really starts and ends.
- `KantePageBar`: the bar at the foot of an app window that switches between a few large pages. The current page is raised with a marker line; a dot on a tab says something runs there, Warning and Error as a diamond, so the kind is not colour alone. Keyboard and screen readers included.
- `KanteStyle.stageColor` and `stageTextColor`: the ground of monitors and video previews, dark in every kind and in Leinen too, as the web `.stage`.
- `KanteSliderSkin` draws vertical sliders (faders): the track runs along the height, filled from the bottom.

#### Note
- Additions only: existing calls keep working; without a loop nothing changes, horizontal sliders look as before.

![Bars 3 and 4 looped in lane, tab and staff (demo data)](https://shrippen.github.io/Kante/shots/release-1.35-loop.png)

![Page bar, picture area and vertical sliders, in Kante and Leinen](https://shrippen.github.io/Kante/shots/release-1.35-pagebar.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-135

### Deutsch

Schleifen in Tab und Noten: Tabulatur und Bassnoten zeigen den Loop-Bereich, den bisher nur die Tab-Lane zeigte. Aus lmix: eine Seitenleiste, dunkle Bildflächen und senkrechte Schieberegler.

#### Neu
- `KanteTabStaff` und `KanteBassStaff`: `loopStart` und `loopEnd` wie in der Tab-Lane, eine Tönung mit Klammerkanten, damit eine Schleife in jeder Ansicht zu sehen ist, nicht nur an der Farbe.
- Eine Schleife über einen Zeilenumbruch geht in der nächsten Zeile weiter; Klammern nur, wo sie wirklich beginnt und endet.
- `KantePageBar`: die Leiste am Fuß eines App-Fensters, die zwischen wenigen großen Seiten umschaltet. Die aktuelle Seite ist hervorgehoben und hat eine Markierungslinie; ein Punkt auf einem Reiter zeigt, dass dort etwas läuft, Warnung und Fehler als Raute, damit die Art nicht nur an der Farbe hängt. Mit Tastatur und Screenreader.
- `KanteStyle.stageColor` und `stageTextColor`: der Grund von Monitoren und Videovorschauen, dunkel in jeder Art und auch in Leinen, wie `.stage` im Web.
- `KanteSliderSkin` zeichnet senkrechte Schieberegler (Fader): Die Spur läuft entlang der Höhe und füllt sich von unten.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter; ohne Schleife ändert sich nichts, waagerechte Schieberegler sehen aus wie bisher.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-135

## [1.34.1] — 2026-10-13

### English

A date field with a two-digit year keeps the year it shows.

#### Fixed
- `KanteDateField` with a short format such as `dd.MM.yy` or `M/d/yy`: the field shows "26" and read it back as 1926 when it was entered and left. Two-digit years now lie in the century around today, at most 20 years ahead. In Plasmai a running entry started 100 years back, and Kimai refused a stopped one as too long.

#### Note
- Fields with a four-digit year (the default `dd.MM.yyyy`) were not affected.

![What the field reads back from its own text, German and US format](https://shrippen.github.io/Kante/shots/release-1.34.1-years.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1341

### Deutsch

Ein Datumsfeld mit zweistelliger Jahreszahl behält das Jahr, das es zeigt.

#### Behoben
- `KanteDateField` mit einem Kurzformat wie `dd.MM.yy` oder `M/d/yy`: Das Feld zeigt „26“ und las das beim Betreten und Verlassen als 1926 zurück. Zweistellige Jahre liegen jetzt im Jahrhundert um heute, höchstens 20 Jahre voraus. In Plasmai begann ein laufender Eintrag 100 Jahre früher, und Kimai lehnte einen beendeten als zu lang ab.

#### Hinweis
- Felder mit vierstelligem Jahr (der Standard `dd.MM.yyyy`) waren nicht betroffen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1341

## [1.34.0] — 2026-10-13

### English

Japanese in pieces gets a Japanese face, not a Chinese one.

#### New
- `KanteStyle.japaneseFamily` and `japaneseFont()`: the first installed Japanese face of a preference list.

#### Fixed
- Ruby text, pitch curve and correction diff draw Japanese in a Japanese face. Under a German or English locale single kanji fell back to a Chinese face: other glyph forms, a lower baseline, a centred 。.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-134

### Deutsch

Japanisch in Stücken bekommt eine japanische Schrift statt einer chinesischen.

#### Neu
- `KanteStyle.japaneseFamily` und `japaneseFont()`: die erste installierte japanische Schrift einer Vorzugsliste.

#### Behoben
- Ruby-Text, Pitch-Kurve und Korrektur-Diff zeigen Japanisch in einer japanischen Schrift. Unter deutscher oder englischer Locale fielen einzelne Kanji auf eine chinesische Schrift zurück: andere Zeichenformen, tiefere Grundlinie, mittiges 。.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-134

## [1.33.0] — 2026-10-13

### English

Words to look up in Japanese text: a click on a word, for Kaiwa's dictionary.

#### New
- `KanteRubyText`: segments form words; with `interactive` a word underlines on hover and opens with a click, or with Tab, the arrow keys and Enter. Screen readers hear the focused word.

#### Note
- Additions only: existing calls keep working.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-133

### Deutsch

Wörter zum Nachschlagen in japanischem Text: ein Klick auf ein Wort, für Kaiwas Wörterbuch.

#### Neu
- `KanteRubyText`: Segmente bilden Wörter; mit `interactive` unterstreicht sich ein Wort beim Darüberfahren und öffnet sich per Klick oder mit Tab, Pfeiltasten und Eingabe. Screenreader lesen das gewählte Wort vor.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-133

## [1.32.0] — 2026-10-12

### English

Dead notes for Kontra: a note muted without pitch gets its own sign.

#### New
- `KanteTechniqueMark`: the dead note "x", with played, another technique or not heard as for every technique.
- Tab lane and tablature write a dead note's fret as x, as in printed tab.

#### Note
- Additions only: existing calls keep working.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-132

### Deutsch

Dead Notes für Kontra: ein gedämpfter Ton ohne Tonhöhe bekommt ein eigenes Zeichen.

#### Neu
- `KanteTechniqueMark`: die Dead Note „x“, mit gespielt, andere Technik oder nicht gehört wie bei jeder Technik.
- Tab-Lane und Tabulatur schreiben den Bund einer Dead Note als x, wie in gedruckter Tabulatur.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-132

## [1.31.0] — 2026-10-11

### English

Technique marks for Kontra: tab, lane and staff show how a note is to be played, and whether it was.

#### New
- `KanteTechniqueMark`: the tab signs for slide, hammer-on, pull-off, slap, pop and ghost note; played, another technique or not heard show by frame and strike, not by colour alone.
- Tab lane, tablature and bass staff take a technique and its result per note; a ghost note's fret reads in parentheses.

#### Note
- Additions only: existing calls keep working.

![Technique signs in lane, tab and staff (demo data)](https://shrippen.github.io/Kante/shots/release-1.31-techniques.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-131

### Deutsch

Technik-Zeichen für Kontra: Tab, Lane und Noten zeigen, wie eine Note zu spielen ist und ob sie so gespielt wurde.

#### Neu
- `KanteTechniqueMark`: die Tab-Zeichen für Slide, Hammer-on, Pull-off, Slap, Pop und Ghost Note; gespielt, andere Technik oder nicht gehört zeigen Rahmen und Durchstreichung, nicht nur die Farbe.
- Tab-Lane, Tabulatur und Bassnoten nehmen je Note eine Technik und ihr Ergebnis; der Bund einer Ghost Note steht in Klammern.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-131

## [1.30.0] — 2026-10-11

### English

A keyboard for Kontra's bass over MIDI: players who play bass lines on keys see the notes fall onto the keys they play.

#### New
- `KanteKeyboard`: piano keys for a MIDI range with markers by shape (current, next, root, scale) and the note state signs; key names from the app; optionally usable by keyboard and click.
- `KanteKeyLane`: falling notes over the keys, with the tab lane's notes, timing and state signs, so an app feeds both the same data.
- `KanteKeyLayout`: the key geometry both share, with piano proportions.

#### Note
- Additions only: existing calls keep working.

![Key lane over the keyboard (demo data)](https://shrippen.github.io/Kante/shots/release-1.30-keyboard.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-130

### Deutsch

Eine Klaviatur für Kontras Bass über MIDI: wer Basslinien auf Tasten spielt, sieht die Noten auf die Tasten fallen, die zu spielen sind.

#### Neu
- `KanteKeyboard`: Klaviertasten für einen MIDI-Bereich mit Markierungen nach Form (aktuell, nächste, Grundton, Tonleiter) und den Zeichen der Notenzustände; Tastennamen von der App; auf Wunsch mit Tastatur und Klick bedienbar.
- `KanteKeyLane`: fallende Noten über den Tasten, mit Noten, Zeitachse und Zustandszeichen der Tab-Lane, so dass eine App beiden dieselben Daten gibt.
- `KanteKeyLayout`: die gemeinsame Tastengeometrie, in Klavierproportionen.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-130

## [1.29.0] — 2026-10-11

### English

Colour labels in apps and an audio meter for mixers, for lmix's Qt Console.

#### New
- Seven colour labels, the same on the web and in apps: red, orange, yellow, green, cyan, blue, purple. A label keeps its colour in every theme; its name stands beside it.
- `KanteAudioMeter`: a level in dBFS with three zones, peak hold and a scale, also vertical.

#### Note
- Web: `data-label` also takes `orange` and `cyan`. `KanteLevelMeter` stays the input check with zones in words.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-129

### Deutsch

Farblabels in Apps und ein Audio-Meter für Mischpulte, für die Qt-Konsole von lmix.

#### Neu
- Sieben Farblabels, im Web und in Apps gleich: Rot, Orange, Gelb, Grün, Cyan, Blau, Lila. Ein Label behält seine Farbe in jedem Theme; sein Name steht daneben.
- `KanteAudioMeter`: ein Pegel in dBFS mit drei Zonen, Spitzenwert-Halten und Skala, auch senkrecht.

#### Hinweis
- Web: `data-label` kennt auch `orange` und `cyan`. `KanteLevelMeter` bleibt die Eingangsprüfung mit Zonen in Worten.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-129

## [1.28.0] — 2026-10-11

### English

More wishes from Kontra, the bass trainer: choices that are not available yet, help next to a term, a Kante number field and alternate endings in the tablature.

#### New
- `KanteInfoTip`: a “?” next to a term that explains it on hover, focus or click; its name for screen readers is plain text the app sets.
- `KanteSpinBox`: a spin box in Kante, with the same API as the Qt one (units via `textFromValue`, typing, keys).
- `KanteTabStaff`: volta brackets over the bars of an ending (“1.”, “2.”), from `endings` in the bar data; also across a line break.

#### Improved
- `KanteSegmented` and `.seg`: single segments can be disabled. They are faded and struck through, take no click, arrow keys skip them, and their tooltip can say why.
- `KanteFieldSkin`: on a spin box, + or − fades when the value is at its limit.
- `KanteTabStaff`, `KanteBassStaff`, `KanteTabLane`: bars show the number the app sends (`bars[i].number`), so repeats played out read 5, 6, 5, 6 as in the score.
- String colours: the palette moves into `KanteStyle` with the presets “kante”, “mono” and “bright”; lane, tablature and fretboard share it (`stringColors`). Strings keep their names, so colour is never the only sign.

#### Note
- Additions only: existing calls keep working. A tablature without `endings` keeps its layout. Tablature and fretboard now draw their strings in the string palette instead of muted; `stringPalette: "mono"` comes closest to the old look.

![Disabled segments, info tip and spin boxes (demo data)](https://shrippen.github.io/Kante/shots/release-1.28-wishes2-controls.png)

![String palettes kante, mono, bright (demo data)](https://shrippen.github.io/Kante/shots/release-1.28-strings.png)

![Volta brackets in the tablature (demo data)](https://shrippen.github.io/Kante/shots/release-1.28-volta.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-128

### Deutsch

Weitere Wünsche aus Kontra, dem Basstrainer: Auswahlen, die es noch nicht gibt, Hilfe neben einem Begriff, ein Zahlenfeld in Kante und Wiederholungsklammern in der Tabulatur.

#### Neu
- `KanteInfoTip`: ein „?“ neben einem Begriff, das ihn bei Zeigen, Fokus oder Klick erklärt; seinen Namen für Screenreader setzt die App als einfachen Text.
- `KanteSpinBox`: ein Zahlenfeld in Kante, mit derselben API wie das von Qt (Einheiten über `textFromValue`, Eintippen, Tasten).
- `KanteTabStaff`: Wiederholungsklammern (Volta) über den Takten eines Schlusses („1.“, „2.“), aus `endings` in den Taktdaten; auch über einen Zeilenumbruch.

#### Verbessert
- `KanteSegmented` und `.seg`: einzelne Segmente lassen sich abschalten. Sie sind blass und durchgestrichen, nehmen keinen Klick an, die Pfeiltasten überspringen sie, und ihr Tooltip kann sagen, warum.
- `KanteFieldSkin`: an einem Zahlenfeld wird + oder − blass, wenn der Wert an seiner Grenze ist.
- `KanteTabStaff`, `KanteBassStaff`, `KanteTabLane`: Takte zeigen die Nummer, die die App schickt (`bars[i].number`), ausgespielte Wiederholungen lesen sich so wie in den Noten: 5, 6, 5, 6.
- Saitenfarben: die Palette zieht nach `KanteStyle`, mit den Vorgaben „kante“, „mono“ (einfarbig) und „bright“ (kräftig); Spur, Tabulatur und Griffbrett teilen sie (`stringColors`). Saiten behalten ihre Namen, die Farbe ist nie das einzige Zeichen.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter. Eine Tabulatur ohne `endings` behält ihr Layout. Tabulatur und Griffbrett zeichnen ihre Saiten jetzt in der Saitenpalette statt gedämpft; `stringPalette: "mono"` kommt dem alten Bild am nächsten.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-128

## [1.27.0] — 2026-10-09

### English

Wishes from a QA round of Kontra, the bass trainer: Kante controls instead of light platform ones, a primary action that stands out in Kante Light, steps that differ by shape, and more for the bass staff.

#### New
- `KanteSwitch` and `KanteComboBox`: a switch and a combo box in Kante, the combo box's open list included.
- Note state `offpitch`: the right note, its pitch off by more than the app's limit. A wave as its sign, the deviation beside it (“+32 ct”).
- `KanteBassStaff`: chord symbols per bar or at a time, and a key per bar (naturals only when the key returns to C).

#### Improved
- `KanteSteps`: done shows a check, the current step a filled number and an outline, upcoming steps a hollow number, so colour is never the only difference (WCAG 1.4.1).

#### Fixed
- Kante Light: the primary button looked like any other. It is now filled in the platform highlight, darkened until its label reads at 4.5:1.
- `KanteFieldSkin`: the combo box arrow is drawn, so it shows without an icon theme.

#### Note
- Additions only: existing calls keep working. A plain combo box with `KanteFieldSkin` keeps the style's list; use `KanteComboBox` for a Kante list.

![Primary action, steps, switch and combo box (demo data)](https://shrippen.github.io/Kante/shots/release-1.27-wishes-controls.png)

![The offpitch state with cents (demo data)](https://shrippen.github.io/Kante/shots/release-1.27-offpitch.png)

![Chord symbols and key changes (demo data)](https://shrippen.github.io/Kante/shots/release-1.27-chords-keys.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-127

### Deutsch

Wünsche aus einer QA-Runde von Kontra, dem Basstrainer: Kante-Bedienelemente statt heller Plattform-Elemente, eine Hauptaktion, die in Kante Light heraussticht, Schritte, die sich in der Form unterscheiden, und mehr für das Bass-Notensystem.

#### Neu
- `KanteSwitch` und `KanteComboBox`: Schalter und Auswahlfeld in Kante, die offene Liste des Auswahlfelds eingeschlossen.
- Notenzustand `offpitch` („unsauber“): der richtige Ton, aber mehr als die Grenze der App verstimmt. Eine Welle als Zeichen, die Abweichung daneben („+32 ct“).
- `KanteBassStaff`: Akkordsymbole pro Takt oder an einer Zeit und eine Tonart pro Takt, Auflösungszeichen nur bei der Rückkehr nach C.

#### Verbessert
- `KanteSteps`: erledigt zeigt einen Haken, der aktuelle Schritt eine gefüllte Nummer und einen Rahmen, kommende eine hohle Nummer; die Farbe ist nie der einzige Unterschied (WCAG 1.4.1).

#### Behoben
- Kante Light: der Hauptknopf sah aus wie jeder andere. Er ist jetzt in der Hervorhebungsfarbe der Plattform gefüllt, abgedunkelt, bis seine Beschriftung 4,5:1 erreicht.
- `KanteFieldSkin`: der Pfeil des Auswahlfelds wird gezeichnet und erscheint so auch ohne Symbolthema.

#### Hinweis
- Nur Ergänzungen: bestehende Aufrufe funktionieren weiter. Ein einfaches Auswahlfeld mit `KanteFieldSkin` behält die Liste des Stils; für eine Kante-Liste `KanteComboBox` nehmen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-127
