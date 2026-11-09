import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.76.2, from Kontra's benchmark of 9.11.2026: KanteScope queued an item once per child
 * it got, and its sweep looked at the item's children that often. Kontra's notation view queued
 * items 5250 times while it opened (1.4 million children looked at): 2.7 s standing still,
 * and 0.8 s on the next line.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante1762"
    width: 640
    height: 480
    when: windowShown
    visible: true

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: areaComponent
        Item {
            id: area
            width: 300
            height: 200
            property alias scope: scope
            property alias holder: holder
            property alias repeater: repeater
            KanteScope { id: scope; target: area }
            Item {
                id: holder
                Repeater {
                    id: repeater
                    model: 0
                    Rectangle {
                        width: 2
                        height: 2
                        enabled: false
                        color: Kirigami.Theme.backgroundColor
                    }
                }
            }
        }
    }

    // Many children at once: their parent waits once for the sweep, and every child is still
    // dressed after it.
    function test_scopeQueuesParentOnce() {
        const area = createTemporaryObject(areaComponent, tc)
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(area.scope, "applied", true)
        wait(0)

        const count = 300
        area.repeater.model = count
        compare(area.scope.pending.length, 1)

        const last = area.repeater.itemAt(count - 1)
        tryCompare(last, "color", KanteStyle.dialogColor)
        compare(area.scope.pending.length, 0)
    }
}
