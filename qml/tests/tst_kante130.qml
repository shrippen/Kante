import QtQuick
import QtTest
import Kante

/**
 * Kante 1.30, the keyboard view for Kontra's bass over MIDI: KanteKeyLayout (geometry and
 * names), KanteKeyboard (keys and markers, optional keyboard use) and KanteKeyLane
 * (falling notes over the keys). Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante130"
    width: 900
    height: 700
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    readonly property var kinds: [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]

    Component { id: layoutComponent; KanteKeyLayout { low: 28; high: 67; width: 690 } }
    Component { id: spyComponent; SignalSpy {} }

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

    // ── Layout ───────────────────────────────────────────────────────
    function test_layoutProportions() {
        var k = createTemporaryObject(layoutComponent, tc)
        // E1..G4: 24 white keys.
        compare(k.count, 40)
        fuzzyCompare(k.whiteWidth, 690 / 24, 1e-6)
        compare(k.x(28), 0)
        fuzzyCompare(k.x(67) + k.keyWidth(67), 690, 1e-6)
        verify(k.isBlack(30) && !k.isBlack(28) && !k.isBlack(29))
        fuzzyCompare(k.keyWidth(30), k.whiteWidth * 0.58, 1e-6)
        // F♯1 sits over the boundary of F1 and G1, a little to the left.
        var boundary = k.x(31)
        verify(k.x(30) < boundary && k.x(30) + k.keyWidth(30) > boundary)
        verify(k.x(30) + k.keyWidth(30) / 2 < boundary)
        // White keys left to right, each one wide.
        for (var m = 29; m <= 67; m++) {
            verify(k.x(m) > k.x(m - 1), "key " + m + " right of " + (m - 1))
        }
        compare(k.keyAt(k.x(30) + 1, true), 30, "the black key wins on its level")
        compare(k.keyAt(k.x(30) + 1, false), 29, "below the black keys: the white one")
        compare(k.keyAt(-5, false), -1)
    }

    function test_layoutNames() {
        var k = createTemporaryObject(layoutComponent, tc)
        compare(k.nameOf(28), "E1")
        compare(k.nameOf(60), "C4")
        compare(k.nameOf(61), "C♯4")
        compare(k.nameOf(70), "B♭4")
        k.middleCOctave = 3
        compare(k.nameOf(60), "C3")
        k.noteNames = ["C", "Cis", "D", "Es", "E", "F", "Fis", "G", "As", "A", "B", "H"]
        compare(k.nameOf(59), "H2", "the app's names")
    }

    function test_layoutStartsOnBlack() {
        var k = createTemporaryObject(layoutComponent, tc, { low: 30, high: 54 })
        compare(k.x(30), 0, "starts at the black key's edge")
        fuzzyCompare(k.x(54) + k.keyWidth(54), 690, 1e-6)
    }

    // ── Keyboard ─────────────────────────────────────────────────────
    Component {
        id: boardComponent
        KanteKeyboard {
            width: 690; height: 120; low: 28; high: 67
            markers: [{ midi: 38, role: "current", label: "1" }, { midi: 40, role: "next" }, { midi: 28, role: "root" },
                      { midi: 31, role: "scale" }, { midi: 34, role: "wrong" }, { midi: 47, role: "offpitch", cents: -18 },
                      { midi: 90, role: "current" }]
        }
    }

    function keysOf(b) {
        return findAll(b, function (x) { return x.midi !== undefined && x.blackKey !== undefined && x.current !== undefined })
    }

    function test_keyboardKinds() {
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var b = createTemporaryObject(boardComponent, stage())
            waitForRendering(b)
            compare(keysOf(b).length, 40)
            verify(KanteStyle.relLum(b.whiteColor) > KanteStyle.relLum(b.blackColor), "white keys lighter than black ones")
            // Black keys over the white ones.
            var black = keysOf(b).filter(function (x) { return x.blackKey })[0]
            verify(black.z > 0)
            verify(black.height < b.height)
            // C keys carry their names.
            var names = findAll(b, function (x) { return x.text !== undefined && x.visible && /^C\d$/.test(x.text) })
            compare(names.map(function (x) { return x.text }).join(","), "C2,C3,C4")
            // Markers: in range only, a shape or a sign each.
            var signs = findAll(b, function (x) { return x.noteState !== undefined && x.visible })
            compare(signs.length, 2, "wrong and offpitch as KanteNoteMark")
            compare(signs.filter(function (x) { return x.centsLabel !== "" }).length, 1)
        }
    }

    function test_keyboardMarkersRead() {
        var b = createTemporaryObject(boardComponent, stage())
        var d = b.Accessible.description
        verify(d.indexOf("Aktuell: D2") === 0, d)
        verify(d.indexOf("Nächste: E2") > 0)
        verify(d.indexOf(KanteStyle.noteStateName("wrong") + ": B♭1") > 0, d)
        verify(d.indexOf("Grundton: E1") > 0)
        verify(d.indexOf("90") < 0 && d.indexOf("F♯6") < 0, "out of range: left out")
        // The current key is tinted, besides its square.
        var cur = keysOf(b).filter(function (x) { return x.midi === 38 })[0]
        verify(cur.current)
        verify(String(cur.color) !== String(b.whiteColor))
    }

    function test_keyNames() {
        var b = createTemporaryObject(boardComponent, stage(), { keyNames: KanteKeyboard.KeyNames.WhiteKeys })
        waitForRendering(b)
        compare(findAll(b, function (x) { return x.text !== undefined && x.visible && /^[A-G]\d$/.test(x.text) }).length, 24)
        b.keyNames = KanteKeyboard.KeyNames.None
        compare(findAll(b, function (x) { return x.text !== undefined && x.visible && /^[A-G]\d$/.test(x.text) }).length, 0)
    }

    function test_keyboardDisplayTakesNoFocus() {
        var b = createTemporaryObject(boardComponent, stage())
        verify(!b.activeFocusOnTab)
        compare(b.Accessible.role, Accessible.Chart)
    }

    function test_keyboardInteractive() {
        var b = createTemporaryObject(boardComponent, stage(), { interactive: true, focusKey: 40 })
        var spy = createTemporaryObject(spyComponent, tc, { target: b, signalName: "activated" })
        verify(b.activeFocusOnTab)
        b.forceActiveFocus()
        keyClick(Qt.Key_Right)
        compare(b.focusKey, 41)
        keyClick(Qt.Key_Left)
        keyClick(Qt.Key_Left)
        compare(b.focusKey, 39)
        keyClick(Qt.Key_Home)
        compare(b.focusKey, 28)
        keyClick(Qt.Key_Left)
        compare(b.focusKey, 28, "stays at the end")
        keyClick(Qt.Key_End)
        compare(b.focusKey, 67)
        keyClick(Qt.Key_Return)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 67)
        verify(b.Accessible.description.indexOf("G4") === 0, b.Accessible.description)
        // Focus ring on the focus key.
        var ring = findAll(b, function (x) { return x.border !== undefined && x.border.width === 2 && x.visible && x.color.a === 0 })
        compare(ring.length, 1)
        // A click on the upper half of a black key picks the black key, below it the white one.
        waitForRendering(b)
        var L = b.keyLayout
        mouseClick(b, L.x(30) + L.keyWidth(30) / 2, 10)
        compare(spy.signalArguments[1][0], 30)
        mouseClick(b, L.x(30) + L.keyWidth(30) / 2, b.height - 10)
        compare(spy.signalArguments[2][0], 29)
        compare(b.focusKey, 29)
    }

    // ── Lane ─────────────────────────────────────────────────────────
    function laneNotes() {
        var midi = [28, 31, 33, 35, 40, 38, 45, 43]
        var n = []
        for (var i = 0; i < midi.length; i++) {
            n.push({ time: i * 0.5, duration: 0.4, midi: midi[i], state: i < 2 ? "hit" : "pending" })
        }
        return n
    }
    Component {
        id: laneComponent
        KanteKeyLane { width: 690; height: 300; low: 28; high: 67; pixelsPerSecond: 100; bars: [0, { time: 2, number: 7 }] }
    }

    function noteItems(l) {
        return findAll(l, function (x) { return x.override !== undefined && x.colW !== undefined })
    }

    function test_laneColumnsOverKeys() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 1 })
        var b = createTemporaryObject(boardComponent, stage())
        var items = noteItems(l)
        compare(items.length, 8)
        for (var i = 0; i < items.length; i++) {
            var m = l.notes[items[i].index].midi
            fuzzyCompare(items[i].x, b.keyLayout.x(m) + b.keyLayout.keyWidth(m) / 2, 1e-6)
        }
    }

    function test_laneTiming() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 1 })
        compare(l.playY, Math.round(300 * 0.8), "play line at 0.2 from the bottom, as the tab lane")
        compare(l.nextIndex, 2)
        // A note at the position sits on the play line; later ones above it.
        var items = noteItems(l)
        var strip = items[0].parent
        compare(strip.y + items[2].y, l.playY)
        verify(strip.y + items[4].y < l.playY)
        l.position = 1.5
        compare(strip.y + items[3].y, l.playY, "the strip moves with position")
        compare(l.nextIndex, 3)
        verify(l.Accessible.description.indexOf(KanteStyle.noteStateName("pending") + ": B1") === 0, l.Accessible.description)
    }

    function test_laneNoteStates() {
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var l = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 1.2 })
            verify(l.Accessible.description.indexOf(KanteStyle.noteStateName("hit") + " 2") > 0)
            var rev = l.stateRevision
            l.setNoteState(2, "offpitch", 30)
            verify(l.stateRevision > rev)
            compare(l.stateOf(2), "offpitch")
            compare(l.centsOf(2), 30)
            verify(l.Accessible.description.indexOf(KanteStyle.noteStateName("offpitch") + " 1") > 0)
            var it = noteItems(l)[2]
            compare(it.st, "offpitch")
            tryVerify(function () { return findAll(l, function (x) { return x.noteState === "offpitch" && x.visible }).length === 1 })
            l.marks = KanteKeyLane.Marks.Off
            compare(it.st, "pending")
            l.marks = KanteKeyLane.Marks.Full
            l.resetStates()
            compare(l.stateOf(2), "pending")
        }
    }

    function test_laneSignsOnlyInView() {
        // A hit long past: its sign is not made (the software renderer does not clip Shapes).
        var l = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 3.4 })
        var items = noteItems(l)
        verify(!items[0].headIn)
        verify(items[6].headIn)
        wait(50)
        compare(findAll(l, function (x) { return x.noteState === "hit" && x.visible }).length, 0)
    }

    function test_laneOutOfRangeHidden() {
        var n = laneNotes()
        n[4].midi = 90
        var l = createTemporaryObject(laneComponent, stage(), { notes: n, position: 1.5 })
        verify(!noteItems(l)[4].visible)
    }

    function test_laneBarNumbers() {
        var l = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 1 })
        waitForRendering(l)
        compare(findAll(l, function (x) { return x.text === "7" && x.visible }).length, 1)
    }
}
