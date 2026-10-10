import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import Kante

/**
 * Every Kante component in one view (Kante 1.10): buttons, fields, controls,
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
    height: 7000
    color: KanteStyle.backgroundColor

    Binding { target: KanteStyle; property: "kind"; value: root.kind }
    Binding { target: KanteStyle; property: "preferDark"; value: root.dark }
    // As in an app: the platform controls below (labels, check boxes) take the Kante colours.
    KanteScope { target: root }

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
                // 1.27: the wrappers, so an app does not leave a light platform control on a dark page
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    KanteSwitch { text: "Bundlos"; checked: true }
                    KanteSwitch { text: "Tiefe Saite oben" }
                    KanteComboBox { model: ["Standard-Eingang", "Scarlett 2i2", "USB-Bass"]; currentIndex: 1; Layout.preferredWidth: KanteStyle.unit(220) }
                    KanteComboBox { model: ["Kein Gerät"]; invalid: true; Layout.preferredWidth: KanteStyle.unit(160) }
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
                    KantePill { text: "Analysiert"; status: KantePill.State.Running }
                    KantePill { text: "Prüfen"; status: KantePill.State.Review }
                    KantePill { text: "Gesperrt"; status: KantePill.State.Locked }
                    KantePill { text: "Fertig"; status: KantePill.State.Done }
                    KantePill { text: "Fehler"; status: KantePill.State.Failed }
                    KantePill { text: "Pausiert"; status: KantePill.State.Off }
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
                            KanteKpi { value: "312"; label: "Kosten"; delta: "+8 %"; trend: 1; good: -1 }
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
                    KanteStatusLight { name: "Nextcloud"; detail: "langsam · 1,9 s"; status: KanteStatusLight.State.Warn }
                    KanteStatusLight { name: "Gitea"; detail: "keine Antwort"; status: KanteStatusLight.State.Bad }
                    KanteCommandBox { text: "kpackagetool6 -i kader.plasmoid" }
                }
                KanteBulkBar { Layout.fillWidth: true; count: 7; KanteButton { text: "Übergeben"; emphasis: KanteButton.Emphasis.Primary; size: KanteButton.Size.Small } }
                KanteSettingRow { Layout.fillWidth: true; title: "Schwelle"; hint: "Ab hier dreht der Lüfter hoch."; modified: true; KanteTextField { text: "62" } }
                KanteListRow { Layout.fillWidth: true; text: "Rohschnitt"; meta: "02:14"; selected: true; KanteSwatch { } }
                KanteListRow { Layout.fillWidth: true; text: "Farbkorrektur"; meta: "01:05"; KanteSwatch { swatchColor: KanteStyle.tagColor } }
                KanteTabBar { model: ["Alle", "Prüfen", "Fertig", "Archiv"]; counts: [42, 7, 35, 12]; countKinds: [0, 2, 0, 0]; badges: true }
                KanteCallout { Layout.fillWidth: true; title: "Hinweis"; text: "Schließbar, mit Aktion."; dismissible: true; KanteButton { text: "Mehr"; emphasis: KanteButton.Emphasis.Data; size: KanteButton.Size.Small } }
                // KanteUpdateCheck: no network in the gallery (enabled false), the answer is fed in once
                KanteUpdateCheck {
                    id: updateCheck
                    project: "kante"; version: "1.0.0"; enabled: false
                    Component.onCompleted: { enabled = true; receive(JSON.stringify({ format: 1, projects: { kante: { version: "1.1.0", date: "", url: "https://github.com/shrippen/Kante" } } })) }
                }
                KanteCallout {
                    Layout.fillWidth: true; visible: updateCheck.available; dismissible: true
                    title: "Update"; text: "Version " + updateCheck.latestVersion
                    onDismissed: updateCheck.dismiss()
                    KanteButton { text: "Release"; emphasis: KanteButton.Emphasis.Data; size: KanteButton.Size.Small; onClicked: Qt.openUrlExternally(updateCheck.latestUrl) }
                }
            }

            Section {
                title: "1.8 · zeit und eingaben"
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    KanteDayStrip {
                        Layout.preferredWidth: KanteStyle.unit(420)
                        sunrise: 7.2; sunset: 19.1; workFrom: 8; workTo: 17; now: 15.2
                        allDay: [{ title: "Urlaub Lena" }]
                        segments: [{ from: 8.25, to: 12, kind: "work", color: KanteStyle.dataColor(0) }, { from: 12.75, to: 14.5, kind: "work", color: KanteStyle.dataColor(2) },
                                   { from: 14.5, to: 16.5, kind: "dim" }, { from: 10, to: 10.5, kind: "event" }]
                    }
                    KanteBarChart {
                        Layout.preferredWidth: KanteStyle.unit(300); Layout.preferredHeight: KanteStyle.unit(140)
                        axis: true; valueFormat: KanteBarChart.ValueFormat.Hours; goal: 8; highlight: 2
                        values: [[4.5, 2.25, 1], [3, 3.5], [6, 1.75, 0.5], [2, 5], [5.5, 0.75]]
                        stackColors: [KanteStyle.dataColor(0), KanteStyle.dataColor(2), KanteStyle.dataColor(3)]
                        labels: ["MO", "DI", "MI", "DO", "FR"]
                    }
                }
                KanteWeekTimeline {
                    Layout.fillWidth: true
                    Layout.maximumWidth: KanteStyle.unit(720)
                    today: 2; now: 15.2
                    entries: [
                        { day: 0, start: 8.25, end: 12, color: KanteStyle.dataColor(0), title: "Andon" },
                        { day: 0, start: 12.75, end: 17, color: KanteStyle.dataColor(2), title: "Kimai" },
                        { day: 1, start: 9, end: 11.5, color: KanteStyle.dataColor(0), title: "Andon" },
                        { day: 1, start: 13, end: 18.5, color: KanteStyle.dataColor(3), title: "Kader" },
                        { day: 2, start: 7.5, end: 10, color: KanteStyle.dataColor(2), title: "Kimai" },
                        { day: 2, start: 10.25, end: 15, title: "ohne Projekt" },
                        { day: 3, start: 20, end: 23.5, color: KanteStyle.dataColor(4), title: "Nacht" },
                        { day: 5, start: 10, end: 12, color: KanteStyle.dataColor(3), title: "Kader" }
                    ]
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    KanteDateField { id: galleryDate; date: new Date(2026, 8, 30); Layout.preferredWidth: KanteStyle.unit(170) }
                    KanteTimeField { hour: 9; minute: 30; Layout.preferredWidth: KanteStyle.unit(120) }
                    KanteSearchCombo {
                        Layout.preferredWidth: KanteStyle.unit(220)
                        placeholderText: "Kunde suchen"
                        textRole: "name"; colorRole: "color"; currentIndex: 1
                        model: [{ name: "Andon GmbH", color: KanteStyle.dataColor(0) }, { name: "Kader & Söhne", color: KanteStyle.dataColor(2) }, { name: "Ohne Farbe" }]
                    }
                    KanteTagPicker {
                        Layout.preferredWidth: KanteStyle.unit(330)
                        placeholderText: "Tag"
                        tags: ["urlaub", { name: "rolle-12", color: KanteStyle.focusColor }]
                        suggestions: ["urlaub", "archiv", "rolle-12", "1998"]
                        onEdited: function (t) { tags = t }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(8)
                    KanteChip { text: "dunkel"; chipColor: "#202020" }
                    KanteChip { text: "mit-icon"; iconName: "tag"; chipColor: KanteStyle.focusColor; removable: true }
                    KanteChip { text: "sehr-langer-tag-name"; removable: true; Layout.preferredWidth: KanteStyle.unit(110) }
                    KanteChip { text: "gequetscht"; removable: true; Layout.preferredWidth: KanteStyle.unit(44) }
                    KanteChip { text: "kompakt"; compact: true; chipColor: KanteStyle.warningColor }
                    KanteChip { text: "kompakt"; compact: true; chipColor: "#202020" }
                    KanteSwatch { size: KanteSwatch.Size.Normal; source: KanteSwatch.Source.Own }
                    KanteSwatch { size: KanteSwatch.Size.Small; source: KanteSwatch.Source.Inherited; swatchColor: KanteStyle.tagColor }
                    KanteSwatch { size: KanteSwatch.Size.Dense; swatchColor: KanteStyle.warningColor }
                }
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    ColumnLayout {
                        Layout.preferredWidth: KanteStyle.unit(380)
                        spacing: 0
                        KanteListRow { Layout.fillWidth: true; leadingText: "09:15"; leadingWidth: KanteStyle.unit(44); text: "Rohschnitt"; subtitle: "Kader · Schnitt"; meta: "02:14"; count: "3"; selected: true; KanteSwatch { size: KanteSwatch.Size.Small } }
                        KanteListRow { Layout.fillWidth: true; leadingText: "11:30"; leadingWidth: KanteStyle.unit(44); text: "Farbkorrektur"; subtitle: "Andon · Pflege"; meta: "01:05"; count: "12"; KanteSwatch { size: KanteSwatch.Size.Small; swatchColor: KanteStyle.tagColor } }
                        KanteListRow { Layout.fillWidth: true; text: "Ablage"; density: KanteListRow.Density.Compact; dropTarget: true; meta: "hier ablegen" }
                        KanteListRow { Layout.fillWidth: true; text: "Export"; enabled: false; disabledReason: "Nur mit Lizenz"; rule: false }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        KanteSettingRow { id: s1; Layout.fillWidth: true; section: "Anzeige"; title: "Schwelle"; hint: "Ab hier dreht der Lüfter hoch."; titleWidth: Math.max(s1.implicitTitleWidth, s2.implicitTitleWidth); KanteTextField { text: "62" } }
                        KanteSettingRow { id: s2; Layout.fillWidth: true; title: "Intervall"; titleWidth: s1.titleWidth; modified: true; KanteTextField { text: "5 s" } }
                        KanteSettingRow { Layout.preferredWidth: KanteStyle.unit(300); narrow: true; title: "Schmal"; hint: "Titel über dem Feld."; KanteTextField { text: "schmal" } }
                        KanteCallout { Layout.fillWidth: true; title: "Ohne Aktionen"; text: "Die unsichtbare Aktion nimmt keinen Platz."; KanteButton { text: "Weg"; visible: false } }
                    }
                }
            }

            Section {
                title: "1.9 · popups im fenster, 12 h, abschnitte, ablesen"
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    KanteDateField { date: new Date(2026, 8, 30); Layout.preferredWidth: KanteStyle.unit(170); popupAbove: true }
                    KanteTimeField { objectName: "time12"; twelveHour: true; amText: "AM"; pmText: "PM"; hour: 21; minute: 30 }
                    KanteSearchCombo {
                        objectName: "sectionCombo"
                        Layout.preferredWidth: KanteStyle.unit(220)
                        placeholderText: "Projekt suchen"
                        textRole: "name"; colorRole: "color"; sectionRole: "customer"
                        model: [{ name: "Website", customer: "Andon GmbH", color: KanteStyle.dataColor(0) }, { name: "Shop", customer: "Andon GmbH", color: KanteStyle.dataColor(0) },
                                { name: "Archiv", customer: "Kader & Söhne", color: KanteStyle.dataColor(2) }, { name: "Intern", customer: "Kader & Söhne", color: KanteStyle.dataColor(2) }]
                    }
                    KanteTagPicker {
                        objectName: "colorTags"
                        Layout.preferredWidth: KanteStyle.unit(300)
                        placeholderText: "Tag"
                        tags: ["urlaub"]
                        suggestions: ["urlaub", { name: "archiv", color: KanteStyle.positiveTextColor }, { name: "rolle-12", color: KanteStyle.focusColor }, "1998"]
                        onEdited: function (t) { tags = t }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    KanteBarChart {
                        Layout.preferredWidth: KanteStyle.unit(320); Layout.preferredHeight: KanteStyle.unit(150)
                        axis: true; valueFormat: KanteBarChart.ValueFormat.Hours
                        values: [[4.5, 2.25], [3, 3.5], [6, 1.75], [2, 5]]
                        stackColors: [KanteStyle.dataColor(0), KanteStyle.dataColor(2)]
                        partNames: ["Andon", "Kader"]
                        labels: ["MO", "DI", "MI", "DO"]
                        hoverIndex: 1; hoverPart: 1
                    }
                    ColumnLayout {
                        Layout.preferredWidth: KanteStyle.unit(380)
                        spacing: 0
                        KanteListRow {
                            Layout.fillWidth: true; text: "Import"; subtitle: "3 Fehler"; count: "3"
                            countKind: KanteListRow.CountKind.Error
                            trailing: Kirigami.Icon { source: "go-next-symbolic"; implicitWidth: KanteStyle.unit(16); implicitHeight: implicitWidth; color: KanteStyle.mutedTextColor }
                        }
                        QQC2.ItemDelegate {
                            Layout.fillWidth: true
                            padding: 0
                            contentItem: KanteListRow {
                                text: "In einem ItemDelegate"; meta: "tippen"; count: "12"; rule: false
                                trailing: Kirigami.Icon { source: "go-next-symbolic"; implicitWidth: KanteStyle.unit(16); implicitHeight: implicitWidth; color: KanteStyle.mutedTextColor }
                            }
                        }
                    }
                }
            }

            Section {
                title: "1.10 · gespräch, kleine diagramme"
                RowLayout {
                spacing: KanteStyle.unit(24)
                ColumnLayout {
                    Layout.preferredWidth: KanteStyle.unit(460)
                    spacing: KanteStyle.unit(10)
                    KanteMessage {
                        Layout.fillWidth: true
                        author: "KI"; time: "09:12"
                        text: "Das Passwort steht im Klartext. Ersetzen durch einen Verweis auf Bitwarden?"
                        head: KanteChip { text: "Änderung 2"; compact: false }
                    }
                    KanteMessage {
                        Layout.fillWidth: true
                        from: KanteMessage.From.Own; author: "Du"; time: "09:14"
                        text: "Ja, aber nicht löschen."
                    }
                    KanteMessage {
                        Layout.fillWidth: true
                        from: KanteMessage.From.System; time: "09:15"
                        text: "Neue Version für 2 Dateien"
                    }
                }
                ColumnLayout {
                    Layout.preferredWidth: KanteStyle.unit(240)
                    spacing: KanteStyle.unit(10)
                    KanteSectionLabel { text: "Regelkonform"; rule: true; Layout.fillWidth: true }
                    KanteBarChart { compact: true; values: [0.62, 0.7, 0.66, 0.74, 0.8, 0.83, 0.87]; highlight: 6; labels: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]; formatter: v => Math.round(v * 100) + " %" }
                    KanteSectionLabel { text: "Fortschritt" }
                    KanteProgressBar { Layout.fillWidth: true; parts: [{ value: 0.3, color: KanteStyle.positiveTextColor }, { value: 0.12, color: KanteStyle.negativeTextColor }] }
                    KanteChip { text: "nur Anzeige"; interactive: false }
                }
                }
            }

            Section {
                id: practice
                title: "1.23 · üben (kontra), 1.27 unsauber, akkorde, tonartwechsel"
                // Demo data: a riff at 100 bpm (a quarter is 0.6 s); the transport drives it.
                property real position: 2.1
                property bool playing: false
                property bool looping: true
                property bool metronome: false
                property bool countIn: false
                property real speed: 1.0
                // 1.24: how states show (0 Full, 1 Quiet for a play mode, 2 Off)
                property int marks: 0
                readonly property var riff: {
                    var n = [], t = 0
                    var beats = [1, 0.5, 0.5, 1, 1, 0.5, 0.5, 0.5, 0.5, 2, 1.5, 0.5, 1, 1, 4]
                    var midi = [40, 43, 45, 47, 45, 43, 40, 43, 45, 50, 52, 50, 47, 45, 40]
                    var str = [0, 0, 1, 1, 1, 0, 0, 0, 1, 2, 2, 2, 1, 1, 0]
                    var fret = [0, 3, 0, 2, 0, 3, 0, 3, 0, 0, 2, 0, 2, 0, 0]
                    var st = ["hit", "offpitch", "early", "hit", "wrong", "late", "missed"]
                    for (var i = 0; i < beats.length; i++) {
                        n.push({ time: t, duration: beats[i] * 0.6, beats: beats[i], midi: midi[i], string: str[i], fret: fret[i],
                                 state: i < st.length ? st[i] : "pending", tied: false, cents: i === 1 ? 32 : undefined })
                        t += beats[i] * 0.6
                    }
                    return n
                }
                readonly property var riffBars: [0, 2.4, 4.8, 7.2, 9.6, 12.0]
                Timer {
                    interval: 16; repeat: true; running: practice.playing
                    onTriggered: {
                        var p = practice.position + interval / 1000 * practice.speed
                        practice.position = practice.looping && p > 4.8 ? 2.4 : (p > 12 ? 0 : p)
                    }
                }

                KanteTransportBar {
                    Layout.fillWidth: true
                    playing: practice.playing; looping: practice.looping; metronome: practice.metronome
                    countIn: practice.countIn; speed: practice.speed; position: practice.position; duration: 12
                    onPlayToggled: practice.playing = !practice.playing
                    onLoopToggled: practice.looping = !practice.looping
                    onMetronomeToggled: practice.metronome = !practice.metronome
                    onCountInToggled: practice.countIn = !practice.countIn
                    onSpeedChangeRequested: function (s) { practice.speed = s }
                    onRewind: practice.position = 0
                }
                KanteSegmented {
                    model: ["Voll", "Leise", "Aus"]
                    tooltips: ["Zustände voll", "Zustände leise (Spielen)", "Keine Zustände"]
                    currentIndex: practice.marks
                    onActivated: function (i) { practice.marks = i }
                }
                KanteTabLane {
                    Layout.fillWidth: true; Layout.preferredHeight: KanteStyle.unit(180)
                    notes: practice.riff; bars: practice.riffBars; position: practice.position
                    loopStart: practice.looping ? 2.4 : -1; loopEnd: practice.looping ? 4.8 : -1
                    marks: practice.marks
                }
                KanteTabStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; bars: practice.riffBars; position: practice.position; barsPerSystem: 4
                    marks: practice.marks
                }
                KanteBassStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; rests: []; keyFifths: 1; position: practice.position; barsPerSystem: 4
                    marks: practice.marks
                    // 1.27: chord symbols per bar and at a time, a key change in bar 3 (G to F major)
                    bars: [{ time: 0, numerator: 4, denominator: 4, chord: "Em" }, { time: 2.4, chord: "G" }, { time: 4.8, keyFifths: -1, chord: "Dm7" }, 7.2, 9.6]
                    chords: [{ time: 1.2, text: "Am7" }, { time: 3.6, text: "D/F#" }]
                }
                KanteFretboard {
                    Layout.fillWidth: true
                    markers: {
                        var lane = practice.riff, out = [{ string: 0, fret: 5, role: "root", label: "A" }, { string: 1, fret: 7, role: "scale" }, { string: 2, fret: 5, role: "scale" }]
                        for (var i = 0; i < lane.length; i++) {
                            if (lane[i].time > practice.position) {
                                out.push({ string: lane[i].string, fret: lane[i].fret, role: "next" })
                                if (i > 0) out.push({ string: lane[i - 1].string, fret: lane[i - 1].fret, role: "current", label: "1" })
                                break
                            }
                        }
                        return out
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    KanteTunerGauge { Layout.preferredWidth: KanteStyle.unit(270); noteName: "E"; octave: 1; cents: -12; active: true; hint: "Höher stimmen" }
                    KanteTunerGauge { Layout.preferredWidth: KanteStyle.unit(270); noteName: "A"; octave: 1; cents: 2; active: true }
                    ColumnLayout {
                        spacing: KanteStyle.unit(14)
                        KanteLevelMeter { Layout.preferredWidth: KanteStyle.unit(380); peakDb: -14; rmsDb: -22 }
                        KanteLevelMeter { Layout.preferredWidth: KanteStyle.unit(380); peakDb: -0.4; rmsDb: -5; clipped: true }
                        KanteTimingHistogram {
                            Layout.preferredWidth: KanteStyle.unit(380); Layout.preferredHeight: KanteStyle.unit(170)
                            counts: [0, 1, 3, 6, 11, 15, 9, 5, 2, 1]; firstBinMs: -50; binMs: 10; meanMs: 4.2
                        }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    Repeater {
                        model: ["pending", "hit", "offpitch", "wrong", "missed", "early", "late"]
                        delegate: RowLayout {
                            required property string modelData
                            spacing: KanteStyle.unit(4)
                            KanteNoteMark { noteState: modelData; cents: modelData === "offpitch" ? 32 : NaN; Layout.rightMargin: centsWidth }
                            Text { text: KanteStyle.noteStateName(modelData); color: KanteStyle.textColor; font: KanteStyle.labelFont() }
                        }
                    }
                }
            }

            Section {
                title: "1.25 · gespräch (kaiwa)"
                // The talk button walks through its states on click, as an app would drive it.
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    KanteTalkButton {
                        id: galleryTalk
                        level: 0.6
                        onTalkStarted: talkState = KanteTalkButton.State.Listening
                        onTalkEnded: talkState = KanteTalkButton.State.Thinking
                        onInterruptRequested: talkState = KanteTalkButton.State.Ready
                        onErrorActionRequested: talkState = KanteTalkButton.State.Ready
                    }
                    KanteTalkButton { talkState: KanteTalkButton.State.Speaking }
                    KanteTalkButton { talkState: KanteTalkButton.State.Error }
                    KanteGoalMeter { value: 0.6; label: "12 T" }
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.preferredWidth: KanteStyle.unit(460)
                        spacing: KanteStyle.unit(10)
                        KanteMessage {
                            Layout.fillWidth: true
                            author: "店員 · Kassiererin"; time: "12:04"
                            KanteRubyText { Layout.fillWidth: true; markup: "いらっしゃいませ。{温|あたた|new}めますか。"; density: KanteRubyText.Density.New }
                        }
                        KanteMessage {
                            Layout.fillWidth: true
                            from: KanteMessage.From.Own; time: "12:05"; text: "ふくろ、いりません。"
                            KanteHeardLine { Layout.fillWidth: true; text: "ふくろ(?)いりません"; unsure: true }
                        }
                        KanteRubyText { Layout.fillWidth: true; markup: "{駅|えき}までは{歩|ある|new}いて{五分|ごふん}です。" }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: KanteStyle.unit(10)
                        KanteHintCard {
                            Layout.fillWidth: true
                            tier: KanteHintCard.Tier.Yellow; tierText: "Falsch"; meta: "Partikel"
                            titleItem: KanteDiffText { parts: [{ text: "コーヒー" }, { text: "を", kind: "removed" }, { text: "が", kind: "added" }, { text: "好きです" }] }
                            text: "好き verlangt が für das, was man mag."
                            KanteButton { text: "Anhören"; size: KanteButton.Size.Small }
                        }
                        KanteHintCard {
                            Layout.fillWidth: true; compact: true
                            tier: KanteHintCard.Tier.Red; tierText: "Verhindert Verständnis"; meta: "Wortwahl"
                            titleItem: KanteDiffText { parts: [{ text: "Leuchtturm", kind: "removed" }, { text: "とうだいもり", kind: "added" }] }
                        }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    KantePitchCurve {
                        Layout.preferredWidth: KanteStyle.unit(420); Layout.preferredHeight: KanteStyle.unit(170)
                        morae: ["は", "し", "(が)"]; target: [1, 0, 0]; kernel: 0; missAt: 1
                        actual: [0.15, 0.2, 0.3, 0.45, 0.6, 0.75, 0.85, 0.9, 0.92]
                    }
                    KantePath {
                        model: [
                            { title: "Begrüßung", meta: "N5-01", state: "done" },
                            { title: "Sich vorstellen", meta: "N5-02", state: "done" },
                            { title: "Wiederholung", meta: "8 fällig", state: "review" },
                            { title: "An der Konbini", meta: "N5-03 · 2 von 4 Szenarien", state: "current" },
                            { title: "Im Café", meta: "N5-04", state: "open" },
                            { title: "Nach dem Weg fragen", meta: "N5-05", state: "locked" }
                        ]
                    }
                }
            }
        }
    }
}
