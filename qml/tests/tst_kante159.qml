import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.59, from Kontra's fretboard quiz: KanteHeatGrid, a heat grid with row and column
 * labels, a number per cell, a legend, a tooltip and keyboard focus per cell, and an
 * accessible name per cell. KanteHeatmap keeps its scale (KanteStyle.heatColor).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante159"
    width: 800
    height: 600
    when: windowShown

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    property bool darkBefore: false
    function init() {
        kindBefore = KanteStyle.kind
        darkBefore = KanteStyle.preferDark
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
        KanteStyle.preferDark = darkBefore
    }

    Component {
        id: gridComponent
        KanteHeatGrid {
            rowLabels: ["G", "D", "A", "E"]
            columnLabels: ["0", "1", "2", "3"]
            rowTitle: "Saite"
            columnTitle: "Bund"
            unit: " %"
            cells: [
                [100, 75, null, 0],
                [50, { value: 25, tip: "D, Bund 1: 1 von 4" }, 80, 60],
                [0, 100, { value: 40, label: "40!" }, 20],
                [10, 20, 30, { value: 90, accessibleName: "E, Bund 3: 90 Prozent" }]
            ]
        }
    }
    Component {
        id: chainComponent
        Column {
            property alias before: before
            property alias after: after
            property alias grid: chainGrid
            Item { id: before; objectName: "before"; width: 20; height: 20; activeFocusOnTab: true }
            KanteHeatGrid {
                id: chainGrid
                rowLabels: ["G", "D", "A", "E"]
                columnLabels: ["0", "1", "2", "3"]
                cells: [[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4]]
                onActivated: (r, c) => tc.onActivated(r, c)
            }
            Item { id: after; objectName: "after"; width: 20; height: 20; activeFocusOnTab: true }
        }
    }
    Component {
        id: heatmapComponent
        KanteHeatmap { levels: [0, 1, 2, 3, 4] }
    }

    property int activations: 0
    property int lastRow: -1
    property int lastColumn: -1
    function onActivated(r, c) {
        activations++
        lastRow = r
        lastColumn = c
    }

    function make() {
        activations = 0
        const g = createTemporaryObject(gridComponent, tc.Window.contentItem)
        verify(g)
        g.activated.connect(onActivated)
        waitForRendering(g)
        return g
    }
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
    function named(item, name) {
        return findAll(item, c => c.objectName === name)
    }

    function test_labelsAndCells() {
        const g = make()
        compare(g.rowCount, 4)
        compare(g.columnCount, 4)
        compare(named(g, "kanteHeatRowLabel").map(t => t.text), ["G", "D", "A", "E"])
        compare(named(g, "kanteHeatColumnLabel").map(t => t.text), ["0", "1", "2", "3"])
        compare(named(g, "kanteHeatCell").length, 16)
        // Column labels stand over their cells, row labels left of them.
        const col = named(g, "kanteHeatColumnLabel")[2]
        const cell = g.cellAt(0, 2)
        fuzzyCompare(col.mapToItem(g, col.width / 2, 0).x, cell.mapToItem(g, cell.width / 2, 0).x, 1)
        const label = named(g, "kanteHeatRowLabel")[1]
        verify(label.mapToItem(g, label.width, 0).x <= g.cellAt(1, 0).mapToItem(g, 0, 0).x)
    }

    function test_numbersInCells() {
        const g = make()
        compare(g.cellAt(0, 0).text, "100 %")
        compare(g.cellAt(0, 2).text, "–", "no data")
        compare(g.cellAt(2, 2).text, "40!", "label replaces the number")
        g.formatter = v => Math.round(v) + "/100"
        compare(g.cellAt(0, 1).text, "75/100")
        // The number is drawn in the cell, unless showValues is off.
        const t = named(g.cellAt(0, 1), "kanteHeatValue")[0]
        compare(t.text, "75/100")
        verify(t.visible)
        g.showValues = false
        verify(!t.visible)
    }

    function test_levels() {
        const g = make()
        compare(g.scaleMin, 0)
        compare(g.scaleMax, 100)
        compare(g.cellAt(0, 0).level, 4)
        compare(g.cellAt(0, 3).level, 0)
        compare(g.cellAt(1, 1).level, 1)
        compare(g.cellAt(1, 0).level, 2)
        compare(g.cellAt(0, 2).level, -1, "no data")
        // Fixed ends: values outside clamp.
        g.minValue = 50
        g.maxValue = 90
        compare(g.cellAt(0, 0).level, 4)
        compare(g.cellAt(0, 3).level, 0)
        compare(g.cellAt(1, 2).level, 3)
    }

    function test_legend() {
        const g = make()
        compare(named(g, "kanteHeatLegendLabel").map(t => t.text), ["0 %", "25 %", "50 %", "75 %", "100 %"])
        verify(g.hasEmpty)
        const legend = named(g, "kanteHeatLegend")[0]
        verify(legend.Accessible.name.indexOf("Keine Daten") >= 0)
        g.legendLabels = ["wenig", "", "", "", "viel"]
        compare(named(g, "kanteHeatLegendLabel")[4].text, "viel")
        g.legend = false
        verify(!legend.visible)
    }

    function test_accessibleNamesAndTips() {
        const g = make()
        const plain = g.cellAt(0, 1)
        compare(plain.Accessible.role, Accessible.Cell)
        compare(plain.Accessible.name, "G, 1: 75 %")
        compare(plain.QQC2.ToolTip.text, "G, 1: 75 %", "tooltip defaults to the name")
        compare(g.cellAt(1, 1).QQC2.ToolTip.text, "D, Bund 1: 1 von 4")
        compare(g.cellAt(3, 3).Accessible.name, "E, Bund 3: 90 Prozent")
        compare(g.cellAt(0, 2).Accessible.name, "G, 2: –")
    }

    function test_keyboard() {
        activations = 0
        const chain = createTemporaryObject(chainComponent, tc.Window.contentItem)
        const g = chain.grid
        waitForRendering(chain)
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000, "Tab focuses the current cell")
        verify(g.cellAt(0, 0).QQC2.ToolTip.visible, "focus shows the tooltip")
        keyClick(Qt.Key_Right)
        verify(g.cellAt(0, 1).activeFocus)
        keyClick(Qt.Key_Down)
        verify(g.cellAt(1, 1).activeFocus)
        compare([g.currentRow, g.currentColumn], [1, 1])
        keyClick(Qt.Key_End)
        verify(g.cellAt(1, 3).activeFocus)
        keyClick(Qt.Key_Home, Qt.ControlModifier)
        verify(g.cellAt(0, 0).activeFocus)
        keyClick(Qt.Key_Up)
        verify(g.cellAt(0, 0).activeFocus, "stays at the edge")
        keyClick(Qt.Key_End, Qt.ControlModifier)
        verify(g.cellAt(3, 3).activeFocus)
        keyClick(Qt.Key_Return)
        compare(activations, 1)
        compare([lastRow, lastColumn], [3, 3])
        // Tab leaves the grid; Shift+Tab comes back to the current cell.
        keyClick(Qt.Key_Tab)
        verify(chain.after.activeFocus, "Tab leaves")
        keyClick(Qt.Key_Backtab)
        tryVerify(() => g.cellAt(3, 3).activeFocus, 1000, "back at the current cell")
    }

    function test_click() {
        const g = make()
        const cell = g.cellAt(2, 1)
        mouseClick(cell, cell.width / 2, cell.height / 2)
        compare(activations, 1)
        compare([lastRow, lastColumn], [2, 1])
        verify(cell.activeFocus)
        g.interactive = false
        mouseClick(cell, cell.width / 2, cell.height / 2)
        compare(activations, 1, "not interactive: no activation")
        verify(!g.activeFocusOnTab)
    }

    // Gapped column labels (only every third fret written): the name says the real fret.
    function test_gappedLabelsKeepTheRealName() {
        const g = make()
        g.columnLabels = ["0", "", "", "3"]
        compare(g.cellAt(0, 1).Accessible.name, "G: 75 %", "no invented index")
        compare(g.cellAt(0, 1).QQC2.ToolTip.text, "G: 75 %")
        g.columnNames = ["Bund 0", "Bund 1", "Bund 2", "Bund 3"]
        compare(g.cellAt(0, 1).Accessible.name, "G, Bund 1: 75 %")
        compare(g.cellAt(0, 3).Accessible.name, "G, Bund 3: 0 %")
        g.rowNames = ["G-Saite"]
        compare(g.cellAt(0, 1).Accessible.name, "G-Saite, Bund 1: 75 %")
        compare(g.cellAt(1, 1).Accessible.name, "D, Bund 1: 25 %", "label where no name")
    }

    // Cells shrink while the focus sat on a cell that goes away: Tab still lands on a cell.
    function test_shrinkKeepsAFocusedCell() {
        activations = 0
        const chain = createTemporaryObject(chainComponent, tc.Window.contentItem)
        const g = chain.grid
        g.columnLabels = []
        g.cells = [[1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6], [1, 2, 3, 4, 5, 6]]
        waitForRendering(chain)
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        keyClick(Qt.Key_End, Qt.ControlModifier)
        compare([g.currentRow, g.currentColumn], [3, 5])
        keyClick(Qt.Key_Tab)
        verify(chain.after.activeFocus)
        g.rowLabels = ["G", "D"]
        g.cells = [[1, 2, 3], [1, 2, 3]]
        waitForRendering(chain)
        compare([g.currentRow, g.currentColumn], [1, 2], "clamped")
        keyClick(Qt.Key_Backtab)
        tryVerify(() => g.cellAt(1, 2) && g.cellAt(1, 2).activeFocus, 1000, "focus on a valid cell")
        keyClick(Qt.Key_Left)
        verify(g.cellAt(1, 1).activeFocus, "arrows work")
        // Shrink while a cell that goes away holds the focus: it moves on, arrows still work.
        keyClick(Qt.Key_End)
        verify(g.cellAt(1, 2).activeFocus)
        g.cells = [[1, 2], [1, 2]]
        tryVerify(() => g.cellAt(1, 1) && g.cellAt(1, 1).activeFocus, 1000, "focus moves to a valid cell")
        keyClick(Qt.Key_Up)
        verify(g.cellAt(0, 1).activeFocus)
    }

    // Row title and column labels share one baseline.
    function test_headerBaseline() {
        const g = make()
        const title = findAll(g, c => c.text === "Saite")[0]
        const col = named(g, "kanteHeatColumnLabel")[0]
        fuzzyCompare(title.mapToItem(g, 0, title.baselineOffset).y, col.mapToItem(g, 0, col.baselineOffset).y, 1)
    }

    // The number reads on every level, dark and Leinen: in its ink or on its plate.
    function test_textReadsOnEveryLevel() {
        for (const dark of [true, false]) {
            KanteStyle.preferDark = dark
            if (!dark && !KanteStyle.light) {
                skip("the platform theme is dark: no Leinen here")
            }
            const g = make()
            const cells = named(g, "kanteHeatCell")
            for (const cell of cells) {
                const plate = named(cell, "kanteHeatPlate")[0]
                const text = named(cell, "kanteHeatValue")[0]
                const bg = plate.needed ? g.fillOf(-1) : g.fillOf(cell.level)
                const ratio = KanteStyle.contrastOf(g.over(text.color, bg), bg)
                verify(ratio >= 4.5, (dark ? "dark" : "light") + " level " + cell.level + ": " + ratio)
            }
        }
    }

    function test_heatmapKeepsItsScale() {
        const h = createTemporaryObject(heatmapComponent, tc)
        for (let l = 0; l <= 4; l++) {
            compare(String(h.levelColor(l)), String(KanteStyle.heatColor(l)))
        }
        compare(KanteStyle.heatColor(4).a, 1)
        fuzzyCompare(KanteStyle.heatColor(2).a, 0.44, 0.01)
    }
}
