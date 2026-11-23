import QtQuick
import QtTest
import Kante

/** KanteChip sizing. Run: tools/check-qml.sh (qmltestrunner, offscreen). */
TestCase {
    id: tc
    name: "KanteChip"
    width: 500
    height: 400
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: flowComponent
        Flow {
            width: 400
            spacing: 8
            property bool removable: false
            Repeater {
                model: ["ILVA", "WÄRTER", "Marie", "urlaub"]
                KanteChip { text: modelData; removable: parent.removable }
            }
        }
    }

    // A chip at its natural width shows its whole name, with or without a cross.
    function test_naturalWidthNotElided() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        for (let r = 0; r < 2; r++) {
            const flow = createTemporaryObject(flowComponent, tc, { removable: r === 1 })
            for (let i = 0; i < flow.children.length; i++) {
                const chip = flow.children[i]
                if (!chip.text) {
                    continue
                }
                const label = findChild(chip, "chipLabel")
                compare(chip.width, chip.implicitWidth)
                verify(chip.textShown, chip.text + " shown")
                verify(!label.truncated, chip.text + " removable=" + (r === 1)
                       + " truncated: width " + label.width + " < implicit " + label.implicitWidth)
            }
        }
    }
}
