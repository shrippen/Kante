import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.79, from Mitori: `KanteDialog.rejectText` names the reject button (Cancel, No,
 * Close, Abort) like `acceptText` names the accept button. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante179"
    width: 800
    height: 600
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

    Component {
        id: discardComponent
        KanteDialog {
            title: "Discard the round?"
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            rejectText: "Keep going"
            QQC2.Label { text: "Content" }
        }
    }

    Component {
        id: yesNoComponent
        KanteDialog {
            title: "Remove bus?"
            standardButtons: QQC2.Dialog.Yes | QQC2.Dialog.No
            rejectText: "Keep it"
            QQC2.Label { text: "Content" }
        }
    }

    function opened(component, props) {
        const d = createTemporaryObject(component, tc, props || {})
        d.open()
        tryCompare(d, "opened", true)
        return d
    }

    function test_rejectButtonIsNamed() {
        const d = opened(discardComponent)
        compare(d.rejectButton(), d.standardButton(QQC2.Dialog.Cancel))
        tryCompare(d.rejectButton(), "text", "Keep going")
        // The accept button keeps its standard text.
        verify(d.acceptButton().text !== "Keep going")
    }

    function test_rejectTextBackToStandard() {
        const d = opened(discardComponent)
        const reject = d.rejectButton()
        const standard = d.standardTexts.find(pair => pair[0] === reject)[1]
        verify(standard !== "Keep going")
        d.rejectText = ""
        compare(reject.text, standard)
        d.rejectText = "Back"
        compare(reject.text, "Back")
    }

    // The button box sets its standard texts again on a language change.
    function test_rejectTextOutlivesTheStandardTexts() {
        const d = opened(discardComponent)
        const reject = d.rejectButton()
        reject.text = "Abbrechen"
        compare(reject.text, "Keep going")
        d.rejectText = ""
        compare(reject.text, "Abbrechen")
        reject.text = "Annuler"
        d.rejectText = "Keep going"
        compare(reject.text, "Keep going")
        d.rejectText = ""
        compare(reject.text, "Annuler")
    }

    function test_noOfYesNo() {
        const d = opened(yesNoComponent)
        compare(d.rejectButton(), d.standardButton(QQC2.Dialog.No))
        tryCompare(d.rejectButton(), "text", "Keep it")
        verify(d.acceptButton().text !== "Keep it")
    }

    function test_unsetTextLeavesTheStandardOne() {
        const d = opened(discardComponent, { rejectText: "" })
        verify(d.rejectButton().text !== "Keep going")
        verify(d.rejectButton().text.length > 0)
    }

    function test_afterAStyleSwitch() {
        const d = opened(discardComponent)
        tryCompare(d.rejectButton(), "text", "Keep going")
        KanteStyle.kind = KanteStyle.Kind.System
        tryCompare(d.rejectButton(), "text", "Keep going")
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(d.rejectButton(), "text", "Keep going")
        d.rejectText = ""
        verify(d.rejectButton().text !== "Keep going")
    }

    function test_withAcceptText() {
        const d = opened(discardComponent, { acceptText: "Discard" })
        tryCompare(d.acceptButton(), "text", "Discard")
        tryCompare(d.rejectButton(), "text", "Keep going")
        d.acceptText = ""
        verify(d.acceptButton().text !== "Discard")
        compare(d.rejectButton().text, "Keep going")
        d.acceptText = "Throw away"
        d.rejectText = ""
        compare(d.acceptButton().text, "Throw away")
        verify(d.rejectButton().text !== "Keep going")
    }
}
