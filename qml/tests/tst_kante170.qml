import QtQuick
import QtQuick.Controls
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.70, from Mitori's dialogs: a KanteDialog of the content's size (Fit) measures its
 * content. The scope sat as a second child of the content, so the dialog's implicit content
 * size was 0 (Fit 0 wide, a text without contentHeight ran into the buttons). The dialog takes
 * its content size from the app's item now.
 * The scope stays in the content: a disabled item in an open dialog keeps Kante's colours (1.51).
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

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    Component {
        id: disabledDialogs
        KanteDialog {
            property alias off: off
            Rectangle {
                id: off
                width: 40
                height: 20
                enabled: false
                property color ink: Kirigami.Theme.textColor
            }
        }
    }

    function test_disabledInDialogKeepsKante() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const dialog = createTemporaryObject(disabledDialogs, tc)
        dialog.open()
        tryVerify(() => dialog.opened)
        tryVerify(() => Qt.colorEqual(dialog.off.ink, KanteStyle.disabledTextColor), 2000,
                  "disabled text " + dialog.off.ink + ", not " + KanteStyle.disabledTextColor)
        dialog.close()
    }

    function test_fitMeasuresContent() {
        const dialog = createTemporaryObject(dialogs, tc)
        verify(dialog.contentWidth > 0, "content width " + dialog.contentWidth)
        verify(dialog.contentHeight > 0, "content height " + dialog.contentHeight)
    }
}
