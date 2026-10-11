import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.28, wishes from Kontra (2): disabled segments in KanteSegmented, KanteInfoTip,
 * KanteSpinBox and volta brackets (alternate endings) in KanteTabStaff.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante128"
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

    // ── Segmented: disabled segments ─────────────────────────────────
    Component {
        id: segComponent
        KanteSegmented { model: ["Klinke", "Mikrofon", "MIDI", "Datei"]; disabledIndexes: [1, 2]; tooltips: ["", "", "Kommt in Phase 4", ""] }
    }

    // The delegates of the segments, left to right.
    function segmentsOf(s) {
        var row = findChild(s, function (x) { return x instanceof Row })
        return row.children.filter(function (x) { return x.off !== undefined })
    }
    function findChild(item, pred) {
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (pred(c)) {
                return c
            }
            var d = findChild(c, pred)
            if (d) {
                return d
            }
        }
        return null
    }

    function test_segmentDisabledSkippedByKeys() {
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var s = createTemporaryObject(segComponent, stage())
            s.forceActiveFocus()
            keyClick(Qt.Key_Right)
            compare(s.currentIndex, 3, "Right skips the disabled segments")
            keyClick(Qt.Key_Right)
            compare(s.currentIndex, 3, "stays at the end")
            keyClick(Qt.Key_Left)
            compare(s.currentIndex, 0, "Left skips them back")
            s.select(2)
            compare(s.currentIndex, 0, "select() ignores a disabled segment")
        }
    }

    function test_segmentDisabledNoClick() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(segComponent, stage())
        var spy = createTemporaryObject(spyComponent, tc, { target: s, signalName: "activated" })
        var segs = segmentsOf(s)
        compare(segs.length, 4)
        waitForRendering(s)
        mouseClick(segs[1])
        compare(s.currentIndex, 0)
        compare(spy.count, 0)
        mouseClick(segs[3])
        compare(s.currentIndex, 3)
        compare(spy.count, 1)
    }

    function test_segmentDisabledLooksDisabled() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(segComponent, stage())
        var segs = segmentsOf(s)
        verify(segs[1].off)
        verify(!segs[3].off)
        compare(String(segs[2].ink), String(KanteStyle.disabledTextColor))
        // Not colour alone: a line through the label.
        var strike = findChild(segs[1], function (x) { return x instanceof Rectangle && x.visible && x.height <= Math.max(1, KanteStyle.unit(1.5)) })
        verify(strike !== null)
        verify(findChild(segs[3], function (x) { return x instanceof Rectangle && x.visible && x.height <= Math.max(1, KanteStyle.unit(1.5)) }) === null)
        // The accessible part is disabled (screen readers hear "unavailable"), the hover stays.
        var a = findChild(segs[1], function (x) { return x.Accessible.role === Accessible.RadioButton })
        verify(a !== null)
        verify(!a.enabled)
        compare(a.Accessible.name, "Mikrofon")
        verify(segs[1].enabled, "the segment itself keeps its hover for the tooltip")
        s.disabledIndexes = []
        verify(!segs[1].off)
        verify(a.enabled)
    }

    Component { id: spyComponent; SignalSpy {} }

    // ── Info tip ─────────────────────────────────────────────────────
    Component { id: tipComponent; KanteInfoTip { term: "Latenz"; info: "Zeit vom Anschlag bis zum Ton." } }

    function test_infoTipNameAndText() {
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var t = createTemporaryObject(tipComponent, stage())
            compare(t.text, "?")
            compare(t.Accessible.name, "Hilfe zu Latenz")
            compare(t.Accessible.description, "Zeit vom Anschlag bis zum Ton.")
            compare(t.QQC2.ToolTip.text, "Zeit vom Anschlag bis zum Ton.")
            t.accessibleName = "Help on latency"
            compare(t.Accessible.name, "Help on latency", "plain text, set by the app")
        }
    }

    function test_infoTipOpensAndCloses() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var t = createTemporaryObject(tipComponent, stage())
        verify(!t.QQC2.ToolTip.visible)
        t.forceActiveFocus()
        verify(t.QQC2.ToolTip.visible, "shows on keyboard focus")
        keyClick(Qt.Key_Space)
        verify(t.checked)
        keyClick(Qt.Key_Escape)
        verify(!t.checked, "Esc closes")
        t.toggle()
        verify(t.checked)
        t.focus = false
        tc.forceActiveFocus()
        verify(!t.checked, "leaving the button closes it")
        verify(!t.QQC2.ToolTip.visible)
    }

    // ── Spin box ─────────────────────────────────────────────────────
    Component {
        id: spinComponent
        KanteSpinBox {
            from: 40; to: 200; stepSize: 5; value: 90; editable: true
            textFromValue: function (v) { return v + " BPM" }
            valueFromText: function (t) { return parseInt(t) }
            Accessible.name: "Tempo"
        }
    }

    function skinOf(control) {
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i].invalid !== undefined && control.children[i].spinBox !== undefined) {
                return control.children[i]
            }
        }
        return null
    }

    function test_spinBoxKinds() {
        var s = createTemporaryObject(spinComponent, stage())
        var skin = skinOf(s)
        verify(skin !== null)
        verify(skin.spinBox)
        compare(s.displayText, "90 BPM")
        compare(s.Accessible.name, "Tempo")
        verify(s.up.indicator === null || s.up.indicator.opacity > 0, "System: the platform's arrows")
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(s.implicitHeight >= KanteStyle.heightMedium)
        if (s.up.indicator !== null) {
            compare(s.up.indicator.opacity, 0)
        }
        compare(String(s.contentItem.color), String(KanteStyle.textColor))
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        verify(s.up.indicator === null || s.up.indicator.opacity > 0, "Kante Light keeps the platform's spin box")
    }

    function test_spinBoxKeysAndText() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(spinComponent, stage())
        var spy = createTemporaryObject(spyComponent, tc, { target: s, signalName: "valueModified" })
        s.forceActiveFocus()
        keyClick(Qt.Key_Up)
        compare(s.value, 95)
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Down)
        compare(s.value, 85)
        compare(spy.count, 3)
        // Typed text goes through valueFromText.
        s.contentItem.selectAll()
        keyClick(Qt.Key_1)
        keyClick(Qt.Key_2)
        keyClick(Qt.Key_0)
        keyClick(Qt.Key_Return)
        compare(s.value, 120)
        compare(s.displayText, "120 BPM")
    }

    function test_spinBoxLimits() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(spinComponent, stage())
        var skin = skinOf(s)
        verify(!skin.atLimit(1) && !skin.atLimit(-1))
        s.value = 200
        verify(skin.atLimit(1))
        verify(!skin.atLimit(-1))
        s.value = 40
        verify(skin.atLimit(-1))
        s.enabled = false
        verify(skin.atLimit(1), "disabled: both signs muted")
    }

    // ── Volta brackets ───────────────────────────────────────────────
    Component { id: staffComponent; KanteTabStaff { width: 900; barsPerSystem: 4; systems: 2 } }

    function notes8() {
        var n = []
        for (var i = 0; i < 16; i++) {
            n.push({ time: i, duration: 1, beats: 1, string: i % 4, fret: i % 5 })
        }
        return n
    }

    function test_voltaBackwardCompatible() {
        var s = createTemporaryObject(staffComponent, stage(), { notes: notes8(), bars: [0, 2, 4, { time: 6, repeatEnd: true }, 8, 10, 12, 14] })
        verify(!s.hasEndings)
        compare(s.endingRow, 0)
        compare(s.staffTop, s.markRow + s.ls * 0.5, "no endings: the old layout")
        compare(s.layout.endings.length, 0)
    }

    function test_voltaBrackets() {
        // |: 1 2 | 3 [1. 4 :| ] | 5 [2. 6 7 (next line) 8 ]
        var bars = [{ time: 0, repeatStart: true }, 2, 4, { time: 6, repeatEnd: true, endings: [1] },
                    { time: 8, endings: [2] }, { time: 10, endings: 2 }, 12, 14]
        var s = createTemporaryObject(staffComponent, stage(), { notes: notes8(), bars: bars })
        verify(s.hasEndings)
        verify(s.endingRow > 0)
        compare(s.staffTop, s.endingRow + s.markRow + s.ls * 0.5)
        var e = s.layout.endings
        compare(e.length, 2)
        compare(e[0].text, "1.")
        verify(e[0].left)
        verify(e[0].right, "closed: the first ending ends with a repeat sign")
        compare(e[0].sys, 0)
        compare(e[1].text, "2.")
        verify(e[1].left)
        verify(!e[1].right, "the last ending is open")
        compare(e[1].sys, 1)
        verify(e[1].w > s.barWidth * 1.5, "one bracket over both bars of the second ending")
        // Screen readers hear the ending of the current bar.
        s.position = 6.5
        verify(s.Accessible.description.indexOf("Volta 1") >= 0, s.Accessible.description)
        s.position = 1
        verify(s.Accessible.description.indexOf("Volta") < 0)
    }

    function test_voltaAcrossLines() {
        // The ending runs from bar 4 over the line break into bar 5.
        var bars = [0, 2, 4, { time: 6, endings: [1, 2] }, { time: 8, endings: [1, 2], repeatEnd: true }, 10, 12, 14]
        var s = createTemporaryObject(staffComponent, stage(), { notes: notes8(), bars: bars })
        var e = s.layout.endings
        compare(e.length, 2)
        compare(e[0].text, "1., 2.")
        verify(e[0].left)
        verify(!e[0].right, "goes on in the next line")
        compare(e[1].text, "", "no number on the continuation")
        verify(!e[1].left)
        verify(e[1].right)
        compare(s.endingsOf(undefined).length, 0)
        compare(s.endingsOf([2, 1, 2, 0]).join(","), "1,2")
    }

    function test_voltaDrawnInAllKinds() {
        var bars = [0, { time: 2, endings: [1], repeatEnd: true }, { time: 4, endings: [2] }, 6]
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var s = createTemporaryObject(staffComponent, stage(), { notes: notes8().slice(0, 8), bars: bars })
            waitForRendering(s)
            var label = findChild(s, function (x) { return x.text === "1." && x.visible })
            verify(label !== null, "the number is drawn")
        }
    }

    // ── Written bar numbers ──────────────────────────────────────────
    Component { id: bassComponent; KanteBassStaff { width: 900; barsPerSystem: 4; systems: 1 } }
    Component { id: laneComponent; KanteTabLane { width: 900; height: 200; pixelsPerSecond: 100 } }

    // Unrolled repeat: the score's bars 5 and 6 play twice.
    readonly property var unrolled: [{ time: 0, number: 5 }, { time: 2, number: 6 }, { time: 4, number: 5 }, { time: 6, number: "6" }]

    function texts(item, pred) {
        var out = []
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (c.text !== undefined && c.visible && pred(c)) {
                out.push(c)
            }
            out = out.concat(texts(c, pred))
        }
        return out
    }

    function test_barNumbersTabStaff() {
        var s = createTemporaryObject(staffComponent, stage(), { notes: notes8().slice(0, 8), bars: unrolled })
        var heads = s.layout.heads.filter(function (h) { return h.number !== undefined })
        compare(heads.map(function (h) { return h.number }).join(","), "5,6,5,6")
        s.position = 4.5
        verify(s.Accessible.description.indexOf("Takt 5 von 4") === 0, s.Accessible.description)
        s.bars = [0, 2, { time: 4 }, 6]
        heads = s.layout.heads.filter(function (h) { return h.number !== undefined })
        compare(heads.map(function (h) { return h.number }).join(","), "1,2,3,4", "without number: index + 1")
    }

    function test_barNumbersBassStaff() {
        var notes = []
        for (var i = 0; i < 8; i++) {
            notes.push({ time: i, beats: 1, midi: 40 + i })
        }
        var s = createTemporaryObject(bassComponent, stage(), { notes: notes, bars: unrolled })
        var nums = s.layout.glyphs.filter(function (g) { return g.ink === "muted" && g.text !== undefined && g.text !== "" })
        compare(nums.map(function (g) { return g.text }).join(","), "5,6,5,6")
        s.bars = [0, 2, 4, 6]
        nums = s.layout.glyphs.filter(function (g) { return g.ink === "muted" && g.text !== undefined && g.text !== "" })
        compare(nums.map(function (g) { return g.text }).join(","), "1,2,3,4")
    }

    function test_barNumbersTabLane() {
        var l = createTemporaryObject(laneComponent, stage(), { bars: unrolled, position: 2 })
        compare(l.barLabel(l.bars[2], 2), "5")
        compare(l.barLabel(3, 3), "4", "a plain time: index + 1")
        waitForRendering(l)
        var shown = texts(l, function (t) { return t.text === "5" || t.text === "6" })
        verify(shown.length >= 2, "written numbers drawn: " + shown.length)
    }
}
