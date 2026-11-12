import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Motion of KanteNoteMark (a live mark pulses on a hit, shakes on wrong or missed) and
 * KanteDialog (fades and scales in, fades out), only with KanteStyle.animate.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteMotion"
    width: 600
    height: 500
    when: windowShown

    // KanteStyle is one for all test files: give the next one back what it had.
    property int kindBefore: KanteStyle.Kind.System
    property bool motionBefore: true
    function init() {
        kindBefore = KanteStyle.kind
        motionBefore = KanteStyle.motion
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
        KanteStyle.motion = motionBefore
    }

    Component {
        id: markComponent
        KanteNoteMark { width: 20; height: 20 }
    }
    Component {
        id: createdHitComponent
        KanteNoteMark { width: 20; height: 20; noteState: "hit" }
    }

    // --- Note mark

    function test_hitPulses() {
        verify(KanteStyle.animate, "animation is on")
        const m = createTemporaryObject(markComponent, tc)
        m.noteState = "hit"
        verify(m.moving)
        verify(m.pulse > 1)
        tryCompare(m, "moving", false, 1000)
        compare(m.pulse, 1)
    }

    function test_wrongAndMissedShake() {
        const m = createTemporaryObject(markComponent, tc)
        m.noteState = "wrong"
        verify(m.moving)
        let moved = false
        for (let i = 0; i < 20 && m.moving; ++i) {
            moved = moved || m.shake !== 0
            wait(10)
        }
        verify(moved, "the mark swings sideways")
        tryCompare(m, "moving", false, 1000)
        compare(m.shake, 0)
        compare(m.pulse, 1)

        m.noteState = "missed"
        verify(m.moving)
        tryCompare(m, "moving", false, 1000)
    }

    function test_noLayoutChange() {
        const m = createTemporaryObject(markComponent, tc)
        m.noteState = "hit"
        compare(m.x, 0)
        compare(m.width, 20)
        compare(m.height, 20)
    }

    function test_otherStatesStill() {
        const m = createTemporaryObject(markComponent, tc)
        m.noteState = "early"
        verify(!m.moving)
        m.noteState = "late"
        verify(!m.moving)
    }

    function test_createdStillStays() {
        const m = createTemporaryObject(createdHitComponent, tc)
        verify(!m.moving)
        compare(m.pulse, 1)
        compare(m.shake, 0)
    }

    function test_noMotionWhenOff() {
        KanteStyle.motion = false
        verify(!KanteStyle.animate)
        const m = createTemporaryObject(markComponent, tc)
        m.noteState = "hit"
        verify(!m.moving)
        compare(m.pulse, 1)
        m.noteState = "wrong"
        verify(!m.moving)
        compare(m.shake, 0)
    }

    // --- Lanes: a state set while playing moves the mark; notes built in a state do not

    Component {
        id: tabLaneComponent
        KanteTabLane { width: 600; height: 300; pixelsPerSecond: 100 }
    }
    Component {
        id: keyLaneComponent
        KanteKeyLane { width: 600; height: 300; low: 40; high: 64; pixelsPerSecond: 100 }
    }

    function findAll(item, pred) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (pred(c)) {
                out.push(c)
            }
            out = out.concat(findAll(c, pred))
        }
        return out
    }
    function marksIn(lane) {
        return findAll(lane, c => c.pulse !== undefined && c.moving !== undefined)
    }
    function tabNotes(state) {
        return [{ time: 0.2, duration: 0.3, string: 1, fret: 3, state: state },
                { time: 0.6, duration: 0.3, string: 2, fret: 5, state: state }]
    }
    function keyNotes(state) {
        return [{ time: 0.2, duration: 0.3, midi: 50, state: state },
                { time: 0.6, duration: 0.3, midi: 52, state: state }]
    }

    function laneMarkMoves(component, notes, state) {
        const lane = createTemporaryObject(component, tc, { notes: notes })
        waitForRendering(lane)
        compare(marksIn(lane).length, 0)
        lane.setNoteState(0, state)
        tryVerify(() => marksIn(lane).length === 1, 1000)
        return marksIn(lane)[0]
    }

    function test_tabLaneHitMoves() {
        const m = laneMarkMoves(tabLaneComponent, tabNotes("pending"), "hit")
        verify(m.moving)
        verify(m.pulse > 1)
    }
    function test_tabLaneWrongMoves() {
        verify(laneMarkMoves(tabLaneComponent, tabNotes("pending"), "wrong").moving)
    }
    function test_keyLaneHitMoves() {
        const m = laneMarkMoves(keyLaneComponent, keyNotes("pending"), "hit")
        verify(m.moving)
        verify(m.pulse > 1)
    }
    function test_keyLaneWrongMoves() {
        verify(laneMarkMoves(keyLaneComponent, keyNotes("pending"), "wrong").moving)
    }

    function test_lanesBuiltInStateStill() {
        for (const [component, notes] of [[tabLaneComponent, tabNotes("hit")], [keyLaneComponent, keyNotes("hit")]]) {
            const lane = createTemporaryObject(component, tc, { notes: notes })
            waitForRendering(lane)
            tryVerify(() => marksIn(lane).length === 2, 1000, "marks " + marksIn(lane).length)
            for (const m of marksIn(lane)) {
                verify(!m.moving, component === tabLaneComponent ? "tab" : "key")
                compare(m.pulse, 1)
            }
        }
    }

    function test_laneMotionOffWhenOff() {
        KanteStyle.motion = false
        const m = laneMarkMoves(tabLaneComponent, tabNotes("pending"), "hit")
        verify(!m.moving)
    }

    // --- Dialog

    Component {
        id: dialogComponent
        KanteDialog {
            title: "Title"
            modal: true
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            acceptText: "Add"
            rejectText: "Keep"
            QQC2.Label { text: "Body" }
        }
    }

    Component {
        id: plainComponent
        QQC2.Dialog { }
    }

    Component {
        id: ownComponent
        KanteDialog {
            enter: Transition { NumberAnimation { property: "opacity"; to: 1 } }
        }
    }

    function test_dialogTransitionsWithMotion() {
        const d = createTemporaryObject(dialogComponent, tc)
        verify(d.enter !== null)
        verify(d.exit !== null)
        d.open()
        tryCompare(d, "opened", true, 2000)
        compare(d.opacity, 1)
        compare(d.scale, 1)
        d.close()
        tryCompare(d, "visible", false, 2000)
    }

    function test_dialogStartsFaded() {
        const d = createTemporaryObject(dialogComponent, tc)
        d.open()
        verify(d.opacity < 1, "fading in")
        tryCompare(d, "opacity", 1, 2000)
        d.close()
    }

    function test_dialogInstantWithoutMotion() {
        KanteStyle.motion = false
        const d = createTemporaryObject(dialogComponent, tc)
        let accepted = 0
        d.accepted.connect(() => accepted++)
        d.open()
        tryCompare(d, "opened", true, 2000)
        compare(d.acceptButton().text, "Add")
        compare(d.rejectButton().text, "Keep")
        d.acceptButton().clicked()
        tryCompare(d, "visible", false, 2000)
        compare(accepted, 1)
    }

    // Without animate the style's own transitions stay, not nulled by Kante.
    function test_dialogKeepsStyleTransitions() {
        KanteStyle.kind = KanteStyle.Kind.System
        verify(!KanteStyle.animate)
        const plain = createTemporaryObject(plainComponent, tc)
        const d = createTemporaryObject(dialogComponent, tc)
        compare(d.enter, plain.enter)
        compare(d.exit, plain.exit)
        d.open()
        tryCompare(d, "opened", true, 2000)
        d.close()
        tryCompare(d, "visible", false, 2000)
    }

    function test_dialogKeepsAppTransitions() {
        KanteStyle.motion = false
        const own = createTemporaryObject(ownComponent, tc)
        const ownEnter = own.enter
        verify(ownEnter !== null)
        verify(ownEnter !== own.kanteEnter)
        KanteStyle.motion = false
        compare(own.enter, ownEnter)
        KanteStyle.motion = true
        compare(own.enter, own.kanteEnter)
        KanteStyle.motion = false
        compare(own.enter, ownEnter)
    }

    function test_dialogGivesStyleBack() {
        const d = createTemporaryObject(dialogComponent, tc)
        const plain = createTemporaryObject(plainComponent, tc)
        verify(d.enter !== plain.enter)
        KanteStyle.motion = false
        compare(d.enter, plain.enter)
        compare(d.exit, plain.exit)
    }
}
