import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * A hidden KanteMenuItem takes no row in its menu: the Menu's ListView lays items out by
 * height, regardless of `visible`. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteMenuHidden"
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
        id: menuComponent
        Item {
            property alias menu: menu
            property alias first: first
            property alias middle: middle
            property alias last: last
            QQC2.Menu {
                id: menu
                KanteMenuItem { id: first; text: "First" }
                KanteMenuItem { id: middle; text: "Middle"; visible: false }
                KanteMenuItem { id: last; text: "Last" }
            }
            KantePopupSkin { popup: menu }
        }
    }

    function test_hidden_item_takes_no_row() {
        const o = createTemporaryObject(menuComponent, tc.Window.contentItem)
        o.menu.open()
        tryVerify(() => o.menu.opened)

        compare(o.middle.height, 0, "hidden item has no height")

        // The ListView lays out on the next frame.
        tryCompare(o.last, "y", o.first.height, 2000, "last item sits directly under the first")
    }
}
