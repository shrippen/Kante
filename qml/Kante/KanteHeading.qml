import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "."

/**
 * Heading.
 *   System  Kirigami.Heading (unchanged).
 *   Kante   level 4 and below (sections): small uppercase monospace label
 *           followed by a thin rule; above: uppercase Rajdhani title.
 */
Kirigami.Heading {
    id: control

    readonly property bool sectionLabel: level >= 4

    // Kante draws its own text over the hidden original; the heading's own font
    // and color stay untouched, so switching back to System restores them exactly.
    QQC2.Label {
        id: kanteText
        visible: KanteStyle.active
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, control.width)
        text: control.text
        font: control.sectionLabel ? KanteStyle.labelFont()
                                   : KanteStyle.headingFont(KanteStyle.defaultFont.pointSize * (control.level <= 2 ? 1.6 : 1.3))
        color: control.sectionLabel ? KanteStyle.mutedTextColor : KanteStyle.strongTextColor
        elide: Text.ElideRight
    }

    Rectangle {
        visible: KanteStyle.active && control.sectionLabel
        x: kanteText.width + Math.round(kanteText.font.pixelSize * 0.8)
        width: Math.max(0, control.width - x)
        height: 1
        anchors.verticalCenter: parent.verticalCenter
        color: KanteStyle.ruleColor
    }

    Binding {
        target: control
        property: "color"
        value: "transparent"
        when: KanteStyle.active
        restoreMode: Binding.RestoreBindingOrValue
    }
}
