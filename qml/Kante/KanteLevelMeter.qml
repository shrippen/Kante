import QtQuick
import QtQuick.Controls as QQC2
import "."

/**
 * Audio level meter: a bar in dBFS with three zones (positive up to `warnAt`,
 * warning up to `dangerAt`, negative above), a peak-hold mark that falls back
 * after `holdMs`, and an optional scale under the bar (`scale`: the floor, both
 * zone limits and 0). Horizontal, or vertical with `vertical` (bottom up, scale
 * to the right). The tooltip names the value; `level` undefined = nothing measured.
 * Zone colours are the tier roles, so the meter reads the same in every kind.
 */
Item {
    id: meter

    /** Level in dBFS (peak or RMS, as the app measures); undefined while nothing is measured. */
    property var level: undefined
    property real floor: -60
    property real warnAt: -18
    property real dangerAt: -6
    property bool vertical: false
    /** Labels under (vertical: beside) the bar. */
    property bool scale: false
    /** Peak hold in ms; 0 switches the mark off. */
    property int holdMs: 1500
    /** Bar thickness. */
    property real thickness: KanteStyle.unit(8)

    function fraction(db) {
        return Math.max(0, Math.min(1, (db - floor) / -floor))
    }
    readonly property real value: level === undefined ? 0 : fraction(level)
    property real held: 0

    onValueChanged: {
        if (holdMs <= 0)
            return
        if (value >= held) {
            held = value
            fall.restart()
        }
    }
    Timer {
        id: fall
        interval: meter.holdMs
        onTriggered: meter.held = meter.value
    }

    implicitWidth: vertical ? thickness + (scale ? scaleRow.implicitWidth + KanteStyle.unit(4) : 0) : KanteStyle.unit(160)
    implicitHeight: vertical ? KanteStyle.unit(160) : thickness + (scale ? scaleMetrics.height + KanteStyle.unit(2) : 0)

    // The bar; zones are drawn along x and the item is rotated for vertical meters.
    Item {
        id: track
        width: meter.vertical ? meter.height : meter.width
        height: meter.thickness
        transformOrigin: Item.TopLeft
        rotation: meter.vertical ? -90 : 0
        y: meter.vertical ? meter.height : 0

        Rectangle {
            anchors.fill: parent
            color: KanteStyle.sunkenColor
        }
        Rectangle {
            width: Math.min(meter.value, meter.fraction(meter.warnAt)) * track.width
            height: track.height
            color: KanteStyle.positiveTextColor
        }
        Rectangle {
            x: meter.fraction(meter.warnAt) * track.width
            width: Math.max(0, Math.min(meter.value, meter.fraction(meter.dangerAt)) - meter.fraction(meter.warnAt)) * track.width
            height: track.height
            color: KanteStyle.warningColor
        }
        Rectangle {
            x: meter.fraction(meter.dangerAt) * track.width
            width: Math.max(0, meter.value - meter.fraction(meter.dangerAt)) * track.width
            height: track.height
            color: KanteStyle.negativeTextColor
        }
        // Peak hold
        Rectangle {
            visible: meter.holdMs > 0 && meter.held > 0
            x: Math.min(track.width - width, meter.held * track.width)
            width: 2
            height: track.height
            color: meter.held >= meter.fraction(meter.dangerAt) ? KanteStyle.negativeTextColor : KanteStyle.textColor
        }
    }

    TextMetrics {
        id: scaleMetrics
        font: KanteStyle.labelFont()
        text: "-60"
    }
    Item {
        id: scaleRow
        visible: meter.scale
        readonly property var marks: [meter.floor, meter.warnAt, meter.dangerAt, 0]
        implicitWidth: scaleMetrics.width
        x: meter.vertical ? meter.thickness + KanteStyle.unit(4) : 0
        y: meter.vertical ? 0 : meter.thickness + KanteStyle.unit(2)
        width: meter.vertical ? implicitWidth : meter.width
        height: meter.vertical ? meter.height : scaleMetrics.height
        Repeater {
            model: scaleRow.marks
            delegate: Text {
                required property real modelData
                required property int index
                text: modelData === 0 ? "0" : String(modelData)
                font: KanteStyle.labelFont()
                color: KanteStyle.mutedTextColor
                readonly property real at: meter.fraction(modelData)
                // Ends stay inside the meter; marks between centre on their value.
                x: meter.vertical ? 0 : Math.max(0, Math.min(scaleRow.width - implicitWidth, at * scaleRow.width - implicitWidth / 2))
                y: meter.vertical ? Math.max(0, Math.min(scaleRow.height - implicitHeight, (1 - at) * scaleRow.height - implicitHeight / 2)) : 0
            }
        }
    }

    readonly property string valueText: level === undefined ? qsTr("No signal")
        : qsTr("%1 dBFS").arg(Number(level).toFixed(1))

    Accessible.role: Accessible.ProgressBar
    Accessible.name: valueText

    HoverHandler { id: hover }
    QQC2.ToolTip.visible: hover.hovered
    QQC2.ToolTip.delay: KanteStyle.durationFast
    QQC2.ToolTip.text: valueText
}
