import QtQuick
import QtTest
import Kante

/**
 * Kante 1.41, a target band in the timing histogram (Kontra, DIDAKTIK I5): an aim such as
 * laid-back (+10 to +30 ms) shows as a tinted range with dashed edges and a label, so the
 * player sees whether the bars sit inside it; not by colour alone. KanteBarChart draws any
 * `ranges` [{from, to, label}] in columns. Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante141"
    width: 600
    height: 300
    when: windowShown

    Component { id: histComponent; KanteTimingHistogram { width: 500; height: 220 } }

    function findAll(item, pred) {
        var out = []
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (pred(c)) {
                out.push(c)
            }
            out = out.concat(findAll(c, pred))
        }
        return out
    }

    function test_bandInColumns() {
        var h = createTemporaryObject(histComponent, tc.Window.contentItem, {
            counts: [1, 3, 7, 4, 2, 1], firstBinMs: -30, binMs: 10, meanMs: 4,
            bandMinMs: 10, bandMaxMs: 30, bandText: "Ziel"
        })
        var r = h.rangeList()
        compare(r.length, 1)
        compare(r[0].from, 4)
        compare(r[0].to, 6)
        compare(r[0].label, "Ziel +10…+30 ms")
        compare(h.chart.ranges.length, 1)
        verify(h.Accessible.description.indexOf("Ziel +10…+30 ms") > 0, h.Accessible.description)

        var bands = findAll(h.chart, function (c) { return c.objectName === "kanteRange" && c.visible })
        compare(bands.length, 1)
        verify(Math.abs(bands[0].width - 2 * h.chart.columnWidth) < 1)
    }

    function test_bandOutsideIsClipped() {
        var h = createTemporaryObject(histComponent, tc, {
            counts: [1, 2, 1], firstBinMs: -15, binMs: 10, bandMinMs: -30, bandMaxMs: -10
        })
        var r = h.rangeList()
        compare(r[0].from, 0)
        verify(Math.abs(r[0].to - 0.5) < 1e-9)
    }

    function test_bandBeyondTheBinsHidesItsLabel() {
        var h = createTemporaryObject(histComponent, tc.Window.contentItem, {
            counts: [1, 2, 1], firstBinMs: -15, binMs: 10, bandMinMs: 40, bandMaxMs: 60
        })
        var shown = findAll(h.chart, function (c) {
            return (c.objectName === "kanteRange" || c.objectName === "kanteRangeLabel") && c.visible
        })
        compare(shown.length, 0)
    }

    function test_swappedBoundsLabelInOrder() {
        var h = createTemporaryObject(histComponent, tc, { counts: [1, 2, 1], firstBinMs: -15, binMs: 10, bandMinMs: 30, bandMaxMs: 10 })
        compare(h.bandLabel(), "Ziel +10…+30 ms")
    }

    function test_noBand() {
        var h = createTemporaryObject(histComponent, tc, { counts: [1, 2, 1], firstBinMs: -15, binMs: 10 })
        compare(h.rangeList().length, 0)
        compare(h.chart.ranges.length, 0)
    }
}
