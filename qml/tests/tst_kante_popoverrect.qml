import QtQuick
import QtTest
import Kante

/**
 * KantePopover.openAtRect and rectSlot (Kante 1.82, for Klappe): a card beside a rectangle,
 * inside a bounds item.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KantePopoverRect"
    width: 600
    height: 500
    when: windowShown

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    // The bounds are a frame inside the window: x 100..500, y 50..350.
    Component {
        id: component
        Item {
            anchors.fill: parent
            property alias popover: popover
            property alias plan: plan
            Item { id: plan; x: 100; y: 50; width: 400; height: 300 }
            KantePopover {
                id: popover
                title: "Figur"
                KanteSwitch { text: "Sichtbar" }
            }
        }
    }

    function make() {
        return createTemporaryObject(component, tc.Window.contentItem)
    }

    // The card's top left corner in the window.
    function cardAt(o) {
        return o.popover.background.mapToItem(null, 0, 0)
    }

    function open(o, rect, side) {
        o.popover.openAtRect(o.plan, rect, o.plan, side)
        tryVerify(() => o.popover.opened)
    }

    function test_right_of_the_rect() {
        const o = make()
        open(o, Qt.rect(50, 100, 40, 20))
        const card = cardAt(o)
        // Clear of the rect's right edge (window x 100 + 90), pointer on the card's left.
        verify(card.x >= 190 + o.popover.pointerLength, "right of the rect: " + card.x)
        compare(o.popover.pointerSide, "left")
        verify(o.popover.pointer.visible)
        // The pointer's tip is level with the middle of the rect (window y 50 + 110).
        fuzzyCompare(card.y + o.popover.pointerY, 160, 1)
        o.popover.close()
    }

    function test_left_at_the_edge_of_the_bounds() {
        const o = make()
        open(o, Qt.rect(330, 100, 40, 20))
        const card = cardAt(o)
        compare(o.popover.pointerSide, "right")
        verify(card.x + o.popover.width <= 100 + 330 - o.popover.pointerLength + 1, "left of the rect: " + card.x)
        // Inside the bounds, not only inside the window (which has room at the right).
        verify(card.x >= 100, "inside the bounds: " + card.x)
        o.popover.close()
    }

    function test_kept_inside_the_bounds_vertically() {
        const o = make()
        open(o, Qt.rect(50, 295, 40, 10))
        let card = cardAt(o)
        verify(card.y + o.popover.height <= 350, "above the bounds' foot: " + (card.y + o.popover.height))
        verify(o.popover.pointerY > 0 && o.popover.pointerY < o.popover.height)
        o.popover.close()
        tryVerify(() => !o.popover.visible)

        open(o, Qt.rect(50, 0, 40, 10))
        card = cardAt(o)
        verify(card.y >= 50, "below the bounds' top: " + card.y)
        o.popover.close()
    }

    function test_the_pointer_stays_clear_of_the_corner() {
        const o = make()
        open(o, Qt.rect(330, 0, 40, 4))
        compare(o.popover.pointerSide, "right")
        verify(o.popover.pointerY - o.popover.pointerWidth / 2 >= KanteStyle.chamferSmall,
               "below the chamfer: " + o.popover.pointerY)
        o.popover.close()
    }

    function test_a_forced_side() {
        const o = make()
        const rect = Qt.rect(200, 100, 40, 20)
        open(o, rect, KantePopover.Side.Left)
        compare(o.popover.pointerSide, "right")
        o.popover.close()
        tryVerify(() => !o.popover.visible)

        open(o, rect, KantePopover.Side.Right)
        compare(o.popover.pointerSide, "left")
        o.popover.close()
    }

    function test_rect_slot_tells_where_it_fits() {
        const o = make()
        let slot = o.popover.rectSlot(o.plan, Qt.rect(50, 100, 40, 20), o.plan, KantePopover.Side.Auto)
        compare(slot.side, KantePopover.Side.Right)
        verify(slot.fits)

        slot = o.popover.rectSlot(o.plan, Qt.rect(330, 100, 40, 20), o.plan, KantePopover.Side.Right)
        compare(slot.side, KantePopover.Side.Right)
        verify(!slot.fits, "no room on the forced side")

        slot = o.popover.rectSlot(o.plan, Qt.rect(330, 100, 40, 20), o.plan, KantePopover.Side.Auto)
        compare(slot.side, KantePopover.Side.Left)
        verify(slot.fits)
    }

    function test_no_room_has_no_pointer() {
        const o = make()
        o.popover.implicitWidth = 380
        open(o, Qt.rect(180, 100, 40, 20))
        compare(o.popover.pointerSide, "")
        verify(!o.popover.pointer.visible)
        o.popover.close()
    }
}
