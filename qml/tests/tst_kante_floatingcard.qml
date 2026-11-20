import QtQuick
import QtTest
import Kante

/**
 * KanteFloatingCard: the size follows the children plus the padding, and the hard shadow
 * shows only when the style is themed. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteFloatingCard"
    width: 400
    height: 400
    visible: true
    when: windowShown

    Component {
        id: cardComponent
        KanteFloatingCard {
            property alias box: box
            Rectangle { id: box; width: 80; height: 30 }
        }
    }

    // The shadow is the one KantePolygon child of the card.
    function shadowOf(card) {
        return card.children.find(c => c instanceof KantePolygon)
    }

    function test_sizeFromContentAndPadding() {
        const c = createTemporaryObject(cardComponent, tc)
        compare(c.padding, KanteStyle.unit(10))
        compare(c.implicitWidth, 80 + 2 * c.padding)
        compare(c.implicitHeight, 30 + 2 * c.padding)
        compare(c.width, c.implicitWidth)

        c.padding = 4
        compare(c.width, 88)
        compare(c.height, 38)
    }

    function test_contentSitsInsidePadding() {
        const c = createTemporaryObject(cardComponent, tc)
        compare(c.box.mapToItem(c, 0, 0).x, c.padding)
        compare(c.box.mapToItem(c, 0, 0).y, c.padding)
    }

    function test_shadowOnlyWhenThemed() {
        const c = createTemporaryObject(cardComponent, tc)
        const s = shadowOf(c)
        verify(s !== undefined, "shadow exists")
        compare(s.visible, KanteStyle.themed)
        compare(s.width, c.width)
        compare(s.height, c.height)
    }
}
