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
        compare(KanteStyle.levelColor(NaN), KanteStyle.sunkenColor, "no number: the ground")
        compare(KanteStyle.levelColor(undefined), KanteStyle.sunkenColor)
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
        compare(it[0].children[0].width, KanteStyle.swatchSize)
        // The model reads style colours: a new style makes new items.
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        compare(items(legend)[0].children[0].radius > 0, KanteStyle.markerRadius > 0, "the key's shape as markerRadius")
        KanteStyle.kind = KanteStyle.Kind.System
        verify(items(legend)[0].children[0].radius > 0, "round key in System")
    }
    function test_legendWraps() {
        var legend = createTemporaryObject(legendComponent, stage(), { width: 60 })
        var it = items(legend)
        verify(it[1].y > it[0].y, "narrow: one item per line")
        var long = createTemporaryObject(legendComponent, stage(), { width: 80, model: [{ color: "red", text: "a rather long word for a narrow legend" }] })
        verify(long.childrenRect.width <= 80.5, "a long word wraps inside (" + long.childrenRect.width + ")")
    }

    // Mitori's heatmap legend on a 360 px phone: four keys on the first line, "10 and more" alone
    // on the second. Wrapped lines are balanced instead (here 2 + 3: the first two words are long).
    Component {
        id: fiveComponent
        KanteLegend {
            model: [{ color: KanteStyle.levelColor(0), text: "no practice" },
                    { color: KanteStyle.levelColor(1), text: "1–2 techniques" },
                    { color: KanteStyle.levelColor(2), text: "3–5" },
                    { color: KanteStyle.levelColor(3), text: "6–9" },
                    { color: KanteStyle.levelColor(4), text: "10 and more" }]
        }
    }
    function lineCounts(list) {
        var counts = {}
        for (var i = 0; i < list.length; i++) {
            counts[list[i].y] = (counts[list[i].y] || 0) + 1
        }
        return Object.keys(counts).sort((a, b) => a - b).map(y => counts[y])
    }
    function test_legendBalancesLines() {
        var probe = createTemporaryObject(fiveComponent, stage(), { width: 2000 })
        var it = items(probe)
        var four = it[3].x + it[3].width
        var legend = createTemporaryObject(fiveComponent, stage(), { width: four + 2 })
        var counts = lineCounts(items(legend))
        compare(counts.length, 2, "no more lines: " + counts)
        verify(counts[1] > 1, "no item alone on the last line: " + counts)
        legend.width = 2000
        legend.forceLayout()
        compare(lineCounts(items(legend)), [5], "wide: one line")
        legend.width = 60
        legend.forceLayout()
        compare(lineCounts(items(legend)), [1, 1, 1, 1, 1], "narrow: one item per line")
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
