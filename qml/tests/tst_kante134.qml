import QtQuick
import QtTest
import Kante

/**
 * Kante 1.34, the loop range in tablature and bass staff (Kontra's workshop mode loops bars
 * 3 and 4): loopStart / loopEnd as on KanteTabLane, one part per line with bracket edges
 * where the loop starts and ends. Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante134"
    width: 900
    height: 700
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    // Three bars per line, two lines: bars 3 and 4 (2.4 s to 4.8 s) cross the line break.
    Component { id: tabComponent; KanteTabStaff { width: 900; barsPerSystem: 3; systems: 2 } }
    Component { id: bassComponent; KanteBassStaff { width: 900; barsPerSystem: 3; systems: 2 } }

    // A quarter is 0.3 s, four per bar: bars of 1.2 s.
    function notes() {
        var out = []
        for (var i = 0; i < 24; i++) {
            out.push({ time: i * 0.3, duration: 0.3, beats: 1, string: i % 4, fret: i % 5, midi: 40 + (i % 5) })
        }
        return out
    }
    function bars() {
        return [0, 1.2, 2.4, 3.6, 4.8, 6.0]
    }
    function barLeft(s, b) {
        return s.headerWidth + (b % 3) * s.barWidth
    }

    function checkAcrossLines(s) {
        var p = s.loopParts
        compare(p.length, 2, "one part per line")
        compare(p[0].sys, 0)
        compare(p[1].sys, 1)
        verify(p[0].left && !p[0].right, "starts on the first line, runs on")
        verify(!p[1].left && p[1].right, "goes on without bracket, ends on the second line")
        // Edges on the bar lines: bar 3 is the last of line 1, bar 4 the first of line 2.
        fuzzyCompare(p[0].x, barLeft(s, 2), 0.5)
        fuzzyCompare(p[0].x + p[0].w, barLeft(s, 2) + s.barWidth, 0.5)
        fuzzyCompare(p[1].x, barLeft(s, 3), 0.5)
        fuzzyCompare(p[1].x + p[1].w, barLeft(s, 3) + s.barWidth, 0.5)
    }

    function test_tabAcrossLines() {
        var s = createTemporaryObject(tabComponent, stage(), { notes: notes(), bars: bars(), loopStart: 2.4, loopEnd: 4.8 })
        waitForRendering(s)
        checkAcrossLines(s)
    }

    function test_bassAcrossLines() {
        var s = createTemporaryObject(bassComponent, stage(), { notes: notes(), bars: bars(), loopStart: 2.4, loopEnd: 4.8 })
        waitForRendering(s)
        checkAcrossLines(s)
    }

    function test_noneAndInvalid() {
        var s = createTemporaryObject(tabComponent, stage(), { notes: notes(), bars: bars() })
        compare(s.loopParts.length, 0, "default -1: no loop")
        s.loopStart = 3
        s.loopEnd = 2
        compare(s.loopParts.length, 0, "end before start: no loop")
        var b = createTemporaryObject(bassComponent, stage(), { notes: notes(), bars: bars(), loopStart: 1, loopEnd: -1 })
        compare(b.loopParts.length, 0)
    }

    function test_insideBar() {
        // From the second beat of bar 1 to the third of bar 2: both edges inside a bar, on one line.
        var s = createTemporaryObject(tabComponent, stage(), { notes: notes(), bars: bars(), loopStart: 0.3, loopEnd: 1.8 })
        var p = s.loopParts
        compare(p.length, 1)
        verify(p[0].left && p[0].right)
        fuzzyCompare(p[0].x, s.xOf(0.3, 0), 0.5)
        fuzzyCompare(p[0].x + p[0].w, s.xOf(1.8, 1), 0.5)
    }

    function test_offPage() {
        // The page shows bars 1 to 6; a loop after it leaves no part.
        var s = createTemporaryObject(tabComponent, stage(), { notes: notes(), bars: bars(), loopStart: 8, loopEnd: 9 })
        compare(s.loopParts.length, 0)
    }

    function test_fretGroundTinted() {
        // Frets in the loop keep a ground that carries the tint, so the loop reads behind them.
        var s = createTemporaryObject(tabComponent, stage(), { notes: notes(), bars: bars(), loopStart: 2.4, loopEnd: 4.8, position: 0.6 })
        waitForRendering(s)
        verify(s.inLoop(2.4) && s.inLoop(4.5) && !s.inLoop(4.8) && !s.inLoop(2.1))
    }
}
