import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.55, from lmix's dialog review: KanteDialog sizes Small, Medium and Large (at most
 * 90 % of the window) and destructive questions with the bar and the accept button in the
 * negative colour; a destructive quiet or normal KanteButton with red text. Run:
 * tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante155"
    width: 1600
    height: 900
    when: windowShown

    // Every test in the Kante style, also the first.
    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    Component {
        id: dialogComponent
        KanteDialog {
            title: "Remove bus?"
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            acceptText: "Remove bus"
            // KanteDialog has a child of its own, so it does not size to this.
            contentHeight: 2000
            Item { implicitWidth: 100; implicitHeight: 2000 }
        }
    }

    function test_sizesAreSteps() {
        const g = Kirigami.Units.gridUnit
        const steps = [[KanteDialog.Size.Small, 24], [KanteDialog.Size.Medium, 36], [KanteDialog.Size.Large, 48]]
        for (const [size, units] of steps) {
            const d = createTemporaryObject(dialogComponent, tc, { size: size })
            compare(d.width, Math.min(units * g, tc.Window.width * 0.9), "size " + size)
        }
        const fit = createTemporaryObject(dialogComponent, tc)
        compare(fit.width, fit.implicitWidth)
    }

    function test_aSizedDialogFitsTheWindow() {
        const d = createTemporaryObject(dialogComponent, tc, { size: KanteDialog.Size.Large })
        d.open()
        tryCompare(d, "opened", true)
        // The content is 2000 high: the dialog stops at 90 % of the window.
        verify(d.implicitHeight > tc.Window.height)
        compare(d.height, tc.Window.height * 0.9)
    }

    // Fit set width and height too: Qt then took them as the app's and no longer shrank a
    // dialog taller than the window to it, the footer went out of view.
    function test_aFitDialogLeavesItsSizeToQt() {
        const d = createTemporaryObject(dialogComponent, tc)
        d.open()
        tryCompare(d, "opened", true)
        verify(d.implicitHeight > tc.Window.height)
        verify(d.height <= tc.Window.height, "height " + d.height + " in " + tc.Window.height)
    }

    // Back from a size step to Fit at run time: the restored width and
    // height counted as the app's, and Qt no longer fitted the dialog in.
    function test_backToFitLeavesTheSizeToQtAgain() {
        const d = createTemporaryObject(dialogComponent, tc, { size: KanteDialog.Size.Small })
        d.open()
        tryCompare(d, "opened", true)
        d.size = KanteDialog.Size.Fit
        d.close()
        tryCompare(d, "visible", false)
        d.open()
        tryCompare(d, "opened", true)
        verify(d.height <= tc.Window.height, "height " + d.height + " in " + tc.Window.height)
    }

    function test_destructiveIsRed() {
        const d = createTemporaryObject(dialogComponent, tc, { destructive: true, size: KanteDialog.Size.Small })
        d.open()
        tryCompare(d, "opened", true)
        compare(d.kanteBarColor, KanteStyle.negativeTextColor)
        const accept = d.standardButton(QQC2.Dialog.Ok)
        compare(accept.text, "Remove bus")
        compare(accept.emphasis, KanteButton.Emphasis.Destructive)
        compare(d.standardButton(QQC2.Dialog.Cancel).emphasis, KanteButton.Emphasis.Normal)

        // Cancel first, the red button after it.
        const cancel = d.standardButton(QQC2.Dialog.Cancel)
        verify(cancel.mapToItem(null, 0, 0).x < accept.mapToItem(null, 0, 0).x, "Cancel before the red button")

        const plain = createTemporaryObject(dialogComponent, tc)
        plain.open()
        tryCompare(plain, "opened", true)
        compare(plain.kanteBarColor, KanteStyle.accentColor)
        compare(plain.standardButton(QQC2.Dialog.Ok).emphasis, KanteButton.Emphasis.Primary)
    }

    // The button box sets its standard texts again on a language change (at start, once
    // the translations are in): the accept button read "OK" in German, not its name.
    function test_acceptTextOutlivesTheStandardTexts() {
        const d = createTemporaryObject(dialogComponent, tc)
        d.open()
        tryCompare(d, "opened", true)
        const accept = d.standardButton(QQC2.Dialog.Ok)
        compare(accept.text, "Remove bus")
        // Another language's standard text, so it shows that it was kept.
        accept.text = "Ja"
        compare(accept.text, "Remove bus")
        // Unset, the standard text it got last comes back.
        d.acceptText = ""
        compare(accept.text, "Ja")
        // A language change while unset, then set and unset again: the newest standard
        // text comes back, not the one kept before.
        accept.text = "Oui"
        d.acceptText = "Remove bus"
        compare(accept.text, "Remove bus")
        d.acceptText = ""
        compare(accept.text, "Oui")
    }

    // From one name to another, then unset: the name before was kept as the standard text,
    // the button read "Remove bus" instead of OK.
    function test_aNewNameIsNoStandardText() {
        const d = createTemporaryObject(dialogComponent, tc)
        d.open()
        tryCompare(d, "opened", true)
        const accept = d.standardButton(QQC2.Dialog.Ok)
        const standard = d.standardTexts.find(pair => pair[0] === accept)[1]
        d.acceptText = "Add"
        compare(accept.text, "Add")
        d.acceptText = ""
        compare(accept.text, standard)
    }

    // Yes is the accept button of a yes/no question: red as Ok would be.
    function test_aDestructiveYesIsRed() {
        const d = createTemporaryObject(dialogComponent, tc, {
            destructive: true, standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.No, acceptText: "" })
        d.open()
        tryCompare(d, "opened", true)
        compare(d.standardButton(QQC2.Dialog.Yes).emphasis, KanteButton.Emphasis.Destructive)
        compare(d.standardButton(QQC2.Dialog.No).emphasis, KanteButton.Emphasis.Normal)
    }

    // A quiet button that removes (lmix's audio column, P02): red text, no
    // fill, so it stays smaller than the actions beside it.
    Component {
        id: quietComponent
        KanteButton {
            text: "Remove bus"
            emphasis: KanteButton.Emphasis.Quiet
        }
    }
    function test_aDestructiveQuietButtonIsRedText() {
        const b = createTemporaryObject(quietComponent, tc, { destructive: true })
        compare(b.kanteInk, KanteStyle.negativeTextColor)
        verify(!b.filled)
        const plain = createTemporaryObject(quietComponent, tc)
        compare(plain.kanteInk, KanteStyle.mutedTextColor)
        // Filled buttons keep their ink: the red one is already red.
        const filled = createTemporaryObject(quietComponent, tc, { destructive: true, emphasis: KanteButton.Emphasis.Primary })
        compare(filled.kanteInk, KanteStyle.primaryTextColor)
        // The platform's button (System) takes it in its palette.
        KanteStyle.kind = KanteStyle.Kind.System
        compare(b.palette.buttonText, KanteStyle.negativeTextColor)
    }
}
