import QtQuick
import QtTest
import QtQuick.Controls as QQC2
import Kante

/**
 * A focused KanteComboBox (closed or open) takes letters, digits and navigation keys itself;
 * the window's Shortcuts fire only without focus in the box.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteComboKeys"
    width: 400
    height: 300
    when: windowShown

    property int fired: 0

    Component {
        id: scene
        Item {
            width: 400
            height: 300
            property alias combo: box
            property alias other: outside
            Shortcut { sequence: "l"; onActivated: tc.fired++ }
            Shortcut { sequence: "1"; onActivated: tc.fired++ }
            Shortcut { sequence: "Delete"; onActivated: tc.fired++ }
            Shortcut { sequence: "Return"; onActivated: tc.fired++ }
            Shortcut { sequence: "Enter"; onActivated: tc.fired++ }
            Shortcut { sequence: "Ctrl+D"; onActivated: tc.fired += 100 }
            Item { id: outside; focus: true; width: 1; height: 1 }
            KanteComboBox {
                id: box
                model: ["alpha", "lima", "1st", "zulu"]
                currentIndex: 0
                width: 200
            }
        }
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        fired = 0
    }

    function make() {
        const item = createTemporaryObject(scene, tc)
        verify(item)
        waitForRendering(item)
        return item
    }

    function test_noFocusFiresShortcut() {
        const s = make()
        s.other.forceActiveFocus()
        keyClick(Qt.Key_L)
        compare(fired, 1)
    }

    function test_focusedBoxPicksByLetter() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_L)
        compare(fired, 0)
        compare(s.combo.currentIndex, 1)
        keyClick(Qt.Key_1)
        compare(fired, 0)
        compare(s.combo.currentIndex, 2)
    }

    function test_openPopupBlocksShortcuts() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_Space)
        tryCompare(s.combo.popup, "opened", true)
        keyClick(Qt.Key_L)
        keyClick(Qt.Key_1)
        keyClick(Qt.Key_Delete)
        compare(fired, 0)
    }

    // The closed box does nothing with Delete: the window's Delete (remove the selection)
    // still works while a box has focus.
    function test_deleteReachesWindow() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_Delete, Qt.NoModifier, -1)
        compare(fired, 1)
    }

    function test_ctrlStaysWithWindow() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_D, Qt.ControlModifier)
        compare(fired, 100)
    }

    // The closed box does nothing with Return and Enter: a window Shortcut on them fires.
    function test_returnEnterReachWindow() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_Return)
        compare(fired, 1)
        keyClick(Qt.Key_Enter)
        compare(fired, 2)
    }

    // An open popup takes Return and Enter: they choose the highlighted entry.
    function test_openPopupTakesReturnEnter() {
        const s = make()
        s.combo.forceActiveFocus()
        keyClick(Qt.Key_Space)
        tryCompare(s.combo.popup, "opened", true)
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Return)
        compare(fired, 0)
        compare(s.combo.currentIndex, 1)
        tryCompare(s.combo.popup, "opened", false)
        keyClick(Qt.Key_Space)
        tryCompare(s.combo.popup, "opened", true)
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Enter)
        compare(fired, 0)
        compare(s.combo.currentIndex, 2)
    }
}
