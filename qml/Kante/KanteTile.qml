import QtQuick
import QtQuick.Layouts
import "."

/**
 * Image tile: 3:2 stage, a 4 px tier bar (green / yellow / red, never colour
 * alone: name and figure sit below), selection as a cyan frame and tick, keyboard
 * focus as four cyan brackets that lock on. Put the image in the stage
 * (`content`); `figure` is the number on the right (98 %).
 */
FocusScope {
    id: tile

    enum Tier {
        Good,
        Check,
        Bad
    }

    property int tier: KanteTile.Tier.Good
    property string name: ""
    property string figure: ""
    property bool selected: false
    default property alias content: stage.data
    signal clicked()

    readonly property color tone: tier === KanteTile.Tier.Bad ? KanteStyle.negativeTextColor
        : (tier === KanteTile.Tier.Check ? KanteStyle.accentTextColor : KanteStyle.positiveTextColor)

    implicitWidth: KanteStyle.unit(180)
    implicitHeight: implicitWidth * 2 / 3 + KanteStyle.unit(34)
    activeFocusOnTab: true

    Keys.onReturnPressed: clicked()
    Keys.onSpacePressed: clicked()

    KanteCard {
        anchors.fill: parent
        color: KanteStyle.cardColor
        barColor: tile.tone
        chamfer: KanteStyle.chamferSmall
    }

    Item {
        id: stage
        x: 0
        y: KanteStyle.unit(4)
        width: parent.width
        height: width * 2 / 3
        clip: true
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: KanteStyle.unit(8)
        spacing: KanteStyle.unit(8)
        Text {
            Layout.fillWidth: true
            text: tile.name
            color: KanteStyle.mutedTextColor
            font: KanteStyle.monoFont(KanteStyle.labelFont().pointSize, false)
            elide: Text.ElideRight
        }
        Text {
            text: tile.figure
            color: tile.tone
            font: KanteStyle.monoFont(KanteStyle.labelFont().pointSize, true)
        }
    }

    // Selected: cyan frame and a tick in a cyan square.
    Rectangle {
        anchors.fill: parent
        visible: tile.selected
        color: "transparent"
        border.width: 2
        border.color: KanteStyle.focusColor
    }
    Rectangle {
        visible: tile.selected
        x: KanteStyle.unit(6)
        y: KanteStyle.unit(10)
        width: KanteStyle.unit(18)
        height: width
        color: KanteStyle.focusColor
        KanteTick {
            anchors.fill: parent
            anchors.margins: 3
            checked: tile.selected
            color: KanteStyle.onStateColor
        }
    }

    KanteBrackets {
        anchors.fill: parent
        active: tile.activeFocus
    }

    HoverHandler { id: hover }
    Rectangle {
        anchors.fill: parent
        visible: hover.hovered && !tile.selected
        color: "transparent"
        border.width: 2
        border.color: KanteStyle.frameColor
    }
    TapHandler { onTapped: { tile.forceActiveFocus(); tile.clicked() } }
}
