import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.58, from lmix's keys overview: KanteDialog's `footerStart` puts the app's own
 * buttons at the start of the footer, before the standard buttons, in every style and
 * after a switch at run time, mirrored right to left. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante158"
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

    Component {
        id: bareComponent
        KanteDialog {
            title: "Keys"
            standardButtons: QQC2.Dialog.NoButton
            footerStart: [
                KanteButton { text: "Shortcuts…" }
            ]
            contentHeight: 40
            Item { implicitWidth: 300; implicitHeight: 40 }
        }
    }

    // The own buttons lie inside the footer and the footer inside the dialog.
    function checkInside(d) {
        const own = d.footerStart[0]
        const top = own.mapToItem(d.footer, 0, 0).y
        verify(top >= 0, "top " + top)
        verify(top + own.height <= d.footer.height, "bottom " + (top + own.height) + " <= " + d.footer.height)
        const bottom = own.mapToItem(d.contentItem.parent, 0, own.height).y
        const dialogBottom = d.footer.mapToItem(d.contentItem.parent, 0, d.footer.height).y
        verify(bottom <= dialogBottom, "in the dialog")
        verify(d.height >= d.footer.y + d.footer.height - 0.5, "dialog " + d.height + " holds the footer")
    }

    function test_withoutStandardButtonsTheFooterHoldsThem() {
        for (const kind of [KanteStyle.Kind.Kante, KanteStyle.Kind.System]) {
            KanteStyle.kind = kind
            const d = createTemporaryObject(bareComponent, tc)
            d.open()
            tryCompare(d, "opened", true)
            verify(d.footer && d.footer.visible, "a footer in style " + kind)
            checkInside(d)
        }
    }

    function test_removedButtonsLeaveTheFooter() {
        const d = openDialog()
        const a = d.footerStart[0]
        const b = Qt.createQmlObject('import Kante; KanteButton { text: "More" }', tc)
        d.footerStart = [a, b]
        compare(b.parent.parent, d.footer)
        d.footerStart = [a]
        verify(b.parent === null || b.parent.parent !== d.footer, "b out of the footer")
        compare(a.parent.parent, d.footer)
        d.footerStart = []
        verify(a.parent === null || a.parent.parent !== d.footer, "a out of the footer")
        b.destroy()
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

    // A window laid out right to left (LayoutMirroring, as an app in Arabic or Hebrew
    // sets it): the dialog's overlay and so the dialog inherit it.
    Component {
        id: mirroredComponent
        Window {
            property alias dialog: mirroredDialog
            width: 900
            height: 600
            visible: true
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            KanteDialog {
                id: mirroredDialog
                title: "Keys"
                standardButtons: QQC2.Dialog.Close
                footerStart: [
                    KanteButton { text: "Shortcuts…" }
                ]
                contentHeight: 40
                Item { implicitWidth: 300; implicitHeight: 40 }
            }
        }
    }

    function test_rightToLeftTheyStandAtTheRight() {
        for (const kind of [KanteStyle.Kind.Kante, KanteStyle.Kind.System]) {
            KanteStyle.kind = kind
            const w = createTemporaryObject(mirroredComponent, tc)
            const d = w.dialog
            d.open()
            tryCompare(d, "opened", true)
            verify(d.mirrored, "the dialog is mirrored")
            const own = d.footerStart[0]
            const close = d.standardButton(QQC2.Dialog.Close)
            compare(own.parent.parent, d.footer)
            const ownLeft = own.mapToItem(d.footer, 0, 0).x
            const closeRight = close.mapToItem(d.footer, close.width, 0).x
            verify(ownLeft >= closeRight, "after Close in style " + kind + ": " + ownLeft + " >= " + closeRight)
            verify(ownLeft + own.width / 2 > d.footer.width / 2, "at the start, on the right")
            verify(ownLeft + own.width <= d.footer.width - d.footer.rightPadding + 0.5 || ownLeft + own.width <= d.footer.width,
                   "inside the footer")
            checkInside(d)
        }
    }
}
