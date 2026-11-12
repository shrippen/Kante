import QtQuick
import "."

/**
 * The legend of a chart (Kante 1.61, for Mitori): a key and a word per item, wrapping onto more
 * lines when narrow. Every visualisation without axes needs one, such as
 * the shares by level in a KanteProgressBar or the steps of a KanteHeatmap.
 *
 *   model   [{color, text}, …], drawn in this order; an item may carry `value` ("3"), shown
 *           before the word; `frame: false` (1.63) draws its key without the frame, a blank key
 *           for a blank place (as the gaps of a KanteHeatGrid)
 *   keySize the key, KanteStyle.swatchSize; square in the Kante style, round elsewhere (as
 *           markerRadius)
 * A word longer than the legend is wide wraps under its key. Wrapped lines are balanced: the legend
 * takes the narrowest width that needs no more lines, so the last line does not hold one item
 * alone (five keys: 3 + 2, not 4 + 1).
 *
 * Screen readers hear each item as "value text".
 */
Flow {
    id: legend

    property var model: []
    property real keySize: KanteStyle.swatchSize

    // The items' widths, kept by measure(); the free width goes to the end of the lines.
    property var itemWidths: []
    readonly property real slack: width > 0 ? width - balancedWidth() : 0

    spacing: KanteStyle.unit(12)
    leftPadding: effectiveLayoutDirection === Qt.RightToLeft ? slack : 0
    rightPadding: effectiveLayoutDirection === Qt.RightToLeft ? 0 : slack

    // The lines a Flow `room` wide fills with the items, as Flow wraps them.
    function lineCount(room) {
        let lines = 1
        let x = 0
        for (const w of itemWidths) {
            if (x > 0 && x + w > room) {
                lines++
                x = 0
            }
            x += w + spacing
        }
        return lines
    }

    // The narrowest width of a run of items that needs no more lines than the whole width.
    function balancedWidth() {
        const lines = lineCount(width)
        if (lines <= 1) {
            return width
        }
        let best = width
        for (let i = 0; i < itemWidths.length; i++) {
            let run = -spacing
            for (let j = i; j < itemWidths.length; j++) {
                run += itemWidths[j] + spacing
                if (run >= best) {
                    break
                }
                // Half a pixel more, so rounding does not wrap an item that fits.
                if (lineCount(run + 0.5) === lines) {
                    best = run + 0.5
                }
            }
        }
        return best
    }

    function measure() {
        const widths = []
        for (let i = 0; i < items.count; i++) {
            const item = items.itemAt(i)
            if (!item) {
                return
            }
            widths.push(item.implicitWidth)
        }
        itemWidths = widths
    }

    Repeater {
        id: items

        model: legend.model
        onItemAdded: legend.measure()
        onItemRemoved: legend.measure()

        delegate: Row {
            id: item
            required property var modelData
            onImplicitWidthChanged: legend.measure()
            readonly property string words: (modelData.value !== undefined ? modelData.value + " " : "") + (modelData.text || "")
            spacing: KanteStyle.unit(6)
            Accessible.role: Accessible.StaticText
            Accessible.name: words

            Rectangle {
                objectName: "kanteLegendKey"
                anchors.verticalCenter: parent.verticalCenter
                width: legend.keySize
                height: legend.keySize
                radius: KanteStyle.markerRadius > 0 ? width / 2 : 0
                color: item.modelData.color || KanteStyle.sunkenColor
                border.width: item.modelData.frame === false ? 0 : KanteStyle.borderWidth
                border.color: KanteStyle.frameColor
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: legend.width > 0 ? Math.min(implicitWidth, legend.width - legend.keySize - item.spacing) : implicitWidth
                wrapMode: Text.Wrap
                text: item.words
                font: KanteStyle.smallFont
                color: KanteStyle.mutedTextColor
            }
        }
    }
}
