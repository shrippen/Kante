import QtQuick
import QtQuick.Controls
import QtTest
import Kante

/**
 * Kante 1.70, from Mitori's dialogs: a KanteDialog of the content's size (Fit) measures its
 * content. The scope sat as a second child of the content, so the dialog's implicit content
 * size was 0 (Fit 0 wide, a text without contentHeight ran into the buttons).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante170"
    width: 400
    height: 300
    when: windowShown

    Component {
        id: dialogs
        KanteDialog {
            Label { text: "Hello" }
        }
    }

    function test_fitMeasuresContent() {
        const dialog = createTemporaryObject(dialogs, tc)
        verify(dialog.implicitContentWidth > 0, "content width " + dialog.implicitContentWidth)
        verify(dialog.implicitContentHeight > 0, "content height " + dialog.implicitContentHeight)
    }
}
