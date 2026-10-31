import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.59, from lmix's detached pages: a window that holds a Kante dialog, sheet,
 * popover or message goes down cleanly, also when the garbage collector takes it (a
 * window made with createObject(null) and no longer held). The dialog's Bindings gave
 * its background back while Qt deleted the popup (SIGSEGV in QQmlBind::~QQmlBind); this
 * file crashed the test runner before. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante159"
    when: windowShown

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    // As lmix's page window: an ApplicationWindow, the dialog on its overlay, inside an
    // item of the page.
    Component {
        id: kanteDialogWindow
        QQC2.ApplicationWindow {
            width: 600
            height: 400
            visible: true
            property alias dialog: d
            Item {
                anchors.fill: parent
                KanteDialog {
                    id: d
                    parent: QQC2.Overlay.overlay
                    anchors.centerIn: parent
                    modal: true
                    destructive: true
                    size: KanteDialog.Size.Small
                    title: "Remove input?"
                    acceptText: "Remove"
                    standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
                    footerStart: [KanteButton { text: "Undo…" }]
                    contentHeight: 40
                    QQC2.Label { text: "Spare goes." }
                }
            }
        }
    }

    Component {
        id: skinnedDialogWindow
        Window {
            width: 600
            height: 400
            visible: true
            property alias dialog: d
            QQC2.Dialog {
                id: d
                title: "Reset?"
                standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
                QQC2.Label { text: "All settings go." }
                KanteDialogSkin { dialog: d }
            }
        }
    }

    Component {
        id: kirigamiDialogWindow
        Window {
            width: 600
            height: 400
            visible: true
            property alias dialog: d
            Kirigami.Dialog {
                id: d
                title: "Reason"
                standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
                QQC2.Label { text: "Why" }
                KanteDialogSkin { dialog: d }
            }
        }
    }

    Component {
        id: sheetWindow
        Window {
            width: 600
            height: 400
            visible: true
            property alias dialog: d
            QQC2.Drawer {
                id: d
                edge: Qt.BottomEdge
                width: 600
                height: 120
                contentItem: QQC2.Label { text: "Sheet" }
                KanteSheetSkin { popup: d }
            }
        }
    }

    Component {
        id: popoverWindow
        Window {
            width: 600
            height: 400
            visible: true
            property alias dialog: d
            KantePopover {
                id: d
                title: "Tile"
                QQC2.Label { text: "Size" }
            }
        }
    }

    Component {
        id: messageWindow
        Window {
            width: 600
            height: 400
            visible: true
            // No popup: open() and close() do nothing.
            readonly property QtObject dialog: QtObject {
                property bool opened: true
                property bool visible: false
                function open() {}
                function close() {}
            }
            Kirigami.InlineMessage {
                id: m
                width: 400
                visible: true
                text: "Saved"
                KanteMessageSkin { message: m }
            }
        }
    }

    // Made, shown (opened and closed again when `open`), let go: only the garbage
    // collector holds it then.
    function makeAndLetGo(component, open, switchAfter) {
        let w = component.createObject(null)
        verify(w !== null)
        tryCompare(w, "visible", true)
        if (switchAfter) {
            KanteStyle.kind = KanteStyle.Kind.Kante
        }
        if (open) {
            w.dialog.open()
            tryCompare(w.dialog, "opened", true)
            w.dialog.close()
            tryCompare(w.dialog, "visible", false)
        }
        w.visible = false
        w = null
    }

    function goDown(component) {
        for (const kind of [KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight, KanteStyle.Kind.System]) {
            for (const open of [false, true]) {
                KanteStyle.kind = kind
                makeAndLetGo(component, open, false)
                gc()
                wait(50)
            }
        }
        // Made in another style, Kante set while it stands: the Bindings hold the
        // platform's parts to give back.
        for (const open of [false, true]) {
            KanteStyle.kind = KanteStyle.Kind.System
            makeAndLetGo(component, open, true)
            gc()
            wait(50)
        }
        // Destroyed by hand, too.
        KanteStyle.kind = KanteStyle.Kind.Kante
        const w = component.createObject(null)
        tryCompare(w, "visible", true)
        w.destroy()
        wait(50)
        gc()
        wait(50)
        // Still standing: the runner did not crash.
        verify(true)
    }

    function test_aKanteDialogWindowGoesDown() { goDown(kanteDialogWindow) }
    function test_aSkinnedDialogWindowGoesDown() { goDown(skinnedDialogWindow) }
    function test_aKirigamiDialogWindowGoesDown() { goDown(kirigamiDialogWindow) }
    function test_aSheetWindowGoesDown() { goDown(sheetWindow) }
    function test_aPopoverWindowGoesDown() { goDown(popoverWindow) }
    function test_aMessageWindowGoesDown() { goDown(messageWindow) }

    // While the dialog stands, a switch back still gives the platform's parts back.
    Component {
        id: standingDialog
        KanteDialog {
            title: "Keys"
            standardButtons: QQC2.Dialog.Close
            QQC2.Label { text: "x" }
        }
    }
    function test_aStandingDialogStillGivesThePlatformPartsBack() {
        KanteStyle.kind = KanteStyle.Kind.System
        const d = createTemporaryObject(standingDialog, tc)
        const platform = d.background
        verify(platform !== null)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(d.background, d.kanteBackground)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(d.background, platform)
    }
}
