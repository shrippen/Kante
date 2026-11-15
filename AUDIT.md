# Code-Audit Kante, 15.11.2026, Stand e52d40f

## Urteil
Kante bleibt wartbar. Seit dem letzten Audit vor einem Tag kamen acht kleine Änderungen hinzu, fast alle an Bausteinen für die App Klappe. Neu ist `ARCHITECTURE.md`: Die Datei beschreibt den Soll-Aufbau und führt die offenen Funde des letzten Audits als bekannte Abweichungen. Die meisten neuen Tests heißen nach ihrem Baustein, wie Fund 6 es vorschlug. Etwas schlechter steht die Zeichenfläche für Pläne (Shape-Canvas) da: Sie liegt jetzt über der Grenze von 800 Zeilen und steht neu in der Bestandsliste. Zwei kleine Rechenwege stehen doppelt im Repo, und einer davon zeigt schon heute andere Werte als sein Gegenstück.

## Kennzahlen
| | letztes Audit | jetzt |
|---|---|---|
| Quelldateien | 249 | 255 |
| Einträge in der Bestandsliste | 23 | 24 |
| größte Datei (Zeilen) | 1711 (Galerie der App-Bausteine); die Prüfung liest kein CSS, das Stylesheet hat 2237 | 1711 (unverändert); Stylesheet 2237 |
| längste Funktion (Zeilen) | 665 (Hülle um das Skript des Kimai-Kits); die längste echte Funktion hat 450 | 665 und 450 (unverändert) |

## Funde

### 1. Zwei Bausteine schreiben eine Zeit mit Zehntelsekunden je selbst, und schon heute verschieden
Die Abspielleiste zeigt eine Zeit wahlweise mit Zehnteln („01:05,3“). Die Zeitleiste mit Spuren zeigt beim Ziehen ebenfalls eine Zeit mit Zehnteln, aber mit eigenem Rechenweg und in anderer Schreibweise („1:05,3“ gegen „1:05.3“, Komma gegen Punkt, mit und ohne führende Null). Beide sind für dieselbe App gebaut und stehen dort nebeneinander. Die Rechenwege weichen auch im Ergebnis ab: Für 1,2 Sekunden zeigt die Abspielleiste „00:01,1“, die Zeitleiste „0:01.2“. Nachgerechnet für alle Zehntel bis 2000 Sekunden: in 7992 von 20000 Fällen zeigt die Abspielleiste ein Zehntel weniger, weil eine Rechenungenauigkeit beim Abschneiden nur in der Zeitleiste abgefangen ist. Soll sich das Zeitformat ändern oder ein dritter Baustein eine Zeit zeigen, müssen alle Stellen gleich nachgezogen werden, und wie man sieht, gelingt das nicht. Vorschlag: eine Funktion für „Zeit mit Zehnteln“ im zentralen Stilbaustein, die beide benutzen; die Zeitleiste behält ihre Möglichkeit, dass die App ein eigenes Format liefert. Aufwand klein. Risiko gering: Beide Formate haben Tests (die Abspielleiste prüft Werte wie 65,37 und 59,99, bei denen der Fehler nicht auftritt; ein Test mit 1,2 Sekunden gehört dazu). Beleg: `qml/Kante/KanteTransportBar.qml:83`, `qml/Kante/KanteTransportBar.qml:91`, `qml/Kante/KanteTrackTimeline.qml:214`, `qml/tests/tst_kante181_klappe.qml:564`, `qml/tests/tst_kante_klappe.qml:669`.

### 2. Zwei Bausteine übersetzen Farbnamen je selbst, und die Listen laufen schon auseinander
Zeichenfläche und Zeitleiste nehmen Farben als Namen entgegen („muted“, „accent“, „focus“, „warning“ oder eine der Etikettfarben wie „blue“). Jeder Baustein übersetzt diese Namen mit einer eigenen, fast gleichen Liste. Der Kommentar der Zeitleiste verspricht „dieselben Namen wie die Zeichenfläche“. Das stimmt schon nicht mehr: Die Zeichenfläche kennt zusätzlich „ground“ (die Hintergrundfarbe), die Zeitleiste zeigt dafür stillschweigend die Textfarbe. Ein dritter Baustein, der Monatskalender, hat für fast dieselben Namen eine dritte Liste. Kommt ein Farbname hinzu, müssen alle Listen geändert werden. `ARCHITECTURE.md` verlangt, dass so etwas einmal steht. Vorschlag: eine Funktion „Farbe zu einem Namen“ im zentralen Stilbaustein, neben der schon vorhandenen für die Etikettfarben, die alle drei benutzen. Aufwand klein. Risiko gering: Zeichenfläche und Zeitleiste haben Tests mit solchen Namen; der Kalender ist in den Sammeltests geprüft. Beleg: `qml/Kante/KanteShapeCanvas.qml:207`, `qml/Kante/KanteTrackTimeline.qml:220`, `qml/Kante/KanteCalendarGrid.qml:30`, `qml/Kante/KanteStyle.qml:158`.

### 3. Die Zeichenfläche für Pläne ist über 800 Zeilen gewachsen, obwohl sie eine natürliche Naht hat
Die Zeichenfläche erledigt drei Aufgaben in einer Datei: Sie rechnet aus, welche Form unter dem Mauszeiger liegt, sie zeichnet alle Formen und Beschriftungen, und sie verarbeitet Maus, Tasten und Fingergesten. In den letzten Tagen kamen schnelleres Zeichnen, mehrzeilige Beschriftungen und Beschriftungen in Planmaßen dazu; die Datei hat jetzt 812 Zeilen und steht neu in der Bestandsliste. Die Begründung dort sagt, es gebe keine natürliche Naht. Es gibt eine: Das Zeichnen steht schon heute als eigener, geschlossener Block von rund 315 Zeilen mit eigenen Hilfsfunktionen und eigenem Zwischenspeicher für Farben. Wer an den Beschriftungen arbeitet, muss heute an Treffertest und Mausbedienung vorbei lesen. Innerhalb des Zeichnens steht außerdem die Berechnung des umschließenden Rechtecks einer Form zweimal, einmal für „liegt die Form im Bild“ und einmal für den Platz der Beschriftung. Vorschlag: das Zeichnen als eigenen Baustein ohne eigene Bedienung herauslösen und das umschließende Rechteck einmal berechnen; die Datei fällt dann wieder aus der Bestandsliste. Aufwand mittel. Risiko gering: Drei Testdateien prüfen die Zeichenfläche, eine davon Bildpunkte am Rand, dazu eine Zeitmessung für das Zeichnen. Beleg: `qml/Kante/KanteShapeCanvas.qml:220`, `qml/Kante/KanteShapeCanvas.qml:355`, `qml/Kante/KanteShapeCanvas.qml:406`, `qml/Kante/KanteShapeCanvas.qml:523`, `qml/Kante/KanteShapeCanvas.qml:672`, `structure.baseline:22`.

### 4. Der neue Ordner für Zeitmessungen fehlt im Soll-Aufbau
Mit dem schnelleren Zeichnen kam ein eigener Ordner für Zeitmessungen hinzu. Er läuft nicht mit den übrigen Tests, sondern nur von Hand. `ARCHITECTURE.md` entstand danach, nennt ihn aber nicht. Wer eine neue Messung schreibt, weiß deshalb nicht, ob sie dorthin oder zu den Tests gehört, und wer die Tests aufräumt (Fund 6), hält die Datei leicht für vergessen. Vorschlag: den Ordner mit einer Zeile in der Bausteintabelle von `ARCHITECTURE.md` aufnehmen, mit dem Hinweis, dass er nicht im Build läuft. Aufwand klein. Risiko keines, es ändert sich nur die Beschreibung. Beleg: `qml/perf/tst_shapecanvas_perf.qml:1`, `ARCHITECTURE.md:17`, `tools/check-qml.sh:14`.

## Seit dem letzten Audit
Zum letzten Bericht hat der Eigentümer noch nicht entschieden. Alle neun Funde sind offen und werden hier nicht neu gemeldet; `ARCHITECTURE.md` führt sie als bekannte Abweichungen.

- Fund 1 (Notensysteme für Bass und Tabulatur doppelt): offen, Dateien unverändert.
- Fund 2 (Achsenteilung dreimal): offen, unverändert.
- Fund 3 (Farben zweimal von Hand): offen, unverändert.
- Fund 4 („Kante Light“ meint zweierlei): offen, unverändert.
- Fund 5 (Webseiten-Skript in einer Funktion): offen, unverändert.
- Fund 6 (Tests und Galerie nach Versionsnummer): offen, aber neue Tests folgen dem Vorschlag. Fünf der sechs neuen Testdateien heißen nach ihrem Baustein. Die Tests für das Ziehen in der Zeitleiste kamen dagegen in eine Datei, die nach der App Klappe heißt.
- Fund 7 (abgeschnittene Ecke rund 25 Mal): offen, unverändert.
- Fund 8 (Release-Notizen-Werkzeug im Design System): offen, unverändert.
- Fund 9 (Bestandsliste): offen. Neu dazugekommen ist die Zeichenfläche (siehe Fund 3 dieses Berichts); kein alter Eintrag ist verschwunden.

Abgelehnt hat der Eigentümer bisher keinen Fund.
