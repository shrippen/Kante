# Changelog

The release notes of Kante, newest first. Each section is the text of its entry in `#changes` on
the landing page (`docs/index.html`). Releases before 1.27 are described in the README, one section
per version. Knust and the plugin kit keep their own logs: `kimai/knust/CHANGELOG.md`,
`kimai/kit/CHANGELOG.md`.

## [1.76.2] — 2026-11-09

### English

Apps with many items under a KanteScope no longer stand still when a view fills.

#### Improved
- `KanteScope` looked at an item once for every child it got. When a list or a staff made hundreds of items at once, it went through all of them hundreds of times. Kontra's notation view stood still for 2.7 s when it opened and for up to a second on the next line while playing. Now each item is looked at once: opening takes 17 ms and the next line 10 ms.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1762

### Deutsch

Apps mit vielen Elementen unter einem KanteScope stehen nicht mehr still, wenn sich eine Ansicht füllt.

#### Verbessert
- `KanteScope` sah sich ein Element für jedes Kind, das es bekam, einmal an. Legte eine Liste oder ein Notensystem Hunderte Elemente auf einmal an, ging es alle Hunderte Male durch. Kontras Notenansicht stand beim Öffnen 2,7 s still und beim Spielen in der nächsten Zeile bis zu einer Sekunde. Jetzt wird jedes Element einmal angesehen: Das Öffnen dauert 17 ms, die nächste Zeile 10 ms.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1762

## [1.76.1] — 2026-11-09

### English

A long song map starts at bar 1 in right-to-left layouts, and a shorter song keeps a fitting range.

#### Fixed
- `KanteSongMap`, right to left and too long for its width: the view started at the end of the piece, so the last bars showed. It now starts at bar 1, also when the number of bars changes; a new width keeps the view where it was, counted from bar 1.
- `KanteSongMap`: when the piece got shorter, the chosen range stayed, for example bars 6 to 8 of a piece with two bars, and a loop bound to it named bars that do not exist. The range now ends at the last bar, or is cleared when none of its bars is left.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1761

### Deutsch

Eine lange Liedkarte beginnt auch bei Schrift von rechts nach links bei Takt 1, und ein kürzeres Lied behält einen passenden Bereich.

#### Behoben
- `KanteSongMap`, von rechts nach links und zu lang für seine Breite: Die Ansicht begann am Ende des Stücks, man sah die letzten Takte. Sie beginnt jetzt bei Takt 1, auch wenn sich die Zahl der Takte ändert; eine neue Breite lässt die Ansicht, wo sie war, gezählt von Takt 1.
- `KanteSongMap`: Wurde das Stück kürzer, blieb der gewählte Bereich, etwa Takt 6 bis 8 bei einem Stück mit zwei Takten, und eine daran gebundene Schleife nannte Takte, die es nicht gibt. Der Bereich endet jetzt am letzten Takt oder wird geleert, wenn keiner seiner Takte bleibt.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1761

## [1.76.0] — 2026-11-09

### English

A strip over a whole song shows where it goes well and where to practise.

#### New
- `KanteSongMap`: one column per bar of a piece, its height the bar's value, for example the hit rate over the last runs, so weak bars stand out as low columns. The tooltip and screen readers say the number ("Takt 5: 82 %"); a bar not played yet is a dashed mark, not a zero. Dragging over bars, or Shift with the arrows and then Enter, chooses a range, for example the loop to practise; the range is tinted and underlined. A long piece scrolls sideways. Made for Kontra's song map.

![A song map: sixteen bars as columns of different heights, bars 5 to 8 chosen as the loop, one bar not played yet](https://shrippen.github.io/Kante/shots/release-1.76-song-map.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-176

### Deutsch

Ein Streifen über ein ganzes Lied zeigt, wo es gut läuft und wo Übung fehlt.

#### Neu
- `KanteSongMap`: eine Säule je Takt eines Stücks, ihre Höhe der Wert des Takts, etwa die Trefferquote der letzten Durchläufe, so fallen schwache Takte als niedrige Säulen auf. Tooltip und Screenreader nennen die Zahl („Takt 5: 82 %“); ein Takt, der noch nicht gespielt wurde, ist eine gestrichelte Marke, keine Null. Ziehen über Takte, oder Umschalt mit den Pfeilen und dann Enter, wählt einen Bereich, etwa die Schleife zum Üben; der Bereich ist getönt und unterstrichen. Ein langes Stück scrollt seitwärts. Gemacht für Kontras Liedkarte.

![Eine Liedkarte: sechzehn Takte als Säulen verschiedener Höhe, Takte 5 bis 8 als Schleife gewählt, ein Takt noch nicht gespielt](https://shrippen.github.io/Kante/shots/release-1.76-song-map.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-176

## [1.75.1] — 2026-11-07

### English

Calendars with many days open faster and follow a new width at once.

#### Improved
- `KanteCalendarHeatmap`: each day was an item of its own with its name for screen readers, 1800 of them on Mitori's page of five years. The days are now drawn as one shape, and a screen reader hears a week at a time, every day of it with its date and tip. The page opened in 744 ms, now in about 525 ms with this alone; a new width moves no items any more, which made a calendar that fits its weeks to the width slow. It looks the same.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1751

### Deutsch

Kalender mit vielen Tagen öffnen schneller und folgen einer neuen Breite sofort.

#### Verbessert
- `KanteCalendarHeatmap`: Jeder Tag war ein eigenes Element mit eigenem Namen für Screenreader, 1800 davon auf Mitoris Seite mit fünf Jahren. Die Tage werden jetzt als eine Form gezeichnet, und ein Screenreader hört eine Woche auf einmal, jeden Tag darin mit Datum und Tooltip-Text. Die Seite öffnete in 744 ms, jetzt allein dadurch in etwa 525 ms; eine neue Breite verschiebt keine Elemente mehr, das machte einen Kalender langsam, der seine Wochen an die Breite anpasst. Er sieht gleich aus.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1751

## [1.75.0] — 2026-11-06

### English

A document can show where the fields' values stand.

#### New
- `.doc-reader`, `.doc-pages`, `.doc-page`: the page a `.doc-view` frame shows, a bar and the pages to scroll, for apps that draw a document themselves.
- `.doc-mark`: a mark on a page in the theme's primary colour, so what a field holds can be found in the document at a glance.

![A receipt in its frame with a bar on top, amount and date marked](https://shrippen.github.io/Kante/shots/release-1.75-doc-mark.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-175

### Deutsch

Ein Dokument kann zeigen, wo die Werte der Felder stehen.

#### Neu
- `.doc-reader`, `.doc-pages`, `.doc-page`: die Seite, die ein `.doc-view`-Rahmen zeigt, eine Leiste und die Seiten zum Scrollen, für Apps, die ein Dokument selbst zeichnen.
- `.doc-mark`: eine Markierung auf einer Seite in der Primärfarbe des Themes, damit sich der Wert eines Felds im Dokument auf einen Blick findet.

![Ein Beleg im Rahmen mit Leiste oben, Betrag und Datum markiert](https://shrippen.github.io/Kante/shots/release-1.75-doc-mark.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-175

## [1.74.3] — 2026-11-05

### English

Tiles answer to Enter, and long hints stay readable.

#### Fixed
- `KanteOptionTile`: Return and Enter did nothing, only Space chose a tile. `KanteTile` also takes the keypad's Enter now.
- `KanteOptionTile`: title and hint were cut after one line. They now show in up to two lines.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1743

### Deutsch

Kacheln reagieren auf Enter, lange Hinweise bleiben lesbar.

#### Behoben
- `KanteOptionTile`: Return und Enter taten nichts, nur die Leertaste wählte eine Kachel. `KanteTile` nimmt jetzt auch Enter vom Ziffernblock.
- `KanteOptionTile`: Titel und Hinweis wurden nach einer Zeile abgeschnitten. Sie zeigen jetzt bis zu zwei Zeilen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1743

## [1.74.2] — 2026-11-05

### English

Calendars with many days open twice as fast.

#### Improved
- `KanteCalendarHeatmap`: a year of days took about 95 ms to create, each day with its own handlers, tooltip and date calculations. The days now share one tooltip and one pair of handlers and read their dates from one list: about 47 ms. A page with several years opens noticeably sooner on a phone. It looks and behaves as before, and screen readers still hear each day.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1742

### Deutsch

Kalender mit vielen Tagen öffnen doppelt so schnell.

#### Verbessert
- `KanteCalendarHeatmap`: Ein Jahr Tage brauchte beim Erstellen etwa 95 ms, jeder Tag mit eigenen Handlern, eigenem Tooltip und eigenen Datumsrechnungen. Die Tage teilen sich jetzt einen Tooltip und ein Paar Handler und lesen ihr Datum aus einer Liste: etwa 47 ms. Eine Seite mit mehreren Jahren öffnet auf dem Telefon spürbar früher. Aussehen und Verhalten bleiben gleich, Screenreader hören weiter jeden Tag.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1742

## [1.74.1] — 2026-11-05

### English

Symbols sharp again on Plasma, and buttons with a margin under the desktop style.

#### Fixed
- Icons drawn by `KanteIcon` came out grey and soft in a layout on Plasma: 1.73.0 asked the theme for the file before the size was known and scaled the wrong one. It now picks after the size is set, and again at a new size.
- `KanteButton`: icon and label ran to the edge under the desktop style (Plasma, plasmoids), whose padding is 0. A button with a label now keeps at least 8 px on each side, a lone symbol stays in the middle even on a narrow button; styles with at least that much padding look as before, Fusion (4 px) gets a little wider.

![Buttons with an icon and label, the upper row with 1.73.0: a grey, soft floppy disk and text against the edge; the lower row with 1.74.1: sharp symbols and a margin](https://shrippen.github.io/Kante/shots/release-1.74.1-symbole.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1741

### Deutsch

Symbole auf Plasma wieder scharf, und Knöpfe mit Rand unter dem Desktop-Stil.

#### Behoben
- Symbole aus `KanteIcon` wurden in einem Layout auf Plasma grau und weich: 1.73.0 fragte das Thema nach der Datei, bevor die Größe feststand, und skalierte die falsche. Es wählt jetzt, nachdem die Größe gesetzt ist, und bei einer neuen Größe erneut.
- `KanteButton`: Symbol und Text liefen unter dem Desktop-Stil (Plasma, Plasmoids), dessen Polster 0 ist, bis an den Rand. Ein Knopf mit Text behält jetzt mindestens 8 px je Seite, ein einzelnes Symbol bleibt auch im schmalen Knopf mittig; Stile mit mindestens so viel Polster sehen aus wie vorher, Fusion (4 px) wird etwas breiter.

![Knöpfe mit Symbol und Text, obere Reihe mit 1.73.0: graue, weiche Diskette und Text am Rand; untere Reihe mit 1.74.1: scharfe Symbole und ein Rand](https://shrippen.github.io/Kante/shots/release-1.74.1-symbole.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1741

## [1.74.0] — 2026-11-05

### English

A workbench that keeps the receipt in view, with each field's sources side by side.

#### New
- The workbench's desk can hold a document beside its fields. The document stays in view while the fields scroll, so the fields can be checked against the paper at any time.
- A comparison table shows one row per field: what each source says, then the value it will hold. A click on a value takes it, and a source that differs from the others stands out.

![A workbench with a list, a comparison of date and category from bank, receipt and suggestion, and a document area on the right](https://shrippen.github.io/Kante/shots/release-1.74-bench-doc.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-174

### Deutsch

Eine Werkbank, die den Beleg im Blick behält, mit den Quellen jedes Felds nebeneinander.

#### Neu
- Der Arbeitsbereich der Werkbank kann ein Dokument neben seinen Feldern zeigen. Es bleibt stehen, während die Felder scrollen, sodass sich jedes Feld jederzeit am Papier prüfen lässt.
- Eine Vergleichstabelle zeigt je Feld eine Zeile: was jede Quelle sagt, dann den Wert, den das Feld bekommt. Ein Klick auf einen Wert übernimmt ihn, und eine abweichende Quelle fällt auf.

![Eine Werkbank mit Liste, einem Vergleich von Datum und Kategorie aus Bank, Beleg und Vorschlag und einem Dokumentbereich rechts](https://shrippen.github.io/Kante/shots/release-1.74-bench-doc.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-174

## [1.73.0] — 2026-11-05

### English

Everything sits where it should: buttons centred, icons in their colour on every platform, placeholders inside the field.

#### New
- `KanteSliderSkin.trackColor`: the colour of the track, for a slider on a dark stage where the sunken default does not show.

#### Fixed
- `KanteButton`: icon and label sat 2 px too low under the Material controls (Android, AppImage), because the content followed the style's uneven padding. They now stand in the middle.
- Icons in buttons, chips, tabs, menus and tiles stayed dark on the dark ground on Android and in an AppImage: `Kirigami.Icon` colours a mask only with the Plasma theme. The new `KanteIcon` colours them on every platform.
- `KanteTextField`: Material floated the placeholder above a focused field, across the frame and cut off at the edge of a bar. It now stays inside the box, and a long one is shortened. This also holds for `KanteDateField`.

![Controls in Leinen: transport bar with centred symbols and label, a note line with its placeholder in the field, a search field](https://shrippen.github.io/Kante/shots/release-1.73-mittig.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-173

### Deutsch

Alles sitzt, wo es soll: Knöpfe mittig, Symbole auf jeder Plattform in ihrer Farbe, Platzhalter im Feld.

#### Neu
- `KanteSliderSkin.trackColor`: die Farbe der Spur, für einen Schieber auf einer dunklen Bühne, auf der die vertiefte Vorgabe nicht zu sehen ist.

#### Behoben
- `KanteButton`: Symbol und Text saßen unter den Material-Controls (Android, AppImage) 2 px zu tief, weil der Inhalt dem ungleichen Polster des Stils folgte. Sie stehen jetzt in der Mitte.
- Symbole in Knöpfen, Chips, Tabs, Menüs und Kacheln blieben auf Android und im AppImage dunkel auf dem dunklen Grund: `Kirigami.Icon` färbt eine Maske nur mit dem Plasma-Thema. Das neue `KanteIcon` färbt sie auf jeder Plattform.
- `KanteTextField`: Material ließ den Platzhalter im fokussierten Feld über den Rahmen schweben, am Rand einer Leiste abgeschnitten. Er bleibt jetzt im Feld, ein langer wird gekürzt. Das gilt auch für `KanteDateField`.

![Bedienelemente in Leinen: Transportleiste mit mittigen Symbolen und Text, Notizzeile mit dem Platzhalter im Feld, ein Suchfeld](https://shrippen.github.io/Kante/shots/release-1.73-mittig.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-173

## [1.72.0] — 2026-11-03

### English

A suggestion under a field: the app offers values, the user picks one with a click.

#### New
- A field can show a second line with suggestions, small below it (“Vorschlag: Hosting, Software”), as Paperless-ngx does. A click on a value puts it into the field, and the app hears it as if the user had chosen it. Nothing is filled in on its own: what a learned model guesses stays a suggestion until the user takes it. Built for Andon's VAT check.

![Three fields with a suggestion line below each: Kategorie with Hosting, EÜR-Zeile with Arbeitsmittel taken and two more values, Lieferant with two suppliers](https://shrippen.github.io/Kante/shots/release-1.72-field-suggest.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-172

### Deutsch

Ein Vorschlag unter einem Feld: Die App bietet Werte an, der Nutzer nimmt einen mit einem Klick.

#### Neu
- Ein Feld kann eine zweite Zeile mit Vorschlägen zeigen, klein darunter („Vorschlag: Hosting, Software“), wie Paperless-ngx. Ein Klick auf einen Wert setzt ihn ins Feld, und die App erfährt es, als hätte der Nutzer ihn gewählt. Nichts wird von selbst ausgefüllt: Was ein gelerntes Modell rät, bleibt ein Vorschlag, bis der Nutzer ihn nimmt. Gebaut für Andons USt-Prüfung.

![Drei Felder mit je einer Vorschlagszeile darunter: Kategorie mit Hosting, EÜR-Zeile mit übernommenem Arbeitsmittel und zwei weiteren Werten, Lieferant mit zwei Lieferanten](https://shrippen.github.io/Kante/shots/release-1.72-field-suggest.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-172

## [1.71.0] — 2026-11-03

### English

A dialog with a wrapping text no longer reports a binding loop while it is built.

#### Fixed
- `KanteDialog` (1.70 measured its content): the content height follows once the dialog is built. While Qt built it, Kante's header and colours arrived and a wrapping text changed its height inside the dialog's own height: Mitori's question before deleting a notebook reported a binding loop.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-171

### Deutsch

Ein Dialog mit umbrechendem Text meldet beim Aufbau keine Bindungsschleife mehr.

#### Behoben
- `KanteDialog` (1.70 misst seinen Inhalt): Die Inhaltshöhe folgt, sobald der Dialog aufgebaut ist. Während Qt ihn aufbaute, kamen Kantes Kopf und Farben an, und ein umbrechender Text änderte seine Höhe mitten in der Höhe des Dialogs: Mitoris Frage vor dem Löschen eines Notizbuchs meldete eine Bindungsschleife.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-171

## [1.70.0] — 2026-11-03

### English

A dialog of its content's size measures its content.

#### Fixed
- `KanteDialog` with size Fit: the dialog takes its content's width and height. Its colour scope is a second child of the content, and Qt measures a popup's content only from a single child: the dialog was 0 wide, and a text without `contentHeight` ran into the buttons. The dialog now takes the size from the app's item; the scope stays where it is (it themes disabled items, 1.51). Found in Mitori (its own Shinki dialog had the same pattern).

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-170

### Deutsch

Ein Dialog in der Größe seines Inhalts misst seinen Inhalt.

#### Behoben
- `KanteDialog` mit Größe Fit: Der Dialog nimmt Breite und Höhe seines Inhalts. Sein Farb-Scope ist ein zweites Kind im Inhalt, und Qt misst den Inhalt eines Popups nur bei einem einzigen Kind: Der Dialog war 0 breit, und ein Text ohne `contentHeight` lief in die Knöpfe. Jetzt nimmt der Dialog die Größe vom Element der App; der Scope bleibt, wo er ist (er färbt deaktivierte Elemente, 1.51). Gefunden in Mitori (dessen Shinki-Dialog hatte dasselbe Muster).

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-170

## [1.69.0] — 2026-11-03

### English

A chip that is one choice of a set keeps the app's choice.

#### Fixed
- `KanteChip` with `choice`: a tap only reports (`clicked`), `checked` stays the app's binding. Before, a tap toggled the chip itself and broke the binding: an old choice stayed marked, and a second tap on the chosen chip cleared it. Found in Mitori (grade chips).

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-169

### Deutsch

Ein Chip, der eine Wahl aus einer Reihe ist, behält die Wahl der App.

#### Behoben
- `KanteChip` mit `choice`: Ein Tipp meldet nur (`clicked`), `checked` bleibt die Bindung der App. Bisher schaltete ein Tipp den Chip selbst um und brach die Bindung: Eine alte Wahl blieb markiert, und ein zweiter Tipp auf den gewählten Chip hob sie auf. Gefunden in Mitori (Grad-Chips).

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-169

## [1.68.0] — 2026-11-03

### English

A heading that may wrap shows its whole text in Kante too.

#### Fixed
- `KanteHeading` with `wrapMode` breaks a long title into lines in Kante and Kante Light; before, Kante drew it on one line and cut it off with “…”. Found in Mitori (long comment titles).

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-168

### Deutsch

Eine Überschrift, die umbrechen darf, zeigt auch in Kante ihren ganzen Text.

#### Behoben
- `KanteHeading` mit `wrapMode` bricht einen langen Titel in Kante und Kante Light in Zeilen um; bisher zeichnete Kante ihn einzeilig und schnitt ihn mit „…“ ab. Gefunden in Mitori (lange Titel der Kommentare).

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-168

## [1.67.0] — 2026-11-03

### English

An app can offer Leinen as a choice of its own: Kante's light palette no longer depends on a light platform theme.

#### New
- `KanteStyle.preferLight` forces Leinen whatever the platform theme says, as `preferDark` forces dark (`preferDark` wins when both are set). For Mitori's style setting, which offers Kante and Leinen side by side.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-167

### Deutsch

Eine App kann Leinen als eigene Wahl anbieten: Kantes helle Palette hängt nicht mehr am hellen Plattform-Thema.

#### Neu
- `KanteStyle.preferLight` erzwingt Leinen, gleich was das Plattform-Thema sagt, so wie `preferDark` dunkel erzwingt (`preferDark` gewinnt, wenn beide gesetzt sind). Für Mitoris Stilwahl, die Kante und Leinen nebeneinander anbietet.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-167

## [1.66.0] — 2026-11-02

### English

A window with a Kante dialog or page scope that the garbage collector takes leaves no errors in the log.

#### Fixed
- When the garbage collector took a window, a pending step of `KanteScope` or `KanteDialog` ran on it and wrote a `TypeError` to the log, up to 14 times in a test. Found in Mitori.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-166

### Deutsch

Ein Fenster mit einem Kante-Dialog oder Seiten-Scope, das der Garbage Collector nimmt, hinterlässt keine Fehler im Log.

#### Behoben
- Nahm der Garbage Collector ein Fenster, lief ein ausstehender Schritt von `KanteScope` oder `KanteDialog` darauf und schrieb einen `TypeError` ins Log, im Test bis zu 14-mal. Gefunden in Mitori.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-166

## [1.65.0] — 2026-11-02

### English

A window that holds a Kante dialog goes down without a crash.

#### Fixed
- An app crashed when a window with a `KanteDialog`, or a dialog with `KanteDialogSkin`, in it went down and the garbage collector took it: the dialog gave its old background back while Qt was already deleting it. lmix had to take its page windows down by hand for it.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-165

### Deutsch

Ein Fenster mit einem Kante-Dialog darin geht ohne Absturz zu.

#### Behoben
- Eine App stürzte ab, wenn ein Fenster mit einem `KanteDialog` oder einem Dialog mit `KanteDialogSkin` darin abgebaut wurde und der Garbage Collector es nahm: Der Dialog gab seinen alten Hintergrund zurück, während Qt ihn schon löschte. lmix musste seine Seitenfenster dafür von Hand abbauen.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-165

## [1.64.0] — 2026-11-02

### English

The heat grid keeps the focus where it was and fills a width; bar charts can start their scale above zero.

#### New
- Heat grids can fill their width: a fixed number of columns shares the room, with square cells as large as it allows. Built for Mitori's forms, eight a row on a phone and eleven on a tablet.
- Bar charts can start their scale above zero, so an average from 1 to 4 has an axis from 1 to 4. A bar on the lowest value can keep a small height, so it still shows; the read-out says its real value. Built for Mitori's exam mode.
- The row names of a heat grid can take another font, so long technique names stay readable on a phone.

#### Improved
- Level 0 of a heat grid and its legend key have the same, clearer frame, so level 0 stands apart from the page and from a blank place.

#### Fixed
- When the focused cell of a heat grid turned into a blank place, the focus jumped to the first cell and the view to the start; now it moves to the nearest cell.
- When all cells turned blank while one had the focus, Tab went backwards and the app logged a warning; now Tab goes on.
- A cell the app chose in two steps (first the row, then the column) was moved to the first cell in between when the grid did not have the focus; now it stays.

![Techniques by attack with readable names, level 0 in the legend with its word, a focused cell](https://shrippen.github.io/Kante/shots/release-1.64-technique-map.png)

![Twelve forms filling the width, eight a row; beside them the average per round on an axis from 1 to 4](https://shrippen.github.io/Kante/shots/release-1.64-forms-exam.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-164

### Deutsch

Das Wärmeraster behält den Fokus, wo er war, und füllt eine Breite; Balkendiagramme können ihre Skala über null beginnen.

#### Neu
- Wärmeraster können ihre Breite füllen: Eine feste Zahl von Spalten teilt sich den Platz, mit quadratischen Zellen, so groß er es erlaubt. Gebaut für Mitoris Formen, acht je Reihe auf dem Handy und elf auf dem Tablet.
- Balkendiagramme können ihre Skala über null beginnen, so hat ein Schnitt von 1 bis 4 eine Achse von 1 bis 4. Ein Balken auf dem kleinsten Wert kann eine kleine Höhe behalten und bleibt so sichtbar; die Ablesung nennt seinen echten Wert. Gebaut für Mitoris Prüfungsmodus.
- Die Zeilennamen eines Wärmerasters können eine andere Schrift nehmen, so bleiben lange Technik-Namen auf dem Handy lesbar.

#### Verbessert
- Stufe 0 eines Wärmerasters und ihr Legenden-Schlüssel haben denselben, deutlicheren Rahmen, so hebt sich Stufe 0 von der Seite und von einem leeren Platz ab.

#### Behoben
- Wurde die Zelle mit dem Fokus zu einem leeren Platz, sprang der Fokus auf die erste Zelle und die Ansicht an den Anfang; jetzt geht er zur nächstgelegenen Zelle.
- Wurden alle Zellen leer, während eine den Fokus hatte, ging Tab rückwärts und die App schrieb eine Warnung; jetzt geht Tab weiter.
- Eine Zelle, die die App in zwei Schritten wählte (erst die Zeile, dann die Spalte), wurde dazwischen auf die erste Zelle gesetzt, wenn das Raster keinen Fokus hatte; jetzt bleibt sie.

![Techniken je Angriff mit lesbaren Namen, Stufe 0 mit ihrem Wort in der Legende, eine Zelle mit Fokus](https://shrippen.github.io/Kante/shots/release-1.64-technique-map.png)

![Zwölf Formen, die die Breite füllen, acht je Reihe; daneben der Schnitt je Runde auf einer Achse von 1 bis 4](https://shrippen.github.io/Kante/shots/release-1.64-forms-exam.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-164

## [1.63.0] — 2026-11-02

### English

A heat grid with labels: rows, columns, a number in every cell and a legend, also for wide grids on a phone.

#### New
- `KanteHeatGrid`: rows × columns on the heat scale, with row and column labels, the value as a number in each cell, a legend with the value of each level, a tooltip per cell and keyboard focus (arrows, Enter). Screen readers hear each cell by name. Built for Kontra's fretboard quiz (hits per string and fret); `KanteHeatmap` stays the unlabelled grid of days.
- Wide grids fit a phone: the cells scroll sideways while the row names stay, with a scroll bar, and the focused cell stays in sight. Column names can stand upright, so long names allow narrow columns; long row names are cut to a width with the full name as a tooltip. Built for Mitori's technique map (techniques × attacks).
- Levels 0 to 4 as steps, with a word per level in the legend, and blank places where there is nothing to show; level 0 keeps a fine frame, so it stays apart from a blank place. The focus ring stands out on every level, also on the strongest, which is filled with the focus colour.

![Hits per string and fret, a number in every cell, the legend below](https://shrippen.github.io/Kante/shots/release-1.63-heatgrid.png)

![Techniques by attack with upright attack names, levels 1 to 4, blank places, a scroll bar and a focused cell](https://shrippen.github.io/Kante/shots/release-1.63-technique-map.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-163

### Deutsch

Ein Wärmeraster mit Beschriftung: Zeilen, Spalten, eine Zahl in jeder Zelle und eine Legende, auch für breite Raster auf dem Handy.

#### Neu
- `KanteHeatGrid`: Zeilen × Spalten auf der Wärmeskala, mit Zeilen- und Spaltenbeschriftung, dem Wert als Zahl in jeder Zelle, einer Legende mit dem Wert jeder Stufe, einem Tooltip je Zelle und Tastaturfokus (Pfeile, Enter). Screenreader lesen jede Zelle mit Namen vor. Gebaut für Kontras Griffbrett-Quiz (Treffer je Saite und Bund); `KanteHeatmap` bleibt das unbeschriftete Raster der Tage.
- Breite Raster passen aufs Handy: Die Zellen scrollen waagerecht, die Zeilennamen bleiben stehen, eine Scrollleiste zeigt die Stelle, und die Zelle mit dem Fokus bleibt im Blick. Spaltennamen können hochkant stehen, so erlauben lange Namen schmale Spalten; lange Zeilennamen werden auf eine Breite gekürzt, der ganze Name steht im Tooltip. Gebaut für Mitoris Technik-Landkarte (Techniken × Angriffe).
- Stufen 0 bis 4 als Schritte, mit einem Wort je Stufe in der Legende, und leere Plätze, wo es nichts zu zeigen gibt; Stufe 0 behält einen feinen Rahmen und bleibt so von einem leeren Platz zu unterscheiden. Der Fokusrahmen ist auf jeder Stufe zu sehen, auch auf der stärksten, die in der Fokusfarbe gefüllt ist.

![Treffer je Saite und Bund, eine Zahl in jeder Zelle, darunter die Legende](https://shrippen.github.io/Kante/shots/release-1.63-heatgrid.png)

![Techniken je Angriff mit hochkanten Angriffsnamen, Stufen 1 bis 4, leeren Plätzen, einer Scrollleiste und einer Zelle mit Fokus](https://shrippen.github.io/Kante/shots/release-1.63-technique-map.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-163

## [1.62.1] — 2026-11-02

### English

The practice calendar sits right also in a wide layout, and a single week names its own month.

#### Fixed
- Right to left, `KanteCalendarHeatmap` stayed at the left edge when a layout gave it more width than it needs.
- A calendar of one week ending on 30 November was labelled December.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1621

### Deutsch

Der Übungskalender steht auch in einem breiten Layout richtig, und eine einzelne Woche nennt ihren eigenen Monat.

#### Behoben
- Von rechts nach links blieb `KanteCalendarHeatmap` am linken Rand, wenn ein Layout ihr mehr Breite gab, als sie braucht.
- Ein Kalender von einer Woche, die am 30. November endet, war mit Dezember beschriftet.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1621

## [1.62.0] — 2026-11-02

### English

Practice days on a calendar, with weekdays, months and a tooltip per day.

#### New
- `KanteCalendarHeatmap` shows days on a calendar grid: a column per week, weekday names at the side, the month's name above the week it begins in. Each day is coloured by its level like the heatmap; hovering or tapping it shows the date and a text, screen readers hear the date in full. Right to left, the newest week is on the left.

![Twenty-six weeks of practice days in four shades of teal, weekdays at the left, months above, below a legend from 1–2 techniques to 10 and more](https://shrippen.github.io/Kante/shots/release-1.62-calendar.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-162

### Deutsch

Übungstage auf einem Kalender, mit Wochentagen, Monaten und einem Tooltip je Tag.

#### Neu
- `KanteCalendarHeatmap` zeigt Tage auf einem Kalenderraster: eine Spalte je Woche, Wochentage an der Seite, der Monatsname über der Woche, in der er beginnt. Jeder Tag hat die Farbe seiner Stufe wie in der Heatmap; beim Darüberfahren oder Antippen zeigt er Datum und Text, Bildschirmleser hören das volle Datum. Von rechts nach links steht die neueste Woche links.

![Sechsundzwanzig Wochen Übungstage in vier Abstufungen von Petrol, links die Wochentage, oben die Monate, darunter eine Legende von 1–2 Techniken bis 10 und mehr](https://shrippen.github.io/Kante/shots/release-1.62-calendar.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-162

## [1.61.1] — 2026-11-02

### English

A tap in a sheet stays in the sheet.

#### Fixed
- A `KanteListRow` under a modal sheet or dialog took taps meant for it, when the tap landed on a `TapHandler` such as the buttons of `KanteLevelPicker`. In Mitori a rating in the technique sheet also opened the row underneath.

All changes: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1611

### Deutsch

Ein Tipp in einem Blatt bleibt im Blatt.

#### Behoben
- Eine `KanteListRow` unter einem modalen Blatt oder Dialog nahm Tipps an, die ihm galten, wenn der Tipp auf einem `TapHandler` landete, etwa den Knöpfen von `KanteLevelPicker`. In Mitori öffnete eine Einschätzung im Technik-Blatt zugleich die Zeile darunter.

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#fixed-in-kante-1611

## [1.61.0] — 2026-11-02

### English

Shares by level get colours from one scale and a legend that explains them.

#### New
- `KanteLegend` explains a chart: a key and a word per item, wrapping when narrow.
- `KanteStyle.levelColor` gives the colour of a level on a scale, the same as the heatmap's, for shares by level.
- Parts of a stacked `KanteProgressBar` show their `text` as a tooltip and name it for screen readers.

![A bar of shares by level in four steps of the focus colour, below it the legend with counts](https://shrippen.github.io/Kante/shots/release-1.61-legend.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-161

### Deutsch

Anteile je Stufe bekommen Farben aus einer Skala und eine Legende, die sie erklärt.

#### Neu
- `KanteLegend` erklärt ein Diagramm: ein Farbfeld und ein Wort je Eintrag, bei wenig Platz umbrochen.
- `KanteStyle.levelColor` liefert die Farbe einer Stufe auf einer Skala, dieselbe wie in der Heatmap, für Anteile je Stufe.
- Teile einer gestapelten `KanteProgressBar` zeigen ihren `text` als Tooltip und nennen ihn Bildschirmlesern.

![Eine Leiste mit Anteilen je Stufe in vier Stufen der Fokusfarbe, darunter die Legende mit Anzahlen](https://shrippen.github.io/Kante/shots/release-1.61-legend.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-161

## [1.60.0] — 2026-11-02

### English

Kante can show and pick a level of four, for ratings such as how well a technique sits.

#### New
- `KanteLevelDots` shows a level as dots, such as how well a technique sits (3 of 4), small enough for a list row.
- `KanteLevelPicker` picks a level 1 to 4 with large buttons, number and word; a tap on the chosen level counts again. Mitori rates its techniques with it.

![A list with dots per technique, below four buttons 1 to 4 with 3 chosen](https://shrippen.github.io/Kante/shots/release-1.60-levels.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-160

### Deutsch

Kante kann eine Stufe von vier zeigen und wählen lassen, für Einschätzungen wie die, wie sicher eine Technik sitzt.

#### Neu
- `KanteLevelDots` zeigt eine Stufe als Punkte, etwa wie sicher eine Technik sitzt (3 von 4), klein genug für eine Listenzeile.
- `KanteLevelPicker` wählt eine Stufe von 1 bis 4 mit großen Knöpfen, Zahl und Wort; ein Tipp auf die gewählte Stufe zählt erneut. Mitori schätzt damit seine Techniken ein.

![Eine Liste mit Punkten je Technik, darunter vier Knöpfe 1 bis 4, 3 gewählt](https://shrippen.github.io/Kante/shots/release-1.60-levels.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-160

## [1.59.0] — 2026-11-01

### English

Kante gets the pieces for a video player and a start menu of tiles.

#### New
- `KanteTransportBar` for video: fixed tempi as segments (25, 50, 75, 100 %), buttons for single frames back and on (keys , and .), and the metronome and count-in can be hidden. Mitori's player uses it for the exam videos.
- `KanteOptionTile` as a launch tile: with `checkable: false` it opens something and is never chosen; `glyph` shows a character such as a kanji in place of the icon.

#### Improved
- Right to left, the transport bar keeps its order: it runs along time like a timeline, and its marks point the right way.

![Three launch tiles with kanji, below a transport bar with single frames and four tempi](https://shrippen.github.io/Kante/shots/release-1.59-video.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-159

### Deutsch

Kante bekommt die Bausteine für einen Videoplayer und ein Startmenü aus Kacheln.

#### Neu
- `KanteTransportBar` für Video: feste Tempi als Segmente (25, 50, 75, 100 %), Knöpfe für einzelne Bilder zurück und vor (Tasten , und .), Metronom und Einzählen lassen sich ausblenden. Der Player von Mitori nutzt sie für die Prüfungsvideos.
- `KanteOptionTile` als Startkachel: mit `checkable: false` öffnet sie etwas und wird nie gewählt; `glyph` zeigt statt des Symbols ein Zeichen, etwa ein Kanji.

#### Verbessert
- Von rechts nach links behält die Transportleiste ihre Reihenfolge: Sie folgt der Zeit wie eine Zeitleiste, und ihre Marken zeigen in die richtige Richtung.

![Drei Startkacheln mit Kanji, darunter eine Transportleiste mit Einzelbildern und vier Tempi](https://shrippen.github.io/Kante/shots/release-1.59-video.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-159

## [1.58.0] — 2026-10-30

### English

A dialog can have buttons of its own at the start of its footer.

#### New
- `KanteDialog` gets `footerStart`: the app's own buttons at the start of the footer, before Close or Ok and apart from them, in every style; right to left they stand at the right. lmix puts "Shortcuts…" there in its keys overview; before, it had to rename the Help button.

![An own button at the start of the footer, Close at its end](https://shrippen.github.io/Kante/shots/release-1.58-footer.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-158

### Deutsch

Ein Dialog kann eigene Knöpfe am Anfang seines Fußes haben.

#### Neu
- `KanteDialog` bekommt `footerStart`: die eigenen Knöpfe der App am Anfang des Fußes, vor Schließen oder Ok und abgesetzt davon, in jedem Stil; von rechts nach links stehen sie rechts. lmix setzt dort „Belegungen…“ in seine Tastenübersicht; vorher musste es den Hilfe-Knopf umbenennen.

![Ein eigener Knopf am Anfang des Fußes, Schließen am Ende](https://shrippen.github.io/Kante/shots/release-1.58-footer.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-158

## [1.57.0] — 2026-10-30

### English

A menu row gets room at its end.

#### New
- `KanteMenuItem` gets `trailing`: items after the value, such as ◀ ▶ of a direction or the lengths as segments; they take their own clicks.

![An effect menu: the direction as ◀ ▶ and the lengths as segments at the row's end](https://shrippen.github.io/Kante/shots/release-1.57-menu.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-157

### Deutsch

Eine Menüzeile bekommt Platz an ihrem Ende.

#### Neu
- `KanteMenuItem` bekommt `trailing`: Inhalt hinter dem Wert, etwa ◀ ▶ einer Richtung oder die Dauern als Segmente; er nimmt seine Klicks selbst an.

![Ein Effektmenü: die Richtung als ◀ ▶ und die Dauern als Segmente am Zeilenende](https://shrippen.github.io/Kante/shots/release-1.57-menu.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-157

## [1.56.0] — 2026-10-30

### English

Line weights, markers, tint levels and the sizes of an hour grid are Kante roles now, so an app that draws a timeline or a board by hand needs no sizes of its own.

#### New
- `KanteStyle` gets line weights for borders (1), marking lines (2) and the colour edge of an entry (3), in every style.
- Markers, meters and swatches have a size: day dots and legend keys square in the Kante style, a thin meter for a day's load, a colour key for a legend.
- Four tint levels (wash, fill, strong fill, edge) for a colour that is data, such as a project's, and opacities for something done or out of range.
- An hour grid and a month cell get their sizes: the height of a minute and of an entry line.
- The web gets the same weights and levels as tokens (`--line-*`, `--level-*`).

#### Fixed
- A combo box in the Kante style no longer cuts its value short when the platform style sizes it („Erledigu…“ in Kurrent's heatmap): it is as wide as its widest entry, at least `KanteStyle.comboMinimumWidth`, and follows the font.

![An hour grid drawn from the roles: grid lines, free time, a planned block with its colour edge, the now line, day dots, a load meter and the four tint levels](https://shrippen.github.io/Kante/shots/release-1.56-lines.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-156

### Deutsch

Linienstärken, Marker, Tönungsstufen und die Maße eines Stundenrasters sind jetzt Rollen von Kante, damit eine App, die eine Zeitleiste oder ein Brett selbst zeichnet, keine eigenen Größen braucht.

#### Neu
- `KanteStyle` bekommt Linienstärken für Ränder (1), markierende Linien (2) und die Farbkante eines Eintrags (3), in jedem Stil.
- Marker, Messbalken und Farbfelder haben eine Größe: Tagespunkte und Legendenzeichen im Stil Kante eckig, ein schmaler Balken für die Auslastung eines Tages, ein Farbfeld für eine Legende.
- Vier Tönungsstufen (Hauch, Fläche, starke Fläche, Rand) für eine Farbe, die Daten zeigt, etwa die eines Projekts, und Deckkräfte für Erledigtes und für das, was außerhalb liegt.
- Stundenraster und Monatszelle bekommen ihre Maße: die Höhe einer Minute und einer Eintragszeile.
- Das Web bekommt dieselben Stärken und Stufen als Tokens (`--line-*`, `--level-*`).

#### Behoben
- Ein Auswahlfeld im Stil Kante schneidet seinen Wert nicht mehr ab, wenn der Plattformstil seine Breite bestimmt („Erledigu…“ in Kurrents Heatmap): Es ist so breit wie sein längster Eintrag, mindestens `KanteStyle.comboMinimumWidth`, und folgt der Schrift.

![Ein Stundenraster aus den Rollen: Rasterlinien, freie Zeit, ein geplanter Block mit Farbkante, die Jetzt-Linie, Tagespunkte, ein Auslastungsbalken und die vier Tönungsstufen](https://shrippen.github.io/Kante/shots/release-1.56-lines.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-156

## [1.55.0] — 2026-10-30

### English

Dialogs come in three widths, and a destructive question is red.

#### New
- `KanteDialog` gets `size`: Small, Medium and Large, at most 90 % of the window.
- `KanteDialog` gets `destructive`: the bar and the accept button (Ok, or Yes of a yes/no question) in the negative colour, Cancel before it.
- `KanteButton` gets `destructive`: a Normal or Quiet button with red text in the Kante style, for a removal that should not outweigh the actions beside it.

#### Fixed
- `KanteDialog`'s `acceptText` holds in every language: in German the button read „OK“, because the button box sets its standard texts again once the translations are in.

![A destructive question: red bar, the button names what goes, Cancel first](https://shrippen.github.io/Kante/shots/release-1.55-dialog.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-155

### Deutsch

Dialoge gibt es in drei Breiten, und eine destruktive Frage ist rot.

#### Neu
- `KanteDialog` bekommt `size`: Small, Medium und Large, höchstens 90 % des Fensters.
- `KanteDialog` bekommt `destructive`: Balken und Bestätigungsknopf (Ok, oder Ja einer Ja/Nein-Frage) in der Warnfarbe, Abbrechen davor.
- `KanteButton` bekommt `destructive`: ein Normal- oder Quiet-Knopf mit roter Schrift im Stil Kante, für ein Entfernen, das die Aktionen daneben nicht überragen soll.

#### Behoben
- `acceptText` von `KanteDialog` hält in jeder Sprache: Auf Deutsch hieß der Knopf „OK“, weil die Knopfleiste ihre Standardtexte neu setzt, sobald die Übersetzungen geladen sind.

![Eine destruktive Frage: roter Balken, der Knopf nennt, was geht, Abbrechen zuerst](https://shrippen.github.io/Kante/shots/release-1.55-dialog.png)

Alle Änderungen: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-155

## [1.54.0] — 2026-10-30

### English

The page bar can be lower, down to a coloured strip, and the month grid marks its days.

#### New
- `KantePageBar` gets `density`: Compact (lower, smaller labels; it grows for a small button at its end) and Band (one segment per page, the others half as high; the name as tooltip). lmix's operators want the room for their inputs.
- `KanteCalendarGrid` marks days with up to three dots (`dots`) and tints a range of days (`rangeFrom`, `rangeTo`), as Kurrent's Agenda needs for appointments, tasks and the days a view shows.

![The page bar in Normal, Compact and Band](https://shrippen.github.io/Kante/shots/release-1.54-pagebar.png)

![Day dots and a range in the month grid](https://shrippen.github.io/Kante/shots/release-1.54-calendar.png)

All changes: https://github.com/shrippen/Kante/blob/main/README.md#added-in-kante-154

### Deutsch

Die Seitenleiste kann niedriger sein, bis hin zu einem Farbband, und das Monatsraster markiert seine Tage.

#### Neu
- `KantePageBar` bekommt `density`: Compact (niedriger, kleinere Schrift; wächst für einen kleinen Knopf am Ende) und Band (ein Abschnitt je Seite, die übrigen halb so hoch; der Name als Tooltip). Wer lmix bedient, braucht den Platz für die Inputs.
- `KanteCalendarGrid` markiert Tage mit bis zu drei Punkten (`dots`) und tönt einen Zeitraum (`rangeFrom`, `rangeTo`), wie ihn Kurrents Agenda für Termine, Aufgaben und die gezeigten Tage braucht.

![Die Seitenleiste in Normal, Compact und Band](https://shrippen.github.io/Kante/shots/release-1.54-pagebar.png)

![Tagespunkte und ein Zeitraum im Monatsraster](https://shrippen.github.io/Kante/shots/release-1.54-calendar.png)

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
