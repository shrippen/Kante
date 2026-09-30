import QtQuick
import QtQuick.Shapes
import "."

/**
 * Line chart in the data palette. `series` is a list of lists of numbers, every
 * line its own colour; each ends in a square mark. Miter joins, 2 px lines, 1 px grid.
 * `compact` drops the grid and the marks' room for a sparkline; `accentIndex` picks the colour of
 * a single line (default: the first data colour).
 */
Item {
    id: chart

    property var series: []
    property real minValue: 0
    /** Top of the scale; 0 = the largest value. */
    property real maxValue: 0
    property bool compact: false
    property int colorIndex: 0
    property real lineWidth: compact ? 1.6 : 2

    readonly property real scaleTop: {
        if (maxValue > 0) {
            return maxValue
        }
        var m = minValue + 1
        for (var i = 0; i < series.length; i++) {
            for (var k = 0; k < series[i].length; k++) {
                m = Math.max(m, series[i][k])
            }
        }
        return m
    }
    readonly property real mark: KanteStyle.unit(compact ? 5 : 6)

    implicitWidth: KanteStyle.unit(compact ? 120 : 260)
    implicitHeight: KanteStyle.unit(compact ? 32 : 120)

    function pointsOf(values) {
        var pts = []
        var n = values.length
        var w = width - mark
        var h = height - mark
        for (var i = 0; i < n; i++) {
            var x = mark / 2 + (n > 1 ? i / (n - 1) * w : w / 2)
            var y = mark / 2 + h - (values[i] - minValue) / (scaleTop - minValue) * h
            pts.push(Qt.point(x, y))
        }
        return pts
    }

    Repeater {
        model: chart.compact ? 0 : 3
        delegate: Rectangle {
            required property int index
            width: chart.width
            height: 1
            y: chart.height - 1 - index * (chart.height - 1) / 3
            color: index === 0 ? KanteStyle.frameColor : KanteStyle.ruleColor
        }
    }

    Repeater {
        model: chart.series.length
        delegate: Item {
            id: line
            required property int index
            readonly property var pts: chart.pointsOf(chart.series[index])
            readonly property color tone: KanteStyle.dataColor(chart.series.length === 1 ? chart.colorIndex : index)
            anchors.fill: parent

            Shape {
                anchors.fill: parent
                antialiasing: true
                ShapePath {
                    strokeColor: line.tone
                    strokeWidth: chart.lineWidth
                    fillColor: "transparent"
                    joinStyle: ShapePath.MiterJoin
                    PathPolyline { path: line.pts }
                }
            }
            Rectangle {
                visible: line.pts.length > 0
                width: chart.mark
                height: chart.mark
                color: line.tone
                x: line.pts.length > 0 ? line.pts[line.pts.length - 1].x - width / 2 : 0
                y: line.pts.length > 0 ? line.pts[line.pts.length - 1].y - height / 2 : 0
            }
        }
    }
}
