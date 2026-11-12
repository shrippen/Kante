import QtQuick
import QtTest
import Kante

/**
 * Kante 1.82, staffs that stay fast and move (Kontra polish pass, 12.11.): lines are kept
 * while they stay in view (a page turn builds one line), a change of several inputs lays
 * out once, `settleMs` waits for a resize to end, and a line stays light enough to build.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante182"
    width: 1600
    height: 900
    when: windowShown

    function bars(count) {
        const list = []
        for (let i = 0; i < count; i++) {
            list.push({ time: i * 2 })
        }
        return list
    }
    // Eight eighths per bar on all strings.
    function tabNotes(count) {
        const list = []
        for (let i = 0; i < count * 8; i++) {
            list.push({ time: i * 0.25, duration: 0.25, beats: 0.5, string: i % 4, fret: i % 7 })
        }
        return list
    }
    function midiNotes(count) {
        const list = []
        for (let i = 0; i < count * 8; i++) {
            list.push({ time: i * 0.25, duration: 0.25, beats: 0.5, midi: 40 + i % 12 })
        }
        return list
    }
    function lineItems(staff) {
        const view = findChild(staff, "staffLines")
        const out = []
        for (let i = 0; i < view.contentItem.children.length; i++) {
            const c = view.contentItem.children[i]
            if (c.lineIndex !== undefined && c.opacity > 0.5) {
                out.push(c)
            }
        }
        return out.sort(function (a, b) { return a.lineIndex - b.lineIndex })
    }
    function count(item) {
        let n = 1
        for (let i = 0; i < item.children.length; i++) {
            n += count(item.children[i])
        }
        return n
    }

    Component { id: tabComponent; KanteTabStaff { width: 1500; height: 800; systems: 3; lineSpacing: 14; minBarWidth: 200 } }
    Component { id: bassComponent; KanteBassStaff { width: 1500; height: 800; systems: 3; staffSpace: 10; minBarWidth: 180 } }

    function init() {
        KanteStyle.motion = false
    }
    function cleanup() {
        KanteStyle.motion = true
    }

    function test_pageTurnKeepsLines_data() {
        return [{ tag: "tab", comp: tabComponent, notes: tabNotes(35) }, { tag: "notation", comp: bassComponent, notes: midiNotes(35) }]
    }
    function test_pageTurnKeepsLines(row) {
        const staff = createTemporaryObject(row.comp, tc, { bars: bars(35), notes: row.notes })
        waitForRendering(staff)
        const before = lineItems(staff)
        compare(before.length, 3)
        // To the second line: it moves up, a new one comes in at the bottom.
        staff.position = staff.perSystem * 2 + 0.1
        tryCompare(staff, "firstBar", staff.perSystem)
        tryVerify(function () { return lineItems(staff).length === 3 && lineItems(staff)[0].lineIndex === 1 })
        const after = lineItems(staff)
        verify(after[0] === before[1], "the second line lives on as the first")
        verify(after[1] === before[2])
        compare(after[2].lineIndex, 3)
    }

    function test_severalInputsLayOutOnce() {
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(35), notes: tabNotes(35) })
        waitForRendering(staff)
        const r = staff.lineRevision
        // Width, spacing and bar width change one after the other, as in a resize.
        staff.width = 1200
        staff.lineSpacing = 15
        staff.minBarWidth = 220
        tryVerify(function () { return staff.lineRevision > r })
        wait(50)
        compare(staff.lineRevision, r + 1)
    }

    function test_settleWaitsForTheLastChange() {
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(35), notes: tabNotes(35), settleMs: 150 })
        waitForRendering(staff)
        const r = staff.lineRevision
        for (let w = 1480; w >= 1300; w -= 20) {
            staff.width = w
            wait(20)
        }
        compare(staff.layoutSize.width, 1500, "no layout while the size moves")
        compare(staff.lineRevision, r)
        tryCompare(staff, "layoutSize", Qt.size(1300, 800))
        tryVerify(function () { return staff.lineRevision === r + 1 })
    }

    function test_moreRoomAddsALine() {
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(35), notes: tabNotes(35) })
        waitForRendering(staff)
        const before = lineItems(staff)
        staff.systems = 4
        tryVerify(function () { return lineItems(staff).length === 4 })
        const after = lineItems(staff)
        verify(after[0] === before[0] && after[2] === before[2], "the lines that stay are kept")
    }

    // A line of 7 bars with 8 notes each stays below this many items (P5): before 1.82 a
    // page of three such lines had 2280 (Kontra 12.11.: 57 ms to turn), with 1.82 1272.
    function test_lineStaysLight() {
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(35), notes: tabNotes(35) })
        waitForRendering(staff)
        const line = lineItems(staff)[0]
        verify(count(line) < 500, "items in a line: " + count(line))
    }
    function marksIn(item, out) {
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (c.noteState !== undefined && c.moving !== undefined) {
                out.push(c)
            }
            marksIn(c, out)
        }
        return out
    }
    // A mark built by a state change during play moves (A4); built with the line it stays still.
    function test_markOfAStateChangeMoves_data() {
        return [{ tag: "tab", comp: tabComponent, notes: tabNotes(8) }, { tag: "notation", comp: bassComponent, notes: midiNotes(8) }]
    }
    function test_markOfAStateChangeMoves(row) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
        const staff = createTemporaryObject(row.comp, tc, { bars: bars(8), notes: row.notes })
        waitForRendering(staff)
        compare(marksIn(staff, []).length, 0, "no marks for pending notes")
        // Past the calm after new notes: now a state comes from play.
        tryVerify(function () { return !staff.calm })
        staff.setNoteState(0, "hit")
        tryVerify(function () { return marksIn(staff, []).length === 1 })
        verify(marksIn(staff, [])[0].moving, "the new mark pulses")

        const built = createTemporaryObject(row.comp, tc, { bars: bars(8), notes: row.notes.map(function (n, i) {
            return Object.assign({}, n, i === 0 ? { state: "hit" } : {}) }) })
        waitForRendering(built)
        const marks = marksIn(built, [])
        compare(marks.length, 1)
        verify(!marks[0].moving, "a mark built with its line stays still")
    }

    // Every line draws its notes on its own staff, also lines below the top one and after a
    // page turn (review #155: they stood one or two lines lower).
    function test_notesStandOnTheirLine() {
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(35), notes: tabNotes(35) })
        waitForRendering(staff)
        const check = function () {
            for (const k in staff.lineCache) {
                const L = staff.lineCache[k]
                const strings = L.lines.filter(function (r) { return r.kind === "line" })
                const top = Math.min.apply(null, strings.map(function (r) { return r.y }))
                const bottom = Math.max.apply(null, strings.map(function (r) { return r.y }))
                for (const f of L.frets) {
                    verify(f.y >= top - 1 && f.y <= bottom + 1, "line " + k + ": fret at " + f.y + " outside " + top + "–" + bottom)
                }
                for (const i in L.boxes) {
                    compare(L.boxes[i].sys, 0, "line " + k + " band")
                }
            }
        }
        check()
        staff.position = staff.perSystem * 2 + 0.1
        tryVerify(function () { return staff.lineCache[3] !== undefined })
        check()
    }
    function test_notationStandsOnItsLine() {
        const staff = createTemporaryObject(bassComponent, tc, { bars: bars(35), notes: midiNotes(35) })
        waitForRendering(staff)
        for (const k in staff.lineCache) {
            const L = staff.lineCache[k]
            for (const i in L.boxes) {
                compare(L.boxes[i].sys, 0, "line " + k)
            }
            for (const m of L.marks) {
                verify(m.y < staff.systemHeight, "line " + k + ": mark at " + m.y)
            }
        }
    }

    // New notes with their states set again (Kontra transposes during a run) do not make
    // every mark move at once (review #155); a state set later in play does.
    function test_newNotesWithStatesStayStill() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
        const staff = createTemporaryObject(tabComponent, tc, { bars: bars(8), notes: tabNotes(8) })
        waitForRendering(staff)
        staff.notes = tabNotes(8).map(function (n) { return Object.assign({}, n, { fret: n.fret + 1 }) })
        for (let i = 0; i < 6; i++) {
            staff.setNoteState(i, "hit")
        }
        tryVerify(function () { return marksIn(staff, []).length === 6 })
        compare(marksIn(staff, []).filter(function (m) { return m.moving }).length, 0)
        wait(800)
        staff.setNoteState(6, "hit")
        tryVerify(function () { return marksIn(staff, []).length === 7 })
        compare(marksIn(staff, []).filter(function (m) { return m.moving }).length, 1)
    }

    // Right after it was made the staff's room still settles (a page opening, Kontra 12.11.:
    // the first line showed squeezed, then grew and slid down). Changes then come at once;
    // only later ones move.
    function test_firstMomentStandsStill_data() {
        return [{ tag: "tab", comp: tabComponent, notes: tabNotes(8), key: "lineSpacing", to: 11 },
                { tag: "notation", comp: bassComponent, notes: midiNotes(8), key: "staffSpace", to: 8 }]
    }
    function test_firstMomentStandsStill(row) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
        const staff = createTemporaryObject(row.comp, tc, { bars: bars(8), notes: row.notes })
        staff[row.key] = row.to
        tryVerify(function () { return lineItems(staff).length > 0 })
        waitForRendering(staff)
        compare(lineItems(staff)[0].zoom, 1, "the first line grew in")
    }

    // A new spacing (a row came above, Kontra 12.11.) moves a line up or down only: the width
    // stays, nothing slides sideways.
    function test_newSpacingOnlyUpDown_data() {
        return [{ tag: "tab", comp: tabComponent, notes: tabNotes(8), key: "lineSpacing", to: 11 },
                { tag: "notation", comp: bassComponent, notes: midiNotes(8), key: "staffSpace", to: 8 }]
    }
    function test_newSpacingOnlyUpDown(row) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
        const staff = createTemporaryObject(row.comp, tc, { bars: bars(8), notes: row.notes })
        tryVerify(function () { return lineItems(staff).length > 0 && staff.grown })
        const line = lineItems(staff)[0]
        staff[row.key] = row.to
        tryVerify(function () { return line.zoom !== 1 }, 500, "the line moves")
        compare(line.transform[0].xScale, 1, "the line slid sideways")
    }

    // A new spacing waits like a new size (Kontra 12.11.: the presentation scaled the spacing
    // at once and went full screen a moment later, two layouts and a jump from 3 to 4 lines).
    // The bar width may follow the spacing too (Kontra binds it to the same scale; the bass
    // staff's default is staffSpace * 18): it waits as well (review #159).
    Component { id: tabScaledComponent; KanteTabStaff { width: 1500; height: 800; systems: 3; lineSpacing: 14; minBarWidth: lineSpacing * 14 } }
    Component { id: bassDefaultComponent; KanteBassStaff { width: 1500; height: 800; systems: 3; staffSpace: 10 } }
    function test_spacingSettlesWithSize_data() {
        return [{ tag: "tab", comp: tabComponent, notes: tabNotes(16), key: "lineSpacing", to: 21 },
                { tag: "notation", comp: bassComponent, notes: midiNotes(16), key: "staffSpace", to: 15 },
                { tag: "tab, bar width by spacing", comp: tabScaledComponent, notes: tabNotes(16), key: "lineSpacing", to: 21 },
                { tag: "notation, default bar width", comp: bassDefaultComponent, notes: midiNotes(16), key: "staffSpace", to: 15 }]
    }
    function test_spacingSettlesWithSize(row) {
        const staff = createTemporaryObject(row.comp, tc, { bars: bars(16), notes: row.notes, settleMs: 120 })
        waitForRendering(staff)
        const r = staff.lineRevision
        staff[row.key] = row.to
        staff.height = 850
        wait(50)
        compare(staff.lineRevision, r, "laid out before the room settled")
        tryVerify(function () { return staff.lineRevision === r + 1 })
        wait(200)
        compare(staff.lineRevision, r + 1, "laid out twice")
    }
}
