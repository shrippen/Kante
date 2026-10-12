import QtQuick
import QtTest
import Kante

/**
 * Kante 1.32, the dead note for Kontra (LH-BEW-06, round 10): technique "dead" draws x in
 * KanteTechniqueMark, and a dead note's fret reads x in KanteTabLane and KanteTabStaff.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante132"
    width: 900
    height: 700
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    Component { id: markComponent; KanteTechniqueMark { height: 20 } }
    Component { id: laneComponent; KanteTabLane { width: 900; height: 200; pixelsPerSecond: 100 } }
    Component { id: staffComponent; KanteTabStaff { width: 900; barsPerSystem: 2; systems: 1 } }
    Component { id: bassComponent; KanteBassStaff { width: 900; barsPerSystem: 2; systems: 1 } }

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
    function marksIn(item) {
        return findAll(item, function (c) { return c.technique !== undefined && c.sign !== undefined })
    }

    // E1, a dead note on the A string at fret 7, a ghost note on D at fret 5.
    function tabNotes() {
        return [
            { time: 0, duration: 0.5, beats: 1, string: 0, fret: 0, midi: 28 },
            { time: 0.5, duration: 0.5, beats: 1, string: 1, fret: 7, midi: 40, technique: "dead", techniqueResult: "played" },
            { time: 1, duration: 0.5, beats: 1, string: 2, fret: 5, midi: 43, technique: "ghost" }
        ]
    }

    function test_deadMark() {
        var m = createTemporaryObject(markComponent, stage(), { technique: "dead" })
        compare(m.sign, "x")
        verify(m.drawn && m.visible)
        compare(KanteStyle.techniqueName("dead"), "Dead Note")
        compare(m.Accessible.name, "Dead Note")
        m.result = "unheard"
        verify(m.framed && m.struck, "results as for every technique")
    }

    function test_laneDeadFret() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: tabNotes(), position: 0.5 })
        waitForRendering(l)
        // The fret reads x; the mark has its own x (not counted).
        tryVerify(function () { return findAll(l, function (c) { return c.text === "x" && c.parent && c.parent.sign === undefined }).length === 1 }, 3000)
        compare(findAll(l, function (c) { return c.text === "7" }).length, 0, "no fret number for a dead note")
        compare(findAll(l, function (c) { return c.text === "(5)" }).length, 1, "ghost unchanged")
        compare(marksIn(l).filter(function (m) { return m.technique === "dead" })[0].result, "played")
    }

    function test_staffDeadFret() {
        var s = createTemporaryObject(staffComponent, stage(), { notes: tabNotes(), bars: [0, 2] })
        waitForRendering(s)
        compare(s.layout.frets.filter(function (f) { return f.text === "x" }).length, 1)
        compare(s.layout.frets.filter(function (f) { return f.text === "7" }).length, 0)
        compare(marksIn(s).filter(function (m) { return m.drawn }).length, 2)
    }

    function test_bassStaffDeadSign() {
        var s = createTemporaryObject(bassComponent, stage(), { notes: tabNotes(), bars: [{ time: 0 }, { time: 2 }] })
        waitForRendering(s)
        compare(s.layout.techniques.length, 2)
        compare(marksIn(s).filter(function (m) { return m.technique === "dead" })[0].sign, "x")
    }
}
