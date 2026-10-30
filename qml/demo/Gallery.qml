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

    // Tab through the gallery: the focused control stays in view (1.49).
    KanteFocusFollow { flickable: flick }

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
                    // vertical: a fader, filled from the bottom
                    QQC2.Slider { orientation: Qt.Vertical; value: 0.7; Layout.preferredHeight: KanteStyle.unit(120); KanteSliderSkin { control: parent } }
                    QQC2.Slider { orientation: Qt.Vertical; value: 0.3; Layout.preferredHeight: KanteStyle.unit(120); KanteSliderSkin { control: parent } }
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
                // A skipped step shows a dash, not the check (1.49).
                KanteSteps { model: ["Instrument", "Eingang", "Latenz", "Fertig"]; current: 3; skipped: [2] }
                // Page bar at the window's foot: busy dots by kind, a picture area (stage) and an action at the right end.
                KantePageBar {
                    Layout.fillWidth: true
                    model: ["Eingänge", "Audio", "Ausgänge", "Einstellungen"]
                    tooltips: ["Quellen und Monitore", "Mischpult", "Aufnahme und Stream", ""]
                    busy: [false, true, true, false]
                    busyKinds: [0, KantePageBar.Kind.Normal, KantePageBar.Kind.Warning, 0]
                    Rectangle {
                        implicitWidth: KanteStyle.unit(56)
                        implicitHeight: KanteStyle.unit(32)
                        color: KanteStyle.stageColor
                        Text { anchors.centerIn: parent; text: "PGM"; font: KanteStyle.labelFont(); color: KanteStyle.stageTextColor }
                    }
                    KanteButton { text: "Alles aus"; emphasis: KanteButton.Emphasis.Destructive; size: KanteButton.Size.Small }
                }
                // Lower (1.54): Compact with smaller labels, Band as a strip of segments.
                KantePageBar {
                    Layout.fillWidth: true
                    density: KantePageBar.Density.Compact
                    model: ["Eingänge", "Audio", "Ausgänge", "Einstellungen"]
                    busy: [false, true, false, false]
                }
                KantePageBar {
                    Layout.fillWidth: true
                    density: KantePageBar.Density.Band
                    model: ["Eingänge", "Audio", "Ausgänge", "Einstellungen"]
                    busy: [false, true, false, false]
                }
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
                    KanteCalendarGrid { Layout.preferredWidth: KanteStyle.unit(280); year: 2026; month: 10; holidays: [3]; absences: [12, 13, 14]; selectedDay: 20
                                        dots: ({ 6: ["muted"], 8: ["muted", "accent"], 20: ["accent"], 22: ["negative"] })
                                        rangeFrom: 19; rangeTo: 25 }
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
                title: "1.23 · üben (kontra), 1.27 unsauber, akkorde, tonartwechsel, 1.35 loop in tab und noten"
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
                    loopStart: practice.looping ? 2.4 : -1; loopEnd: practice.looping ? 4.8 : -1
                    marks: practice.marks
                }
                KanteBassStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; rests: []; keyFifths: 1; position: practice.position; barsPerSystem: 4
                    loopStart: practice.looping ? 2.4 : -1; loopEnd: practice.looping ? 4.8 : -1
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
                id: wishes2
                title: "1.28 · kontra-wünsche 2: segmente aus, hilfe, zahlenfeld, volta"
                // Eight bars of quarter notes at 100 bpm: |: 1 2 3 [1. 4 :| ] [2. 5 6 ] 7 8
                readonly property var quarters: {
                    var n = []
                    for (var i = 0; i < 32; i++) {
                        n.push({ time: i * 0.6, duration: 0.6, beats: 1, string: i % 4, fret: (i * 3) % 5 })
                    }
                    return n
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    KanteSegmented {
                        model: ["Klinke", "Mikrofon", "MIDI", "Datei"]
                        disabledIndexes: [1, 2]
                        tooltips: ["", "Kommt in Phase 4", "Kommt in Phase 4", ""]
                    }
                    QQC2.Label { text: "Latenz"; color: KanteStyle.textColor }
                    KanteInfoTip { term: "Latenz"; info: "Zeit vom Anschlag bis zum Ton, in Millisekunden." }
                    KanteSpinBox {
                        from: 40; to: 200; stepSize: 5; value: 90; editable: true
                        textFromValue: function (v) { return v + " BPM" }
                        valueFromText: function (t) { return parseInt(t) }
                        Accessible.name: "Tempo"
                    }
                    KanteSpinBox {
                        from: -12; to: 12; value: -2
                        textFromValue: function (v) { return (v > 0 ? "+" : "") + v + " HT" }
                        Accessible.name: "Transponieren"
                    }
                    KanteSpinBox { from: 1; to: 8; value: 8; Accessible.name: "Bis Takt" }
                }
                KanteTabStaff {
                    Layout.fillWidth: true
                    barsPerSystem: 4
                    systems: 2
                    notes: wishes2.quarters
                    bars: [{ time: 0, repeatStart: true }, 2.4, 4.8, { time: 7.2, endings: [1], repeatEnd: true },
                           { time: 9.6, endings: [2] }, { time: 12.0, endings: [2] }, 14.4, 16.8]
                    position: 7.5
                }
            }

            Section {
                id: techDemo
                title: "1.31, 1.32 · technik-zeichen (kontra)"
                // A slap line in E at 100 bpm (an eighth is 0.3 s): slap, pop, ghost, slide,
                // hammer-on and pull-off; the first half played, each technique judged.
                property real position: 1.3
                readonly property var line: {
                    var spec = [[0, 0, "slap", "played"], [2, 7, "pop", "played"], [0, 0, "ghost", "other"],
                                [0, 3, "", ""], [0, 5, "slide", "played"], [1, 2, "", ""], [1, 4, "hammer", "unheard"],
                                [1, 2, "pull", ""], [0, 0, "slap", ""], [2, 9, "pop", ""], [0, 0, "ghost", ""], [1, 0, "", ""]]
                    var tuning = [28, 33, 38, 43]
                    var n = []
                    for (var i = 0; i < spec.length; i++) {
                        var played = i * 0.3 < techDemo.position
                        n.push({ time: i * 0.3, duration: 0.27, beats: 0.5, string: spec[i][0], fret: spec[i][1],
                                 midi: tuning[spec[i][0]] + spec[i][1], technique: spec[i][2],
                                 techniqueResult: played ? spec[i][3] : "", state: played ? "hit" : "pending" })
                    }
                    return n
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    Repeater {
                        model: ["slap", "pop", "ghost", "dead", "slide", "hammer", "pull"]
                        delegate: RowLayout {
                            required property string modelData
                            spacing: KanteStyle.unit(4)
                            KanteTechniqueMark { technique: modelData; height: KanteStyle.unit(16); width: implicitWidth }
                            Text { text: KanteStyle.techniqueName(modelData); color: KanteStyle.textColor; font: KanteStyle.labelFont() }
                        }
                    }
                }
                RowLayout {
                    spacing: KanteStyle.unit(14)
                    Repeater {
                        model: ["played", "other", "unheard"]
                        delegate: RowLayout {
                            required property string modelData
                            spacing: KanteStyle.unit(4)
                            KanteTechniqueMark { technique: "slap"; result: modelData; height: KanteStyle.unit(16); width: implicitWidth }
                            Text { text: KanteStyle.techniqueResultName(modelData); color: KanteStyle.textColor; font: KanteStyle.labelFont() }
                        }
                    }
                }
                KanteTabLane {
                    Layout.fillWidth: true
                    Layout.preferredHeight: KanteStyle.unit(200)
                    notes: techDemo.line
                    bars: [0, 2.4]
                    position: techDemo.position
                    pixelsPerSecond: KanteStyle.unit(260)
                }
                KanteTabStaff {
                    Layout.fillWidth: true
                    barsPerSystem: 2
                    notes: techDemo.line
                    bars: [0, 2.4]
                    position: techDemo.position
                }
                KanteBassStaff {
                    Layout.fillWidth: true
                    barsPerSystem: 2
                    notes: techDemo.line
                    bars: [{ time: 0 }, { time: 2.4 }]
                    position: techDemo.position
                }
            }

            Section {
                id: keysDemo
                title: "1.30 · klaviatur (kontra, bass über midi)"
                // A funk line in E at 120 bpm (an eighth is 0.25 s), the first bars played.
                property real position: 1.6
                readonly property var line: {
                    var midi = [28, 28, 40, 31, 33, 34, 35, 28, 38, 40, 43, 45, 47, 40, 28, 31]
                    var st = ["hit", "hit", "early", "hit", "wrong", "offpitch", "late"]
                    var n = []
                    for (var i = 0; i < midi.length; i++) {
                        n.push({ time: i * 0.25, duration: 0.22, midi: midi[i], state: i < st.length ? st[i] : "pending",
                                 cents: i === 5 ? 28 : undefined })
                    }
                    return n
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    KanteKeyLane {
                        Layout.fillWidth: true
                        Layout.preferredHeight: KanteStyle.unit(220)
                        low: 28; high: 60
                        notes: keysDemo.line
                        bars: [0, 2]
                        position: keysDemo.position
                    }
                    KanteKeyboard {
                        Layout.fillWidth: true
                        low: 28; high: 60
                        markers: [{ midi: 35, role: "current", label: "1" }, { midi: 28, role: "next" },
                                  { midi: 34, role: "wrong" }, { midi: 40, role: "root" }]
                    }
                }
                KanteKeyboard {
                    Layout.preferredWidth: KanteStyle.unit(420)
                    Layout.preferredHeight: KanteStyle.unit(70)
                    low: 28; high: 52
                    keyNames: KanteKeyboard.KeyNames.WhiteKeys
                    interactive: true
                    onActivated: function (midi) { focusKey = midi }
                }
            }

            Section {
                id: partsDemo
                title: "1.50 · probenzeichen (kontra)"
                // A bar's `section` names the part that starts there; several names join ("Refrain · B").
                readonly property var bars: [{ time: 0, section: "Intro" }, { time: 2.4, section: "Strophe mit langem Namen" },
                                             { time: 4.8, section: ["Refrain", "B"] }, { time: 7.2, section: "Outro" }]
                RowLayout {
                    spacing: KanteStyle.unit(10)
                    KanteRehearsalMark { text: "A" }
                    KanteRehearsalMark { text: KanteStyle.rehearsalText(["Refrain", "B"]) }
                    // A long name is cut short to its room.
                    KanteRehearsalMark { text: "Bridge mit sehr langem Namen"; maximumWidth: KanteStyle.unit(120) }
                }
                KanteTabLane {
                    Layout.fillWidth: true; Layout.preferredHeight: KanteStyle.unit(180)
                    notes: practice.riff; bars: partsDemo.bars; position: 0; pixelsPerSecond: KanteStyle.unit(90); playLine: 0.05
                }
                KanteTabStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; bars: partsDemo.bars; position: 0; barsPerSystem: 4
                }
                KanteBassStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; rests: []; bars: partsDemo.bars; position: 0; barsPerSystem: 4
                }
            }

            Section {
                id: qa151
                title: "1.51 · qa kontra: gesperrte einträge, fokusfalle, hinweis ohne text, saiten, balken"
                RowLayout {
                    spacing: KanteStyle.unit(16)
                    // Disabled platform controls take the Kante colours from the gallery's KanteScope.
                    ColumnLayout {
                        Layout.preferredWidth: KanteStyle.unit(200)
                        QQC2.ItemDelegate { text: "Bibliothek"; Layout.fillWidth: true }
                        QQC2.ItemDelegate { text: "Üben (kein Stück)"; enabled: false; Layout.fillWidth: true }
                        Kirigami.Separator { Layout.fillWidth: true; enabled: false }
                        QQC2.ItemDelegate { text: "Einstellungen"; Layout.fillWidth: true }
                    }
                    // A title only: no empty line under it.
                    KanteCallout { Layout.alignment: Qt.AlignTop; Layout.preferredWidth: KanteStyle.unit(240); kind: KanteCallout.Kind.Ok; title: "Gespeichert" }
                    // A sheet in the page: Tab stays inside while it is open; closed, the focus goes back.
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        KanteButton { id: sheetOpener; text: "Auswertung öffnen"; onClicked: sheetDemo.visible = true }
                        KanteCard {
                            id: sheetDemo
                            visible: false
                            implicitWidth: KanteStyle.unit(260)
                            implicitHeight: sheetCol.implicitHeight + KanteStyle.unit(24)
                            ColumnLayout {
                                id: sheetCol
                                x: KanteStyle.unit(12)
                                y: KanteStyle.unit(12)
                                KanteButton { text: "Schließen"; onClicked: sheetDemo.visible = false }
                                KanteButton { text: "Takt 3 üben" }
                            }
                        }
                        KanteFocusTrap { area: sheetDemo; returnTo: sheetOpener }
                    }
                }
                // String colours: in Kante Light and Leinen at least 4.5:1, apart under deuteranopia.
                KanteTabStaff {
                    Layout.fillWidth: true
                    notes: practice.riff; bars: partsDemo.bars; position: 0; barsPerSystem: 4
                }
                // Screen readers hear every bar: "−10 bis 0 ms: 5 Noten".
                KanteTimingHistogram {
                    Layout.preferredWidth: KanteStyle.unit(420)
                    counts: [1, 3, 5, 2]
                    firstBinMs: -20
                    binMs: 10
                    meanMs: -4
                }
            }

            Section {
                title: "1.43 · mischpult (lmix): griff, menü, popover, farben, tabelle, kacheln"
                RowLayout {
                    spacing: KanteStyle.unit(24)
                    ColumnLayout {
                        spacing: KanteStyle.unit(8)
                        Rectangle {
                            Layout.preferredWidth: KanteStyle.unit(260)
                            Layout.preferredHeight: galleryMonitorHeight.value
                            color: KanteStyle.stageColor
                            Text { anchors.centerIn: parent; text: Math.round(galleryMonitorHeight.value) + " px"; color: KanteStyle.stageTextColor; font: KanteStyle.monoFont(10) }
                        }
                        KanteSplitHandle {
                            id: galleryMonitorHeight
                            Layout.preferredWidth: KanteStyle.unit(260)
                            value: KanteStyle.unit(90)
                            from: KanteStyle.unit(40)
                            to: KanteStyle.unit(180)
                            defaultValue: KanteStyle.unit(90)
                            accessibleName: "Höhe der Monitore"
                            onMoved: function (v) { value = v }
                        }
                        RowLayout {
                            spacing: KanteStyle.unit(6)
                            Text { text: "Speichern"; color: KanteStyle.textColor; font: KanteStyle.defaultFont }
                            KanteKeycap { text: "Strg+S" }
                            Text { text: "Abbrechen"; color: KanteStyle.textColor; font: KanteStyle.defaultFont }
                            KanteKeycap { text: "Esc" }
                        }
                        KanteSwatchPicker {
                            colors: [KanteStyle.negativeTextColor, KanteStyle.neutralTextColor, KanteStyle.accentColor, KanteStyle.positiveTextColor, KanteStyle.focusColor]
                            names: ["Rot", "Orange", "Gelb", "Grün", "Türkis"]
                            noneText: "Keine"
                            currentIndex: 4
                            onPicked: function (i) { currentIndex = i }
                        }
                        KanteTableHeader {
                            id: galleryTable
                            Layout.preferredWidth: KanteStyle.unit(300)
                            columns: [{ title: "", width: KanteStyle.unit(14) }, { title: "Ziel", width: 0 }, { title: "Format", width: KanteStyle.unit(70) }]
                        }
                        Repeater {
                            model: [["Aufnahme", "1080p30"], ["Stream", "720p30"]]
                            Item {
                                Layout.preferredWidth: galleryTable.width
                                Layout.preferredHeight: KanteStyle.unit(24)
                                required property var modelData
                                KanteLamp { x: galleryTable.columnX(0); anchors.verticalCenter: parent.verticalCenter }
                                Text { x: galleryTable.columnX(1); width: galleryTable.columnWidth(1); anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[0]; color: KanteStyle.textColor; font: KanteStyle.defaultFont }
                                Text { x: galleryTable.columnX(2); anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[1]; color: KanteStyle.textColor; font: KanteStyle.monoFont(9) }
                            }
                        }
                    }
                    ColumnLayout {
                        spacing: KanteStyle.unit(8)
                        RowLayout {
                            spacing: KanteStyle.unit(6)
                            KanteButton {
                                text: "Datei"
                                onClicked: galleryMenu.popup(this, 0, height)
                                QQC2.Menu {
                                    id: galleryMenu
                                    KantePopupSkin { popup: galleryMenu }
                                    KanteMenuSection { text: "Show"; rule: false }
                                    KanteMenuItem { text: "Öffnen…"; icon.name: "document-open"; shortcutText: "Strg+O" }
                                    KanteMenuItem { text: "Speichern"; icon.name: "document-save"; shortcutText: "Strg+S" }
                                    KanteMenuSection { text: "Input" }
                                    KanteMenuItem { text: "Bei Signalverlust"; iconRoom: true; valueText: "Standbild" }
                                    KanteMenuItem { text: "Entfernen"; icon.name: "edit-delete"; destructive: true; shortcutText: "Entf" }
                                }
                            }
                            KanteButton {
                                id: galleryViewButton
                                text: "Ansicht"
                                onClicked: galleryPopover.openAt(galleryViewButton)
                            }
                            KantePopover {
                                id: galleryPopover
                                title: "Ansicht"
                                KanteSwitch { text: "Ton am Rand"; checked: true }
                                KanteSwitch { text: "Einfacher Modus" }
                                // 1.55: a removal that stays quiet at the foot.
                                KanteButton {
                                    text: "Bus entfernen"
                                    emphasis: KanteButton.Emphasis.Quiet
                                    destructive: true
                                    onClicked: galleryRemoveDialog.open()
                                }
                            }
                            KanteButton {
                                text: "Toast"
                                onClicked: galleryToast.show()
                            }
                            // 1.55: a sized, destructive question.
                            KanteButton {
                                text: "Bus entfernen…"
                                emphasis: KanteButton.Emphasis.Destructive
                                onClicked: galleryRemoveDialog.open()
                            }
                            KanteDialog {
                                id: galleryRemoveDialog
                                parent: QQC2.Overlay.overlay
                                anchors.centerIn: parent
                                modal: true
                                size: KanteDialog.Size.Small
                                destructive: true
                                title: "Bus „Bühne“ entfernen?"
                                standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
                                acceptText: "Bus entfernen"
                                contentHeight: galleryRemoveText.implicitHeight
                                QQC2.Label {
                                    id: galleryRemoveText
                                    width: parent.width
                                    wrapMode: Text.WordWrap
                                    text: "3 Inputs senden nicht mehr dorthin."
                                }
                            }
                            // 1.57: an own button at the start of the footer.
                            KanteButton {
                                text: "Tasten…"
                                onClicked: galleryKeysDialog.open()
                            }
                            KanteDialog {
                                id: galleryKeysDialog
                                parent: QQC2.Overlay.overlay
                                anchors.centerIn: parent
                                modal: true
                                size: KanteDialog.Size.Small
                                title: "Tasten"
                                standardButtons: QQC2.Dialog.Close
                                footerStart: [
                                    KanteButton {
                                        text: "Belegungen…"
                                        emphasis: KanteButton.Emphasis.Quiet
                                        onClicked: galleryKeysDialog.close()
                                    }
                                ]
                                contentHeight: galleryKeysRow.implicitHeight
                                Row {
                                    id: galleryKeysRow
                                    spacing: Kirigami.Units.smallSpacing
                                    KanteKeycap { text: "Strg" }
                                    KanteKeycap { text: "K" }
                                    QQC2.Label { text: "Belegungen" }
                                }
                            }
                        }
                        GridLayout {
                            columns: 3
                            columnSpacing: KanteStyle.unit(6)
                            rowSpacing: KanteStyle.unit(6)
                            KanteOptionTile { text: "Kamera"; hint: "Capture, Webcam"; icon.name: "camera-web"; checked: true }
                            KanteOptionTile { text: "Video"; hint: "Datei"; icon.name: "video-x-generic" }
                            KanteOptionTile { text: "Stream"; hint: "HLS, RTMP"; icon.name: "network-wired" }
                        }
                        KanteToast {
                            id: galleryToast
                            Layout.preferredWidth: KanteStyle.unit(340)
                            text: "Input 3 „Schach“ entfernt"
                            actionText: "Rückgängig"
                            actionShortcut: "Strg+Z"
                            life: 8000
                        }
                    }
                }
            }

            Section {
                title: "1.25, 1.33 · gespräch (kaiwa)"
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
                        // 1.33: words to look up; click, or Tab then Left / Right and Enter.
                        KanteRubyText {
                            id: lookupDemo
                            Layout.fillWidth: true
                            interactive: true
                            segments: [{ text: "駅", reading: "えき", word: 0 }, { text: "まで", word: 1 }, { text: "は", word: 2 },
                                       { text: "歩", reading: "ある", isNew: true, word: 3 }, { text: "いて", word: 3 },
                                       { text: "五分", reading: "ごふん", word: 4 }, { text: "です", word: 5 }, { text: "。" }]
                            onWordActivated: function (word) { lookupLabel.text = "→ " + wordText(word) }
                        }
                        Text { id: lookupLabel; text: "1.33: Wort anklicken"; color: KanteStyle.mutedTextColor; font: KanteStyle.defaultFont }
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
