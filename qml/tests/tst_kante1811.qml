import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.81.1: in System a button builds none of Kante's drawing. KanteToolButton built its
 * ground, layout, icon and label hidden, KanteButton its shape and label: a tool button cost twice
 * a plain one (qml/perf/tst_controls_perf.qml). In Kante they are built as before.
 * Run: tools/check-qml.sh
 */
TestCase {
    id: tc
    name: "Kante1811"
    width: 400
    height: 400
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    Component {
        id: toolButtonScene
        KanteToolButton { icon.name: "document-edit"; text: "Edit" }
    }
    Component {
        id: buttonScene
        KanteButton { text: "Save"; icon.name: "document-save" }
    }

    // Items below `item` (itself included) for which `is` holds.
    function count(item, is) {
        let n = is(item) ? 1 : 0
        for (let i = 0; i < item.children.length; i++) {
            n += count(item.children[i], is)
        }
        return n
    }
    function isKanteIcon(x) { return x.iconSource !== undefined && typeof x.pick === "function" }
    function isPolygon(x) { return x.cutTopRight !== undefined && x.fillColor !== undefined }
    function isLabel(x) { return x.toString().indexOf("QQuickLabel") >= 0 || x.toString().indexOf("Label_QMLTYPE") >= 0 }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_tool_button_draws_nothing_in_system() {
        KanteStyle.kind = KanteStyle.Kind.System
        const b = createTemporaryObject(toolButtonScene, stage())
        compare(count(b, isKanteIcon), 0, "System: no Kante icon")
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(count(b, isKanteIcon), 1, "Kante: the icon")
    }

    function test_button_draws_nothing_in_system() {
        KanteStyle.kind = KanteStyle.Kind.System
        const b = createTemporaryObject(buttonScene, stage())
        compare(count(b, isPolygon), 0, "System: no shape")
        const labels = count(b, isLabel)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(count(b, isPolygon), 1, "Kante: the shape")
        compare(count(b, isLabel), labels + 1, "Kante: its own label")
    }
}
