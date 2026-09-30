import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import Kante

/**
 * Every Kante component in one view (Kante 1.4): buttons, fields, controls,
 * tabs, display, feedback, surfaces and the motion pieces. Not part of the module;
 * load it in an app or with qml to look at the style:
 *   qml -I kante/qml kante/qml/demo/Gallery.qml
 * `kind` picks the style (0 System, 1 Kante, 2 Kante Light).
 */
Rectangle {
    id: root

    property int kind: 1
    property bool dark: true
    width: 1100
    height: 3300
    color: KanteStyle.backgroundColor

    Binding { target: KanteStyle; property: "kind"; value: root.kind }
    Binding { target: KanteStyle; property: "preferDark"; value: root.dark }

    component Section: ColumnLayout {
        property string title: ""
        Layout.fillWidth: true
        spacing: KanteStyle.unit(10)
        KanteHud { fullText: "// " + parent.title; color: KanteStyle.accentTextColor }
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: col.implicitHeight + KanteStyle.unit(40)

        ColumnLayout {
            id: col
            x: KanteStyle.unit(24)
            y: KanteStyle.unit(20)
            width: parent.width - KanteStyle.unit(48)
            spacing: KanteStyle.unit(22)

            KanteHeading { text: "Kante"; pageTitle: true }

            Section {
                title: "buttons"
                RowLayout {
                    spacing: KanteStyle.unit(10)
                    KanteButton { text: "Übernehmen"; emphasis: KanteButton.Emphasis.Primary }
                    KanteButton { text: "Abbrechen" }
                    KanteButton { text: "Löschen"; emphasis: KanteButton.Emphasis.Destructive }
                    KanteButton { text: "Details"; emphasis: KanteButton.Emphasis.Data }
                    KanteButton { text: "Zurücksetzen"; emphasis: KanteButton.Emphasis.Quiet }
                    KanteButton { text: "Lädt"; emphasis: KanteButton.Emphasis.Primary; busy: true }
                    KanteButton { text: "Aus"; emphasis: KanteButton.Emphasis.Primary; enabled: false }
                }
                RowLayout {
                    spacing: KanteStyle.unit(10)
                    KanteButton { text: "Klein"; size: KanteButton.Size.Small; emphasis: KanteButton.Emphasis.Primary }
                    KanteButton { text: "Mittel"; emphasis: KanteButton.Emphasis.Primary }
                    KanteButton { text: "Groß"; size: KanteButton.Size.Large; emphasis: KanteButton.Emphasis.Primary }
                    KanteButton { text: "Stanze"; size: KanteButton.Size.Large; emphasis: KanteButton.Emphasis.Primary; raised: true }
                    KanteTube { KanteButton { text: "Download"; size: KanteButton.Size.Large; emphasis: KanteButton.Emphasis.Primary } }
                }
            }

            Section {
                title: "eingaben"
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    KanteTextField { text: "Kader"; Layout.preferredWidth: KanteStyle.unit(160) }
                    KanteTextField { text: "kader plasmoid"; invalid: true; Layout.preferredWidth: KanteStyle.unit(160) }
                    QQC2.ComboBox { model: ["Negativ, Farbe", "Dia"]; Layout.preferredWidth: KanteStyle.unit(160); KanteFieldSkin { control: parent } }
                    QQC2.Slider { value: 0.6; Layout.preferredWidth: KanteStyle.unit(160); KanteSliderSkin { control: parent } }
                }
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    QQC2.CheckBox { text: "Behalten"; checked: true; KanteCheckSkin { control: parent } }
                    QQC2.CheckBox { text: "Überschreiben"; KanteCheckSkin { control: parent } }
                    QQC2.RadioButton { text: "Automatisch"; checked: true; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Radio } }
                    QQC2.RadioButton { text: "Manuell"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Radio } }
                    QQC2.Switch { text: "Rahmen"; checked: true; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Switch } }
                    QQC2.Switch { text: "Staub"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Switch } }
                }
            }

            Section {
                title: "navigation"
                KanteTabBar { model: ["Alle", "Prüfen", "Fertig"]; counts: [42, 7, 35] }
                KanteSegmented { model: ["Raster", "Liste", "Bühne"] }
                KanteSteps { model: ["Einlesen", "Erkennen", "Prüfen", "Übergeben"]; current: 2 }
            }

            Section {
                title: "anzeige"
                RowLayout {
                    spacing: KanteStyle.unit(10)
                    KantePill { text: "Analysiert"; state: KantePill.State.Running }
                    KantePill { text: "Prüfen"; state: KantePill.State.Review }
                    KantePill { text: "Gesperrt"; state: KantePill.State.Locked }
                    KantePill { text: "Fertig"; state: KantePill.State.Done }
                    KantePill { text: "Fehler"; state: KantePill.State.Failed }
                    KantePill { text: "Pausiert"; state: KantePill.State.Off }
                    KanteCounter { text: "7" }
                    KanteCounter { text: "42"; kind: KanteCounter.Kind.Info }
                    KanteCounter { text: "2"; kind: KanteCounter.Kind.Error }
                }
                RowLayout {
                    spacing: KanteStyle.unit(10)
                    KanteSticker { text: "v0.4.0" }
                    KanteSticker { text: "Plasma 6"; dot: KanteStyle.accentColor }
                    KanteSticker { text: "GPL-3.0" }
                    KanteLamp { rhythm: KanteLamp.Rhythm.Pulse }
                    KanteLamp { rhythm: KanteLamp.Rhythm.Breathe }
                    KanteLamp { rhythm: KanteLamp.Rhythm.Tick }
                    KanteOdometer { value: 42 }
                    KanteHud { fullText: "// kader v0.4.0 · analyse läuft"; typing: true }
                }
            }

            Section {
                title: "rückmeldung"
                RowLayout {
                    spacing: KanteStyle.unit(16)
                    ColumnLayout {
                        Layout.preferredWidth: KanteStyle.unit(260)
                        KanteProgressBar { value: 0.62; Layout.fillWidth: true }
                        KanteProgressBar { indeterminate: true; Layout.fillWidth: true }
                        KanteProgressBar { segments: 12; value: 0.58; Layout.fillWidth: true }
                        RowLayout { KanteLoader {} KanteSkeleton { lines: 3; Layout.preferredWidth: KanteStyle.unit(140) } }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        KanteCallout { Layout.fillWidth: true; title: "Hinweis"; text: "Kader arbeitet lokal." }
                        KanteCallout { Layout.fillWidth: true; title: "Achtung"; text: "Überschreibt die Originale."; kind: KanteCallout.Kind.Danger }
                        KanteToast { id: toast; title: "Fertig"; text: "42 Bilder zugeschnitten."; kind: KanteToast.Kind.Ok; life: 0; Layout.fillWidth: true; Component.onCompleted: show() }
                    }
                }
                KanteBanner { Layout.fillWidth: true; title: "Noch nicht fertig"; text: "Version 0.x" }
                KanteEmptyState {
                    Layout.fillWidth: true
                    title: "Noch keine Rolle"
                    text: "Zieh gescannte Bilder in das Fenster."
                    KanteButton { text: "Ordner wählen"; emphasis: KanteButton.Emphasis.Primary; size: KanteButton.Size.Small }
                }
            }

            Section {
                title: "flächen"
                RowLayout {
                    spacing: KanteStyle.unit(16)
                    KanteTile { name: "IMG_0040"; figure: "99 %"; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteTile { name: "IMG_0041"; figure: "61 %"; tier: KanteTile.Tier.Check; selected: true; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteTile { name: "IMG_0042"; figure: "—"; tier: KanteTile.Tier.Bad; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteCard {
                        Layout.preferredWidth: KanteStyle.unit(200)
                        Layout.preferredHeight: KanteStyle.unit(110)
                        barColor: KanteStyle.focusColor
                        interactive: true
                        Text { x: KanteStyle.unit(16); y: KanteStyle.unit(24); text: "Link-Karte"; color: KanteStyle.strongTextColor; font: KanteStyle.headingFont(14) }
                    }
                    Item {
                        Layout.preferredWidth: KanteStyle.unit(150)
                        Layout.preferredHeight: KanteStyle.unit(110)
                        KanteCard { anchors.fill: parent; barColor: KanteStyle.accentColor; chamferBottom: KanteStyle.chamfer }
                        KanteRunner { anchors.fill: parent }
                        Text { anchors.centerIn: parent; text: "ARBEITET"; color: KanteStyle.mutedTextColor; font: KanteStyle.labelFont() }
                    }
                }
                KanteReveal {
                    Layout.preferredWidth: KanteStyle.unit(260)
                    Layout.preferredHeight: KanteStyle.unit(70)
                    KanteCard { anchors.fill: parent; barColor: KanteStyle.focusColor
                        Text { x: 16; y: 22; text: "Abtasten"; color: KanteStyle.strongTextColor; font: KanteStyle.headingFont(14) } }
                }
                RowLayout {
                    spacing: KanteStyle.unit(16)
                    KanteTile { name: "Nextcloud"; figure: "OK · 61 ms"; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteTile { name: "Jellyfin"; figure: "OK"; stale: true; staleText: "seit 12 min"; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteTile { name: "Editiermodus"; figure: ""; editing: true; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteTile { name: "Aufgenommen"; figure: ""; picked: true; Rectangle { anchors.fill: parent; color: "#3c3836" } }
                    KanteDropZone { Layout.preferredWidth: KanteStyle.unit(100); Layout.preferredHeight: KanteStyle.unit(70) }
                    KanteDropZone { kind: KanteDropZone.Kind.Cell; Layout.preferredWidth: KanteStyle.unit(100); Layout.preferredHeight: KanteStyle.unit(70) }
                    KanteLiveText { text: "1 687" }
                }
                KanteScrollMeter { Layout.fillWidth: true; flickable: flick }
            }

            Section {
                title: "1.5 · daten und listen"
                RowLayout {
                    spacing: KanteStyle.unit(20)
                    KanteBarChart { Layout.preferredWidth: KanteStyle.unit(240); Layout.preferredHeight: KanteStyle.unit(110); values: [3, 5, 2, 6, 4]; labels: ["MO", "DI", "MI", "DO", "FR"]; goal: 4.5; highlight: 3 }
                    KanteBarChart { Layout.preferredWidth: KanteStyle.unit(200); Layout.preferredHeight: KanteStyle.unit(110); values: [[2, 1], [3, 2], [1, 3]]; labels: ["A", "B", "C"] }
                    KanteLineChart { Layout.preferredWidth: KanteStyle.unit(240); Layout.preferredHeight: KanteStyle.unit(110); series: [[1, 3, 2, 5, 4], [2, 2, 3, 3, 4]]; labels: ["MO", "DI", "MI", "DO", "FR"]; unit: " h"; axis: true }
                    ColumnLayout {
                        KanteSparkline { values: [1, 3, 2, 5, 4, 6] }
                        KanteHeatmap { columns: 10; levels: [0, 1, 2, 3, 4, 2, 0, 1, 3, 4, 1, 2, 0, 3, 4] }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(20)
                    KanteCurveEditor {
                        id: fan
                        Layout.preferredWidth: KanteStyle.unit(300)
                        Layout.preferredHeight: KanteStyle.unit(180)
                        xMin: 20; xMax: 100; xUnit: "°"; yUnit: " %"; step: 5
                        points: [{ x: 30, y: 20 }, { x: 50, y: 40 }, { x: 70, y: 75 }, { x: 90, y: 100 }]
                        markers: [{ x: 62, label: "CPU 62°", color: KanteStyle.dataColor(0) }, { x: 44, label: "GPU 44°", color: KanteStyle.dataColor(2) }]
                        onEdited: function (p) { points = p }
                    }
                    KanteBandEditor {
                        id: bands
                        Layout.preferredWidth: KanteStyle.unit(260)
                        unit: " °C"
                        pick: true
                        bands: [{ value: 0, color: KanteStyle.dataColor(0) }, { value: 40, color: KanteStyle.dataColor(1) }, { value: 70, color: KanteStyle.dataColor(4) }]
                        onEdited: function (b) { bands = b }
                    }
                }
                KanteWeekView {
                    Layout.fillWidth: true
                    Layout.maximumWidth: KanteStyle.unit(560)
                    today: 2
                    events: [
                        { day: 0, start: 9, end: 11, title: "Sprint", kind: "" },
                        { day: 2, start: 10, end: 12.5, title: "Kunde", kind: "info" },
                        { day: 2, start: 14, end: 15, title: "Abgabe", kind: "warn" },
                        { day: 4, start: 9, end: 10, title: "Review", kind: "ok" }
                    ]
                }
                KanteAgenda {
                    Layout.preferredWidth: KanteStyle.unit(320)
                    days: [
                        { label: "MI 30.09.", today: true, entries: [{ time: "10:00", title: "Kunde", kind: "info" }, { time: "14:00", title: "Abgabe", kind: "warn" }] },
                        { label: "DO 01.10.", today: false, entries: [] }
                    ]
                }
                RowLayout {
                    spacing: KanteStyle.unit(20)
                    KanteCalendarGrid { Layout.preferredWidth: KanteStyle.unit(280); year: 2026; month: 10; holidays: [3]; absences: [12, 13, 14]; selectedDay: 20 }
                    ColumnLayout {
                        spacing: KanteStyle.unit(14)
                        RowLayout {
                            spacing: KanteStyle.unit(24)
                            KanteKpi { value: "1 687"; label: "Umsatz · Woche"; delta: "+12,4 %"; trend: 1 }
                            KanteKpi { value: "18,75"; label: "Stunden"; delta: "−3,1 %"; trend: -1 }
                            KanteClock { running: false; time: new Date(2026, 9, 1, 10, 9, 42) }
                        }
                        KanteDayStrip { Layout.preferredWidth: KanteStyle.unit(320); segments: [{ from: 9, to: 12.5, kind: "work" }, { from: 14, to: 17, kind: "dim" }, { from: 11, to: 11.7, kind: "event" }]; now: 15.2 }
                        RowLayout {
                            spacing: KanteStyle.unit(8)
                            KanteChip { text: "urlaub"; chipColor: KanteStyle.focusColor }
                            KanteChip { text: "archiv"; checkable: true; checked: true }
                            KanteChip { text: "rolle-12"; removable: true; chipColor: KanteStyle.warningColor }
                            KanteSwatch { source: KanteSwatch.Source.Own }
                            KanteSwatch { source: KanteSwatch.Source.Inherited; swatchColor: KanteStyle.tagColor }
                            KanteSwatch { source: KanteSwatch.Source.Generated; swatchColor: KanteStyle.warningColor }
                        }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(16)
                    KanteStatusLight { name: "Jellyfin"; detail: "OK · 42 ms" }
                    KanteStatusLight { name: "Nextcloud"; detail: "langsam · 1,9 s"; state: KanteStatusLight.State.Warn }
                    KanteStatusLight { name: "Gitea"; detail: "keine Antwort"; state: KanteStatusLight.State.Bad }
                    KanteCommandBox { text: "kpackagetool6 -i kader.plasmoid" }
                }
                KanteBulkBar { Layout.fillWidth: true; count: 7; KanteButton { text: "Übergeben"; emphasis: KanteButton.Emphasis.Primary; size: KanteButton.Size.Small } }
                KanteSettingRow { Layout.fillWidth: true; title: "Schwelle"; hint: "Ab hier dreht der Lüfter hoch."; modified: true; KanteTextField { text: "62" } }
                KanteListRow { Layout.fillWidth: true; text: "Rohschnitt"; meta: "02:14"; selected: true; KanteSwatch { } }
                KanteListRow { Layout.fillWidth: true; text: "Farbkorrektur"; meta: "01:05"; KanteSwatch { swatchColor: KanteStyle.tagColor } }
                KanteTabBar { model: ["Alle", "Prüfen", "Fertig", "Archiv"]; counts: [42, 7, 35, 12]; countKinds: [0, 2, 0, 0]; badges: true }
                KanteCallout { Layout.fillWidth: true; title: "Hinweis"; text: "Schließbar, mit Aktion."; dismissible: true; KanteButton { text: "Mehr"; emphasis: KanteButton.Emphasis.Data; size: KanteButton.Size.Small } }
            }
        }
    }
}
