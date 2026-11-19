pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtTest
import Kante

/**
 * KanteScrollArea: content height from the children, the bar shows only while there is
 * something to scroll, one wheel notch is wheelLines lines, pixel deltas pass 1:1, the handle
 * drags, the track pages, keys scroll, and a nested ListView keeps its own wheel.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteScrollArea"
    width: 400
    height: 400
    visible: true
    when: windowShown

    Component {
        id: scene
        Item {
            width: 300
            height: 200
            property alias area: sa
            property alias rows: col
            KanteScrollArea {
                id: sa
                anchors.fill: parent
                focus: true
                ColumnLayout {
                    id: col
                    width: parent.width
                    spacing: 0
                    Repeater {
                        model: 20
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 50; color: "gray" }
                    }
                }
            }
        }
    }

    Component {
        id: nested
        Item {
            width: 300
            height: 200
            property alias area: sa
            property alias list: lv
            KanteScrollArea {
                id: sa
                anchors.fill: parent
                ColumnLayout {
                    width: parent.width
                    spacing: 0
                    ListView {
                        id: lv
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        model: 30
                        delegate: Item { required property int index; width: lv.width; height: 25 }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 400; color: "gray" }
                }
            }
        }
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
    }
    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.motion = true
    }

    function make(c) {
        const s = createTemporaryObject(c, tc)
        verify(s)
        wait(20)
        return s
    }

    function test_contentAndBar() {
        const s = make(scene)
        compare(s.area.contentHeight, 1000)
        verify(s.area.scrollable)
        verify(findChild(s.area, "kanteScrollBar").visible)
        // The content leaves room for the bar.
        verify(findChild(s.area, "kanteScrollHolder").width < s.area.width)
        s.rows.visible = true
        for (let i = s.rows.children.length - 1; i >= 1; --i) {
            s.rows.children[i].visible = false
        }
        wait(20)
        verify(!s.area.scrollable)
        verify(!findChild(s.area, "kanteScrollBar").visible)
        compare(findChild(s.area, "kanteScrollHolder").width, s.area.width)
    }

    function test_wheelNotch() {
        const s = make(scene)
        const step = 3 * s.area.lineHeight
        mouseWheel(s.area, 100, 100, 0, -120)
        compare(s.area.contentY, step)
        mouseWheel(s.area, 100, 100, 0, 120)
        compare(s.area.contentY, 0)
        mouseWheel(s.area, 100, 100, 0, 120)
        compare(s.area.contentY, 0)
        for (let i = 0; i < 40; ++i) {
            mouseWheel(s.area, 100, 100, 0, -120)
        }
        compare(s.area.contentY, 800)
    }

    // A fraction of a notch (a high-resolution wheel) scrolls that fraction of a step.
    function test_partialNotch() {
        const s = make(scene)
        mouseWheel(s.area, 100, 100, 0, -15)
        compare(s.area.contentY, 9)
    }

    function test_handleDrag() {
        const s = make(scene)
        const handle = findChild(s.area, "kanteScrollHandle")
        const bar = findChild(s.area, "kanteScrollBar")
        verify(handle.height >= KanteStyle.unit(28))
        compare(handle.y, 0)
        const x = bar.x + bar.width / 2
        mousePress(s.area, x, handle.height / 2)
        mouseMove(s.area, x, handle.height / 2 + 40)
        mouseRelease(s.area, x, handle.height / 2 + 40)
        verify(s.area.contentY > 0)
        compare(handle.y, 40)
        // Dragged to the bottom.
        mousePress(s.area, x, handle.y + 2)
        mouseMove(s.area, x, 1000)
        mouseRelease(s.area, x, 1000)
        compare(s.area.contentY, 800)
    }

    function test_trackPages() {
        const s = make(scene)
        const bar = findChild(s.area, "kanteScrollBar")
        mouseClick(s.area, bar.x + bar.width / 2, s.area.height - 4)
        compare(s.area.contentY, 180)
        mouseClick(s.area, bar.x + bar.width / 2, 2)
        // The handle sits near the top now, but below y = 2 unless the page went back to 0.
        compare(s.area.contentY, 0)
    }

    function test_keys() {
        const s = make(scene)
        s.area.forceActiveFocus()
        keyClick(Qt.Key_PageDown)
        compare(s.area.contentY, 180)
        keyClick(Qt.Key_End)
        compare(s.area.contentY, 800)
        keyClick(Qt.Key_PageUp)
        compare(s.area.contentY, 620)
        keyClick(Qt.Key_Home)
        compare(s.area.contentY, 0)
    }

    function test_nestedListView() {
        const s = make(nested)
        mouseWheel(s.list, 100, 50, 0, -120)
        // The list's own wheel handling moves it over a few frames.
        tryVerify(function () { return s.list.contentY > 0 })
        // The list takes it while it can move.
        verify(s.list.contentY > 0)
        compare(s.area.contentY, 0)
        // At its end the area scrolls.
        s.list.positionViewAtEnd()
        mouseWheel(s.list, 100, 50, 0, -120)
        tryVerify(function () { return s.area.contentY > 0 })
    }

    function test_systemKind() {
        KanteStyle.kind = KanteStyle.Kind.System
        const s = make(scene)
        verify(findChild(s.area, "kanteScrollBar").visible)
    }
}
