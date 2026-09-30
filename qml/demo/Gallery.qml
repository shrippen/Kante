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
    height: 1500
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
                KanteScrollMeter { Layout.fillWidth: true; flickable: flick }
            }
        }
    }
}
