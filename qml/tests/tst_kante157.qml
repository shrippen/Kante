import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.57, from lmix's keys overview: KanteDialog's `footerStart` puts the app's own
 * buttons at the start of the footer, before the standard buttons, in every style and
 * after a switch at run time. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante157"
    width: 1200
    height: 800
    when: windowShown

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    property int pressed: 0

    Component {
        id: dialogComponent
        KanteDialog {
            title: "Keys"
            standardButtons: QQC2.Dialog.Close
            footerStart: [
                KanteButton {
                    objectName: "own"
                    text: "Shortcuts…"
                    onClicked: tc.pressed++
                }
            ]
            contentHeight: 40
            Item { implicitWidth: 300; implicitHeight: 40 }
        }
    }

    function openDialog() {
        pressed = 0
        const d = createTemporaryObject(dialogComponent, tc)
        d.open()
        tryCompare(d, "opened", true)
        return d
    }

    // The own button in the footer, wholly before the standard one.
    function checkPlaced(d) {
        const own = d.footerStart[0]
        const close = d.standardButton(QQC2.Dialog.Close)
        verify(close, "a Close button")
        compare(own.parent.parent, d.footer, "in the footer shown now")
        verify(own.visible)
        const ownRight = own.mapToItem(d.footer, own.width, 0).x
        const closeLeft = close.mapToItem(d.footer, 0, 0).x
        verify(ownRight <= closeLeft, "before Close: " + ownRight + " <= " + closeLeft)
        verify(own.mapToItem(d.footer, 0, 0).x < d.footer.width / 2, "at the start")
    }

    function test_ownButtonsStandAtTheStart() {
        const d = openDialog()
        checkPlaced(d)
    }

    function test_theyAreNoStandardButtons() {
        const d = openDialog()
        let closed = 0
        d.rejected.connect(() => closed++)
        d.footerStart[0].clicked()
        compare(tc.pressed, 1)
        compare(closed, 0)
        compare(d.visible, true)
    }

    function test_theyFollowAStyleSwitch() {
        const d = openDialog()
        KanteStyle.kind = KanteStyle.Kind.System
        tryVerify(() => d.footer !== d.kanteFooter)
        checkPlaced(d)
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryVerify(() => d.footer === d.kanteFooter)
        checkPlaced(d)
    }

    function test_theFooterMakesRoom() {
        const d = openDialog()
        const own = d.footerStart[0]
        verify(d.footer.implicitWidth >= own.width + d.standardButton(QQC2.Dialog.Close).width,
               "footer " + d.footer.implicitWidth)
    }
}
