import QtQuick
import QtTest
import Kante

/**
 * Kante 1.40, staves whose notes are emptied while the position stays behind the last note
 * (Kontra hides the staff by passing no notes): the accessible description read the note at
 * the old index before currentIndex followed and logged "TypeError: Value is undefined".
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante140"
    width: 900
    height: 500
    when: windowShown

    function notes() {
        return [
            { time: 0, duration: 0.5, beats: 1, string: 0, fret: 3, midi: 31 },
            { time: 0.5, duration: 0.5, beats: 1, string: 0, fret: 5, midi: 33 }
        ]
    }

    Component { id: tabComponent; KanteTabStaff { width: 900; barsPerSystem: 1; systems: 1 } }
    Component { id: bassComponent; KanteBassStaff { width: 900; barsPerSystem: 1; systems: 1 } }

    function checkEmptied(component) {
        failOnWarning(/TypeError/)
        var staff = createTemporaryObject(component, tc.Window.contentItem, { notes: notes(), position: 0.7 })
        verify(staff)
        compare(staff.currentIndex, 1)
        verify(staff.Accessible.description.length > 0)

        staff.notes = []
        compare(staff.currentIndex, -1)
        verify(staff.Accessible.description.length > 0)
    }

    function test_tabStaffEmptied() {
        checkEmptied(tabComponent)
    }

    function test_bassStaffEmptied() {
        checkEmptied(bassComponent)
    }
}
