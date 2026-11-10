import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.78, for a window 533 px wide (Kaiwa): the list row puts its meta figure and trailing
 * items under the texts when the row is narrow; the heat map takes row and column labels, a
 * legend and tooltips; a path node takes a sentence.
 * Run: tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "Kante178"
    width: 600
    height: 600
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    // ---- KanteListRow ----

    Component {
        id: rowScene
        Column {
            property alias row: row
            property alias first: first
            property alias second: second
            width: 600
            KanteListRow {
                id: row
                width: parent.width
                text: "Ein recht langer Titel der Zeile"
                subtitle: "Und eine ebenso lange Unterzeile"
                meta: "02:14"
                trailing: Row {
                    spacing: 4
                    KanteButton { id: first; text: "Üben" }
                    KanteButton { id: second; text: "Löschen" }
                }
            }
        }
    }

    Component {
        id: twoLines
        KanteListRow { width: 600; text: "Ein recht langer Titel der Zeile"; subtitle: "Und eine ebenso lange Unterzeile" }
    }

    function test_wide_row_stays_in_one_line() {
        const scene = createTemporaryObject(rowScene, stage())
        const row = scene.row
        verify(!row.stacked)
        const right = scene.second.mapToItem(row, scene.second.width, 0).x
        verify(right <= row.width, "buttons inside the row")
        verify(scene.first.y < row.height, "on the line of the texts")
        const plain = createTemporaryObject(twoLines, stage())
        compare(row.implicitHeight, plain.implicitHeight, "as high as a row without trailing items")
    }

    function test_narrow_row_stacks_the_tail() {
        const scene = createTemporaryObject(rowScene, stage())
        const row = scene.row
        const wideHeight = row.implicitHeight
        scene.width = 240
        row.width = 240
        verify(row.stacked, "stacked at 240")
        verify(row.implicitHeight > wideHeight, "taller: " + row.implicitHeight + " vs " + wideHeight)
        waitForRendering(scene)
        tryVerify(() => scene.first.mapToItem(row, 0, 0).y > 0)
        const at = scene.first.mapToItem(row, 0, 0)
        const end = scene.second.mapToItem(row, scene.second.width, 0)
        verify(end.x <= row.width, "buttons inside the row, end at " + end.x)
        verify(at.y >= row.height / 2 - 1, "under the texts, y " + at.y)
        verify(at.x > 0 && at.x < row.width / 2, "left-aligned, x " + at.x)
        verify(at.y + scene.first.height <= row.height, "inside the row")
    }

    function test_stacked_texts_wrap() {
        const scene = createTemporaryObject(rowScene, stage())
        const row = scene.row
        row.minTextWidth = KanteStyle.unit(400)
        row.width = 300
        verify(row.stacked)
        function texts(item, found) {
            for (let i = 0; i < item.children.length; i++) {
                const kid = item.children[i]
                if (kid instanceof Text && (kid.text === row.text || kid.text === row.subtitle)) {
                    found.push(kid)
                }
                texts(kid, found)
            }
            return found
        }
        const found = texts(row, [])
        compare(found.length, 2)
        for (const t of found) {
            compare(t.wrapMode, Text.Wrap)
            verify(t.lineCount > 1 || t.implicitWidth <= t.width, "wrapped, not cut")
        }
    }

    function test_row_without_tail_never_stacks() {
        const row = createTemporaryObject(plainRow, stage())
        verify(!row.stacked)
    }
    Component {
        id: plainRow
        KanteListRow { width: 100; text: "Nur Text" }
    }

    function test_focus_in_both_states() {
        for (const width of [600, 240]) {
            const scene = createTemporaryObject(rowScene, stage())
            scene.row.width = width
            compare(scene.row.stacked, width < 300)
            const focused = () => scene.Window.activeFocusItem
            scene.row.forceActiveFocus(Qt.TabFocusReason)
            keyClick(Qt.Key_Tab)
            verify(focused() === scene.first, width + ": first button, focus on " + focused())
            keyClick(Qt.Key_Tab)
            verify(focused() === scene.second, width + ": second button, focus on " + focused())
            keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
            verify(focused() === scene.first, width + ": back to first, focus on " + focused())
            keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
            verify(focused() === scene.row, width + ": back to the row, focus on " + focused())
        }
    }

    // ---- KanteHeatmap ----

    Component {
        id: heatBare
        KanteHeatmap { columns: 5; levels: [0, 1, 2, 3, 4, 0, 1, 2, 3, 4] }
    }
    Component {
        id: heatFull
        KanteHeatmap {
            columns: 5
            levels: [0, 1, 2, 3, 4, 0, 1, 2, 3, 4]
            rowLabels: ["Mo", ""]
            columnLabels: ["a", "b", "c", "d", "e"]
            tips: ["t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9"]
            legendLess: "weniger"
            legendMore: "mehr"
        }
    }

    function test_heatmap_bare_size() {
        const heat = createTemporaryObject(heatBare, stage())
        const cell = heat.cellSize
        compare(heat.implicitWidth, 5 * cell + 4 * heat.spacing)
        compare(heat.implicitHeight, 2 * cell + heat.spacing)
        compare(heat.levelColor(4), KanteStyle.levelColor(4, 4))
    }

    function test_heatmap_labels_and_legend_add_room() {
        const bare = createTemporaryObject(heatBare, stage())
        const full = createTemporaryObject(heatFull, stage())
        verify(full.implicitWidth > bare.implicitWidth, "row labels take room on the left")
        verify(full.implicitHeight > bare.implicitHeight + full.cellSize, "column labels and legend take room")
    }

    function labelTexts(item, found) {
        for (let i = 0; i < item.children.length; i++) {
            const kid = item.children[i]
            if (kid instanceof Text && kid.visible) {
                found.push(kid.text)
            }
            labelTexts(kid, found)
        }
        return found
    }

    function test_heatmap_draws_the_labels() {
        const texts = labelTexts(createTemporaryObject(heatFull, stage()), [])
        for (const wanted of ["Mo", "a", "e", "weniger", "mehr"]) {
            verify(texts.indexOf(wanted) >= 0, wanted + " in " + texts)
        }
        const bare = labelTexts(createTemporaryObject(heatBare, stage()), [])
        compare(bare.length, 0, "no text without labels")
    }

    // A header row, then per row its label and its cells, in this order.
    function test_heatmap_labels_sit_around_the_cells() {
        const heat = createTemporaryObject(heatFull, stage())
        let rowLabel = null
        let columnLabel = null
        let cell = null
        function find(item) {
            for (let i = 0; i < item.children.length; i++) {
                const kid = item.children[i]
                if (kid instanceof Text && kid.text === "Mo") {
                    rowLabel = kid
                }
                if (kid instanceof Text && kid.text === "a") {
                    columnLabel = kid
                }
                if (kid.hasOwnProperty("tip") && kid.tip === "t0") {
                    cell = kid
                }
                find(kid)
            }
        }
        find(heat)
        verify(rowLabel && columnLabel && cell)
        const label = rowLabel.mapToItem(heat, 0, 0)
        const above = columnLabel.mapToItem(heat, 0, 0)
        const at = cell.mapToItem(heat, 0, 0)
        verify(label.x + rowLabel.width <= at.x, "row label left of the cell")
        verify(above.y + columnLabel.height <= at.y, "column label above the cell")
        verify(Math.abs(label.y + rowLabel.height / 2 - (at.y + cell.height / 2)) <= 1, "row label level with its row")
    }

    function test_heatmap_legend_needs_a_text() {
        const heat = createTemporaryObject(heatBare, stage())
        verify(!heat.hasLegend)
        heat.legendMore = "mehr"
        verify(heat.hasLegend)
    }

    function test_heatmap_tip_on_hover() {
        const heat = createTemporaryObject(heatFull, stage())
        // The third cell of the first row: skip the header row and the row label.
        const x = heat.width - 1
        let cell = null
        function find(item) {
            for (let i = 0; i < item.children.length; i++) {
                const kid = item.children[i]
                if (kid.hasOwnProperty("tip") && kid.tip === "t4") {
                    cell = kid
                }
                find(kid)
            }
        }
        find(heat)
        verify(cell, "cell with tip t4")
        mouseMove(heat, cell.mapToItem(heat, 0, 0).x + 2, cell.mapToItem(heat, 0, 0).y + 2)
        tryVerify(() => cell.QQC2.ToolTip.visible, 2000)
        compare(cell.QQC2.ToolTip.text, "t4")
        mouseMove(heat, -50, -50)
        tryVerify(() => !cell.QQC2.ToolTip.visible, 2000)
    }

    function test_heatmap_without_tips_has_no_tooltip() {
        const heat = createTemporaryObject(heatBare, stage())
        verify(heat.tips.length === 0)
        function visibleTips(item) {
            for (let i = 0; i < item.children.length; i++) {
                const kid = item.children[i]
                if (kid.hasOwnProperty("tip") && kid.tip !== "") {
                    return true
                }
                if (visibleTips(kid)) {
                    return true
                }
            }
            return false
        }
        verify(!visibleTips(heat))
    }

    // ---- KantePath ----

    Component {
        id: pathScene
        KantePath {
            model: [
                { title: "Eins", meta: "N5-01", state: "open" },
                { title: "Zwei", meta: "N5-02", state: "open", text: "Ein recht langer Satz, der in einem schmalen Knoten umbrechen muss, weil er nicht passt." }
            ]
        }
    }

    function nodes(path) {
        const found = []
        for (let i = 0; i < path.children.length; i++) {
            if (path.children[i].hasOwnProperty("modelData")) {
                found.push(path.children[i])
            }
        }
        return found
    }

    function test_path_text_grows_the_node() {
        const path = createTemporaryObject(pathScene, stage(), { width: 240 })
        const list = nodes(path)
        compare(list.length, 2)
        verify(list[1].height > list[0].height, "the node with a sentence is taller")
        compare(list[0].Accessible.description, "N5-01")
        verify(list[1].Accessible.description.indexOf("N5-02. Ein recht langer Satz") === 0, list[1].Accessible.description)
    }

    function test_path_text_wraps_and_stays_in_the_node() {
        const path = createTemporaryObject(pathScene, stage(), { width: 240 })
        const node = nodes(path)[1]
        let sentence = null
        function find(item) {
            for (let i = 0; i < item.children.length; i++) {
                const kid = item.children[i]
                if (kid instanceof Text && kid.text.indexOf("Ein recht") === 0) {
                    sentence = kid
                }
                find(kid)
            }
        }
        find(node)
        verify(sentence, "the sentence is drawn")
        compare(sentence.wrapMode, Text.Wrap)
        compare(sentence.elide, Text.ElideNone)
        verify(sentence.lineCount > 1, "wrapped")
        const bottom = sentence.mapToItem(node, 0, sentence.height).y
        verify(bottom <= node.height, "inside the node: " + bottom + " of " + node.height)
    }

    // ---- Gallery ----

    function test_gallery_shows_all_three() {
        const component = Qt.createComponent(Qt.resolvedUrl("../demo/Gallery.qml"), Component.PreferSynchronous)
        tryVerify(() => component.status !== Component.Loading)
        compare(component.status, Component.Ready, component.errorString())
        const gallery = component.createObject(null)
        verify(gallery)
        verify(findChild(gallery, "galleryNarrowRow"), "a narrow list row")
        verify(findChild(gallery, "galleryHeatmapAxes"), "a heat map with labels")
        verify(findChild(gallery, "galleryPathText"), "a path with a sentence")
        gallery.destroy()
    }
}
