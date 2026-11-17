import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtTest
import Kante

/**
 * Creation cost of the controls a list row is built from (Kurrent: about 30 rows on screen,
 * each with tool buttons, a check box and a menu). Not in the normal suite (timings flicker).
 * Run:
 *   QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=kde /usr/lib/qt6/bin/qmltestrunner -import qml -input qml/perf
 * Prints ms per instance in System and in Kante (fastest of five rounds), next to the plain
 * Qt control, and the cost of a row below a KanteScope.
 */
TestCase {
    id: tc
    name: "ControlsPerf"
    width: 600
    height: 400
    when: windowShown

    readonly property int count: 60

    Component { id: plainToolButton; QQC2.ToolButton { icon.name: "document-edit"; display: QQC2.AbstractButton.IconOnly } }
    Component { id: toolButton; KanteToolButton { icon.name: "document-edit"; display: QQC2.AbstractButton.IconOnly } }
    Component { id: toolButtonText; KanteToolButton { text: "Edit" } }
    Component { id: plainButton; QQC2.Button { text: "Done"; icon.name: "dialog-ok" } }
    Component { id: button; KanteButton { text: "Done"; icon.name: "dialog-ok" } }
    Component { id: icon; KanteIcon { width: 22; height: 22; iconSource: "document-edit" } }
    Component { id: plainCheck; QQC2.CheckBox { text: "Task" } }
    Component { id: check; QQC2.CheckBox { id: c; text: "Task"; KanteCheckSkin { control: c } } }
    Component {
        id: plainMenu
        QQC2.Menu {
            QQC2.MenuItem { text: "In 1 hour" }
            QQC2.MenuItem { text: "Tomorrow" }
            QQC2.MenuItem { text: "Next week" }
        }
    }
    Component {
        id: menu
        QQC2.Menu {
            id: m
            KantePopupSkin { popup: m }
            QQC2.MenuItem { text: "In 1 hour" }
            QQC2.MenuItem { text: "Tomorrow" }
            QQC2.MenuItem { text: "Next week" }
        }
    }
    Component { id: chip; KanteChip { text: "label-3" } }

    Item { id: host; width: 600; height: 400 }

    // A list row of plain items (about 20): what a KanteScope sweeps when a delegate comes in.
    Component {
        id: row
        Row {
            Repeater {
                model: 6
                Item {
                    width: 10; height: 10
                    Rectangle { anchors.fill: parent }
                    Text { text: "x" }
                }
            }
            Item { enabled: false; width: 10; height: 10 }
        }
    }
    Item { id: scoped; width: 600; height: 400; KanteScope { target: scoped } }
    Item { id: unscoped; width: 600; height: 400 }

    // ms per row created below `parentItem`, after the deferred sweep ran.
    function rowCost(parentItem) {
        const t = Date.now()
        const made = []
        for (let i = 0; i < count; i++) {
            made.push(row.createObject(parentItem))
        }
        wait(0)
        const ms = (Date.now() - t) / count
        for (const r of made) {
            r.destroy()
        }
        wait(0)
        return ms
    }

    function test_scope() {
        rowCost(unscoped)
        for (const k of [["System", KanteStyle.Kind.System], ["Kante", KanteStyle.Kind.Kante]]) {
            KanteStyle.kind = k[1]
            wait(0)
            console.log("PERF " + k[0] + " row: " + best(() => rowCost(unscoped)).toFixed(2) + " ms, under a KanteScope: "
                        + best(() => rowCost(scoped)).toFixed(2) + " ms")
        }
        KanteStyle.kind = KanteStyle.Kind.System
        verify(true)
    }

    readonly property int rounds: 5

    // Fastest of several rounds: robust against a busy machine.
    function best(measure) {
        let ms = Infinity
        for (let r = 0; r < rounds; r++) {
            ms = Math.min(ms, measure())
        }
        return ms
    }

    // ms per instance: created in a row layout (as in a list row), laid out, then destroyed.
    function cost(component) {
        const row = Qt.createQmlObject("import QtQuick.Layouts; RowLayout { width: 600 }", host)
        const t = Date.now()
        for (let i = 0; i < count; i++) {
            component.createObject(row)
        }
        row.implicitWidth  // settles the layout
        const ms = (Date.now() - t) / count
        row.destroy()
        wait(0)
        return ms
    }

    function test_cost() {
        const cases = [["QQC2.ToolButton", plainToolButton], ["KanteToolButton", toolButton],
                       ["KanteToolButton text", toolButtonText], ["QQC2.Button", plainButton],
                       ["KanteButton", button], ["KanteIcon", icon], ["QQC2.CheckBox", plainCheck],
                       ["CheckBox+KanteCheckSkin", check], ["QQC2.Menu", plainMenu],
                       ["Menu+KantePopupSkin", menu], ["KanteChip", chip]]
        const kinds = [["System", KanteStyle.Kind.System], ["Kante", KanteStyle.Kind.Kante]]
        for (const c of cases) {
            cost(c[1])  // warm up: compile and caches
        }
        for (const k of kinds) {
            KanteStyle.kind = k[1]
            for (const c of cases) {
                console.log("PERF " + k[0] + " " + c[0] + ": " + best(() => cost(c[1])).toFixed(2) + " ms")
            }
        }
        KanteStyle.kind = KanteStyle.Kind.System
        verify(true)
    }
}
