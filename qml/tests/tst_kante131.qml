import QtQuick
import QtTest
import Kante

/**
 * Kante 1.31, technique marks for Kontra (LH-BEW-06): KanteTechniqueMark, the names in
 * KanteStyle, and `technique` / `techniqueResult` in KanteTabLane, KanteTabStaff and
 * KanteBassStaff. Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante131"
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

    // E1 slide → G1, A1 hammer-on, D2 slap, a ghost on G2: the tab lane's and staff's notes.
    function tabNotes() {
        return [
            { time: 0, duration: 0.5, beats: 1, string: 0, fret: 0, midi: 28 },
            { time: 0.5, duration: 0.5, beats: 1, string: 0, fret: 3, midi: 31, technique: "slide" },
            { time: 1, duration: 0.5, beats: 1, string: 1, fret: 0, midi: 33, technique: "hammer" },
            { time: 1.5, duration: 0.5, beats: 1, string: 2, fret: 0, midi: 38, technique: "slap", techniqueResult: "played" },
            { time: 2, duration: 0.5, beats: 1, string: 3, fret: 5, midi: 48, technique: "ghost" }
        ]
    }

    function test_names() {
        compare(KanteStyle.techniqueName("hammer"), "Hammer-on")
        compare(KanteStyle.techniqueName("ghost"), "Ghost Note")
        compare(KanteStyle.techniqueName("tapping"), "", "unknown key")
        compare(KanteStyle.techniqueResultName("unheard"), "Technik nicht gehört")
        compare(KanteStyle.techniqueResultName(""), "")
        compare(KanteStyle.techniqueCountsText({ played: 3, other: 1 }), "Technik gespielt 3, Andere Technik 1")
        compare(KanteStyle.techniqueCountsText({}), "")
    }

    function test_markSigns() {
        var m = createTemporaryObject(markComponent, stage(), { technique: "slap" })
        compare(m.sign, "S")
        verify(m.drawn && m.visible)
        verify(!m.framed && !m.struck, "no result: the sign alone")
        compare(m.Accessible.name, "Slap")
        var signs = { slide: "sl", hammer: "h", pull: "p", slap: "S", pop: "P", ghost: "( )" }
        for (var k in signs) {
            m.technique = k
            compare(m.sign, signs[k], k)
        }
        m.technique = "bend"
        verify(!m.drawn && !m.visible, "unknown technique draws nothing")
    }

    function test_markResultsByShape() {
        var m = createTemporaryObject(markComponent, stage(), { technique: "hammer", result: "played" })
        verify(m.framed && !m.struck)
        compare(m.color, KanteStyle.noteStateColor("hit"))
        compare(m.Accessible.name, "Hammer-on, Technik gespielt")
        m.result = "other"
        verify(m.framed && m.struck, "other: frame and strike")
        compare(m.color, KanteStyle.noteStateColor("wrong"))
        m.result = "unheard"
        verify(m.framed && m.struck)
        compare(m.color, KanteStyle.noteStateColor("missed"))
        // Wider signs make the mark wider, never narrower than high.
        m.technique = "ghost"
        verify(m.implicitWidth > m.height)
        m.technique = "hammer"
        verify(m.implicitWidth >= m.height)
    }

    function test_laneTechniques() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: tabNotes(), position: 0.5 })
        waitForRendering(l)
        // 1.37: the ghost note's parentheses are its sign; without a result it draws no mark.
        tryVerify(function () { return marksIn(l).filter(function (m) { return m.drawn }).length >= 3 }, 3000)
        compare(l.techniqueResultOf(3), "played", "from notes")
        compare(l.techniqueResultOf(1), "")
        verify(l.Accessible.description.indexOf("Technik gespielt 1") >= 0, l.Accessible.description)
        l.setTechniqueResult(1, "other")
        l.setTechniqueResult(2, "unheard")
        compare(l.techniqueResultOf(1), "other")
        var slide = marksIn(l).filter(function (m) { return m.technique === "slide" })[0]
        compare(slide.result, "other", "only that note's sign changed")
        verify(l.Accessible.description.indexOf("Andere Technik 1") >= 0, l.Accessible.description)
        l.setTechniqueResult(1, "played")
        verify(l.Accessible.description.indexOf("Technik gespielt 2") >= 0, l.Accessible.description)
        l.resetStates()
        compare(l.techniqueResultOf(1), "")
        compare(l.techniqueResultOf(3), "played", "back to notes")
        compare(slide.result, "")
        // A ghost note shows its fret in parentheses.
        var ghost = findAll(l, function (c) { return c.text === "(5)" })
        verify(ghost.length === 1, "ghost fret: " + ghost.length)
        l.marks = KanteTabLane.Marks.Off
        compare(marksIn(l).filter(function (m) { return m.technique === "slap" })[0].result, "", "Off: sign without result")
    }

    function test_staffTechniques() {
        var s = createTemporaryObject(staffComponent, stage(), { notes: tabNotes(), bars: [0, 2] })
        waitForRendering(s)
        var ms = marksIn(s).filter(function (m) { return m.drawn })
        compare(ms.length, 3, "1.37: no mark for the ghost note without a result")
        compare(s.layout.frets.filter(function (f) { return f.text === "(5)" }).length, 1, "ghost in parentheses")
        s.setTechniqueResult(2, "other")
        compare(marksIn(s).filter(function (m) { return m.technique === "hammer" })[0].result, "other")
        verify(s.Accessible.description.indexOf("Andere Technik 1") >= 0, s.Accessible.description)
        s.resetStates()
        compare(s.techniqueResultOf(2), "")
        s.marks = KanteTabStaff.Marks.Quiet
        var slap = marksIn(s).filter(function (m) { return m.technique === "slap" })[0]
        compare(slap.result, "played", "Quiet keeps the result shape")
        compare(slap.color, KanteStyle.mutedTextColor)
    }

    function test_bassStaffTechniques() {
        var s = createTemporaryObject(bassComponent, stage(), { notes: tabNotes(), bars: [{ time: 0 }, { time: 2 }] })
        waitForRendering(s)
        compare(s.layout.techniques.length, 4)
        s.setTechniqueResult(4, "unheard")
        compare(marksIn(s).filter(function (m) { return m.technique === "ghost" })[0].result, "unheard")
        verify(s.Accessible.description.indexOf("Technik nicht gehört 1") >= 0, s.Accessible.description)
        s.marks = KanteBassStaff.Marks.Off
        verify(s.Accessible.description.indexOf("Technik") < 0, "Off: no results")
    }
}
