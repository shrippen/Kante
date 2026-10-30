import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.57, from lmix's effect menu: KanteMenuItem gets `trailing`, items at the row's end
 * (◀ ▶ of a direction, the lengths as segments). They take their own clicks; a click beside
 * them triggers the item. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante157"
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
            property alias plain: plain
            property alias slide: slide
            property alias leftArrow: leftArrow
            property alias rightArrow: rightArrow
            property int triggers: 0
            property int arrows: 0
            QQC2.Menu {
                id: menu
                KanteMenuItem { id: plain; text: "Fade"; valueText: "500 ms"; shortcutText: "F" }
                KanteMenuItem {
                    id: slide
                    text: "Slide"
                    valueText: "500 ms"
                    shortcutText: "S"
                    onTriggered: triggers++
                    trailing: [
                        KanteToolButton { id: leftArrow; text: "◀"; focusPolicy: Qt.NoFocus; onClicked: arrows++ },
                        KanteToolButton { id: rightArrow; text: "▶"; focusPolicy: Qt.NoFocus; onClicked: arrows++ }
                    ]
                }
            }
            KantePopupSkin { popup: menu }
        }
    }

    function open() {
        const o = createTemporaryObject(menuComponent, tc.Window.contentItem)
        o.menu.open()
        tryVerify(() => o.menu.opened)
        return o
    }

    function posX(item) {
        return item.mapToItem(null, 0, 0).x
    }

    function keycap(row) {
        return row.contentItem.children.find(c => c.toString().indexOf("KanteKeycap") === 0)
    }

    function test_trailingSitsAfterTheValueBeforeTheKey() {
        const o = open()
        verify(o.leftArrow.visible && o.rightArrow.visible)
        verify(posX(o.leftArrow) > posX(o.slide.valueLabel), "after the value")
        verify(posX(o.rightArrow) > posX(o.leftArrow), "in a row, in order")
        const cap = keycap(o.slide)
        verify(cap && cap.visible)
        verify(posX(cap) >= posX(o.rightArrow) + o.rightArrow.width, "before the key")
    }

    function test_trailingWidensTheRow() {
        const o = open()
        // The same texts beside: the arrows add their width (a menu keeps a least width).
        const wide = o.slide.contentItem.implicitWidth
        const narrow = o.plain.contentItem.implicitWidth
        verify(wide >= narrow + o.leftArrow.width + o.rightArrow.width, wide + " vs " + narrow)
        // Nothing at the end of a plain row: it keeps its width as before.
        compare(o.plain.trailing.length, 0)
        const row = o.plain.contentItem.children.find(c => c.toString().indexOf("RowLayout") >= 0)
        verify(row, "the empty slot")
        verify(!row.visible)
        // The menu is wide enough for the widest row.
        verify(o.menu.width >= wide + o.slide.leftPadding + o.slide.rightPadding)
    }

    function test_trailingTakesItsOwnClicks() {
        const o = open()
        mouseClick(o.rightArrow)
        compare(o.arrows, 1)
        compare(o.triggers, 0, "the arrow, not the row")
        o.menu.open()
        tryVerify(() => o.menu.opened)
        mouseClick(o.slide, o.slide.width / 4, o.slide.height / 2)
        compare(o.triggers, 1, "beside the arrows the row")
        compare(o.arrows, 1)
    }

    function test_trailingInSystem() {
        KanteStyle.kind = KanteStyle.Kind.System
        const o = open()
        verify(o.leftArrow.visible && o.rightArrow.visible)
        verify(posX(o.rightArrow) > posX(o.slide.valueLabel))
    }
}
