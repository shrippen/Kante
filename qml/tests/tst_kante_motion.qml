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
        compare(d.enter, null)
        compare(d.exit, null)

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

    function test_dialogSystemStyleStill() {
        KanteStyle.kind = KanteStyle.Kind.System
        const d = createTemporaryObject(dialogComponent, tc)
        compare(d.enter, null)
        d.open()
        tryCompare(d, "opened", true, 2000)
        d.close()
        tryCompare(d, "visible", false, 2000)
    }
}
