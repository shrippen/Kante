import QtQuick
import QtTest
import Kante

/**
 * The note state all four note views share: KanteBassStaff, KanteTabStaff, KanteTabLane and
 * KanteKeyLane keep states, cents and technique results set with setNoteState /
 * setTechniqueResult apart from `notes`. Same checks on each.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteNoteState"
    width: 1000
    height: 700
    when: windowShown

    function notes(count) {
        const n = []
        for (let i = 0; i < count; i++) {
            n.push({ time: i * 0.5, beats: 1, midi: 40 + i % 12, string: i % 4, fret: i % 12, state: "pending" })
        }
        return n
    }

    Component { id: bass; KanteBassStaff { width: 900; height: 300 } }
    Component { id: tab; KanteTabStaff { width: 900; height: 300 } }
    Component { id: tabLane; KanteTabLane { width: 900; height: 200 } }
    Component { id: keyLane; KanteKeyLane { width: 900; height: 200 } }

    function views() {
        return [bass, tab, tabLane, keyLane].map(function (c) {
            return createTemporaryObject(c, tc, { notes: notes(8) })
        })
    }

    function test_stateAndReset() {
        for (const v of views()) {
            compare(v.stateOf(2), "pending", v)
            const r = v.stateRevision
            v.setNoteState(2, "hit")
            compare(v.stateOf(2), "hit", v)
            compare(v.stateOf(3), "pending", v)
            verify(v.stateRevision > r, "revision counts the change")
            v.resetStates()
            compare(v.stateOf(2), "pending", v)
        }
    }

    function test_centsAndRange() {
        for (const v of views()) {
            verify(isNaN(v.centsOf(1)), v)
            v.setNoteState(1, "offpitch", 32)
            compare(v.centsOf(1), 32, v)
            v.setNoteState(1, "wrong")
            compare(v.centsOf(1), 32, "cents stay when none is given")
            const r = v.stateRevision
            v.setNoteState(-1, "hit")
            v.setNoteState(99, "hit")
            compare(v.stateRevision, r, "out of range changes nothing")
            v.resetStates()
            verify(isNaN(v.centsOf(1)), v)
        }
    }

    function test_newNotesStartClean() {
        for (const v of views()) {
            v.setNoteState(3, "wrong")
            const again = notes(8)
            again[1].state = "late"
            v.notes = again
            compare(v.stateOf(3), "pending", v)
            compare(v.stateOf(1), "late", v)
        }
    }

    function test_summaryCountsStates() {
        for (const v of [createTemporaryObject(tabLane, tc, { notes: notes(8) }),
                         createTemporaryObject(keyLane, tc, { notes: notes(8) })]) {
            v.setNoteState(0, "hit")
            v.setNoteState(1, "hit")
            v.setNoteState(1, "missed")
            verify(v.Accessible.description.indexOf("Getroffen 1") >= 0, v.Accessible.description)
            verify(v.Accessible.description.indexOf("Verpasst 1") >= 0, v.Accessible.description)
            v.resetStates()
            verify(v.Accessible.description.indexOf("Getroffen") < 0, v.Accessible.description)
        }
    }

    function test_techniqueResult() {
        for (const v of [createTemporaryObject(bass, tc, { notes: notes(8) }),
                         createTemporaryObject(tab, tc, { notes: notes(8) }),
                         createTemporaryObject(tabLane, tc, { notes: notes(8) })]) {
            compare(v.techniqueResultOf(4), "", v)
            v.setTechniqueResult(4, "played")
            compare(v.techniqueResultOf(4), "played", v)
            v.setTechniqueResult(99, "played")
            v.resetStates()
            compare(v.techniqueResultOf(4), "", v)
        }
    }

    Component { id: stateComp; KanteNoteState {} }

    function test_shownWhenHidden() {
        const st = createTemporaryObject(stateComp, tc, { notes: [{ time: 0, state: "offpitch", cents: 32, techniqueResult: "played" }] })
        compare(st.shownState(0, st.revision), "offpitch")
        compare(st.shownState(undefined, st.revision), "pending")
        compare(st.centsSuffix(0, st.revision), ", +32 ct")
        compare(st.shownTechniqueResult(0, st.revision), "played")
        verify(st.techniqueSummary(st.revision) !== "")

        st.hidden = true
        compare(st.shownState(0, st.revision), "pending")
        compare(st.centsSuffix(0, st.revision), "")
        compare(st.shownTechniqueResult(0, st.revision), "")
        compare(st.techniqueSummary(st.revision), "")
    }
}
