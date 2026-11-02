import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.63, from Kontra's fretboard quiz and Mitori's technique map: KanteHeatGrid, a heat
 * grid with row and column labels, a number per cell, a legend, a tooltip and keyboard focus
 * per cell, and an accessible name per cell; wide grids scroll under standing row labels,
 * column labels stand upright, levels 0..4 as KanteStyle.levelColor, a focus ring on every level.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante163"
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
    // Mitori's technique map: long technique names, 24 attacks with a suffix, levels 0..4,
    // blank where a technique does not answer an attack.
    Component {
        id: mapComponent
        Column {
            property alias before: mapBefore
            property alias grid: mapGrid
            width: 320
            Item { id: mapBefore; width: 20; height: 20; activeFocusOnTab: true }
            KanteHeatGrid {
                id: mapGrid
                width: parent.width
                minValue: 0
                maxValue: 4
                showEmpty: false
                columnLabelsVertical: true
                rowLabelWidth: 90
                cellSize: KanteStyle.unit(26)
                rowLabels: ["Ikkyo (Ude-osae)", "Irimi-nage", "Shiho-nage omote und ura", "Kote-gaeshi"]
                columnLabels: {
                    const out = []
                    for (let c = 0; c < 24; c++) {
                        out.push((c % 2 ? "Katate-dori" : "Shomen-uchi") + " · " + (c + 1))
                    }
                    return out
                }
                cells: {
                    const out = []
                    for (let r = 0; r < 4; r++) {
                        const row = []
                        for (let c = 0; c < 24; c++) {
                            const l = (r + c) % 6
                            row.push(l === 5 ? null : { value: l, label: l > 0 ? String(l) : "" })
                        }
                        out.push(row)
                    }
                    return out
                }
                legendLevels: [1, 2, 3, 4]
                legendLabels: ["", "1 gesehen", "2 geübt", "3 sicher", "4 prüfungsreif"]
                noDataText: "keine Kombination"
                onActivated: (r, c) => tc.onActivated(r, c)
            }
        }
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
        compare(g.legendModel.map(e => e.text), ["0 %", "25 %", "50 %", "75 %", "100 %", "– Keine Daten"])
        verify(g.hasEmpty)
        const legend = named(g, "kanteHeatLegend")[0]
        const keys = named(g, "kanteHeatLegendKeys")[0]
        verify(findAll(keys, c => c.Accessible.name === "– Keine Daten").length === 1, "screen readers hear each key")
        g.legendLabels = ["wenig", undefined, undefined, undefined, "viel"]
        compare(g.legendModel[4].text, "viel")
        compare(g.legendModel[1].text, "25 %", "an undefined label keeps the value")
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
        const title = named(g, "kanteHeatRowTitle")[0]
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

    // KanteHeatmap and KanteHeatGrid draw one scale: KanteStyle.levelColor(level, 4).
    function test_heatmapKeepsItsScale() {
        const h = createTemporaryObject(heatmapComponent, tc)
        for (let l = 0; l <= 4; l++) {
            compare(String(h.levelColor(l)), String(KanteStyle.levelColor(l, 4)))
        }
    }

    /** Bounding box of a (turned) item in `to`'s coordinates: [left, top, right, bottom]. */
    function boxIn(item, to) {
        const pts = [item.mapToItem(to, 0, 0), item.mapToItem(to, item.width, 0),
                     item.mapToItem(to, 0, item.height), item.mapToItem(to, item.width, item.height)]
        return [Math.min(...pts.map(p => p.x)), Math.min(...pts.map(p => p.y)),
                Math.max(...pts.map(p => p.x)), Math.max(...pts.map(p => p.y))]
    }
    function makeMap() {
        activations = 0
        const m = createTemporaryObject(mapComponent, tc.Window.contentItem)
        verify(m)
        waitForRendering(m)
        return m
    }

    // Whole values on 0..4 are the levels themselves, in KanteStyle.levelColor's colours.
    function test_discreteLevels() {
        const g = makeMap().grid
        for (let r = 0; r < 4; r++) {
            for (let c = 0; c < 24; c++) {
                const want = (r + c) % 6
                const cell = g.cellAt(r, c)
                if (want === 5) {
                    compare(cell.level, -1)
                    continue
                }
                compare(cell.level, want, "value " + want + " is level " + want)
                const fill = named(cell, "kanteHeatFill")[0]
                compare(String(fill.color), String(KanteStyle.levelColor(want, 4)))
                compare(cell.text, want > 0 ? String(want) : "", "level 0 without a number")
            }
        }
        const zero = g.cellAt(0, 0)
        verify(!named(zero, "kanteHeatPlate")[0].visible, "no plate for an empty label")
        compare(zero.Accessible.name, "Ikkyo (Ude-osae), Shomen-uchi · 1")
        // The legend: the levels asked for with their words, then the blank places.
        compare(g.legendModel.map(e => e.text), ["1 gesehen", "2 geübt", "3 sicher", "4 prüfungsreif", "keine Kombination"])
        compare(String(g.legendModel[3].color), String(KanteStyle.levelColor(4, 4)))
    }

    // showEmpty false: no data is a blank gap, not drawn, not focusable, skipped by the keys.
    function test_blankGaps() {
        const m = makeMap()
        const g = m.grid
        const gap = g.cellAt(0, 5)
        verify(!gap.shown)
        verify(gap.Accessible.ignored)
        verify(!named(gap, "kanteHeatFill")[0].visible)
        m.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        keyClick(Qt.Key_End)
        compare([g.currentRow, g.currentColumn], [0, 22], "End: the last drawn cell of the row")
        keyClick(Qt.Key_Right)
        compare([g.currentRow, g.currentColumn], [0, 22], "no drawn cell further on: stays")
        keyClick(Qt.Key_Home)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        compare(g.currentColumn, 4)
        keyClick(Qt.Key_Right)
        compare(g.currentColumn, 6, "the gap at 5 is skipped")
        keyClick(Qt.Key_Left)
        compare(g.currentColumn, 4, "back over the gap")
        keyClick(Qt.Key_Left)
        compare(g.currentColumn, 3)
        keyClick(Qt.Key_Down)
        compare([g.currentRow, g.currentColumn], [1, 3])
        keyClick(Qt.Key_Down)
        compare([g.currentRow, g.currentColumn], [3, 3], "the gap at (2, 3) is skipped")
        // A tap on a gap does nothing.
        const before = activations
        mouseClick(g.cellAt(1, 4), 3, 3)
        compare(activations, before)
        // Cells change so that the current cell becomes a gap: it moves to a drawn one.
        g.currentRow = 0
        g.currentColumn = 5
        g.cells = g.cells.slice()
        verify(g.focusable(g.currentRow, g.currentColumn))
    }

    // A wide grid on a narrow screen: the cells scroll, the row labels stay, a scroll bar shows.
    function test_scrollKeepsRowLabels() {
        const m = makeMap()
        const g = m.grid
        verify(g.scrolling, "24 columns do not fit 320 px")
        const view = named(g, "kanteHeatView")[0]
        const bar = named(g, "kanteHeatScrollBar")[0]
        verify(bar.visible)
        verify(bar.height > 0)
        verify(view.width <= g.width - g.labelWidth)
        const label = named(g, "kanteHeatRowLabel")[2]
        const xBefore = label.mapToItem(g, 0, 0).x
        const cell = g.cellAt(2, 0)
        const cellBefore = cell.mapToItem(g, 0, 0).x
        view.contentX = 200
        waitForRendering(g)
        compare(label.mapToItem(g, 0, 0).x, xBefore, "row label stays")
        fuzzyCompare(cell.mapToItem(g, 0, 0).x, cellBefore - 200, 1, "cells move")
        verify(label.visible)
        // Not scrollable: no scroll bar, the view as wide as the cells.
        g.scrollable = false
        verify(!g.scrolling)
        verify(!bar.visible)
    }

    // Arrow keys move the view along so the focused cell, ring included, stays in sight.
    function test_focusStaysInView() {
        const m = makeMap()
        const g = m.grid
        const view = named(g, "kanteHeatView")[0]
        function inView(r, c) {
            const cell = g.cellAt(r, c)
            const x = cell.mapToItem(view, 0, 0).x
            return x - g.ringRoom >= -0.5 && x + cell.width + g.ringRoom <= view.width + 0.5
        }
        m.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        compare(view.contentX, 0)
        for (let i = 0; i < 12; i++) {
            keyClick(Qt.Key_Right)
            verify(inView(g.currentRow, g.currentColumn), "column " + g.currentColumn + " in view")
        }
        verify(view.contentX > 0, "the view moved")
        keyClick(Qt.Key_End, Qt.ControlModifier)
        verify(inView(g.currentRow, g.currentColumn), "last cell in view")
        fuzzyCompare(view.contentX, view.contentWidth - view.width, 1)
        keyClick(Qt.Key_Home, Qt.ControlModifier)
        verify(inView(0, 0))
        compare(view.contentX, 0)
    }

    // Upright column labels: whole, inside the header, all starting on one line above the
    // cells (the row title stands on it), and the columns narrower than the names are long.
    function test_verticalLabelsWhole() {
        const g = makeMap().grid
        g.rowTitle = "Technik"
        waitForRendering(g)
        const labels = named(g, "kanteHeatColumnLabel")
        compare(labels.length, 24)
        const first = g.cellAt(0, 0).mapToItem(g, 0, 0).y
        const starts = []
        for (let i = 0; i < labels.length; i++) {
            const t = labels[i]
            verify(!t.truncated, "label " + i + " whole")
            compare(t.rotation, -90)
            verify(t.implicitWidth <= t.width + 0.5, "label " + i + " fits its length")
            const box = boxIn(t, g)
            verify(box[1] >= -0.5, "label " + i + " not above the grid")
            verify(box[3] <= first + 0.5, "label " + i + " ends above the cells")
            const cell = g.cellAt(0, i)
            const cx = cell.mapToItem(g, cell.width / 2, 0).x
            verify(box[0] >= cx - cell.width / 2 - 0.5 && box[2] <= cx + cell.width / 2 + 0.5, "label " + i + " over its column")
            starts.push(box[3])
        }
        for (const y of starts) {
            fuzzyCompare(y, starts[0], 0.5, "one start line")
        }
        verify(g.cellWidth < labels[0].implicitWidth, "columns narrower than their names")
        const title = named(g, "kanteHeatRowTitle")[0]
        fuzzyCompare(title.mapToItem(g, 0, title.baselineOffset).y, starts[0], 1, "row title on the start line")
        // Capped: the labels elide and the full name is the tooltip.
        g.columnLabelMaxLength = 40
        waitForRendering(g)
        const t = labels[3]
        verify(t.truncated)
        verify(boxIn(t, g)[3] <= first + 0.5)
        compare(t.parent.tip, "Katate-dori · 4")
        g.columnTips = ["", "", "", "片手取り"]
        compare(t.parent.tip, "片手取り")
    }

    // Long row names: capped by rowLabelWidth, elided, the full name as a tooltip.
    function test_longRowLabels() {
        const g = makeMap().grid
        compare(g.labelWidth, 90)
        verify(g.naturalLabelWidth > 90)
        const label = named(g, "kanteHeatRowLabel")[2]
        compare(label.width, 90)
        verify(label.truncated)
        compare(label.QQC2.ToolTip.text, "Shiho-nage omote und ura")
        verify(g.cellAt(2, 0).mapToItem(g, 0, 0).x >= label.mapToItem(g, label.width, 0).x)
        verify(!named(g, "kanteHeatRowLabel")[1].truncated, "a short name stays whole")
        g.rowLabelWidth = 0
        compare(g.labelWidth, g.naturalLabelWidth)
        verify(!label.truncated)
    }

    // The focus ring shows on every level, the full focus colour of level 4 too: its outer
    // line stands out from the ground, its inner line from the fill (3:1, WCAG non-text), dark and light.
    function test_focusRingOnEveryLevel() {
        for (const dark of [true, false]) {
            KanteStyle.preferDark = dark
            if (!dark && !KanteStyle.light) {
                skip("the platform theme is dark: no Leinen here")
            }
            const m = makeMap()
            const g = m.grid
            const ground = g.fillOf(-1)
            for (let l = 0; l <= 4; l++) {
                const cell = g.cellAt(0, l)
                compare(cell.level, l)
                g.moveTo(0, l)
                verify(cell.activeFocus)
                const ring = named(cell, "kanteHeatRing")[0]
                const inner = named(cell, "kanteHeatRingInner")[0]
                verify(ring.visible)
                const fill = g.fillOf(l)
                const outer = KanteStyle.contrastOf(g.over(ring.border.color, ground), ground)
                const inside = KanteStyle.contrastOf(g.over(inner.border.color, fill), fill)
                verify(outer >= 3, (dark ? "dark" : "light") + " level " + l + " outer " + outer)
                verify(inside >= 3, (dark ? "dark" : "light") + " level " + l + " inner " + inside)
                verify(inner.border.width >= KanteStyle.lineWidth)
            }
        }
    }

    // Right to left the first column is on the right: the view starts at the right end.
    Component {
        id: rtlComponent
        Item {
            property alias grid: rtlGrid
            width: 320
            height: 300
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            KanteHeatGrid {
                id: rtlGrid
                width: parent.width
                rowLabels: ["A", "B"]
                cells: [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]]
            }
        }
    }
    function test_rightToLeftStartsAtTheFirstColumn() {
        const o = createTemporaryObject(rtlComponent, tc.Window.contentItem)
        const g = o.grid
        waitForRendering(o)
        verify(g.scrolling)
        const view = named(g, "kanteHeatView")[0]
        tryVerify(() => Math.abs(view.contentX - (view.contentWidth - view.width)) < 1, 1000, "at the right end")
        const cell = g.cellAt(0, 0)
        const x = cell.mapToItem(view, 0, 0).x
        verify(x >= 0 && x + cell.width <= view.width + 0.5, "first column in view")
        const label = named(g, "kanteHeatRowLabel")[0]
        verify(label.mapToItem(o, 0, 0).x > view.mapToItem(o, 0, 0).x, "row labels on the right")
    }
}
