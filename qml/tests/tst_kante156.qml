import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.56, from Kurrent's Agenda: line weights, markers, meters, swatches, tint levels and
 * the sizes of an hour grid as KanteStyle roles, so a view drawn by hand has no sizes of its
 * own. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante156"
    when: windowShown

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    Component {
        id: comboComponent
        QQC2.ComboBox {
            model: ["Erledigungen", "Fälligkeiten"]
            KanteFieldSkin { id: skin; control: parent }
        }
    }

    // A combo box sized by its style showed its value cut short in the Kante style ("Erledigu…"
    // in Kurrent's heatmap): the skin draws the text 8 px in and clear of the arrow, the style
    // made room for less.
    function test_comboBoxMakesRoomForItsValue() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const combo = createTemporaryObject(comboComponent, tc)
        verify(combo)
        combo.width = Qt.binding(function() { return combo.implicitWidth })
        waitForRendering(combo)
        const text = findChild(combo, "kanteComboValue")
        compare(text.text, "Erledigungen")
        verify(!text.truncated, "the value is cut short: " + text.width + " < " + text.implicitWidth)
    }

    function test_lineWeights() {
        // The web's 1 px borders and 2 px lines; the colour edge sits between them.
        compare(KanteStyle.borderWidth, 1)
        compare(KanteStyle.lineWidth, 2)
        compare(KanteStyle.edgeWidth, 3)
        verify(KanteStyle.borderWidth < KanteStyle.lineWidth)
        verify(KanteStyle.lineWidth < KanteStyle.edgeWidth)
    }

    function test_markersAreSquareInKante_data() {
        return [
            { tag: "kante", kind: KanteStyle.Kind.Kante, square: true },
            { tag: "system", kind: KanteStyle.Kind.System, square: false }
        ]
    }
    function test_markersAreSquareInKante(data) {
        KanteStyle.kind = data.kind
        verify(KanteStyle.markerSize >= 4)
        verify(KanteStyle.meterHeight >= 3)
        if (data.square) {
            compare(KanteStyle.markerRadius, 0)
            compare(KanteStyle.meterRadius, 0)
            compare(KanteStyle.edgeRadius, 0)
        } else {
            compare(KanteStyle.markerRadius, Math.floor(KanteStyle.markerSize / 2))
            compare(KanteStyle.meterRadius, Math.floor(KanteStyle.meterHeight / 2))
            compare(KanteStyle.edgeRadius, 1)
        }
    }

    function test_sizesFollowTheGridUnit() {
        const gu = Kirigami.Units.gridUnit
        compare(KanteStyle.minuteHeight * 60, gu * 1.5)
        compare(KanteStyle.calendarEntryHeight, gu * 1.1)
        compare(KanteStyle.swatchSize, Math.round(gu * 0.7))
        compare(KanteStyle.markerSize, Math.max(4, Math.round(gu / 4)))
    }

    function test_tintLevelsRise() {
        verify(KanteStyle.washLevel < KanteStyle.fillLevel)
        verify(KanteStyle.fillLevel < KanteStyle.strongFillLevel)
        verify(KanteStyle.strongFillLevel < KanteStyle.edgeLevel)
        verify(KanteStyle.edgeLevel < 1)
        // A tinted colour keeps its hue and takes the level as alpha.
        const c = KanteStyle.tint(KanteStyle.positiveTextColor, KanteStyle.fillLevel)
        fuzzyCompare(c.a, KanteStyle.fillLevel, 0.01)
        fuzzyCompare(c.r, KanteStyle.positiveTextColor.r, 0.01)
    }

    function test_opacities() {
        verify(KanteStyle.dimOpacity > 0 && KanteStyle.dimOpacity < KanteStyle.doneOpacity)
        verify(KanteStyle.doneOpacity < 1)
        compare(KanteStyle.dashPattern.length, 2)
    }
}
