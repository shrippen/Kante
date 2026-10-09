import QtQuick
import QtTest
import Kante

/**
 * Kante 1.24: note states without a new list (setNoteState, resetStates) on the tab lane
 * and both staffs, the Quiet and Off marks for a play mode, and the small font that is
 * never larger than the default font (KanteSettingRow hint vs title).
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante124"
    width: 1000
    height: 700
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function notes(count, step) {
        var n = []
        for (var i = 0; i < count; i++) {
            n.push({ time: i * step, duration: step * 0.8, beats: 0.5, midi: 40 + i % 12, string: i % 4, fret: i % 12, state: "pending" })
        }
        return n
    }
    function noteItems(lane) {
        var out = []
        function walk(item) {
            for (var i = 0; i < item.children.length; i++) {
                var c = item.children[i]
                if (c.st !== undefined && c.n !== undefined) out.push(c)
                else walk(c)
            }
        }
        walk(lane)
        return out
    }

    Component {
        id: laneComponent
        KanteTabLane { width: 1000; height: 200; pixelsPerSecond: 125 }
    }

    function test_laneSetNoteState() {
        var lane = createTemporaryObject(laneComponent, tc, { notes: notes(40, 0.25), position: 2 })
        var items = noteItems(lane)
        lane.setNoteState(5, "hit")
        compare(items[5].st, "hit")
        compare(items[4].st, "pending")
        compare(lane.stateOf(5), "hit")
        verify(lane.Accessible.description.indexOf("Getroffen 1") >= 0, lane.Accessible.description)
        lane.setNoteState(6, "missed")
        verify(items[6].hollow)
        lane.resetStates()
        compare(items[5].st, "pending")
        // A new list starts without the states set before.
        lane.setNoteState(3, "wrong")
        var again = notes(40, 0.25)
        again[1].state = "late"
        lane.notes = again
        items = noteItems(lane)
        compare(items[3].st, "pending")
        compare(items[1].st, "late")
        lane.setNoteState(-1, "hit")
        lane.setNoteState(99, "hit")
    }

    // One call touches one note: compare with reassigning the whole list.
    function test_laneSetNoteStateIsCheap() {
        var list = notes(3000, 0.04)
        var lane = createTemporaryObject(laneComponent, tc, { notes: list, position: 20 })
        var calls = 1000
        var t0 = Date.now()
        for (var i = 0; i < calls; i++) {
            lane.setNoteState(500 + i, i % 2 ? "hit" : "wrong")
        }
        var perCall = (Date.now() - t0) / calls
        var t1 = Date.now()
        lane.notes = list.slice()
        var reassign = Date.now() - t1
        console.log("setNoteState " + perCall.toFixed(3) + " ms per call, reassigning 3000 notes " + reassign + " ms")
        verify(perCall < 0.5, "per call " + perCall + " ms")
    }

    function test_laneMarks() {
        var list = notes(4, 0.25)
        list[0].state = "hit"
        list[1].state = "wrong"
        list[2].state = "missed"
        var lane = createTemporaryObject(laneComponent, tc, { notes: list, position: 0 })
        var items = noteItems(lane)
        compare(String(items[0].fill), String(KanteStyle.noteStateColor("hit")))
        lane.marks = KanteTabLane.Marks.Quiet
        // Quiet: the string colour stays, the state is still there (shown by a small sign).
        compare(String(items[0].fill), String(lane.stringColor(items[0].str)))
        compare(items[1].st, "wrong")
        verify(!items[2].hollow, "quiet missed keeps its fill; the sign shows it")
        lane.marks = KanteTabLane.Marks.Off
        compare(items[0].st, "pending")
        compare(items[1].st, "pending")
    }

    Component {
        id: tabComponent
        KanteTabStaff { width: 900; barsPerSystem: 2 }
    }

    function test_tabStaffStates() {
        var s = createTemporaryObject(tabComponent, tc, { notes: notes(16, 0.5), bars: [0, 2, 4, 6], position: 0.1 })
        var layout = s.layout
        s.setNoteState(2, "late")
        verify(s.layout === layout, "no new layout for a state")
        compare(s.shownState(2, s.stateRevision), "late")
        s.marks = KanteTabStaff.Marks.Off
        compare(s.shownState(2, s.stateRevision), "pending")
        s.marks = KanteTabStaff.Marks.Full
        s.resetStates()
        compare(s.shownState(2, s.stateRevision), "pending")
    }

    Component {
        id: bassComponent
        KanteBassStaff { width: 900; barsPerSystem: 2 }
    }

    function test_bassStaffStates() {
        var s = createTemporaryObject(bassComponent, tc, { notes: notes(8, 0.5), position: 0.1 })
        var layout = s.layout
        s.setNoteState(1, "wrong")
        verify(s.layout === layout)
        compare(String(s.inkColor("note", 1, s.stateRevision)), String(KanteStyle.noteStateColor("wrong")))
        s.marks = KanteBassStaff.Marks.Quiet
        compare(String(s.inkColor("note", 1, s.stateRevision)), String(KanteStyle.textColor))
        compare(s.shownState(1, s.stateRevision), "wrong", "quiet keeps the state for the sign")
    }

    // A staff re-colours its page (a few hundred parts) per call, still far below a frame.
    function test_staffSetNoteStateCost() {
        var s = createTemporaryObject(bassComponent, tc, { notes: notes(400, 0.25), barsPerSystem: 4, systems: 2, position: 0.1 })
        var t0 = Date.now()
        for (var i = 0; i < 200; i++) {
            s.setNoteState(i % 32, i % 2 ? "hit" : "late")
        }
        var perCall = (Date.now() - t0) / 200
        console.log("KanteBassStaff.setNoteState " + perCall.toFixed(3) + " ms per call (32 notes on the page)")
        verify(perCall < 4, "per call " + perCall + " ms")
    }

    function test_smallFontNotLargerThanDefault() {
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            verify(KanteStyle.fontPixels(KanteStyle.smallFont) <= KanteStyle.fontPixels(KanteStyle.defaultFont))
        }
    }

    Component {
        id: rowComponent
        KanteSettingRow { width: 600; title: "Schwelle"; hint: "Ab hier dreht der Lüfter hoch." }
    }

    function test_settingRowHintBelowTitle() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var r = createTemporaryObject(rowComponent, tc)
        var texts = []
        function walk(item) {
            for (var i = 0; i < item.children.length; i++) {
                var c = item.children[i]
                if (c.text === "Schwelle" || c.text === "Ab hier dreht der Lüfter hoch.") texts.push(c)
                walk(c)
            }
        }
        walk(r)
        compare(texts.length, 2)
        var title = texts[0].text === "Schwelle" ? texts[0] : texts[1]
        var hint = title === texts[0] ? texts[1] : texts[0]
        verify(KanteStyle.fontPixels(hint.font) <= KanteStyle.fontPixels(title.font),
               "hint " + KanteStyle.fontPixels(hint.font) + " px, title " + KanteStyle.fontPixels(title.font) + " px")
    }
}
