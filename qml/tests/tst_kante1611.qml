import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.61.1: a KanteListRow under a modal popup (a sheet, a dialog) takes no taps meant for
 * the popup. Its passive tap handler saw them anyway (Mitori: a tap on the rating in the
 * technique sheet also opened the row underneath). Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante1611"
    width: 400
    height: 400
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    Component {
        id: scene
        Item {
            property alias row: row
            property alias popup: popup
            property alias button: button
            width: 400
            height: 400
            KanteListRow { id: row; width: 400; y: 100; text: "Under the sheet" }
            QQC2.Popup {
                id: popup
                modal: true
                x: 50; y: 60; width: 300; height: 120
                closePolicy: QQC2.Popup.NoAutoClose
                // Like KanteLevelPicker's cells: a TapHandler that only grabs passively at first.
                Rectangle {
                    id: button
                    anchors.fill: parent
                    property int taps: 0
                    TapHandler { onTapped: button.taps++ }
                }
            }
        }
    }
    SignalSpy { id: rowSpy; signalName: "clicked" }

    function test_rowIgnoresTapsOnAModalPopup() {
        var s = createTemporaryObject(scene, stage())
        rowSpy.clear()
        rowSpy.target = s.row
        mouseClick(s.row, 200, s.row.height / 2)
        compare(rowSpy.count, 1, "without a popup the row takes its tap")
        s.popup.open()
        tryVerify(() => s.popup.opened)
        mouseClick(s.row, 200, s.row.height / 2)        // lands on the popup, above the row
        compare(rowSpy.count, 1, "the tap was the popup's")
        compare(s.button.taps, 1)
        mouseClick(s.row, 10, s.row.height / 2)         // beside the popup, on its dimmed overlay
        compare(rowSpy.count, 1, "a modal popup blocks the rest of the window too")
        s.popup.close()
        tryVerify(() => !s.popup.visible)
        mouseClick(s.row, 200, s.row.height / 2)
        compare(rowSpy.count, 2, "after the popup closed the row takes taps again")
    }

    Component {
        id: inPopup
        Item {
            property alias row: row
            property alias popup: popup
            width: 400
            height: 400
            QQC2.Popup {
                id: popup
                modal: true
                x: 0; y: 0; width: 400; height: 200
                KanteListRow { id: row; width: 380; text: "In the sheet" }
            }
        }
    }
    function test_rowInsideAPopupStillWorks() {
        var s = createTemporaryObject(inPopup, stage())
        s.popup.open()
        tryVerify(() => s.popup.opened)
        rowSpy.clear()
        rowSpy.target = s.row
        mouseClick(s.row, 100, s.row.height / 2)
        compare(rowSpy.count, 1)
    }

    // Items an app or Kirigami keeps in the overlay are no popups: Kirigami's passive
    // notifications sit there at the bottom of every ApplicationWindow, always visible.
    Component {
        id: appWindow
        Kirigami.ApplicationWindow {
            property alias top: top
            property alias bottom: bottom
            property alias overlayItem: overlayItem
            width: 600
            height: 700
            pageStack.initialPage: Kirigami.Page {
                KanteListRow { id: top; width: parent.width; text: "Top" }
                KanteListRow { id: bottom; width: parent.width; y: parent.height - height - 10; text: "Bottom" }
            }
            Rectangle {
                id: overlayItem
                parent: QQC2.Overlay.overlay
                visible: false
                color: "transparent"
                width: 400; height: 400
            }
        }
    }
    function test_rowsInAnAppWindowKeepTheirTaps() {
        var w = createTemporaryObject(appWindow, null)
        w.show()
        tryVerify(() => w.bottom.width > 0 && w.bottom.y > 300)
        waitForRendering(w.contentItem)
        rowSpy.clear()
        rowSpy.target = w.bottom
        mouseClick(w.bottom, w.bottom.width / 2, w.bottom.height / 2)
        compare(rowSpy.count, 1, "the bottom row under Kirigami's notification area")
        w.overlayItem.visible = true
        mouseClick(w.bottom, w.bottom.width / 2, w.bottom.height / 2)
        compare(rowSpy.count, 2, "an app's own item in the overlay is no popup")
        w.close()
    }

    // A row in a drawer, a modal popup above it: the popup's taps stay the popup's.
    Component {
        id: drawerScene
        Item {
            property alias row: row
            property alias drawer: drawer
            property alias popup: popup
            width: 400
            height: 400
            QQC2.Popup {
                id: drawer
                modal: false
                closePolicy: QQC2.Popup.NoAutoClose
                x: 0; y: 0; width: 400; height: 400
                KanteListRow { id: row; width: 380; y: 100; text: "In the drawer" }
            }
            QQC2.Popup {
                id: popup
                modal: true
                closePolicy: QQC2.Popup.NoAutoClose
                x: 50; y: 60; width: 300; height: 120
                Rectangle {
                    anchors.fill: parent
                    TapHandler {}
                }
            }
        }
    }
    function test_rowInAPopupUnderAnotherPopup() {
        var s = createTemporaryObject(drawerScene, stage())
        s.drawer.open()
        tryVerify(() => s.drawer.opened)
        rowSpy.clear()
        rowSpy.target = s.row
        mouseClick(s.row, 200, s.row.height / 2)
        compare(rowSpy.count, 1, "the drawer's row takes its tap")
        s.popup.open()
        tryVerify(() => s.popup.opened)
        mouseClick(s.row, 200, s.row.height / 2)
        compare(rowSpy.count, 1, "the tap was the popup's above the drawer")
    }

    // The row's popup has a higher z (as Kirigami's dialogs, z 300): a popup opened later but
    // drawn below it does not take the row's taps.
    function test_higherPopupKeepsItsRowsTaps() {
        var s = createTemporaryObject(drawerScene, stage())
        s.drawer.z = 10
        s.popup.modal = false
        s.drawer.open()
        tryVerify(() => s.drawer.opened)
        s.popup.open()
        tryVerify(() => s.popup.opened)
        rowSpy.clear()
        rowSpy.target = s.row
        mouseClick(s.row, 200, s.row.height / 2)
        compare(rowSpy.count, 1, "the drawer is drawn above the later popup")
    }
}
