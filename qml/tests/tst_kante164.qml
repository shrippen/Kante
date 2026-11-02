import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.64, from the reviews of 1.63 and Mitori's technique map and exam mode:
 * KanteHeatGrid keeps the focus on the nearest cell, leaves the Tab chain cleanly when its
 * cells go, frames level 0 in the frame colour, takes a row label font and fills its width with
 * a fixed number of columns; KanteBarChart gets a scale floor (`minValue`) and a least bar
 * height (`minBarHeight`).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante164"
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
        id: chainComponent
        Column {
            property alias before: before
            property alias after: after
            property alias grid: chainGrid
            width: 320
            Item { id: before; objectName: "before"; width: 20; height: 20; activeFocusOnTab: true }
            KanteHeatGrid {
                id: chainGrid
                width: parent.width
                showEmpty: false
                minValue: 0
                maxValue: 4
                rowLabels: ["A", "B", "C", "D"]
                cells: [[1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4], [1, 2, 3, 4]]
            }
            Item { id: after; objectName: "after"; width: 20; height: 20; activeFocusOnTab: true }
        }
    }
    function makeChain() {
        const chain = createTemporaryObject(chainComponent, tc.Window.contentItem)
        verify(chain)
        waitForRendering(chain)
        return chain
    }
    function focusedCell(g) {
        return named(g, "kanteHeatCell").filter(c => c.activeFocus)[0] || null
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

    // 1. All cells turn into gaps while one holds the focus (Mitori: another group with no
    // drawn cell): no warning about activeFocusOnTab, Tab goes on, and the grid is no Tab stop
    // afterwards.
    function test_allGapsWhileFocusedTabGoesOn() {
        failOnWarning(/activeFocusOnTab/)
        const chain = makeChain()
        const g = chain.grid
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        g.cells = [[null, null], [null, null]]
        wait(50)
        verify(!focusedCell(g), "no gap holds the focus")
        keyClick(Qt.Key_Tab)
        verify(chain.after.activeFocus, "Tab goes forward, past the grid")
        verify(!g.activeFocusOnTab, "no Tab stop without a drawn cell")
        keyClick(Qt.Key_Backtab)
        verify(chain.before.activeFocus, "Shift+Tab goes past the grid too")
        // Cells come back: the grid is a Tab stop again.
        g.cells = [[1, 2], [3, 4]]
        verify(g.activeFocusOnTab)
        keyClick(Qt.Key_Tab)
        tryVerify(() => !!focusedCell(g), 1000, "Tab enters at a cell")
    }
    function test_allGapsWhileFocusedBacktabGoesBack() {
        failOnWarning(/activeFocusOnTab/)
        const chain = makeChain()
        const g = chain.grid
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        g.showEmpty = true
        g.cells = [[null, null], [null, null]]
        g.showEmpty = false
        wait(50)
        keyClick(Qt.Key_Backtab)
        verify(chain.before.activeFocus, "Shift+Tab goes back")
    }

    // The same when the focused cell goes away with the others (a smaller grid of gaps): the
    // scope holds the focus before the grid knows it has no drawn cell.
    function test_focusedCellGoesWithAllGaps() {
        failOnWarning(/activeFocusOnTab/)
        const chain = makeChain()
        const g = chain.grid
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        keyClick(Qt.Key_End, Qt.ControlModifier)
        verify(g.cellAt(3, 3).activeFocus)
        g.rowLabels = ["A"]
        g.cells = [[null]]
        wait(50)
        keyClick(Qt.Key_Tab)
        verify(chain.after.activeFocus, "Tab goes forward")
        verify(!g.activeFocusOnTab)
    }

    // 2. The focused cell turns into a gap: the focus goes to the nearest drawn cell (same row,
    // else same column), not to the first cell, and the view does not jump to the start.
    Component {
        id: wideComponent
        Column {
            property alias before: wideBefore
            property alias grid: wideGrid
            width: 320
            Item { id: wideBefore; width: 20; height: 20; activeFocusOnTab: true }
            KanteHeatGrid {
                id: wideGrid
                width: parent.width
                showEmpty: false
                minValue: 0
                maxValue: 4
                rowLabelWidth: 60
                rowLabels: ["A", "B", "C"]
                cells: {
                    const out = []
                    for (let r = 0; r < 3; r++) {
                        const row = []
                        for (let c = 0; c < 24; c++) {
                            row.push((r + c) % 5)
                        }
                        out.push(row)
                    }
                    return out
                }
            }
        }
    }
    property var wideCells: []
    function withGaps(g, gaps) {
        return wideCells.map((row, r) => row.map((v, c) => gaps.some(p => p[0] === r && p[1] === c) ? null : v))
    }
    function test_focusGoesToTheNearestCell() {
        const o = createTemporaryObject(wideComponent, tc.Window.contentItem)
        const g = o.grid
        waitForRendering(o)
        verify(g.scrolling)
        const view = named(g, "kanteHeatView")[0]
        wideCells = g.cells
        o.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(0, 0).activeFocus, 1000)
        g.moveTo(1, 15)
        verify(g.cellAt(1, 15).activeFocus)
        const x = view.contentX
        verify(x > 0)
        // Same row: the next drawn cell beside it.
        g.cells = withGaps(g, [[1, 15]])
        tryVerify(() => !!focusedCell(g), 1000)
        compare(g.currentRow, 1, "same row")
        verify(Math.abs(g.currentColumn - 15) === 1, "next to it: " + g.currentColumn)
        verify(focusedCell(g).row === 1)
        verify(view.contentX > 0, "the view stays where it was")
        // A row of gaps only: same column, nearest row.
        g.cells = withGaps(g, [])
        g.moveTo(1, 15)
        verify(g.cellAt(1, 15).activeFocus)
        const gaps = []
        for (let c = 0; c < 24; c++) {
            gaps.push([1, c])
        }
        g.cells = withGaps(g, gaps)
        tryVerify(() => !!focusedCell(g), 1000)
        compare(g.currentColumn, 15, "same column")
        verify(g.currentRow !== 1)
        verify(view.contentX > 0)
        // Without the focus the current cell moves the same way.
        g.cells = withGaps(g, [])
        o.before.forceActiveFocus()
        g.currentRow = 2
        g.currentColumn = 10
        g.cells = withGaps(g, [[2, 10], [2, 9]])
        compare([g.currentRow, g.currentColumn], [2, 11])
    }

    // Of two cells alike far off, the one further on (below, right) is the nearest.
    function test_nearestOfTie() {
        const chain = makeChain()
        const g = chain.grid
        g.cells = [[1, null, null], [null, null, null], [null, null, 1]]
        compare(g.nearestOf(1, 1), [2, 2])
        g.cells = [[null, null, 1], [null, null, null], [1, null, null]]
        compare(g.nearestOf(1, 1), [2, 0])
    }

    // 3. Without the focus, the app sets the row and, a moment later, the column: an in-between
    // gap does not throw the current cell back to the first one.
    function test_currentNotClampedWithoutFocus() {
        const chain = makeChain()
        const g = chain.grid
        g.cells = [[1, 2, 3, 4], [null, 2, 3, 4], [1, 2, 3, 4]]
        waitForRendering(chain)
        g.currentRow = 1           // (1, 0) is a gap for a moment
        wait(50)
        compare([g.currentRow, g.currentColumn], [1, 0], "not moved without the focus")
        g.currentColumn = 2
        wait(50)
        compare([g.currentRow, g.currentColumn], [1, 2])
        // With the focus in the grid it still settles onto a drawn cell.
        chain.before.forceActiveFocus()
        keyClick(Qt.Key_Tab)
        tryVerify(() => g.cellAt(1, 2).activeFocus, 1000)
        g.currentColumn = 0
        tryVerify(() => !!focusedCell(g) && focusedCell(g).shown, 1000)
        verify(g.focusable(g.currentRow, g.currentColumn))
        compare(g.currentRow, 1, "nearest: the same row")
    }

    // 4. Level 0 (and no data) framed in the frame colour, as the legend keys: the frame stands
    // out from the page ground and from the sunken fill of level 0 more than the old rule did.
    function test_levelZeroFrameColour() {
        for (const dark of [true, false]) {
            KanteStyle.preferDark = dark
            if (!dark && !KanteStyle.light) {
                skip("the platform theme is dark: no Leinen here")
            }
            const chain = makeChain()
            const g = chain.grid
            g.showEmpty = true
            g.cells = [[0, 1, null], [2, 3, 4]]
            const ground = g.fillOf(-1)
            for (const cell of [g.cellAt(0, 0), g.cellAt(0, 2)]) {
                const fill = named(cell, "kanteHeatFill")[0]
                verify(fill.border.width > 0)
                compare(String(fill.border.color), String(KanteStyle.frameColor), "the frame colour")
            }
            compare(named(g.cellAt(0, 1), "kanteHeatFill")[0].border.width, 0, "level 1 not framed")
            const frame = g.over(KanteStyle.frameColor, ground)
            const rule = g.over(KanteStyle.ruleColor, ground)
            const onGround = KanteStyle.contrastOf(frame, ground)
            const onZero = KanteStyle.contrastOf(frame, g.fillOf(0))
            const tag = dark ? "dark" : "light"
            verify(onGround >= KanteStyle.contrastOf(rule, ground), tag + ": frame at least as strong as the rule, " + onGround)
            // Measured (Kante 1.64): dark 1.53:1 on the ground, 1.63:1 on level 0; Leinen 1.36:1
            // and 1.28:1. The rule had 1.44:1 and 1.27:1 on the ground.
            verify(onGround >= 1.35, tag + " frame on the ground " + onGround)
            verify(onZero >= 1.25, tag + " frame on level 0 " + onZero)
            // The legend key of level 0 has the same frame.
            const keys = named(g, "kanteHeatLegendKeys")[0]
            const key = findAll(keys, c => c.objectName === "kanteLegendKey")[0]
            compare(String(key.border.color), String(KanteStyle.frameColor))
        }
    }

    // Mitori with level 0 in the legend: a word for it, framed like its cells.
    function test_levelZeroInTheLegend() {
        const g = makeChain().grid
        g.legendLevels = [0, 1, 2, 3, 4]
        g.legendLabels = ["0 neu", "1 gesehen", "2 geübt", "3 sicher", "4 prüfungsreif"]
        g.cells = [[{ value: 0, label: "" }, 1], [null, 4]]
        compare(g.legendModel.map(e => e.text), ["0 neu", "1 gesehen", "2 geübt", "3 sicher", "4 prüfungsreif", "Keine Daten"])
        compare(g.cellAt(0, 0).Accessible.name, "A: 0 neu", "the blank cell says the word of level 0")
    }

    // 5. The row labels take their own font; the default is the label font as before.
    function test_rowLabelFont() {
        const g = makeChain().grid
        g.rowLabels = ["Shiho-nage omote und ura", "B", "C", "D"]
        const label = named(g, "kanteHeatRowLabel")[0]
        compare(label.font.family, g.labelFont.family, "default: the label font")
        compare(label.font.pointSize, g.labelFont.pointSize)
        const mono = g.naturalLabelWidth
        g.rowLabelFont = KanteStyle.smallFont
        compare(label.font.family, KanteStyle.smallFont.family)
        verify(g.naturalLabelWidth !== mono, "the labels' width follows the font")
        const metrics = Qt.createQmlObject("import QtQuick; FontMetrics {}", tc)
        metrics.font = KanteStyle.smallFont
        compare(g.naturalLabelWidth, Math.ceil(metrics.advanceWidth("Shiho-nage omote und ura")))
        metrics.destroy()
        verify(!label.truncated)
    }

    // 6. A fixed number of columns that fills the width (Mitori's forms: 8 a row on a phone).
    Component {
        id: formsComponent
        Item {
            property alias grid: formsGrid
            width: 360
            height: 400
            KanteHeatGrid {
                id: formsGrid
                width: parent.width
                fillWidth: true
                scrollable: false
                showEmpty: false
                minValue: 0
                maxValue: 4
                cellSize: KanteStyle.unit(20)
                cells: [[1, 2, 3, 4, 0, 1, 2, 3], [4, 3, 2, 1, 0, null, null, null]]
            }
        }
    }
    function test_fillWidth() {
        const o = createTemporaryObject(formsComponent, tc.Window.contentItem)
        const g = o.grid
        waitForRendering(o)
        compare(g.columnCount, 8)
        const first = g.cellAt(0, 0)
        const last = g.cellAt(0, 7)
        const right = last.mapToItem(g, last.width, 0).x
        verify(right <= g.width + 0.5, "inside the width: " + right)
        verify(g.width - right - g.ringRoom < 8 + 1, "fills it, short of a pixel per column: " + right)
        compare(first.width, first.height, "square")
        verify(first.width > g.cellSize)
        verify(!g.scrolling)
        // Wider (a tablet): larger cells; 11 a row.
        o.width = 600
        g.cells = [[1, 2, 3, 4, 0, 1, 2, 3, 4, 1, 2]]
        waitForRendering(o)
        const c = g.cellAt(0, 10)
        verify(c.mapToItem(g, c.width, 0).x <= g.width + 0.5)
        verify(g.width - c.mapToItem(g, c.width, 0).x - g.ringRoom < 11 + 1)
        // Too narrow: cellSize at least; then the cells scroll if they may.
        o.width = 100
        compare(g.cellAt(0, 0).width, g.cellSize)
        g.scrollable = true
        verify(g.scrolling)
        // Row labels take their room first.
        o.width = 360
        g.rowLabels = ["Formen"]
        waitForRendering(o)
        const l = g.cellAt(0, 10)
        verify(l.mapToItem(g, l.width, 0).x <= g.width + 0.5)
        verify(g.cellAt(0, 0).mapToItem(g, 0, 0).x >= g.labelWidth)
        compare(named(g, "kanteHeatRowLabel")[0].height, g.cellAt(0, 0).height)
        // Without fillWidth the cells keep cellSize.
        g.fillWidth = false
        compare(g.cellAt(0, 0).height, g.cellSize)
    }

    // 7, 8. KanteBarChart with a floor (Mitori's exam mode: the average per round, 1 to 4) and a
    // least bar height, so a round with average 1 shows, while the read-out says 1.
    Component {
        id: examComponent
        KanteBarChart {
            width: 300
            height: 160
            values: [1, 2.5, 4, 3.25]
            labels: ["1/10", "1/17", "1/24", "1/31"]
            minValue: 1
            maxValue: 4
            minBarHeight: 4
            axis: true
            axisTitle: "Schnitt"
        }
    }
    function test_barChartFloor() {
        const c = createTemporaryObject(examComponent, tc.Window.contentItem)
        verify(c)
        waitForRendering(c)
        compare(c.scaleMax, 4)
        compare(c.scaleSpan, 3)
        // The axis starts at the floor: 1 … 4, a grid line per step.
        const axisTexts = findAll(c, t => t.text !== undefined && t.font !== undefined && t.x < c.padLeft && t.visible && t.objectName !== "kanteAxisTitle").map(t => t.text)
        verify(axisTexts.indexOf("1") >= 0, "floor on the axis: " + axisTexts)
        verify(axisTexts.indexOf("4") >= 0, "top on the axis: " + axisTexts)
        verify(axisTexts.indexOf("0") < 0, "no 0 below the floor: " + axisTexts)
        // Bar heights from the floor.
        const bars = named(c, "kanteBar")
        compare(bars.length, 4)
        tryCompare(bars[2], "height", c.plotHeight, 2000, "4 reaches the top")
        tryCompare(bars[1], "height", c.plotHeight / 2, 2000, "2.5 halfway")
        tryCompare(bars[0], "height", 4, 2000, "the floor value keeps the least height")
        // The read-out says the real value, also of the bar on the floor.
        c.hoverIndex = 0
        const texts = findAll(c, t => t.text !== undefined && t.visible && String(t.text) === "1")
        verify(texts.length >= 2, "1 on the axis and in the read-out")
        compare(c.partAt(0, c.plotHeight - 2), 0, "the least height takes the pointer")
        compare(c.partAt(0, c.plotHeight - 6), -1, "above it nothing")
        compare(c.barAt(c.padLeft + c.columnWidth * 0.5), 0)
        // A goal below the floor is not drawn; on the scale it is.
        const goal = named(c, "kanteGoal")[0]
        c.goal = 0.5
        verify(!goal.visible, "goal below the floor hidden")
        c.goal = 2.5
        verify(goal.visible)
        compare(c.yOf(2.5), c.plotHeight / 2)
        // Without a least height a bar on the floor has none; without a floor all is as before.
        c.minBarHeight = 0
        tryCompare(bars[0], "height", 0, 2000)
        c.minValue = 0
        c.maxValue = 0
        compare(c.scaleMax, 4)
        tryCompare(bars[0], "height", c.plotHeight / 4, 2000)
    }
    // A floor with a scale from the data: the axis rounds up to a step above the floor.
    function test_barChartFloorFromData() {
        const c = createTemporaryObject(examComponent, tc.Window.contentItem)
        c.maxValue = 0
        c.values = [1, 1.5, 2.2]
        compare(c.dataMax, 2.2)
        verify(c.scaleMax >= 2.2)
        compare((c.scaleMax - c.minValue) % c.axisStep, 0)
        // Stacked: the floor cuts the bottom part; the stack's top stands at its total.
        c.values = [[1.5, 1], [0.5, 2]]
        waitForRendering(c)
        const bars = named(c, "kanteBar")
        tryCompare(bars[0], "height", c.heightOf(2.5), 2000)
        tryCompare(bars[1], "height", c.heightOf(2.5), 2000)
        verify(bars[1].clip)
    }
    // A least height lifts a stack: the pointer finds the parts as drawn, from the top.
    function test_barChartLiftedStack() {
        const c = createTemporaryObject(examComponent, tc.Window.contentItem)
        c.minBarHeight = 20
        c.values = [[1.05, 0.05]]
        waitForRendering(c)
        const upper = 0.05 / c.scaleSpan * c.plotHeight
        compare(c.barHeight(0), 20)
        compare(c.partAt(0, c.plotHeight - 20 + upper / 2), 1, "the upper part at the top")
        compare(c.partAt(0, c.plotHeight - 5), 0, "the lifted bottom part below it")
        compare(c.partAt(0, c.plotHeight - 21), -1, "above the bar nothing")
    }
    // A floor below 0: the axis keeps room for its widest label, the negative one.
    function test_barChartNegativeFloorLabel() {
        const c = createTemporaryObject(examComponent, tc.Window.contentItem)
        c.axisTitle = ""           // the title would leave room of its own
        c.minValue = -100
        c.maxValue = 0
        c.values = [5, -50]
        waitForRendering(c)
        const label = findAll(c, t => t.text !== undefined && t.font !== undefined && t.visible && String(t.text) === c.format(-100))
        verify(label.length > 0, "the floor on the axis")
        verify(label[0].x >= 0, "inside the chart: " + label[0].x)
    }
}
