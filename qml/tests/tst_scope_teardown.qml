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
}
