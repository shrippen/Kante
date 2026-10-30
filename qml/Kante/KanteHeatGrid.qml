import QtQuick
import QtQuick.Controls as QQC2
import "."

/**
 * Labelled heat grid (Kante 1.59, from Kontra's fretboard quiz): rows × columns of cells on
 * KanteHeatmap's scale, with row and column labels, the value as a number in each cell, a
 * legend, a tooltip per cell and keyboard focus. KanteHeatmap stays the unlabelled
 * contribution grid.
 *
 *          FRET  0    1    2    3   …
 *   STRING
 *      G        [90] [75] [ – ] [40]
 *      D        [60] [85] [100] [ 20]
 *   legend  ▢ 0  ▤ 25  ▥ 50  ▦ 75  ■ 100   ▭ no data
 *
 *   rowLabels      ["G", "D", "A", "E"], top to bottom
 *   columnLabels   ["0", "1", …, "12"]; "" leaves one out
 *   rowTitle       name of the rows, above their labels (e.g. "Saite"); optional
 *   columnTitle    name of the columns, above their labels (e.g. "Bund"); optional
 *   cells          one list per row; an entry is a number, null (no data) or
 *                  {value, label, tip, accessibleName}: `label` replaces the number in the
 *                  cell, `tip` is the tooltip, `accessibleName` what a screen reader says
 *                  (default "<row>, <column>: <label>", the tooltip's default too)
 *   minValue, maxValue   ends of the scale; NaN (default) takes them from the cells
 *   showValues     the number (or label) in each cell (default true); the text carries the
 *                  value, so the colour is never the only sign
 *   formatter      function (value) -> string; default rounds to one decimal and adds `unit`
 *   legend         the scale below the grid (default true): five swatches with the value
 *                  each stands for (`legendLabels` overrides them), `legendTitle` before them
 *                  and `noDataText` after them when a cell has no data
 *   interactive    Tab focuses the current cell (default true); arrows move, Home / End go
 *                  to the row's ends, Ctrl+Home / End to the first and last cell, Enter /
 *                  Space or a click fire activated(row, column)
 *
 * Level of a value: round((value - min) / (max - min) × 4), 0 to 4 as KanteStyle.heatColor.
 * Level 0 is the sunken ground; a cell without data is the page ground with a rule frame
 * and `emptyText`. The number takes the ink that reads best on its fill (inkOf); where none
 * reaches 4.5:1 (the middle of the scale), it sits on a small plate of the ground.
 */
FocusScope {
    id: grid

    property var rowLabels: []
    property var columnLabels: []
    property string rowTitle: ""
    property string columnTitle: ""
    property var cells: []
    property real minValue: NaN
    property real maxValue: NaN
    property bool showValues: true
    property var formatter: null
    property string unit: ""
    /** Text of a cell without data. */
    property string emptyText: "–"
    property bool legend: true
    property string legendTitle: ""
    /** Five texts for the legend swatches; default the value of each level. */
    property var legendLabels: []
    /** Legend entry for cells without data; "" leaves it out. */
    property string noDataText: "Keine Daten"
    property bool interactive: true
    /** Smallest side of a cell; a cell grows to fit its text. */
    property real cellSize: KanteStyle.unit(30)
    property real spacing: KanteStyle.unit(3)
    /** The focused (or last focused) cell. */
    property int currentRow: 0
    property int currentColumn: 0
    /** Name of the whole grid for screen readers. */
    property string accessibleName: ""

    /** A cell was clicked or chosen with Enter / Space (interactive). */
    signal activated(int row, int column)

    readonly property int rowCount: Math.max(rowLabels.length, cells.length)
    readonly property int columnCount: {
        let n = columnLabels.length
        for (let r = 0; r < cells.length; r++) {
            n = Math.max(n, cells[r] ? cells[r].length : 0)
        }
        return n
    }
    readonly property var dataRange: {
        let lo = Infinity
        let hi = -Infinity
        for (let r = 0; r < cells.length; r++) {
            for (let c = 0; cells[r] && c < cells[r].length; c++) {
                const v = valueOf(r, c)
                if (!isNaN(v)) {
                    lo = Math.min(lo, v)
                    hi = Math.max(hi, v)
                }
            }
        }
        return lo <= hi ? [lo, hi] : [0, 1]
    }
    readonly property real scaleMin: isNaN(minValue) ? dataRange[0] : minValue
    readonly property real scaleMax: isNaN(maxValue) ? dataRange[1] : maxValue
    readonly property bool hasEmpty: {
        for (let r = 0; r < rowCount; r++) {
            for (let c = 0; c < columnCount; c++) {
                if (isNaN(valueOf(r, c)) && !hasLabel(r, c)) {
                    return true
                }
            }
        }
        return false
    }

    /** Contrast the number keeps on its cell (WCAG AA for small text). */
    readonly property real minContrast: 4.5
    readonly property font labelFont: KanteStyle.monoFont(KanteStyle.labelFont().pointSize * 0.85, false)
    readonly property font valueFont: KanteStyle.monoFont(KanteStyle.labelFont().pointSize, false)
    // Cells as wide as the widest text, row labels as wide as the widest label.
    readonly property real cellWidth: {
        let w = cellSize
        for (let r = 0; showValues && r < rowCount; r++) {
            for (let c = 0; c < columnCount; c++) {
                w = Math.max(w, valueMetrics.advanceWidth(textOf(r, c)) + KanteStyle.unit(8))
            }
        }
        for (let c = 0; c < columnLabels.length; c++) {
            w = Math.max(w, labelMetrics.advanceWidth(String(columnLabels[c])) + KanteStyle.unit(4))
        }
        return Math.ceil(w)
    }
    readonly property real labelWidth: {
        let w = titleMetrics.advanceWidth(rowTitle)
        for (let r = 0; r < rowLabels.length; r++) {
            w = Math.max(w, labelMetrics.advanceWidth(String(rowLabels[r])))
        }
        return Math.ceil(w)
    }

    /** Entry of a cell as given: a number, null or an object. */
    function entryOf(r, c) {
        const row = cells[r]
        return row && c < row.length ? row[c] : null
    }
    /** Value of a cell; NaN without data. */
    function valueOf(r, c) {
        const e = entryOf(r, c)
        if (e === null || e === undefined) {
            return NaN
        }
        const v = typeof e === "object" ? e.value : e
        return v === null || v === undefined || v === "" ? NaN : Number(v)
    }
    function hasLabel(r, c) {
        const e = entryOf(r, c)
        return !!e && typeof e === "object" && e.label !== undefined && e.label !== null
    }
    /** A value as the cells and the legend show it. */
    function format(v) {
        if (typeof formatter === "function") {
            return String(formatter(v))
        }
        return Math.round(v * 10) / 10 + unit
    }
    /** Text in a cell: its label, the formatted value or `emptyText`. */
    function textOf(r, c) {
        if (hasLabel(r, c)) {
            return String(entryOf(r, c).label)
        }
        const v = valueOf(r, c)
        return isNaN(v) ? emptyText : format(v)
    }
    /** Level 0 to 4 of a value on the scale, -1 for no data. */
    function levelOf(v) {
        if (isNaN(v)) {
            return -1
        }
        const span = scaleMax - scaleMin
        if (span <= 0) {
            return v >= scaleMax ? 4 : 0
        }
        return Math.max(0, Math.min(4, Math.round((v - scaleMin) / span * 4)))
    }
    function rowName(r) {
        return r < rowLabels.length ? String(rowLabels[r]) : String(r + 1)
    }
    function columnName(c) {
        return c < columnLabels.length && String(columnLabels[c]) !== "" ? String(columnLabels[c]) : String(c + 1)
    }
    /** What a screen reader says for a cell; also the default tooltip. */
    function nameOf(r, c) {
        const e = entryOf(r, c)
        if (e && typeof e === "object" && e.accessibleName) {
            return String(e.accessibleName)
        }
        return rowName(r) + ", " + columnName(c) + ": " + textOf(r, c)
    }
    function tipOf(r, c) {
        const e = entryOf(r, c)
        return e && typeof e === "object" && e.tip ? String(e.tip) : nameOf(r, c)
    }
    /** Text of legend swatch k: `legendLabels[k]` or the value at level k. */
    function legendText(k) {
        if (legendLabels && k < legendLabels.length) {
            return String(legendLabels[k])
        }
        return format(scaleMin + (scaleMax - scaleMin) * k / 4)
    }
    /** `top` over `base` by its alpha, opaque. */
    function over(top, base) {
        const a = top.a
        return Qt.rgba(top.r * a + base.r * (1 - a), top.g * a + base.g * (1 - a), top.b * a + base.b * (1 - a), 1)
    }
    /** Fill of a level as drawn on the page ground: sunken, then the heat tint, opaque. */
    function fillOf(level) {
        const ground = over(KanteStyle.backgroundColor, KanteStyle.backgroundColor)
        if (level < 0) {
            return ground
        }
        return over(KanteStyle.heatColor(level), over(KanteStyle.sunkenColor, ground))
    }
    /**
     * Text colour on a fill: the ground, the strong text or the text on a state colour,
     * whichever reads best (the middle of the cyan scale needs the darkest of them).
     */
    function inkOf(fill) {
        const inks = [KanteStyle.backgroundColor, KanteStyle.strongTextColor, KanteStyle.onStateColor]
        let best = inks[0]
        for (let i = 1; i < inks.length; i++) {
            if (KanteStyle.contrastOf(over(inks[i], fill), fill) > KanteStyle.contrastOf(over(best, fill), fill)) {
                best = inks[i]
            }
        }
        return best
    }
    /** The cell item at row r, column c, or null. */
    function cellAt(r, c) {
        const row = rows.itemAt(r)
        return row ? row.cellAt(c) : null
    }
    /** Moves the focus to a cell, clamped to the grid. */
    function moveTo(r, c) {
        currentRow = Math.max(0, Math.min(rowCount - 1, r))
        currentColumn = Math.max(0, Math.min(columnCount - 1, c))
        const cell = cellAt(currentRow, currentColumn)
        if (cell) {
            cell.forceActiveFocus(Qt.TabFocusReason)
        }
    }

    implicitWidth: body.implicitWidth
    implicitHeight: body.implicitHeight

    // A focus scope in the Tab chain: Tab enters at the current cell, the next Tab leaves.
    activeFocusOnTab: interactive

    Accessible.role: Accessible.Table
    Accessible.name: accessibleName

    FontMetrics {
        id: labelMetrics
        font: grid.labelFont
    }
    FontMetrics {
        id: titleMetrics
        font: KanteStyle.labelFont()
    }
    FontMetrics {
        id: valueMetrics
        font: grid.valueFont
    }

    Column {
        id: body
        spacing: grid.spacing

        // Column title and labels, above the cells.
        Row {
            visible: grid.columnTitle !== ""
            spacing: grid.spacing
            Item {
                width: grid.labelWidth
                height: 1
            }
            Text {
                text: grid.columnTitle
                color: KanteStyle.mutedTextColor
                font: KanteStyle.labelFont()
                Accessible.ignored: true
            }
        }
        Row {
            spacing: grid.spacing
            Text {
                width: grid.labelWidth
                text: grid.rowTitle
                color: KanteStyle.mutedTextColor
                font: KanteStyle.labelFont()
                Accessible.ignored: true
            }
            Repeater {
                model: grid.columnCount
                delegate: Text {
                    required property int index
                    objectName: "kanteHeatColumnLabel"
                    width: grid.cellWidth
                    horizontalAlignment: Text.AlignHCenter
                    text: index < grid.columnLabels.length ? String(grid.columnLabels[index]) : ""
                    color: KanteStyle.mutedTextColor
                    font: grid.labelFont
                    Accessible.ignored: true
                }
            }
        }

        // One row per label: its label, then the cells.
        Repeater {
            id: rows
            model: grid.rowCount
            delegate: Row {
                id: rowItem
                required property int index
                readonly property int row: index
                spacing: grid.spacing

                function cellAt(c) {
                    return cellRepeater.itemAt(c)
                }

                Text {
                    objectName: "kanteHeatRowLabel"
                    width: grid.labelWidth
                    height: grid.cellSize
                    verticalAlignment: Text.AlignVCenter
                    text: rowItem.row < grid.rowLabels.length ? String(grid.rowLabels[rowItem.row]) : ""
                    color: KanteStyle.mutedTextColor
                    font: grid.labelFont
                    Accessible.ignored: true
                }
                Repeater {
                    id: cellRepeater
                    model: grid.columnCount
                    delegate: Item {
                        id: cell
                        required property int index
                        readonly property int row: rowItem.row
                        readonly property int column: index
                        readonly property real value: grid.valueOf(row, column)
                        readonly property int level: grid.levelOf(value)
                        readonly property string text: grid.textOf(row, column)
                        readonly property bool current: grid.currentRow === row && grid.currentColumn === column

                        objectName: "kanteHeatCell"
                        width: grid.cellWidth
                        height: grid.cellSize
                        focus: current

                        Accessible.role: Accessible.Cell
                        Accessible.name: grid.nameOf(row, column)
                        Accessible.focusable: grid.interactive
                        Accessible.focused: activeFocus

                        QQC2.ToolTip.text: grid.tipOf(row, column)
                        QQC2.ToolTip.visible: hover.hovered || activeFocus
                        QQC2.ToolTip.delay: hover.hovered ? 300 : 0

                        onActiveFocusChanged: {
                            if (activeFocus) {
                                grid.currentRow = row
                                grid.currentColumn = column
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: cell.level < 0 ? "transparent" : KanteStyle.sunkenColor
                            border.width: cell.level < 0 ? KanteStyle.borderWidth : 0
                            border.color: KanteStyle.ruleColor
                        }
                        Rectangle {
                            anchors.fill: parent
                            visible: cell.level > 0
                            color: KanteStyle.heatColor(cell.level)
                        }
                        // The number in its best ink; where no ink reaches 4.5:1 on the
                        // fill (the middle of the scale), on a plate of the ground.
                        Rectangle {
                            objectName: "kanteHeatPlate"
                            readonly property color fill: grid.fillOf(cell.level)
                            readonly property color ink: grid.inkOf(fill)
                            readonly property bool needed: cell.level >= 0
                                && KanteStyle.contrastOf(grid.over(ink, fill), fill) < grid.minContrast
                            visible: grid.showValues
                            anchors.centerIn: parent
                            width: valueText.implicitWidth + KanteStyle.unit(4)
                            height: valueText.implicitHeight
                            color: needed ? KanteStyle.backgroundColor : "transparent"
                            Text {
                                id: valueText
                                objectName: "kanteHeatValue"
                                anchors.centerIn: parent
                                text: cell.text
                                color: cell.level < 0 ? KanteStyle.mutedTextColor
                                     : parent.needed ? KanteStyle.strongTextColor : parent.ink
                                font: grid.valueFont
                                Accessible.ignored: true
                            }
                        }
                        // Focus ring outside the cell, a ground line inside it: it stays
                        // visible on a full cyan cell.
                        Rectangle {
                            visible: cell.activeFocus
                            anchors.fill: parent
                            anchors.margins: -KanteStyle.lineWidth
                            color: "transparent"
                            border.width: KanteStyle.lineWidth
                            border.color: KanteStyle.focusColor
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: KanteStyle.lineWidth
                                color: "transparent"
                                border.width: KanteStyle.borderWidth
                                border.color: KanteStyle.backgroundColor
                            }
                        }

                        HoverHandler {
                            id: hover
                        }
                        TapHandler {
                            enabled: grid.interactive
                            onTapped: {
                                grid.moveTo(cell.row, cell.column)
                                grid.activated(cell.row, cell.column)
                            }
                        }

                        Keys.enabled: grid.interactive
                        Keys.onPressed: function (event) {
                            const ctrl = event.modifiers & Qt.ControlModifier
                            // Right to left the columns run from the right: Left goes on.
                            const ahead = rowItem.effectiveLayoutDirection === Qt.RightToLeft ? -1 : 1
                            if (event.key === Qt.Key_Left) {
                                grid.moveTo(row, column - ahead)
                            } else if (event.key === Qt.Key_Right) {
                                grid.moveTo(row, column + ahead)
                            } else if (event.key === Qt.Key_Up) {
                                grid.moveTo(row - 1, column)
                            } else if (event.key === Qt.Key_Down) {
                                grid.moveTo(row + 1, column)
                            } else if (event.key === Qt.Key_Home) {
                                grid.moveTo(ctrl ? 0 : row, 0)
                            } else if (event.key === Qt.Key_End) {
                                grid.moveTo(ctrl ? grid.rowCount - 1 : row, grid.columnCount - 1)
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                                grid.activated(row, column)
                            } else {
                                return
                            }
                            event.accepted = true
                        }
                    }
                }
            }
        }

        // Legend: the five levels with the value each stands for, then "no data".
        Row {
            objectName: "kanteHeatLegend"
            visible: grid.legend
            spacing: KanteStyle.unit(10)
            topPadding: KanteStyle.unit(4)
            Accessible.role: Accessible.StaticText
            Accessible.name: {
                const parts = []
                for (let k = 0; k <= 4; k++) {
                    parts.push(grid.legendText(k))
                }
                if (grid.hasEmpty && grid.noDataText !== "") {
                    parts.push(grid.emptyText + " " + grid.noDataText)
                }
                return (grid.legendTitle !== "" ? grid.legendTitle + ": " : "") + parts.join(", ")
            }

            Text {
                visible: grid.legendTitle !== ""
                anchors.verticalCenter: parent.verticalCenter
                text: grid.legendTitle
                color: KanteStyle.mutedTextColor
                font: KanteStyle.labelFont()
                Accessible.ignored: true
            }
            Repeater {
                model: 5
                delegate: Row {
                    required property int index
                    spacing: KanteStyle.unit(4)
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: KanteStyle.swatchSize
                        height: width
                        color: KanteStyle.sunkenColor
                        Rectangle {
                            anchors.fill: parent
                            color: KanteStyle.heatColor(index)
                        }
                    }
                    Text {
                        objectName: "kanteHeatLegendLabel"
                        anchors.verticalCenter: parent.verticalCenter
                        text: grid.legendText(index)
                        color: KanteStyle.mutedTextColor
                        font: grid.labelFont
                        Accessible.ignored: true
                    }
                }
            }
            Row {
                visible: grid.hasEmpty && grid.noDataText !== ""
                spacing: KanteStyle.unit(4)
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: KanteStyle.swatchSize
                    height: width
                    color: "transparent"
                    border.width: KanteStyle.borderWidth
                    border.color: KanteStyle.ruleColor
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: grid.emptyText + " " + grid.noDataText
                    color: KanteStyle.mutedTextColor
                    font: grid.labelFont
                    Accessible.ignored: true
                }
            }
        }
    }
}
