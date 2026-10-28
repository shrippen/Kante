import QtQuick
import QtTest
import Kante

/**
 * Kante 1.49, from Kontra's QA night (27.10.2026: keyboard only, 200 %, deuteranopia):
 * Return presses a focused button, the focus stays in view on long pages, a skipped step shows no
 * check, the histogram names its count axis, a wrong note's head
 * is framed. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante149"
    width: 600
    height: 400
    when: windowShown

    Component {
        id: buttonComponent
        KanteButton {
            property int presses: 0
            text: "Weiter"
            onClicked: presses++
        }
    }

    Component {
        id: toolComponent
        KanteToolButton {
            property int presses: 0
            text: "Loop"
            onClicked: presses++
        }
    }

    Component {
        id: pageComponent
        Flickable {
            id: page
            width: 300
            height: 200
            contentHeight: column.height
            property alias column: column
            property alias follow: follow
            Column {
                id: column
                Repeater {
                    model: 12
                    KanteButton {
                        property int presses: 0
                        text: "Knopf " + index
                        height: 40
                        onClicked: presses++
                    }
                }
            }
            KanteFocusFollow { id: follow; flickable: page; margin: 10 }
        }
    }

    // Rows and tiles take the focus from their own tap, an Item has no focusReason.
    Component {
        id: rowsComponent
        Flickable {
            id: rows
            width: 300
            height: 200
            contentHeight: rowColumn.height
            property alias column: rowColumn
            Column {
                id: rowColumn
                Repeater {
                    model: 12
                    KanteListRow {
                        property int presses: 0
                        width: 300
                        height: 40
                        text: "Zeile " + index
                        onClicked: presses++
                    }
                }
            }
            KanteFocusFollow { flickable: rows; margin: 10 }
        }
    }

    Component { id: stepsComponent; KanteSteps { width: 560 } }
    Component { id: histComponent; KanteTimingHistogram { width: 500; height: 220 } }
    Component { id: laneComponent; KanteTabLane { width: 500; height: 200 } }

    function findAll(item, pred) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (pred(c)) {
                out.push(c)
            }
            out = out.concat(findAll(c, pred))
        }
        return out
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_returnPressesButton() {
        const b = createTemporaryObject(buttonComponent, tc)
        b.forceActiveFocus()
        keyClick(Qt.Key_Return)
        tryCompare(b, "presses", 1)
        keyClick(Qt.Key_Enter)
        tryCompare(b, "presses", 2)

        b.enabled = false
        b.forceActiveFocus()
        keyClick(Qt.Key_Return)
        wait(50)
        compare(b.presses, 2)
    }

    function test_returnPressesToolButton() {
        const b = createTemporaryObject(toolComponent, tc)
        b.forceActiveFocus()
        keyClick(Qt.Key_Return)
        tryCompare(b, "presses", 1)
    }

    function test_focusStaysInView() {
        const page = createTemporaryObject(pageComponent, tc.Window.contentItem)
        const last = page.column.children[11]
        last.forceActiveFocus()
        // Bottom of the last button (480) plus the margin at the view's bottom edge.
        tryCompare(page, "contentY", 480 - 200)

        page.column.children[2].forceActiveFocus()
        tryCompare(page, "contentY", 80 - 10)

        // Already in view: no move.
        page.column.children[3].forceActiveFocus()
        wait(20)
        compare(page.contentY, 70)
    }

    // Review #86: a mouse press took the focus and scrolled the view, the release fell off the
    // button and the click was lost. The mouse never moves the view.
    function test_clickDoesNotScroll() {
        const page = createTemporaryObject(pageComponent, tc.Window.contentItem)
        const edge = page.column.children[4]
        mouseClick(edge, 20, 5)
        compare(page.contentY, 0)
        compare(edge.presses, 1)
    }

    // Review #86, round 2: a row focuses itself on tap and has no focusReason; the view moved.
    function test_rowClickDoesNotScroll() {
        const page = createTemporaryObject(rowsComponent, tc.Window.contentItem)
        const edge = page.column.children[4]
        mouseClick(edge, 20, 5)
        verify(edge.activeFocus)
        compare(page.contentY, 0)
        mouseClick(page.column.children[5], 20, 5)
        compare(page.contentY, 0)
    }

    // The keyboard still moves it after a click.
    function test_tabAfterClickScrolls() {
        const page = createTemporaryObject(rowsComponent, tc.Window.contentItem)
        mouseClick(page.column.children[4], 20, 5)
        wait(0)
        page.column.children[6].forceActiveFocus(Qt.TabFocusReason)
        verify(page.contentY > 0)
    }

    function test_skippedStepHasNoCheck() {
        const s = createTemporaryObject(stepsComponent, tc.Window.contentItem, {
            model: ["Instrument", "Eingang", "Latenz", "Fertig"], current: 3, skipped: [2]
        })
        const names = findAll(s, function (c) { return c.Accessible.name !== undefined && c.Accessible.name.indexOf("Latenz") >= 0 })
        verify(names.length > 0)
        verify(names[0].Accessible.name.indexOf("übersprungen") > 0, names[0].Accessible.name)
        const dash = findAll(s, function (c) { return c.text === "–" && c.visible })
        compare(dash.length, 1)
    }

    function test_histogramNamesItsAxis() {
        const h = createTemporaryObject(histComponent, tc.Window.contentItem, {
            counts: [1, 3, 7, 4], firstBinMs: -20, binMs: 10, axisTitle: "Notes"
        })
        const t = findAll(h, function (c) { return c.objectName === "kanteAxisTitle" })
        compare(t.length, 1)
        verify(t[0].visible)
        compare(t[0].text, "Notes")
        verify(h.chart.padLeft > t[0].height)
    }

    function test_wrongNoteIsFramed() {
        const lane = createTemporaryObject(laneComponent, tc.Window.contentItem, {
            notes: [{ time: 0.2, duration: 0.3, string: 1, fret: 3 }, { time: 0.6, duration: 0.3, string: 2, fret: 5 }],
            position: 0
        })
        lane.setNoteState(0, "wrong")
        lane.setNoteState(1, "hit")
        tryVerify(function () {
            return findAll(lane, function (c) { return c.objectName === "kanteWrongFrame" && c.visible }).length === 1
        })
    }
}
