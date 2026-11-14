import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import Kante

// A scope held as a property: its target leaves the window while disabled (a page torn down
// off the viewport). The scope must not write to the themes below after that.
TestCase {
    id: tc
    name: "ScopeTeardown"
    width: 300
    height: 200
    when: windowShown

    Component {
        id: treeComponent
        Item {
            id: outer
            enabled: false
            property alias inner: innerItem
            property alias leaf: leafItem
            Item {
                id: innerItem
                property Item scope: KanteScope { target: innerItem }
                Item { id: leafItem }
            }
        }
    }

    // The target stays in the window; a disabled part below it is taken apart (a delegate, a row).
    Component {
        id: partComponent
        Item {
            id: target
            property alias box: boxItem
            property alias leaf: leafItem
            property alias deep: deepItem
            KanteScope { target: target }
            Item {
                id: boxItem
                enabled: false
                Item { id: leafItem }
                Item {
                    Item { id: deepItem }
                }
            }
        }
    }

    SignalSpy { id: spy; signalName: "colorsChanged" }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_no_write_after_window() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const outer = createTemporaryObject(treeComponent, tc.Window.contentItem)
        const scope = outer.inner.scope
        tryVerify(() => Object.keys(scope.dressed).length > 0, 2000, "the disabled leaf is dressed")
        spy.target = outer.leaf.Kirigami.Theme
        spy.clear()
        // As Qt does when it takes a disabled parent apart: the child is enabled again, without a window.
        outer.inner.parent = null
        compare(outer.leaf.enabled, true)
        compare(spy.count, 0, "no theme write once the target has left its window")
    }

    function test_no_write_to_orphan() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const o = createTemporaryObject(partComponent, tc.Window.contentItem)
        tryVerify(() => Qt.colorEqual(o.leaf.Kirigami.Theme.textColor, KanteStyle.disabledTextColor),
                  2000, "the disabled leaf is dressed")
        spy.target = o.leaf.Kirigami.Theme
        spy.clear()
        // As ~QQuickItem does with its children: the leaf loses its parent and is enabled again.
        o.leaf.parent = null
        compare(o.leaf.enabled, true)
        compare(spy.count, 0, "no theme write to an item without a parent")
    }

    // Only the part's children lose their parent; the items below them keep theirs.
    function test_no_write_below_orphan() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const o = createTemporaryObject(partComponent, tc.Window.contentItem)
        tryVerify(() => Qt.colorEqual(o.deep.Kirigami.Theme.textColor, KanteStyle.disabledTextColor),
                  2000, "the disabled deep item is dressed")
        wait(200) // the scope's second sweep dresses again; the spy starts after it
        spy.target = o.deep.Kirigami.Theme
        spy.clear()
        // As ~QQuickItem does: the part's child loses its parent, the deep item keeps its own.
        o.deep.parent.parent = null
        compare(o.deep.enabled, true)
        compare(spy.count, 0, "no theme write below a part taken apart")
    }
}
