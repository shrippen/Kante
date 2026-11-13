import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import Kante

// A dressed item's text colour follows its own `enabled`, also once a shallow scope let go of
// the items (its target is enabled again).
TestCase {
    id: tc
    name: "ScopeShallow"
    width: 300
    height: 200
    when: windowShown

    Component {
        id: shallowTree
        Item {
            id: tgt
            property alias leaf: leafItem
            KanteScope {
                target: tgt
                shallow: true
            }
            Item { id: leafItem }
        }
    }

    Component {
        id: windowTree
        Item {
            id: content
            property Item bar: null
            property Item leaf: bar ? bar.children[0] : null
            KanteScope { target: content }
        }
    }

    Component {
        id: barComponent
        Item {
            enabled: false
            Item {}
        }
    }

    Component {
        id: barScopeComponent
        KanteBarScope {}
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function text(item) {
        return item.Kirigami.Theme.textColor
    }

    function test_shallow_leaf_off_after_target_on() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const o = createTemporaryObject(shallowTree, tc.Window.contentItem)
        wait(50)
        o.enabled = false
        wait(20)
        verify(Qt.colorEqual(text(o.leaf), KanteStyle.disabledTextColor), "dressed " + text(o.leaf))
        o.enabled = true
        wait(20)
        verify(Qt.colorEqual(text(o.leaf), KanteStyle.textColor), "target on " + text(o.leaf))
        o.leaf.enabled = false
        wait(20)
        verify(Qt.colorEqual(text(o.leaf), KanteStyle.disabledTextColor),
               "leaf off, text " + text(o.leaf) + ", not " + KanteStyle.disabledTextColor)
    }

    // A bar made while disabled (a page off view), its scope shallow, in a window with its own scope.
    function test_bar_item_off_after_bar_on() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const o = createTemporaryObject(windowTree, tc.Window.contentItem)
        wait(50)
        o.bar = barComponent.createObject(o)
        barScopeComponent.createObject(o.bar, { target: o.bar })
        wait(50)
        o.bar.enabled = true
        wait(20)
        o.leaf.enabled = false
        wait(20)
        verify(Qt.colorEqual(text(o.leaf), KanteStyle.disabledTextColor),
               "bar item off, text " + text(o.leaf) + ", not " + KanteStyle.disabledTextColor)
    }
}
