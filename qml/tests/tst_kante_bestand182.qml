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
}
