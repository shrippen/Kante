import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.81, for Klappe: KantePopover.openAtPoint and closeOnOutside.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante181"
    width: 600
    height: 500
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    // --- Popover at a point

    Component {
        id: popoverComponent
        Item {
            anchors.fill: parent
            property alias popover: popover
            property alias plan: plan
            property alias other: other
            Item { id: plan; x: 0; y: 0; width: parent.width; height: parent.height }
            Item { id: other; x: 10; y: 10; width: 30; height: 30 }
            KantePopover {
                id: popover
                title: "Figur"
                KanteSwitch { text: "Sichtbar" }
            }
        }
    }

    // The card's top left corner in the window.
    function cardAt(o) {
        return o.popover.background.mapToItem(null, 0, 0)
    }

    function test_popoverPointRight() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.x >= 100 + o.popover.pointerLength, "clear of the point: " + card.x)
        compare(o.popover.pointerSide, "left")
        verify(o.popover.pointer.visible)
        // Top near the point, the pointer's tip level with it.
        verify(card.y <= 120 && card.y > 120 - o.popover.height, "beside the point: " + card.y)
        fuzzyCompare(card.y + o.popover.pointerY, 120, 1)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverPointLeftAtTheEdge() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(tc.width - 20, 120, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.x + o.popover.width <= tc.width - 20 - o.popover.pointerLength + 1, "left of the point: " + card.x)
        verify(card.x >= 0)
        compare(o.popover.pointerSide, "right")
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverPointKeptInWindow() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, tc.height - 5, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.y >= 0, "inside the window: " + card.y)
        verify(card.y + o.popover.height <= tc.height + 1, "inside the window: " + (card.y + o.popover.height))
        // The pointer stays on the card.
        verify(o.popover.pointerY > 0 && o.popover.pointerY < o.popover.height)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverOpenAtHasNoPointer() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        o.popover.close()
        tryVerify(() => !o.popover.visible)
        o.popover.openAt(o.other)
        tryVerify(() => o.popover.opened)
        compare(o.popover.pointerSide, "")
        verify(!o.popover.pointer.visible)
        o.popover.close()
    }

    function test_popoverOutsideClick() {
        const o = createTemporaryObject(popoverComponent, stage())
        compare(o.popover.closeOnOutside, true)
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        mouseClick(stage(), 500, 400)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverStaysOpenOutside() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.closeOnOutside = false
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        mouseClick(stage(), 500, 400)
        wait(100)
        verify(o.popover.visible, "a press outside leaves it open")
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }
}
