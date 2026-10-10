import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.27, wishes from Kontra's QA round: KanteSwitch and KanteComboBox (with the open
 * list in Kante), the primary button in Kante Light, steps with a sign per state, the note
 * state "offpitch" with cents, chord symbols and key changes in KanteBassStaff.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante127"
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

    // ── Switch and combo box ─────────────────────────────────────────
    Component { id: switchComponent; KanteSwitch { text: "Bundlos" } }
    Component { id: comboComponent; KanteComboBox { model: ["Standard", "Scarlett 2i2", "USB-Bass"]; currentIndex: 1; width: 240 } }

    function skinOf(control, prop) {
        for (var i = 0; i < control.children.length; i++) {
            if (control.children[i][prop] !== undefined) {
                return control.children[i]
            }
        }
        return null
    }

    function test_switchSkin() {
        var s = createTemporaryObject(switchComponent, stage())
        var skin = skinOf(s, "shape")
        verify(skin !== null)
        compare(skin.shape, KanteCheckSkin.Shape.Switch)
        verify(!skin.visible, "System: the platform switch")
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(skin.visible)
        compare(s.indicator.opacity, 0)
        s.toggle()
        verify(s.checked)
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        verify(!skin.visible, "Kante Light keeps the platform's controls")
        verify(s.indicator.opacity > 0)
    }

    function test_comboListIsKante() {
        var c = createTemporaryObject(comboComponent, stage())
        var skin = skinOf(c, "invalid")
        verify(skin !== null)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(c.implicitHeight >= KanteStyle.heightMedium)
        verify(c.popup.background !== null && c.popup.background.barColor !== undefined, "the list opens on a Kante card")
        c.popup.open()
        tryVerify(function () { return c.popup.opened })
        var list = c.popup.contentItem
        tryVerify(function () { return list.count === 3 })
        tryVerify(function () { return list.itemAtIndex(1) !== null }, 2000, "rows " + list.count + ", list height " + list.height)
        var row = list.itemAtIndex(1)
        verify(row.chosen)
        verify(row.highlighted, "the chosen row is highlighted when the list opens")
        compare(row.background.opacity, 0)
        var kanteText = row.children.filter(function (x) { return x.text === "Scarlett 2i2" && x !== row.contentItem })
        compare(kanteText.length, 1)
        compare(String(kanteText[0].color), String(KanteStyle.strongTextColor))
        // The highlighted row has a cyan edge besides its tint.
        var edge = findChild(row, function (x) { return x.width === KanteStyle.unit(3) && x.visible })
        verify(edge !== null)
        verify(row.height >= KanteStyle.heightSmall)
        c.popup.close()
        tryVerify(function () { return !c.popup.visible })
        KanteStyle.kind = KanteStyle.Kind.System
        verify(c.popup.background === null || c.popup.background.barColor === undefined, "System: the style's popup")
        compare(row.background.opacity, 1)
        verify(!kanteText[0].visible)
        verify(c.delegate !== null)
    }

    // ── Primary button ───────────────────────────────────────────────
    Component { id: primaryComponent; KanteButton { text: "Weiter"; emphasis: KanteButton.Emphasis.Primary } }
    Component { id: normalComponent; KanteButton { text: "Zurück" } }

    function test_primaryStandsOutInKanteLight() {
        var p = createTemporaryObject(primaryComponent, stage())
        var n = createTemporaryObject(normalComponent, stage())
        verify(!p.drawn, "System: the platform button")
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        verify(p.drawn, "Kante Light draws the primary button")
        verify(!n.drawn, "other buttons stay the platform's")
        compare(p.background.opacity, 0)
        compare(String(p.kanteFill), String(KanteStyle.primaryColor))
        verify(p.font.bold || p.font.weight >= Font.Bold)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(p.drawn && n.drawn)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(p.background.opacity > 0)
    }

    function test_primaryContrast() {
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            var c = KanteStyle.contrastOf(KanteStyle.primaryTextColor, KanteStyle.primaryColor)
            verify(c >= 4.5, "kind " + kinds[i] + ": label on primary " + c.toFixed(2))
            // hover and pressed keep it
            verify(KanteStyle.contrastOf(KanteStyle.primaryTextColor, KanteStyle.primaryHoverColor) >= 4.4)
            verify(KanteStyle.contrastOf(KanteStyle.primaryTextColor, KanteStyle.primaryPressedColor) >= 4.4)
        }
        // A Breeze-like highlight (#3daee9 with white, 2.4:1) is darkened to 4.5:1, hue kept.
        var fixed = KanteStyle.readable(Qt.color("#3daee9"), Qt.color("#fcfcfc"))
        verify(KanteStyle.contrastOf(fixed, Qt.color("#fcfcfc")) >= 4.5)
        verify(Math.abs(fixed.hslHue - Qt.color("#3daee9").hslHue) < 0.02)
    }

    // ── Steps ────────────────────────────────────────────────────────
    Component { id: stepsComponent; KanteSteps { model: ["Instrument", "Anschluss", "Pegel", "Fertig"]; current: 2 } }

    function stepItems(s) {
        return s.children.filter(function (c) { return c.stateKey !== undefined })
    }

    function test_stepsHaveShapes() {
        for (var k = 0; k < kinds.length; k++) {
            KanteStyle.kind = kinds[k]
            var s = createTemporaryObject(stepsComponent, stage())
            var items = stepItems(s)
            compare(items.length, 4)
            compare(items[0].stateKey, "done")
            compare(items[2].stateKey, "current")
            compare(items[3].stateKey, "upcoming")
            compare(items[2].Accessible.name, "Schritt 3 von 4: Pegel, aktuell")
            compare(items[0].Accessible.name, "Schritt 1 von 4: Instrument, erledigt")
            // Not colour alone: done shows a tick, current a frame and a filled sign,
            // upcoming a hollow sign; the bars differ in height.
            var tick = findChild(items[0], function (c) { return c.checked !== undefined && c.progress !== undefined })
            verify(tick !== null && tick.visible)
            var frame = items[2].children.filter(function (c) { return c.border !== undefined && c.border.width === 2 })
            compare(frame.length, 1)
            verify(frame[0].visible)
            var hollow = items[3].children.filter(function (c) { return c.border !== undefined && c.border.width === 1 && c.color.a === 0 })
            compare(hollow.length, 1)
            verify(items[2].children[2].height > items[0].children[2].height)
            verify(items[0].children[2].height > items[3].children[2].height)
        }
    }

    function findChild(item, pred) {
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (pred(c)) return c
            var d = findChild(c, pred)
            if (d) return d
        }
        return null
    }

    // ── Note state offpitch ──────────────────────────────────────────
    Component { id: markComponent; KanteNoteMark { width: 20; height: 20 } }

    function test_offpitchState() {
        compare(String(KanteStyle.noteStateColor("offpitch")), String(KanteStyle.warningColor))
        compare(KanteStyle.noteStateName("offpitch"), "Unsauber")
        verify(KanteStyle.noteStates.indexOf("offpitch") >= 0)
        compare(KanteStyle.centsText(32), "+32 ct")
        compare(KanteStyle.centsText(-18.4), "−18 ct")
        compare(KanteStyle.centsText(0), "0 ct")
        compare(KanteStyle.centsText(NaN), "")
        compare(KanteStyle.centsText(undefined), "")
    }

    function test_offpitchMark() {
        var m = createTemporaryObject(markComponent, stage(), { noteState: "offpitch" })
        verify(m.drawn)
        var wave = m.pathFor("offpitch", 20)
        verify(wave.length > 0)
        verify(wave.indexOf("C") > 0, "a curve, unlike the straight check and cross")
        verify(wave !== m.pathFor("hit", 20) && wave !== m.pathFor("wrong", 20))
        compare(m.centsLabel, "")
        compare(m.centsWidth, 0)
        compare(m.Accessible.name, "Unsauber")
        m.cents = 32
        compare(m.centsLabel, "+32 ct")
        verify(m.centsWidth > 0)
        compare(m.Accessible.name, "Unsauber, +32 ct")
        m.showCents = false
        compare(m.centsWidth, 0)
        // Cents belong to offpitch only.
        m.noteState = "hit"
        compare(m.centsLabel, "")
    }

    function laneNotes() {
        var n = []
        for (var i = 0; i < 6; i++) {
            n.push({ time: i * 0.5, duration: 0.4, string: i % 4, fret: i, state: i === 1 ? "offpitch" : "pending", cents: i === 1 ? 25 : undefined })
        }
        return n
    }
    Component { id: laneComponent; KanteTabLane { width: 800; height: 200 } }
    Component { id: tabComponent; KanteTabStaff { width: 800; barsPerSystem: 2 } }
    Component { id: bassComponent; KanteBassStaff { width: 900; barsPerSystem: 2 } }

    function test_laneOffpitch() {
        var lane = createTemporaryObject(laneComponent, stage(), { notes: laneNotes(), position: 1.5 })
        compare(lane.stateOf(1), "offpitch")
        compare(lane.centsOf(1), 25)
        verify(isNaN(lane.centsOf(0)))
        verify(lane.Accessible.description.indexOf("Unsauber 1") >= 0, lane.Accessible.description)
        lane.setNoteState(2, "offpitch", -40)
        compare(lane.centsOf(2), -40)
        verify(lane.Accessible.description.indexOf("Unsauber 2") >= 0, lane.Accessible.description)
        // Without cents, the note's own cents hold.
        lane.setNoteState(1, "offpitch")
        compare(lane.centsOf(1), 25)
        lane.resetStates()
        verify(isNaN(lane.centsOf(2)))
    }

    function test_staffsOffpitch() {
        var t = createTemporaryObject(tabComponent, stage(), { notes: laneNotes(), position: 0.6 })
        compare(t.currentIndex, 1)
        verify(t.Accessible.description.indexOf("(Unsauber, +25 ct)") > 0, t.Accessible.description)
        t.setNoteState(1, "offpitch", 12)
        verify(t.Accessible.description.indexOf("(Unsauber, +12 ct)") > 0, t.Accessible.description)
        var n = laneNotes()
        for (var i = 0; i < n.length; i++) { n[i].midi = 40 + i; n[i].beats = 1 }
        var b = createTemporaryObject(bassComponent, stage(), { notes: n, position: 0.6 })
        verify(b.Accessible.description.indexOf("(Unsauber, +25 ct)") > 0, b.Accessible.description)
        b.setNoteState(1, "hit")
        verify(b.Accessible.description.indexOf("(Getroffen)") > 0, b.Accessible.description)
    }

    // ── Bass staff: key changes ──────────────────────────────────────
    function quarters(midis) {
        var n = []
        for (var i = 0; i < midis.length; i++) n.push({ time: i * 0.5, beats: 1, midi: midis[i] })
        return n
    }
    function countGlyph(layout, g) {
        return layout.glyphs.filter(function (x) { return x.g === g }).length
    }

    function test_keySigns() {
        var s = createTemporaryObject(bassComponent, stage())
        function signs(a, b) { return s.keySigns(a, b).map(function (x) { return x.pos + ":" + x.sign }).join(" ") }
        // Naturals stand only alone: D major to F major shows just B flat.
        compare(signs(2, -1), "2:-1")
        // A major to G major: just F sharp, no naturals for the dropped C and G.
        compare(signs(3, 1), "6:1")
        // More of the same kind: only the new key.
        compare(signs(1, 3), "6:1 3:1 7:1")
        // To C: naturals for all.
        compare(signs(-3, 0), "2:0 5:0 1:0")
        // No change: the key itself.
        compare(signs(-2, -2), "2:-1 5:-1")
        compare(signs(0, 0), "")
    }

    function test_keyChangesPerBar() {
        // Bar 1 G major, bar 2 D major (keyFifths), bar 3 F major (key_fifths), bar 4 same.
        var s = createTemporaryObject(bassComponent, stage(), {
            keyFifths: 1, barsPerSystem: 4,
            notes: quarters([43, 47, 50, 54, 50, 54, 57, 61, 41, 45, 46, 48, 41, 45, 46, 48]),
            bars: [{ time: 0, numerator: 4, denominator: 4 }, { time: 2, keyFifths: 2 }, { time: 4, key_fifths: -1 }, { time: 6 }]
        })
        compare(s.barList.length, 4)
        compare(s.barList[0].key, 1)
        compare(s.barList[1].key, 2)
        verify(s.barList[1].keyChanged)
        compare(s.barList[2].key, -1)
        compare(s.barList[2].fromKey, 2)
        verify(!s.barList[3].keyChanged)
        compare(s.barList[3].key, -1)
        var L = s.layout
        // No naturals: the change to F major shows only its flat; no note needs one.
        compare(countGlyph(L, ""), 0)
        // Sharps: 1 (header) + 2 (bar 2); flats: 1 (bar 3); F#3 (54) and C#4 (61) in D major need none.
        compare(countGlyph(L, ""), 3)
        compare(countGlyph(L, ""), 1)
        // Spelling follows the bar's key: B flat (46) in F major has no accidental.
        compare(s.spell(46, s.barList[2].key).alter, -1)
        // A change makes room in its bar (one flat), and a thin double bar line before it.
        verify(s.padLeft(2) > s.padLeft(3) + s.sp * 1.5)
        // The header is wide enough for the widest key a line can start with.
        compare(s.maxHeaderKey(s.barList), 2)
        // Screen readers name the pitch in the bar's key.
        s.position = 4.1
        verify(s.Accessible.description.indexOf("F2") > 0, s.Accessible.description)
    }

    function test_keyChangeAtLineStart() {
        // Two bars per line: the change to C in bar 3 shows its naturals at the start of line 2.
        var s = createTemporaryObject(bassComponent, stage(), {
            keyFifths: -2, systems: 2,
            notes: quarters([46, 46, 46, 46, 46, 46, 46, 46, 48, 48, 48, 48]),
            bars: [0, 2, { time: 4, keyFifths: 0 }]
        })
        compare(s.perSystem, 2)
        var L = s.layout
        // Header line 1: 2 flats; line 2 starts with 2 naturals (B, E); B (46) in C needs a flat.
        compare(countGlyph(L, ""), 2)
        compare(countGlyph(L, ""), 2)
    }

    function test_keyCompatibility() {
        // Without per-bar keys: the old header and layout.
        var s = createTemporaryObject(bassComponent, stage(), { keyFifths: 3, notes: quarters([45, 47, 49, 50]), bars: [0] })
        compare(s.headerWidth, s.sp * (4.2 + 3 * 1.1 + 3.0))
        compare(s.staffTop, s.sp * 5.5)
        compare(countGlyph(s.layout, ""), 3)
        verify(!s.hasChords)
        compare(s.barList[0].key, 3)
    }

    // ── Bass staff: chord symbols ────────────────────────────────────
    function test_chordSymbols() {
        var s = createTemporaryObject(bassComponent, stage(), {
            notes: quarters([40, 43, 45, 47, 45, 43, 40, 43]),
            bars: [{ time: 0, chord: "Em" }, { time: 2, chord: "G" }],
            chords: [{ time: 1, text: "Bb7" }, { time: 3, text: "F#m7b5" }],
            position: 1.2
        })
        verify(s.hasChords)
        compare(s.chordList.map(function (c) { return c.text }).join(" "), "Em Bb7 G F#m7b5")
        compare(s.chordLabel("Bb7"), "B♭7")
        compare(s.chordLabel("F#m7b5"), "F♯m7♭5")
        compare(s.chordLabel("Cmaj7/Eb"), "Cmaj7/E♭")
        compare(s.chordLabel("Cdim"), "Cdim")
        var shown = s.layout.glyphs.filter(function (g) { return g.chord === true })
        compare(shown.length, 4)
        compare(shown[1].text, "B♭7")
        // Left to right, above the staff, and the staff moves down for their row.
        for (var i = 1; i < shown.length; i++) verify(shown[i].x > shown[i - 1].x)
        verify(shown[0].y < s.staffTop - s.sp)
        compare(s.staffTop, s.sp * 7.5)
        compare(s.chordAt(1.2), "Bb7")
        compare(s.chordAt(-1), "")
        verify(s.Accessible.description.indexOf("Akkord Bb7") > 0, s.Accessible.description)
    }

    function test_chordsDoNotCollide() {
        var s = createTemporaryObject(bassComponent, stage(), {
            notes: quarters([40, 43, 45, 47]),
            chords: [{ time: 0, text: "Cmaj7(#11)" }, { time: 0.5, text: "D7" }]
        })
        var shown = s.layout.glyphs.filter(function (g) { return g.chord === true })
        compare(shown.length, 2)
        verify(shown[1].x >= shown[0].x + shown[0].text.length * s.sp * 0.95)
    }

    // Everything new loads in every kind.
    Component {
        id: allComponent
        Column {
            KanteSwitch { text: "a"; checked: true }
            KanteComboBox { model: ["a", "b"] }
            KanteButton { text: "Weiter"; emphasis: KanteButton.Emphasis.Primary }
            KanteSteps { model: ["a", "b"]; current: 1 }
            KanteNoteMark { noteState: "offpitch"; cents: -12 }
            KanteBassStaff { width: 600; chords: [{ time: 0, text: "Am" }]; bars: [0, { time: 2, keyFifths: -3 }]; notes: [{ time: 0, beats: 1, midi: 45, state: "offpitch", cents: 30 }] }
        }
    }

    function test_allKinds() {
        var o = createTemporaryObject(allComponent, stage())
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            waitForRendering(o)
            verify(o.children.length === 6)
        }
    }
}
