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
}
