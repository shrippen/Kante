import QtQuick
import "."

/**
 * Steps of a process (a wizard): `model` is a list of labels, `current` the active index.
 * Every state has a shape besides its colour (Kante 1.27, WCAG 1.4.1), as `.steps` on the web:
 *
 *   done      green bar, a filled square with a check mark instead of the number
 *   current   thick accent bar, the number on a filled primary square, the step framed
 *             with a 2 px outline, its label in the strong text colour
 *   upcoming  thin bar, the number in a hollow square, muted label
 *
 * Screen readers hear each step as "Schritt 2 von 4: Erkennen, aktuell"; the words come
 * from `stepText` and `stateNames`, an app sets its translations once.
 *
 * Narrower than all labels need (a width set by a layout, e.g. half a laptop screen): only
 * the current step keeps its label, the others show their sign (Kante 1.39, `compact`).
 *
 *   ┌──────────────┬────┬────┬────┐
 *   │ ■01          │ □02│ □03│ □04│     compact: the current step named, the rest by number
 *   │ INSTRUMENT   │    │    │    │
 */
Row {
    id: steps

    property var model: []
    property int current: 0
    /** Words of a step for screen readers; %1 its number, %2 the count. */
    property string stepText: "Schritt %1 von %2"
    property var stateNames: ({ done: "erledigt", current: "aktuell", upcoming: "offen" })

    spacing: 2

    /** Width all steps need with their labels. */
    readonly property real fullWidth: {
        var w = 0
        var n = model ? model.length : 0
        for (var i = 0; i < n; i++) {
            w += Math.max(KanteStyle.unit(110), labelMetrics.advanceWidth(model[i]) + KanteStyle.unit(24))
        }
        return w + spacing * Math.max(0, n - 1)
    }
    /** Too narrow for every label: only the current step keeps its label. A Row left to size
     *  itself is as wide as its labels (a few units of rounding aside), so only a width set
     *  from outside (a layout) makes it compact. */
    readonly property bool compact: width > 0 && width < fullWidth - KanteStyle.unit(4)

    FontMetrics {
        id: labelMetrics
        font: KanteStyle.headingFont(KanteStyle.defaultFont.pointSize)
    }

    Accessible.role: Accessible.List

    Repeater {
        model: steps.model
        delegate: Item {
            id: step
            required property int index
            required property var modelData
            readonly property bool done: index < steps.current
            readonly property bool now: index === steps.current
            readonly property string stateKey: done ? "done" : (now ? "current" : "upcoming")
            readonly property real signSize: Math.max(KanteStyle.unit(20), number.implicitHeight + KanteStyle.unit(4))
            readonly property bool named: !steps.compact || now
            width: named ? Math.max(KanteStyle.unit(110), label.implicitWidth + KanteStyle.unit(24))
                         : signSize + KanteStyle.unit(20)
            height: Math.max(KanteStyle.unit(60), label.y + label.implicitHeight + KanteStyle.unit(8))

            Accessible.role: Accessible.ListItem
            Accessible.name: steps.stepText.arg(index + 1).arg(steps.model ? steps.model.length : 0) + ": " + modelData
                             + ", " + (steps.stateNames && steps.stateNames[stateKey] !== undefined ? steps.stateNames[stateKey] : stateKey)

            Rectangle { anchors.fill: parent; color: KanteStyle.cardColor }
            // The current step: a 2 px outline around the whole step.
            Rectangle {
                anchors.fill: parent
                visible: step.now
                color: "transparent"
                border.width: 2
                border.color: KanteStyle.accentTextColor
            }
            // Bar: 4 px done, 6 px current, 2 px upcoming.
            Rectangle {
                width: parent.width
                height: KanteStyle.unit(step.now ? 6 : (step.done ? 4 : 2))
                color: step.done ? KanteStyle.positiveTextColor : (step.now ? KanteStyle.accentColor : KanteStyle.frameColor)
            }
            // Sign: check on a filled square (done), number on a filled square (current),
            // number in a hollow square (upcoming).
            Rectangle {
                id: sign
                x: KanteStyle.unit(10)
                y: KanteStyle.unit(12)
                width: step.signSize
                height: step.signSize
                color: step.done ? KanteStyle.positiveTextColor : (step.now ? KanteStyle.primaryColor : "transparent")
                border.width: step.done || step.now ? 0 : 1
                border.color: KanteStyle.mutedTextColor
                KanteTick {
                    visible: step.done
                    anchors.centerIn: parent
                    width: parent.width - KanteStyle.unit(6)
                    height: width
                    checked: true
                    color: KanteStyle.inkOn(KanteStyle.positiveTextColor)
                }
                Text {
                    id: number
                    visible: !step.done
                    anchors.centerIn: parent
                    text: (step.index + 1 < 10 ? "0" : "") + (step.index + 1)
                    color: step.now ? KanteStyle.primaryTextColor : KanteStyle.mutedTextColor
                    font: KanteStyle.monoFont(KanteStyle.labelFont().pointSize, step.now)
                }
            }
            Text {
                id: label
                visible: step.named
                x: KanteStyle.unit(10)
                y: sign.y + sign.height + KanteStyle.unit(2)
                text: step.modelData
                color: step.now ? KanteStyle.strongTextColor : KanteStyle.mutedTextColor
                font: KanteStyle.headingFont(KanteStyle.defaultFont.pointSize)
            }
        }
    }
}
