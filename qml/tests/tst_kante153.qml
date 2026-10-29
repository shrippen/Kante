import QtQuick
import QtTest
import Kante

/**
 * Kante 1.53: a KanteListRow in a ListView takes a tap on any row, not only the first; a
 * drag out of the row is still no tap. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante153"
    width: 400
    height: 300
    when: windowShown
    // Shown, as a list in a window is: a hidden item takes no pointer.
    visible: true

    property var taps: []

    ListView {
        id: list
        width: 300
        height: 200
        model: ["A", "B", "C"]
        boundsBehavior: Flickable.StopAtBounds
        delegate: KanteListRow {
            required property string modelData
            width: ListView.view.width
            focusOnClick: false
            text: modelData
            onClicked: tc.taps = tc.taps.concat([modelData])
        }
    }

    function init() {
        taps = []
    }

    function test_everyRowOfAListTakesATap() {
        const row = list.itemAtIndex(0).height
        mouseClick(list, 50, row / 2)
        wait(Qt.styleHints.mouseDoubleClickInterval + 50)
        mouseClick(list, 50, row * 1.5)
        wait(Qt.styleHints.mouseDoubleClickInterval + 50)
        mouseClick(list, 50, row * 2.5)
        compare(taps, ["A", "B", "C"])
    }

    function test_aDragOutOfARowIsNoTap() {
        const row = list.itemAtIndex(0).height
        mousePress(list, 50, row * 1.5)
        mouseMove(list, 50, row * 1.5 + 2)
        mouseMove(list, 250, row * 1.5 + 2)
        mouseRelease(list, 250, row * 2.5)
        compare(taps, [])
    }
}
