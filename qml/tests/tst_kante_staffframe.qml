import QtQuick
import QtTest
import Kante

/**
 * KanteStaffFrame: what KanteBassStaff and KanteTabStaff share besides their notation: the
 * lookups in time, the loop cut into lines and the room that settles.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteStaffFrame"
    width: 400
    height: 300
    when: windowShown

    Component { id: frameComp; KanteStaffFrame {} }

    function bars() {
        return [{ time: 0, end: 2 }, { time: 2, end: 4 }, { time: 4, end: 6 }, { time: 6, end: 8 }]
    }

    function test_lastAtOrBefore() {
        const f = createTemporaryObject(frameComp, tc)
        const list = [{ time: 0 }, { time: 1 }, { time: "2" }]
        compare(f.lastAtOrBefore(list, -1), -1, "before the first")
        compare(f.lastAtOrBefore(list, 0), 0)
        compare(f.lastAtOrBefore(list, 0.9), 0)
        compare(f.lastAtOrBefore(list, 1), 1)
        compare(f.lastAtOrBefore(list, 99), 2)
        compare(f.lastAtOrBefore([], 1), -1)
        compare(f.lastAtOrBefore(undefined, 1), -1)
    }

    function test_barAt() {
        const f = createTemporaryObject(frameComp, tc)
        compare(f.barAt(bars(), -1), 0, "the first bar before the start")
        compare(f.barAt(bars(), 1.99), 0)
        compare(f.barAt(bars(), 2), 1)
        compare(f.barAt(bars(), 7.5), 3)
        compare(f.barAt([], 1), 0)
    }

    function test_barLabel() {
        const f = createTemporaryObject(frameComp, tc)
        compare(f.barLabel({ number: "7" }, 2), "7", "written number")
        compare(f.barLabel({ number: 5 }, 2), "5")
        compare(f.barLabel({}, 2), "3", "index + 1")
        compare(f.barLabel({ number: "" }, 2), "3")
        compare(f.barLabel(3, 3), "4", "a plain time")
    }

    function test_loopX() {
        const f = createTemporaryObject(frameComp, tc, { perSystem: 2, firstBar: 0, headerWidth: 50, barWidth: 100 })
        const xOf = function (t, b) { return -1 }
        compare(f.loopX(bars(), 2, 1, xOf), 150, "bar start: its line")
        compare(f.loopX(bars(), 4, 1, xOf), 250, "bar end: the next line")
        compare(f.loopX(bars(), 3, 1, xOf), -1, "inside: the staff's xOf")
        compare(f.loopX(bars(), 4, 2, xOf), 50, "second line starts at the header")
    }

    function test_cutLoop() {
        const f = createTemporaryObject(frameComp, tc, { perSystem: 2, firstBar: 0, headerWidth: 50, barWidth: 100 })
        const xOf = function (t, b) { return 50 + (b % 2) * 100 + (t - bars()[b].time) * 10 }
        compare(f.cutLoop(0, 2, 2, 0, bars(), 1, 5, xOf).length, 0, "no width: nothing")
        compare(f.cutLoop(0, 2, 2, 400, bars(), -1, 5, xOf).length, 0, "no loop: nothing")

        const parts = f.cutLoop(0, 2, 2, 400, bars(), 1, 5, xOf)
        compare(parts.length, 2)
        compare(parts[0].sys, 0)
        verify(parts[0].left && !parts[0].right, "starts on the first line, runs on")
        compare(parts[1].sys, 1)
        verify(!parts[1].left && parts[1].right, "runs in, ends on the second line")
    }

    function test_roomSettles() {
        const f = createTemporaryObject(frameComp, tc, { settleMs: 50, width: 300, height: 100 })
        f.takeSize()
        compare(f.layoutSize.width, 300)
        f.width = 500
        compare(f.layoutSize.width, 300, "the drawn lines stay while the room changes")
        tryCompare(f.layoutSize, "width", 500)
    }

    function test_linesStayCached() {
        let laid = []
        const f = createTemporaryObject(frameComp, tc, { perSystem: 2, systems: 2, barCount: 8,
            layoutLine: function (first, per) { laid.push(first); return { first: first } } })
        f.syncLines()
        compare(laid.join(), "0,2")
        compare(f.lineModel.count, 2)

        f.firstBar = 2
        f.syncLines()
        compare(laid.join(), "0,2,4", "line 1 stays, only line 2 comes in")

        f.firstBar = 4
        f.syncLines()
        compare(laid.join(), "0,2,4,6")
        compare(f.lineModel.get(0).lineIndex, 2)
    }
}
