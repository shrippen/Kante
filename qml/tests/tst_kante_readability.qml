import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Readability fixes after the 1.9 review: accent text reads at 4.5:1 on the platform
 * ground even with a dark system accent, empty check boxes have a visible edge, the line
 * chart axis steps on round values, and the dense list row for long navigation lists.
 * Run: kante/tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "KanteReadability"
    width: 400
    height: 300
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_readableLiftsDarkAccent() {
        // The reported case: a dark olive system accent on a dark window ground.
        var ground = Qt.rgba(40 / 255, 40 / 255, 40 / 255, 1)
        var olive = Qt.rgba(97 / 255, 96 / 255, 54 / 255, 1)
        verify(KanteStyle.contrastOf(olive, ground) < 3)
        var fixed = KanteStyle.readable(olive, ground)
        verify(KanteStyle.contrastOf(fixed, ground) >= 4.5, "contrast " + KanteStyle.contrastOf(fixed, ground))
        // A readable colour stays as it is.
        var cyan = Qt.rgba(92 / 255, 207 / 255, 196 / 255, 1)
        compare(KanteStyle.readable(cyan, ground).toString(), Qt.hsla(cyan.hslHue, cyan.hslSaturation, cyan.hslLightness, 1).toString())
    }

    function test_readableDarkensOnLightGround() {
        var ground = Qt.rgba(1, 1, 1, 1)
        var yellow = Qt.rgba(250 / 255, 189 / 255, 47 / 255, 1)
        verify(KanteStyle.contrastOf(KanteStyle.readable(yellow, ground), ground) >= 4.5)
    }

    function test_systemAccentTextReadable() {
        KanteStyle.kind = KanteStyle.Kind.System
        verify(KanteStyle.contrastOf(KanteStyle.accentTextColor, KanteStyle.backgroundColor) >= 4.5)
    }

    Component {
        id: rowComponent
        KanteListRow { text: "Posteingang"; count: "22" }
    }

    function test_denseRowIsLowerThanCompact() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var compact = createTemporaryObject(rowComponent, tc, { density: KanteListRow.Density.Compact })
        var dense = createTemporaryObject(rowComponent, tc, { density: KanteListRow.Density.Dense })
        compare(dense.densityHeight, Math.round(KanteStyle.heightSmall * 0.75))
        verify(dense.implicitHeight < compact.implicitHeight, dense.implicitHeight + " < " + compact.implicitHeight)
    }

    Component {
        id: chartComponent
        KanteLineChart { width: 240; height: 110; series: [[1, 3, 2, 5, 4], [2, 2, 3, 3, 4]]; unit: " h"; axis: true }
    }

    function test_axisStepsOnRoundValues() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var chart = createTemporaryObject(chartComponent, tc)
        // Data up to 5: four steps of 2 (1-2-5 rule), so the top is 8 and every label is whole.
        compare(chart.scaleTop, 8)
    }
}
