import QtQuick
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.76: KanteSongMap. Heights follow the values, a bar without data is no zero, a drag
 * chooses a range, the keys move, extend and choose, tooltips and names say the number.
 * Run: tools/check-qml.sh
 */
TestCase {
    id: tc
    name: "Kante176"
    width: 400
    height: 200
    when: windowShown

    Component {
        id: mapComponent
        KanteSongMap {
            width: 240
            barHeight: 40
            values: [1, 0.5, null, 0.25, 0, 0.75, 1, 0.9]
            accessibleName: "Liedkarte"
        }
    }

    SignalSpy {
        id: chosen
        signalName: "rangeChosen"
    }

    function make() {
        const m = createTemporaryObject(mapComponent, tc.Window.contentItem)
        verify(m)
        chosen.clear()
        chosen.target = m
        waitForRendering(m)
        return m
    }
    function findAll(item, name) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (c.objectName === name) {
                out.push(c)
            }
            out = out.concat(findAll(c, name))
        }
        return out
    }
    function bars(m) {
        return findAll(m, "kanteSongMapBar").sort((a, b) => a.index - b.index)
    }
    function fillOf(bar) {
        return findAll(bar, "kanteSongMapFill")[0]
    }

    function test_heights_follow_the_values() {
        const m = make()
        const b = bars(m)
        compare(b.length, 8)
        compare(fillOf(b[0]).height, 40)
        compare(fillOf(b[1]).height, 20)
        compare(fillOf(b[3]).height, 10)
        // No data: no column; zero: a sliver, framed.
        verify(!fillOf(b[2]).visible)
        verify(fillOf(b[4]).visible)
        verify(fillOf(b[4]).height > 0 && fillOf(b[4]).height < 10)
        compare(fillOf(b[4]).border.width, KanteStyle.borderWidth)
    }

    function test_names_say_the_number() {
        const m = make()
        compare(m.tipOf(1), "Takt 2: 50 %")
        compare(m.tipOf(2), "Takt 3: noch nicht gespielt")
        m.tips = ["", "Takt 2: 3 von 6 Noten"]
        compare(m.tipOf(1), "Takt 2: 3 von 6 Noten")
        compare(m.tipOf(0), "Takt 1: 100 %")
        compare(bars(m)[1].Accessible.name, "Takt 2: 3 von 6 Noten")
    }

    function test_drag_chooses_a_range() {
        const m = make()
        const step = m.barWidth + m.spacing
        mousePress(m, step * 4 + 2, 20)
        mouseMove(m, step * 7 + 2, 20)
        mouseRelease(m, step * 7 + 2, 20)
        compare(chosen.count, 1)
        compare(chosen.signalArguments[0][0], 4)
        compare(chosen.signalArguments[0][1], 7)
        compare(m.selectionFrom, 4)
        compare(m.selectionTo, 7)
        verify(m.selected(5) && !m.selected(3))
        // Backwards gives the same order.
        mousePress(m, step * 3 + 2, 20)
        mouseMove(m, 2, 20)
        mouseRelease(m, 2, 20)
        compare(chosen.signalArguments[1][0], 0)
        compare(chosen.signalArguments[1][1], 3)
    }

    function test_keys_move_extend_and_choose() {
        const m = make()
        m.forceActiveFocus()
        verify(m.activeFocus)
        keyClick(Qt.Key_Right)
        compare(m.currentIndex, 1)
        keyClick(Qt.Key_Return)
        compare(chosen.count, 1)
        compare(chosen.signalArguments[0][0], 1)
        compare(chosen.signalArguments[0][1], 1)
        keyClick(Qt.Key_Right, Qt.ShiftModifier)
        keyClick(Qt.Key_Right, Qt.ShiftModifier)
        compare(m.selectionFrom, 1)
        compare(m.selectionTo, 3)
        keyClick(Qt.Key_Space)
        compare(chosen.count, 2)
        compare(chosen.signalArguments[1][0], 1)
        compare(chosen.signalArguments[1][1], 3)
        keyClick(Qt.Key_End)
        compare(m.currentIndex, 7)
        keyClick(Qt.Key_Home, Qt.ShiftModifier)
        compare(m.selectionFrom, 0)
        compare(m.selectionTo, 7)
    }

    function test_a_long_song_scrolls() {
        const m = make()
        const many = []
        for (let i = 0; i < 120; i++) {
            many.push(i % 5 / 4)
        }
        m.values = many
        waitForRendering(m)
        compare(m.barWidth, m.minBarWidth)
        verify(m.stripWidth > m.width)
        m.forceActiveFocus()
        keyClick(Qt.Key_End)
        const flick = m.children.filter(c => c.contentWidth !== undefined)[0]
        verify(flick.contentX > 0)
    }

    // Review #129: a shorter piece keeps focus and anchor inside it.
    function test_a_shorter_piece_keeps_the_focus_inside() {
        const m = make()
        m.forceActiveFocus()
        keyClick(Qt.Key_End)
        keyClick(Qt.Key_Left, Qt.ShiftModifier)
        m.values = [1, 0.5]
        compare(m.currentIndex, 1)
        compare(m.anchorIndex, -1)
        keyClick(Qt.Key_Return)
        compare(chosen.signalArguments[0][0], 1)
        compare(chosen.signalArguments[0][1], 1)
    }

    // Review #129: Enter after a drag keeps the dragged range.
    function test_enter_after_a_drag_keeps_the_range() {
        const m = make()
        const step = m.barWidth + m.spacing
        mousePress(m, step * 2 + 2, 20)
        mouseMove(m, step * 5 + 2, 20)
        mouseRelease(m, step * 5 + 2, 20)
        m.forceActiveFocus()
        keyClick(Qt.Key_Return)
        compare(chosen.count, 2)
        compare(chosen.signalArguments[1][0], 2)
        compare(chosen.signalArguments[1][1], 5)
    }

    // Review #129: mirrored, the bars run from the right, Right moves to the left neighbour on screen.
    function test_mirrored_bars_follow_the_keys() {
        const m = make()
        m.LayoutMirroring.enabled = true
        waitForRendering(m)
        const b = bars(m)
        verify(b[0].x > b[1].x)
        m.forceActiveFocus()
        keyClick(Qt.Key_End)
        keyClick(Qt.Key_Right)
        compare(m.currentIndex, 6)
        verify(b[6].x > b[7].x)
    }
}
