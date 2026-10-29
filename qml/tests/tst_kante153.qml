import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.53: a KanteListRow in a ListView takes a tap on any row, not only the first; a
 * drag out of the row is still no tap. A KanteScope torn down right after its content grew
 * leaves no deferred call behind. Run: tools/check-qml.sh.
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

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: lateChild
        Item {
            enabled: false
        }
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

    Repeater {
        id: scopes
        model: 0
        delegate: Item {
            property alias box: box
            KanteScope { target: parent }
            Item {
                id: box
                enabled: false
            }
        }
    }

    // A delegate with a scope, gone right after its content grew (a page or dialog in lmix):
    // the scope's deferred sweep ran in the gone delegate's context ("Property 'alive' … is
    // not a function").
    function test_aScopeGoneBeforeItsSweepLeavesNoError() {
        failOnWarning(/KanteScope|invalid context/)
        KanteStyle.kind = KanteStyle.Kind.Kante
        for (let i = 0; i < 5; i++) {
            scopes.model = 1
            wait(20)
            lateChild.createObject(scopes.itemAt(0).box)
            scopes.model = 0
            wait(20)
        }
    }
}
