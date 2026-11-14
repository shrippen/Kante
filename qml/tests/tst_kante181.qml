import QtQuick
import QtTest
import Kante

/**
 * Kante 1.81, tablature that fills its height (Kontra 12.11.: four lines and a third of the
 * page empty): in fill mode the staff takes as many lines as fit at its spacing, no more
 * than the piece needs, and grows the spacing until they fill the height, up to maxGrow.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante181"
    width: 1000
    height: 900
    when: windowShown

    // Bar starts every 2 s; one note per bar.
    function bars(count) {
        const list = []
        for (let i = 0; i < count; i++) {
            list.push({ time: i * 2 })
        }
        return list
    }
    function notes(count) {
        const list = []
        for (let i = 0; i < count; i++) {
            list.push({ time: i * 2 + 0.5, duration: 0.5, beats: 1, string: i % 4, fret: i % 5 })
        }
        return list
    }

    Component {
        id: staffComponent
        KanteTabStaff { width: 900; lineSpacing: 14; minBarWidth: 200 }
    }

    function make(props) {
        const staff = createTemporaryObject(staffComponent, tc, props)
        verify(staff)
        waitForRendering(staff)
        return staff
    }

    function test_fillsTheHeightWithGrownLines() {
        // A line is lineUnits * 14 high; room for 3.4 lines, 40 bars need more.
        const probe = make({ bars: bars(40), notes: notes(40), height: 100 })
        const height = probe.lineUnits * 14 * 3.4
        const staff = make({ bars: bars(40), notes: notes(40), fill: true, height: height })
        compare(staff.shownSystems, 3)
        verify(staff.ls > 14)
        fuzzyCompare(staff.systemHeight * staff.shownSystems, height, 1)
    }

    function test_shortPieceGrowsUpToMaxGrow() {
        const staff = make({ bars: bars(2), notes: notes(2), fill: true, height: 800 })
        compare(staff.shownSystems, 1)
        fuzzyCompare(staff.ls, 14 * 1.5, 0.01)
    }

    function test_lowStaffShrinksToOneLine() {
        const probe = make({ bars: bars(8), notes: notes(8), height: 100 })
        const height = probe.lineUnits * 14 * 0.6
        const staff = make({ bars: bars(8), notes: notes(8), fill: true, height: height })
        compare(staff.shownSystems, 1)
        verify(staff.ls < 14)
        fuzzyCompare(staff.systemHeight, height, 1)
    }

    function test_withoutFillSystemsHold() {
        const staff = make({ bars: bars(40), notes: notes(40), systems: 2, height: 900 })
        compare(staff.shownSystems, 2)
        compare(staff.ls, 14)
    }

    function test_sectionsAndEndingsStillFit() {
        const list = bars(40)
        list[0].section = "Intro"
        list[4].endings = [1]
        const probe = make({ bars: list, notes: notes(40), height: 100 })
        const height = probe.lineUnits * 14 * 2.5
        const staff = make({ bars: list, notes: notes(40), fill: true, height: height })
        compare(staff.shownSystems, 2)
        verify(staff.systemHeight * staff.shownSystems <= height + 1)
        verify(staff.systemHeight * staff.shownSystems >= height - 2)
    }
}
