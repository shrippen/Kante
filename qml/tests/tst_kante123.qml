import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.23: the practice components for Kontra. Note states (colour and shape),
 * the tab lane (next note, window, one binding per frame), tablature and bass staff
 * (paging, rhythm, spelling in the key, accidentals, ledger lines, stems), fretboard,
 * tuner, level meter, timing histogram and transport (signals, keyboard, the app owns
 * the state). Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante123"
    width: 1000
    height: 700
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    function notes(count, step) {
        var n = []
        for (var i = 0; i < count; i++) {
            n.push({ time: i * step, duration: step * 0.8, string: i % 4, fret: i % 12, state: "pending" })
        }
        return n
    }

    // ── States ───────────────────────────────────────────────────────
    function test_noteStateRoles() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(KanteStyle.noteStateColor("hit"), KanteStyle.positiveTextColor)
        compare(KanteStyle.noteStateColor("wrong"), KanteStyle.negativeTextColor)
        compare(KanteStyle.noteStateColor("early"), KanteStyle.noteStateColor("late"))
        compare(KanteStyle.noteStateColor("pending"), KanteStyle.textColor)
        compare(KanteStyle.noteStateName("late"), "Zu spät")
        compare(KanteStyle.noteStateName("nonsense"), "Offen")
        // A label on any state fill reads at least 3:1.
        var states = ["hit", "wrong", "missed", "early", "late"]
        for (var i = 0; i < states.length; i++) {
            var f = KanteStyle.noteStateColor(states[i])
            verify(KanteStyle.contrastOf(KanteStyle.inkOn(f), f) >= 3, states[i])
        }
    }

    Component { id: markComponent; KanteNoteMark { width: 20; height: 20 } }

    function test_noteMarkShapes() {
        var m = createTemporaryObject(markComponent, tc, { noteState: "pending" })
        verify(!m.drawn)
        compare(m.pathFor("pending", 20), "")
        var shapes = {}
        var states = ["hit", "wrong", "missed", "early", "late"]
        for (var i = 0; i < states.length; i++) {
            m.noteState = states[i]
            verify(m.drawn, states[i])
            var p = m.pathFor(states[i], 20)
            verify(p.length > 0)
            verify(shapes[p] === undefined, "every state has its own shape: " + states[i])
            shapes[p] = true
        }
    }

    // ── Tab lane ─────────────────────────────────────────────────────
    Component {
        id: laneComponent
        KanteTabLane { width: 800; height: 200; pixelsPerSecond: 100; playLine: 0.25 }
    }

    function noteItems(lane) {
        // The note delegates: children of the strip with a `st` property.
        var out = []
        function walk(item) {
            for (var i = 0; i < item.children.length; i++) {
                var c = item.children[i]
                if (c.st !== undefined && c.n !== undefined) {
                    out.push(c)
                } else {
                    walk(c)
                }
            }
        }
        walk(lane)
        return out
    }

    function test_laneNextAndRows() {
        var lane = createTemporaryObject(laneComponent, tc, { notes: notes(20, 0.5) })
        lane.position = 1.2
        compare(lane.nextIndex, 3)
        lane.position = 0
        compare(lane.nextIndex, 0)
        lane.position = 100
        compare(lane.nextIndex, -1)
        // High string on top by default, low string on top when asked.
        verify(lane.rowCenter(3) < lane.rowCenter(0))
        lane.lowStringOnTop = true
        verify(lane.rowCenter(0) < lane.rowCenter(3))
        lane.stringColors = ["#ff0000"]
        compare(String(lane.stringColor(0)), "#ff0000")
    }

    function test_laneShowsOnlyTheWindow() {
        var lane = createTemporaryObject(laneComponent, tc, { notes: notes(400, 0.25) })
        lane.position = 30
        var items = noteItems(lane)
        compare(items.length, 400)
        // (The TestCase is invisible, so read the delegates' own condition.)
        var shown = items.filter(function (it) { return it.t + it.d >= lane.windowFrom && it.t <= lane.windowTo })
        // In view: 8 s at 100 px/s (2 s before, 6 s after the line), plus at most a view in steps.
        verify(shown.length > 30 && shown.length < 120, "visible " + shown.length)
        for (var i = 0; i < shown.length; i++) {
            var t = shown[i].t
            verify(t > 30 - 2 - 4.1 && t < 30 + 6 + 4.1, "note at " + t)
        }
    }

    function test_laneStateShapes() {
        var list = notes(6, 0.5)
        var st = ["hit", "wrong", "missed", "early", "late", "pending"]
        for (var i = 0; i < list.length; i++) list[i].state = st[i]
        var lane = createTemporaryObject(laneComponent, tc, { notes: list, position: 1 })
        var items = noteItems(lane)
        compare(items.length, 6)
        verify(items[2].hollow, "missed is hollow")
        verify(!items[0].hollow)
        verify(lane.Accessible.description.indexOf("Getroffen 1") >= 0, lane.Accessible.description)
        verify(lane.Accessible.description.indexOf("Verpasst 1") >= 0)
    }

    // Moving the position only moves the strip: about 200 visible notes, 2000 in the list.
    function test_lanePositionIsCheap() {
        var lane = createTemporaryObject(laneComponent, tc, { notes: notes(2000, 0.04), width: 1000, pixelsPerSecond: 125 })
        lane.position = 10
        wait(0)
        var t0 = Date.now()
        var frames = 600
        for (var f = 0; f < frames; f++) {
            lane.position = 10 + f / 60
        }
        var perFrame = (Date.now() - t0) / frames
        verify(perFrame < 2, "binding work per frame " + perFrame + " ms")
    }

    // ── Tab staff ────────────────────────────────────────────────────
    Component {
        id: tabComponent
        KanteTabStaff { width: 900; barsPerSystem: 2; systems: 2 }
    }

    function tabNotes() {
        // 4/4 at 60 bpm: a bar is 4 s. Bar 1: four eighths and a half; bar 2..4: quarters.
        var n = [], t = 0
        var beats = [0.5, 0.5, 0.5, 0.5, 2]
        for (var i = 0; i < beats.length; i++) {
            n.push({ time: t, duration: beats[i], beats: beats[i], string: i % 4, fret: i, state: i === 0 ? "hit" : "pending" })
            t += beats[i]
        }
        for (; t < 16; t += 1) {
            n.push({ time: t, duration: 1, beats: 1, string: 1, fret: 3, state: "pending" })
        }
        return n
    }

    function test_tabStaffPagesAndRhythm() {
        var s = createTemporaryObject(tabComponent, tc, { notes: tabNotes(), bars: [{ time: 0, repeatStart: true }, 4, 8, { time: 12, repeatEnd: true }], position: 0.6 })
        compare(s.currentIndex, 1)
        compare(s.currentBar, 0)
        compare(s.firstBar, 0)
        // Page: 2 lines × 2 bars = all 4 bars, every note has a fret number.
        compare(s.layout.frets.length, s.notes.length)
        // Two beams (eighths 1+2, 3+4) and one mark (the hit).
        compare(s.layout.lines.filter(function (l) { return l.kind === "beam" }).length, 2)
        compare(s.layout.marks.filter(function (m) { return s.shownState(m.indices[0], s.stateRevision) !== "pending" }).length, 1)
        compare(s.layout.rects.filter(function (r) { return r.kind === "dots" }).length, 2)
        // The top line follows the current bar: bar 3 starts a new page.
        s.position = 9
        compare(s.currentBar, 2)
        compare(s.firstBar, 2)
        verify(s.layout.frets.length < s.notes.length)
        compare(s.rhythmOf(1.5).dot, true)
        compare(s.rhythmOf(0.25).level, 2)
        compare(s.rhythmOf(4).stem, 0)
    }

    // ── Bass staff ───────────────────────────────────────────────────
    Component {
        id: bassComponent
        KanteBassStaff { width: 900; barsPerSystem: 2 }
    }

    function test_bassSpelling() {
        var s = createTemporaryObject(bassComponent, tc)
        // E2 sits on the first ledger line below; G2 on the bottom line; A3 on the top line.
        compare(s.spell(40, 0).pos, -2)
        compare(s.spell(43, 0).pos, 0)
        compare(s.spell(57, 0).pos, 8)
        // F# in D major is in the key; in a flat key the same pitch is G flat.
        var fs = s.spell(42, 2)
        compare(fs.letter, 3)
        compare(fs.alter, 1)
        var gb = s.spell(42, -2)
        compare(gb.letter, 4)
        compare(gb.alter, -1)
        compare(s.spell(46, -1).letter, 6, "B flat in F major")
        compare(s.pitchName(42), "Fis2")
        compare(s.valueOf(1.5).dots, 1)
        compare(s.valueOf(1 / 3).triplet, true)
        compare(s.valueOf(1 / 3).type, 3)
    }

    function test_bassLayout() {
        // 4/4 at 60 bpm. C major: F#2 gets a sharp, the second F#2 in the bar none, E1 ledger lines.
        var n = [
            { time: 0, beats: 1, midi: 42, state: "hit" },
            { time: 1, beats: 1, midi: 42, state: "pending" },
            { time: 2, beats: 0.5, midi: 45 }, { time: 2.5, beats: 0.5, midi: 47 },
            { time: 3, beats: 1, midi: 28, tied: true },
            { time: 4, beats: 4, midi: 28 }
        ]
        var s = createTemporaryObject(bassComponent, tc, { barsPerSystem: 3, notes: n, rests: [{ time: 8, beats: 4 }],
            bars: [{ time: 0, numerator: 4, denominator: 4 }, 4, { time: 8, numerator: 3, denominator: 4 }] })
        var sharps = s.layout.glyphs.filter(function (g) { return g.g === "" })
        compare(sharps.length, 1, "one sharp: the second F# in the bar keeps it")
        compare(s.layout.polys.length, 1, "one beam over the two eighths")
        compare(s.layout.ties.length, 1)
        compare(s.layout.marks.filter(function (m) { return s.shownState(m.index, s.stateRevision) !== "pending" }).length, 1)
        // E1 = pos −9: ledger lines at −2, −4, −6, −8, twice (tied note in the next bar).
        var ledgers = s.layout.rects.filter(function (r) { return r.h === Math.max(1, Math.round(s.sp * 0.16)) && r.w < s.sp * 3 && r.w > s.sp })
        verify(ledgers.length >= 8, "ledger lines " + ledgers.length)
        compare(s.barList[2].changed, true, "3/4 shows")
        compare(s.barList[1].changed, false)
        // Whole rest in the 3/4 bar is not a full bar: three quarters are.
        verify(s.layout.glyphs.some(function (g) { return g.g === "" || g.g === "" }))
    }

    function test_bassStems() {
        var s = createTemporaryObject(bassComponent, tc, { notes: [{ time: 0, beats: 1, midi: 43 }, { time: 1, beats: 1, midi: 55 }] })
        var stems = s.layout.rects.filter(function (r) { return r.w === Math.max(1, Math.round(s.sp * 0.12)) && r.h > s.sp * 2 })
        compare(stems.length, 2)
        var low = s.layout.boxes[0], high = s.layout.boxes[1]
        // G2 (bottom line): stem up on the right of the head; G3 (above the middle): down on the left.
        verify(Math.abs(stems[0].x - (low.x + low.w - stems[0].w)) < 0.01)
        verify(Math.abs(stems[1].x - high.x) < 0.01)
    }

    function test_bravuraLoads() {
        var s = createTemporaryObject(bassComponent, tc)
        tryVerify(function () {
            for (var i = 0; i < s.data.length; i++) {
                if (s.data[i] instanceof FontLoader) return s.data[i].status === FontLoader.Ready
            }
            return false
        }, 3000)
    }

    // ── Fretboard ────────────────────────────────────────────────────
    Component {
        id: fretComponent
        KanteFretboard { width: 700; height: 160; frets: 12 }
    }

    function test_fretboard() {
        var b = createTemporaryObject(fretComponent, tc, { markers: [{ string: 1, fret: 3, role: "current" }, { string: 2, fret: 5, role: "next" }] })
        verify(b.placeX(0) < b.placeX(1) && b.placeX(1) < b.placeX(12))
        // Real spacing: the first fret is wider than the twelfth.
        verify(b.fretX(1) - b.fretX(0) > b.fretX(12) - b.fretX(11))
        b.evenFrets = true
        verify(Math.abs((b.fretX(1) - b.fretX(0)) - (b.fretX(12) - b.fretX(11))) < 0.01)
        b.leftHanded = true
        verify(b.placeX(1) > b.placeX(12))
        verify(b.Accessible.description.indexOf("Aktuell: Saite A, Bund 3") === 0, b.Accessible.description)
        b.firstFret = 4
        verify(!b.inView(0) && !b.inView(4) && b.inView(5) && b.inView(16) && !b.inView(17))
    }

    // ── Tuner ────────────────────────────────────────────────────────
    Component {
        id: tunerComponent
        KanteTunerGauge { noteName: "E"; octave: 1; active: true }
    }

    function test_tuner() {
        var g = createTemporaryObject(tunerComponent, tc, { cents: -12.4 })
        compare(g.centsText, "−12 ct")
        verify(!g.inTune)
        compare(g.shownHint, "")
        g.cents = 2.5
        verify(g.inTune)
        compare(g.shownHint, "Gestimmt")
        g.hint = "Passt"
        compare(g.shownHint, "Passt")
        g.cents = 80
        compare(g.shown, 50)
        g.active = false
        verify(!g.inTune)
        compare(g.Accessible.description, "–")
    }

    // ── Level meter ──────────────────────────────────────────────────
    Component {
        id: levelComponent
        KanteLevelMeter { width: 400 }
    }

    function test_levelZones() {
        var m = createTemporaryObject(levelComponent, tc, { peakDb: -50, rmsDb: -60 })
        compare(m.zone, "quiet")
        m.peakDb = -12
        compare(m.zone, "good")
        compare(m.peakText, "−12 dB")
        m.peakDb = -2
        compare(m.zone, "loud")
        m.clipped = true
        compare(m.zone, "clip")
        compare(m.Accessible.description, "−2 dB, Übersteuert")
        compare(m.xOf(0), m.trackWidth)
        compare(m.xOf(-60), 0)
    }

    // ── Histogram ────────────────────────────────────────────────────
    Component {
        id: histComponent
        KanteTimingHistogram { width: 500; height: 220 }
    }

    function test_histogram() {
        var h = createTemporaryObject(histComponent, tc, { counts: [1, 3, 7, 4, 2, 1], firstBinMs: -30, binMs: 10, meanMs: -4 })
        compare(h.total, 18)
        var e = h.edges()
        compare(e.length, 7)
        compare(e[3], "0")
        compare(e[0], "−30")
        var m = h.markerList()
        compare(m.length, 2)
        compare(m[0].at, 3)
        verify(Math.abs(m[1].at - 2.6) < 1e-9)
        verify(m[1].dashed)
        compare(h.chart.axisStep, 2, "whole steps for counts")
        verify(h.Accessible.description.indexOf("(früh)") > 0, h.Accessible.description)
    }

    // ── Transport ────────────────────────────────────────────────────
    Component {
        id: transportComponent
        KanteTransportBar { width: 900 }
    }
    SignalSpy { id: playSpy; signalName: "playToggled" }
    SignalSpy { id: loopSpy; signalName: "loopToggled" }
    SignalSpy { id: speedSpy; signalName: "speedChangeRequested" }
    SignalSpy { id: metroSpy; signalName: "metronomeToggled" }
    SignalSpy { id: countSpy; signalName: "countInToggled" }
    SignalSpy { id: rewindSpy; signalName: "rewind" }

    function test_transportKeyboard() {
        var bar = createTemporaryObject(transportComponent, tc, { speed: 1.0, position: 83, duration: 225 })
        compare(bar.positionText, "1:23 / 3:45")
        var spies = [playSpy, loopSpy, speedSpy, metroSpy, countSpy, rewindSpy]
        for (var i = 0; i < spies.length; i++) {
            spies[i].clear()
            spies[i].target = bar
        }
        bar.forceActiveFocus()
        keyClick(Qt.Key_K)
        keyClick(Qt.Key_L)
        keyClick(Qt.Key_M)
        keyClick(Qt.Key_C)
        keyClick(Qt.Key_Home)
        keyClick(Qt.Key_Plus)
        compare(playSpy.count, 1)
        compare(loopSpy.count, 1)
        compare(metroSpy.count, 1)
        compare(countSpy.count, 1)
        compare(rewindSpy.count, 1)
        compare(speedSpy.count, 1)
        compare(speedSpy.signalArguments[0][0], 1.05)
        // Space on the focused play button plays.
        keyClick(Qt.Key_Space)
        compare(playSpy.count, 2)
        // Speed stays in 25..150 %.
        bar.speed = 1.5
        keyClick(Qt.Key_Plus)
        compare(speedSpy.count, 1)
        bar.speed = 0.25
        keyClick(Qt.Key_Minus)
        compare(speedSpy.count, 1)
    }

    function findToggle(item, label) {
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (c.checkable === true && c.text === label) return c
            var r = findToggle(c, label)
            if (r) return r
        }
        return null
    }

    function test_transportAppOwnsState() {
        var bar = createTemporaryObject(transportComponent, tc)
        loopSpy.clear()
        loopSpy.target = bar
        var loop = findToggle(bar, "Schleife")
        verify(loop !== null)
        verify(!loop.checked)
        loop.click()
        compare(loopSpy.count, 1)
        verify(!loop.checked, "stays off until the app turns looping on")
        bar.looping = true
        verify(loop.checked)
        compare(loop.Accessible.name, "Schleife")
    }

    // ── Every new component in every kind ────────────────────────────
    Component { id: allComponent
        Column {
            KanteTabLane { width: 600; height: 160; notes: tc.notes(30, 0.3); bars: [0, 2, 4]; position: 1; loopStart: 1; loopEnd: 2 }
            KanteTabStaff { width: 600; notes: tc.tabNotes(); bars: [0, 4, 8, 12]; position: 1 }
            KanteBassStaff { width: 600; notes: [{ time: 0, beats: 1, midi: 40, state: "hit" }]; keyFifths: -3 }
            KanteFretboard { width: 600; markers: [{ string: 0, fret: 0, role: "root" }] }
            KanteTunerGauge { noteName: "A"; octave: 1; cents: 1; active: true }
            KanteLevelMeter { width: 400; peakDb: -10; rmsDb: -20 }
            KanteTimingHistogram { width: 400; height: 160; counts: [1, 2, 1] ; firstBinMs: -15; binMs: 10; meanMs: 0 }
            KanteTransportBar { width: 600 }
            KanteNoteMark { noteState: "late" }
        }
    }

    function test_everyKind() {
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var col = createTemporaryObject(allComponent, tc)
            verify(col !== null)
            for (var i = 0; i < col.children.length; i++) {
                verify(col.children[i].height > 0, "kind " + kinds[k] + " child " + i)
                verify(col.children[i].Accessible.name !== "", "accessible name of child " + i)
            }
        }
    }
}
