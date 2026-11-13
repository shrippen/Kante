import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * The tempo box is one stop for Tab (Kontra QA 28.10., B8, P7 with the keyboard): its content
 * item (a text input, in Kontra's style on Linux a text field) was a second stop. Run:
 * tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteSpeedTab"
    width: 1200
    height: 200
    when: windowShown

    Component { id: barComponent; KanteTransportBar { width: 1200; metronomeVisible: true } }
    Component { id: fieldComponent; QQC2.TextField { } }

    // Tab from the box goes straight on to the metronome.
    function tabLeaves(bar, box) {
        box.forceActiveFocus(Qt.TabFocusReason)
        keyClick(Qt.Key_Tab)
        const now = bar.Window.activeFocusItem
        return now && now.text === bar.metronomeText ? "" : String(now)
    }

    function test_speedIsOneTabStop() {
        // In the window's content: a TestCase is no visible parent, Tab would find nothing.
        const bar = createTemporaryObject(barComponent, tc.Window.contentItem)
        waitForRendering(bar)
        const box = findChild(bar, "speedBox")
        verify(box !== null, "speed box found")
        verify(box.activeFocusOnTab, "the box is a stop")
        // The style's own content (Basic: a text input), then a text field as in Kontra's style.
        compare(tabLeaves(bar, box), "", "after the box, Tab stopped at")
        box.contentItem = createTemporaryObject(fieldComponent, box)
        compare(tabLeaves(bar, box), "", "with a text field inside, Tab stopped at")
    }
}
