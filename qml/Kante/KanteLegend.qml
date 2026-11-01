import QtQuick
import "."

/**
 * The legend of a chart (Kante 1.61, for Mitori): a key and a word per item, wrapping onto more
 * lines when narrow. Every visualisation without axes needs one, such as
 * the shares by level in a KanteProgressBar or the steps of a KanteHeatmap.
 *
 *   model   [{color, text}, …], drawn in this order; an item may carry `value` ("3"), shown
 *           before the word
 *   keySize the square (Kante styles) or round (System) key: KanteStyle.markerSize × 2
 *
 * Screen readers hear each item as "value text".
 */
Flow {
    id: legend

    property var model: []
    property real keySize: KanteStyle.markerSize * 2

    spacing: KanteStyle.unit(12)

    Repeater {
        model: legend.model
        delegate: Row {
            id: item
            required property var modelData
            readonly property string words: (modelData.value !== undefined ? modelData.value + " " : "") + (modelData.text || "")
            spacing: KanteStyle.unit(6)
            Accessible.role: Accessible.StaticText
            Accessible.name: words

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: legend.keySize
                height: legend.keySize
                radius: KanteStyle.active ? 0 : width / 2
                color: item.modelData.color || KanteStyle.sunkenColor
                border.width: KanteStyle.borderWidth
                border.color: KanteStyle.frameColor
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: item.words
                font: KanteStyle.smallFont
                color: KanteStyle.mutedTextColor
            }
        }
    }
}
