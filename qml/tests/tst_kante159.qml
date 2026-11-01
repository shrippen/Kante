import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.59, from Mitori: KanteOptionTile as a launch tile with a glyph, and
 * KanteTransportBar for video (no metronome and count-in, fixed tempi, single frames).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante159"
    width: 1200
    height: 800
    when: windowShown

    // KanteStyle is one for all test files: give the next one back the style it had.
    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    // The window's content: created there, items are visible and take clicks.
    function stage() {
        return tc.Window.contentItem
    }

    // ── Launch tile ──────────────────────────────────────────────────
    Component {
        id: tileComponent
        KanteOptionTile { text: "Programm"; hint: "Aikido · 5. Kyu"; glyph: "技"; checkable: false; autoExclusive: false }
    }
    SignalSpy { id: clickSpy; signalName: "clicked" }

    function glyphText(tile) {
        var stack = [tile.contentItem]
        while (stack.length) {
            var item = stack.pop()
            if (item.text === "技" && item.visible) {
                return item
            }
            for (var i = 0; i < item.children.length; i++) {
                stack.push(item.children[i])
            }
        }
        return null
    }

    function test_launchTile() {
        var tile = createTemporaryObject(tileComponent, stage())
        clickSpy.clear()
        clickSpy.target = tile
        verify(glyphText(tile) !== null, "the glyph is drawn")
        compare(tile.Accessible.role, Accessible.Button)
        mouseClick(tile)
        compare(clickSpy.count, 1)
        verify(!tile.checked, "a launch tile is never chosen")
    }

    function test_optionTileStaysRadio() {
        var tile = createTemporaryObject(tileComponent, stage(), { checkable: true, glyph: "" })
        compare(tile.Accessible.role, Accessible.RadioButton)
        verify(glyphText(tile) === null)
        mouseClick(tile)
        verify(tile.checked)
    }

    // ── Transport for video ──────────────────────────────────────────
    Component {
        id: videoBar
        KanteTransportBar {
            width: 900
            metronomeVisible: false
            countInVisible: false
            speedSteps: [0.25, 0.5, 0.75, 1]
            frameStep: true
        }
    }
    SignalSpy { id: speedSpy; signalName: "speedChangeRequested" }
    SignalSpy { id: metroSpy; signalName: "metronomeToggled" }
    SignalSpy { id: countSpy; signalName: "countInToggled" }
    SignalSpy { id: frameSpy; signalName: "frameStepRequested" }

    function spyOn(bar) {
        var spies = [speedSpy, metroSpy, countSpy, frameSpy]
        for (var i = 0; i < spies.length; i++) {
            spies[i].clear()
            spies[i].target = bar
        }
    }

    function test_fixedTempi() {
        var bar = createTemporaryObject(videoBar, stage(), { speed: 0.5 })
        spyOn(bar)
        bar.forceActiveFocus()
        keyClick(Qt.Key_Plus)
        compare(speedSpy.signalArguments[0][0], 0.75)
        keyClick(Qt.Key_Minus)
        compare(speedSpy.signalArguments[1][0], 0.25)
        bar.speed = 1
        keyClick(Qt.Key_Plus)
        compare(speedSpy.count, 2, "no step above the last")
        compare(bar.speedLabel(0.25), "25 %")
    }

    function test_hiddenTogglesHaveNoKeys() {
        var bar = createTemporaryObject(videoBar, stage())
        spyOn(bar)
        bar.forceActiveFocus()
        keyClick(Qt.Key_M)
        keyClick(Qt.Key_C)
        compare(metroSpy.count, 0)
        compare(countSpy.count, 0)
    }

    function test_singleFrames() {
        var bar = createTemporaryObject(videoBar, stage())
        spyOn(bar)
        bar.forceActiveFocus()
        keyClick(Qt.Key_Comma)
        keyClick(Qt.Key_Period)
        compare(frameSpy.count, 2)
        compare(frameSpy.signalArguments[0][0], -1)
        compare(frameSpy.signalArguments[1][0], 1)
    }

    function findByName(root, name) {
        var stack = [root]
        while (stack.length) {
            var item = stack.pop()
            if (item.Accessible && item.Accessible.name === name && item.visible) {
                return item
            }
            for (var i = 0; i < item.children.length; i++) {
                stack.push(item.children[i])
            }
        }
        return null
    }

    // The frame buttons draw their mark (a hollow triangle and a bar) and take clicks.
    function test_frameButtonsDrawn() {
        var bar = createTemporaryObject(videoBar, stage())
        spyOn(bar)
        var on = findByName(bar, "Bild vor")
        verify(on !== null, "frame-on button")
        verify(findByName(bar, "Bild zurück") !== null, "frame-back button")
        waitForRendering(bar)
        var image = grabImage(on)
        var ink = 0
        var cx = Math.round(on.width / 2), cy = Math.round(on.height / 2)
        for (var x = cx - 7; x <= cx + 7; x++) {
            for (var y = cy - 7; y <= cy + 7; y++) {
                if (image.pixel(x, y).hslLightness < 0.4) {
                    ink++
                }
            }
        }
        verify(ink > 10, "the mark is drawn (" + ink + " dark pixels)")
        mouseClick(on)
        compare(frameSpy.signalArguments[0][0], 1)
    }

    function test_defaultsUnchanged() {
        var bar = createTemporaryObject(videoBar, stage(), { metronomeVisible: true, countInVisible: true, speedSteps: [], frameStep: false, speed: 1 })
        spyOn(bar)
        bar.forceActiveFocus()
        keyClick(Qt.Key_Comma)
        keyClick(Qt.Key_M)
        keyClick(Qt.Key_Plus)
        compare(frameSpy.count, 0)
        compare(metroSpy.count, 1)
        compare(speedSpy.signalArguments[0][0], 1.05)
    }
}
