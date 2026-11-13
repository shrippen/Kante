import QtQuick
import QtTest
import Kante

/**
 * Kante 1.81: KanteHeatGrid keeps its cells in place when it switches between data sets
 * (Mitori's technique map), with room reserved for the labels and columns that may come.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteHeatReserve"
    width: 800
    height: 600
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    // Two data sets: short labels, two columns; long labels, four columns.
    readonly property var small: ({ rows: ["Ikkyo"], columns: ["Tsuki", "Men"] })
    readonly property var large: ({ rows: ["Shiho-nage", "Kote-gaeshi omote"],
                                    columns: ["Ryote-katate-dori", "Ushiro-ryote-dori", "Tsuki", "Men"] })

    Component {
        id: gridComponent
        KanteHeatGrid {
            columnLabelsVertical: true
            maxValue: 4
        }
    }

    function show(grid, set) {
        grid.rowLabels = set.rows
        grid.columnLabels = set.columns
        grid.cells = set.rows.map(() => set.columns.map(() => 1))
        waitForRendering(grid)
    }

    function origin(grid) {
        const cell = grid.cellAt(0, 0)
        return cell.mapToItem(grid, 0, 0)
    }

    function test_cells_stay() {
        const grid = createTemporaryObject(gridComponent, tc.Window.contentItem, {
            reserveRowLabels: large.rows, reserveColumnLabels: large.columns, reserveColumns: large.columns.length })
        show(grid, small)
        const before = origin(grid)
        const width = grid.implicitWidth
        show(grid, large)
        const after = origin(grid)
        compare(after.x, before.x, "the cells start where they started")
        compare(after.y, before.y, "below the same header")
        compare(grid.implicitWidth, width, "room for the larger set's columns")
    }

    // Without reserves the room follows the labels (as before 1.81).
    function test_without_reserve() {
        const grid = createTemporaryObject(gridComponent, tc.Window.contentItem)
        show(grid, small)
        const before = origin(grid)
        show(grid, large)
        verify(origin(grid).x > before.x, "longer row labels push the cells")
        verify(origin(grid).y > before.y, "longer column labels push them down")
    }
}
