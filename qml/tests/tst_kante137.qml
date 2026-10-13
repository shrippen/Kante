import QtQuick
import QtTest
import Kante

/**
 * Kante 1.37, a ghost note in tab (Kontra, round 11, finding F8): only the fret in parentheses,
 * as printed tab has it; no second sign "( )" above it. A result frames the parenthesized fret.
 * Other techniques keep their sign. Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante137"
    width: 900
    height: 500
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function notes() {
        return [
            { time: 0, duration: 0.5, beats: 1, string: 0, fret: 3, midi: 31, technique: "ghost" },
            { time: 0.5, duration: 0.5, beats: 1, string: 0, fret: 5, midi: 33, technique: "hammer" }
        ]
    }

    Component { id: staffComponent; KanteTabStaff { width: 900; barsPerSystem: 1; systems: 1 } }
    Component { id: laneComponent; KanteTabLane { width: 900; height: 200; pixelsPerSecond: 100 } }

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
    function drawnTechniques(item) {
        return marksIn(item).filter(function (m) { return m.drawn }).map(function (m) { return m.technique })
    }

    function test_staff() {
        var s = createTemporaryObject(staffComponent, stage(), { notes: notes(), bars: [0] })
        waitForRendering(s)
        compare(drawnTechniques(s), ["hammer"])
        compare(s.layout.frets.filter(function (f) { return f.text === "(3)" }).length, 1)

        // With a result the ghost's mark frames the parenthesized fret, without a sign of its own.
        s.setTechniqueResult(0, "played")
        var ghost = marksIn(s).filter(function (m) { return m.technique === "ghost" })[0]
        verify(ghost.drawn && ghost.framed && !ghost.signVisible)
        compare(ghost.width, ghost.parent.width)
        compare(ghost.x, 0)
    }

    function test_lane() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: notes(), position: 0.2 })
        waitForRendering(l)
        tryVerify(function () { return drawnTechniques(l).length === 1 }, 3000)
        compare(drawnTechniques(l), ["hammer"])
        compare(findAll(l, function (c) { return c.text === "(3)" }).length, 1)
        l.setTechniqueResult(0, "unheard")
        tryVerify(function () { return drawnTechniques(l).indexOf("ghost") >= 0 }, 3000)
    }
}
