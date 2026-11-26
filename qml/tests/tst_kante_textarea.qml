import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/** KanteTextArea: growth, scrolling, keys, skin. Run: tools/check-qml.sh (offscreen). */
TestCase {
    id: tc
    name: "KanteTextArea"
    width: 400
    height: 400
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: areaComponent
        Column {
            property alias first: first
            property alias area: area
            property alias last: last
            width: 300
            QQC2.TextField { id: first }
            KanteTextArea { id: area; width: 300; placeholderText: "Contact"; maxLines: 3 }
            QQC2.TextField { id: last }
        }
    }

    function scene() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        return createTemporaryObject(areaComponent, tc.Window.contentItem)
    }

    function test_growsThenStops() {
        let s = scene()
        let one = s.area.height
        s.area.text = "a\nb"
        tryVerify(function () { return s.area.height > one })
        let two = s.area.height
        s.area.text = "a\nb\nc\nd\ne\nf"
        wait(50)
        let capped = s.area.height
        s.area.text = "a\nb\nc\nd\ne\nf\ng\nh"
        wait(50)
        compare(s.area.height, capped)
        verify(capped >= two)
        verify(s.area.area.contentHeight > s.area.height)
    }

    function test_enterMakesNewLine() {
        let s = scene()
        s.area.area.forceActiveFocus()
        keyClick(Qt.Key_A)
        keyClick(Qt.Key_Return)
        keyClick(Qt.Key_B)
        compare(s.area.text, "a\nb")
    }

    function test_tabLeavesField() {
        let s = scene()
        s.area.area.forceActiveFocus()
        keyClick(Qt.Key_A)
        keyClick(Qt.Key_Tab)
        compare(s.area.text, "a")
        verify(s.last.activeFocus)
        keyClick(Qt.Key_Backtab)
        verify(s.area.area.activeFocus)
        compare(s.area.text, "a")
    }

    function test_placeholderInBox() {
        let s = scene()
        let ph = findChild(s.area, "kantePlaceholder")
        verify(ph !== null)
        verify(ph.visible)
        s.area.text = "x"
        verify(!ph.visible)
    }

    function test_systemHasNoPlaceholderLabel() {
        let s = scene()
        KanteStyle.kind = KanteStyle.Kind.System
        let ph = findChild(s.area, "kantePlaceholder")
        verify(!ph.visible)
    }

    // The skin is the field's background: it stays put while the text scrolls.
    function test_skinStaysInView() {
        let s = scene()
        s.area.invalid = true
        s.area.text = "a\nb\nc\nd\ne\nf\ng\nh"
        s.area.area.cursorPosition = s.area.text.length
        wait(100)
        let skin = s.area.background
        verify(skin !== null)
        let top = skin.mapToItem(s.area, 0, 0).y
        let bottom = skin.mapToItem(s.area, 0, skin.height).y
        compare(top, 0)
        compare(bottom, s.area.height)
    }
}
