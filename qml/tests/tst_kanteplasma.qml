import QtQuick
import QtTest
import "../Kante"
import "../KantePlasma"

/**
 * Creates the Plasma widget wrappers in both kinds (needs PlasmaComponents3).
 */
TestCase {
    id: tc
    name: "KantePlasma"
    width: 400
    height: 400
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: gallery
        Column {
            KantePlasmaButton { text: "Start"; emphasis: KantePlasmaButton.Emphasis.Primary }
            KantePlasmaButton { text: "Stop"; emphasis: KantePlasmaButton.Emphasis.Destructive; enabled: false }
            KantePlasmaToolButton { icon.name: "document-edit"; checkable: true; checked: true }
            KantePlasmaHeading { level: 4; text: "Recent" }
            KantePlasmaHeading { level: 2; text: "Today" }
        }
    }

    function test_wrappersInBothKinds() {
        var g = createTemporaryObject(gallery, tc)
        verify(g !== null)
        var kinds = [KanteStyle.Kind.Kante, KanteStyle.Kind.System]
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(50)
            compare(g.children.length, 5)
        }
    }

    Component {
        id: headingComponent
        KantePlasmaHeading { level: 4; text: "Recent" }
    }

    function test_headingRestoresAfterKante() {
        var h = createTemporaryObject(headingComponent, tc)
        var colorBefore = String(h.color)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(h.color.a, 0)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(String(h.color), colorBefore)
    }
}
