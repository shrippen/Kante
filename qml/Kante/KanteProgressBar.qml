import QtQuick
import "."

/**
 * Progress: a flat bar (`value` 0..1), a row of segments (`segments` > 0, each
 * one lights up like a lamp) or indeterminate warning stripes. 8 px high.
 */
Item {
    id: bar

    property real value: 0
    property bool indeterminate: false
    /** 0: continuous bar; n: n segments. */
    property int segments: 0
    property color color: KanteStyle.accentColor

    implicitWidth: KanteStyle.unit(200)
    implicitHeight: KanteStyle.unit(8)

    Rectangle {
        anchors.fill: parent
        visible: bar.segments === 0
        color: KanteStyle.sunkenColor

        Rectangle {
            visible: !bar.indeterminate
            width: Math.max(0, Math.min(1, bar.value)) * parent.width
            height: parent.height
            color: bar.color
            Behavior on width { NumberAnimation { duration: KanteStyle.duration; easing.type: Easing.OutCubic } }
        }

        KanteHazard {
            anchors.fill: parent
            visible: bar.indeterminate
            color: bar.color
            gapColor: KanteStyle.sunkenColor
            stripe: KanteStyle.unit(8)
        }
    }

    Row {
        anchors.fill: parent
        visible: bar.segments > 0
        spacing: 3
        Repeater {
            model: bar.segments
            delegate: Rectangle {
                required property int index
                width: (bar.width - (bar.segments - 1) * 3) / bar.segments
                height: bar.height
                readonly property bool lit: !bar.indeterminate && (index + 1) <= Math.round(bar.value * bar.segments)
                color: lit ? bar.color : KanteStyle.sunkenColor
                Behavior on color { ColorAnimation { duration: KanteStyle.durationFast } }
            }
        }
    }
}
