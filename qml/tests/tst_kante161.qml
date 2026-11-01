import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.61, from Mitori: KanteStyle.levelColor, KanteLegend, tooltips on KanteProgressBar parts.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante161"
    width: 800
    height: 600
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }
    function stage() {
        return tc.Window.contentItem
    }

    function test_levelColorScale() {
        compare(KanteStyle.levelColor(0), KanteStyle.sunkenColor)
        compare(KanteStyle.levelColor(4), KanteStyle.focusColor)
        compare(KanteStyle.levelColor(9), KanteStyle.focusColor, "above the top: full")
        var steps = [1, 2, 3].map(l => KanteStyle.levelColor(l).a)
        verify(steps[0] < steps[1] && steps[1] < steps[2] && steps[2] < 1, "even steps up: " + steps)
        fuzzyCompare(steps[0], 0.22, 0.005)
        compare(KanteStyle.levelColor(1, 2, KanteStyle.accentColor).r, KanteStyle.accentColor.r)
        fuzzyCompare(KanteStyle.levelColor(1, 2, KanteStyle.accentColor).a, 0.44, 0.005)
    }

    Component {
        id: heatComponent
        KanteHeatmap { levels: [0, 1, 2, 3, 4] }
    }
    function test_heatmapUsesTheScale() {
        var heat = createTemporaryObject(heatComponent, stage())
        for (var l = 1; l <= 4; l++) {
            compare(heat.levelColor(l), KanteStyle.levelColor(l))
        }
    }

    Component {
        id: legendComponent
        KanteLegend {
            width: 400
            model: [{ color: KanteStyle.levelColor(4), text: "exam-ready", value: 3 },
                    { color: KanteStyle.levelColor(1), text: "seen" },
                    { color: KanteStyle.levelColor(0), text: "not rated", value: 12 }]
        }
    }
    function items(legend) {
        var list = []
        for (var i = 0; i < legend.children.length; i++) {
            if (legend.children[i].words !== undefined) {
                list.push(legend.children[i])
            }
        }
        return list
    }
    function test_legendItems() {
        var legend = createTemporaryObject(legendComponent, stage())
        var it = items(legend)
        compare(it.length, 3)
        compare(it[0].Accessible.name, "3 exam-ready")
        compare(it[1].Accessible.name, "seen")
        compare(it[0].children[0].color, KanteStyle.levelColor(4))
        compare(it[0].children[0].radius, 0, "square key in Kante")
        KanteStyle.kind = KanteStyle.Kind.System
        verify(it[0].children[0].radius > 0, "round key in System")
    }
    function test_legendWraps() {
        var legend = createTemporaryObject(legendComponent, stage(), { width: 60 })
        var it = items(legend)
        verify(it[1].y > it[0].y, "narrow: one item per line")
    }

    Component {
        id: partsComponent
        KanteProgressBar {
            width: 400
            parts: [{ value: 0.5, color: KanteStyle.levelColor(3), text: "5 sure" },
                    { value: 0.2, color: KanteStyle.levelColor(1) }]
        }
    }
    function test_partTooltipAndName() {
        var bar = createTemporaryObject(partsComponent, stage())
        var row = null
        var stack = [bar]
        while (stack.length && !row) {
            var item = stack.pop()
            for (var i = 0; i < item.children.length; i++) {
                if (item.children[i].tip !== undefined) {
                    row = item
                    break
                }
                stack.push(item.children[i])
            }
        }
        verify(row !== null)
        var first = row.children[0], second = row.children[1]
        compare(first.Accessible.name, "5 sure")
        verify(!first.Accessible.ignored)
        verify(second.Accessible.ignored, "a part without text is not announced")
        mouseMove(first, 10, 4)
        tryVerify(() => first.QQC2.ToolTip.visible, 2000, "hover shows the tooltip")
        compare(first.QQC2.ToolTip.text, "5 sure")
    }
}
