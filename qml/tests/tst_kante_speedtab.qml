import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * The tempo box is one stop for Tab (Kontra QA 28.10., B8, P7 with the keyboard): in Kontra's
 * style on Linux its content item is a text field, a second stop. The test gives the box such a
 * field, as that style does. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteSpeedTab"
    width: 1200
    height: 200
    when: windowShown

    Component { id: barComponent; KanteTransportBar { width: 1200 } }
    Component { id: fieldComponent; QQC2.TextField { } }

    function test_speedIsOneTabStop() {
        const bar = createTemporaryObject(barComponent, tc)
        const box = findChild(bar, "speedBox")
        verify(box !== null, "speed box found")
        verify(box.activeFocusOnTab, "the box is a stop")
        box.contentItem = createTemporaryObject(fieldComponent, box)
        verify(!box.contentItem.activeFocusOnTab, "the text inside the speed box is a Tab stop")
    }
}
