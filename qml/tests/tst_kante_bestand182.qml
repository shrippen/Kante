import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * From the review of the QML stock (1.82): the setting row's reset text is English by
 * default (translated through qsTr), a heading follows its horizontalAlignment in Kante,
 * and a scope held as a property (the dialog and sheet skins) finds the window through its
 * target.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteBestand182"
    width: 400
    height: 300
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_resetTextIsEnglish() {
        const row = createTemporaryObject(rowComponent, tc)
        compare(row.resetText, "Reset")
    }
    Component { id: rowComponent; KanteSettingRow {} }

    Component {
        id: headingComponent
        KanteHeading {
            text: "Title"
            level: 2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            width: 300
        }
    }

    function test_headingAlignmentFollowsInKante() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const h = createTemporaryObject(headingComponent, tc)
        const label = h.children.find(c => c.objectName === "kanteText")
        verify(label, "kanteText")
        compare(label.horizontalAlignment, Text.AlignHCenter)
    }

    Component {
        id: oneLineHeading
        KanteHeading {
            text: "Title"
            level: 2
            horizontalAlignment: Text.AlignHCenter
            width: 300
        }
    }

    // A one-line title (no wrapMode, the default) is centred too: its text stands in the middle.
    function test_oneLineHeadingCentredInKante() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const h = createTemporaryObject(oneLineHeading, tc)
        const label = h.children.find(c => c.objectName === "kanteText")
        verify(label, "kanteText")
        const middle = label.x + (label.width - label.contentWidth) / 2 + label.contentWidth / 2
        fuzzyCompare(middle, h.width / 2, 1)
    }

    Component {
        id: skinDialog
        QQC2.Dialog {
            id: d
            property alias off: off
            width: 200
            height: 120
            contentItem: Item {
                QQC2.Label {
                    id: off
                    enabled: false
                    text: "off"
                }
            }
            KanteDialogSkin { dialog: d }
        }
    }

    function test_skinScopeFindsWindow() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const d = createTemporaryObject(skinDialog, tc)
        d.open()
        tryVerify(() => d.opened)
        wait(200)
        verify(Qt.colorEqual(d.off.Kirigami.Theme.textColor, KanteStyle.disabledTextColor),
               "disabled text " + d.off.Kirigami.Theme.textColor + ", not " + KanteStyle.disabledTextColor)
        d.close()
    }

    Component {
        id: ownContentDialog
        KanteDialog {
            property alias off: off
            contentItem: ColumnLayout {
                QQC2.Label {
                    id: off
                    enabled: false
                    text: "off"
                }
            }
        }
    }

    function test_ownContentDisabledKeepsKante() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const d = createTemporaryObject(ownContentDialog, tc)
        d.open()
        tryVerify(() => d.opened)
        wait(200)
        verify(Qt.colorEqual(d.off.Kirigami.Theme.textColor, KanteStyle.disabledTextColor),
               "disabled text " + d.off.Kirigami.Theme.textColor + ", not " + KanteStyle.disabledTextColor)
        d.close()
    }
}
