import QtQuick
import QtTest
import Kante

/**
 * KanteOdometer: `pace: Live` rolls all reels at once and ends before the next change, so
 * a value that changes every 250 ms (a download's percent) shows the right digits.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteOdometer"
    width: 400
    height: 200
    when: windowShown

    readonly property int stepMs: 250
    readonly property int steps: 30

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    Component {
        id: liveComponent
        KanteOdometer { pace: KanteOdometer.Pace.Live }
    }

    Component {
        id: showComponent
        KanteOdometer { }
    }

    // The digit each reel stands at, from its column's position (a reel is the clipping item).
    function shown(odo) {
        let out = ""
        for (let i = 0; i < odo.children.length; ++i) {
            const row = odo.children[i]
            for (let j = 0; j < row.children.length; ++j) {
                const reel = row.children[j]
                if (!reel.clip) {
                    continue
                }
                out += String(Math.round(-reel.children[0].y / reel.height))
            }
        }
        return out
    }

    function test_live_steps() {
        verify(KanteStyle.animate, "animation is on")
        const odo = createTemporaryObject(liveComponent, tc)
        verify(odo)
        compare(odo.pace, KanteOdometer.Pace.Live)

        for (let v = 1; v <= steps; ++v) {
            odo.value = v
            wait(stepMs - 50)
            compare(shown(odo), odo.padded, "value " + v)
            wait(50)
        }
    }

    function test_show_default() {
        const odo = createTemporaryObject(showComponent, tc)
        verify(odo)
        compare(odo.pace, KanteOdometer.Pace.Show)
    }
}
