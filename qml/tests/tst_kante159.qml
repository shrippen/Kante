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

    // Between two steps (a restored tempo, or steps without 1): + goes up, − goes down.
    function test_stepsFromBetween() {
        var bar = createTemporaryObject(videoBar, stage(), { speed: 0.6 })
        spyOn(bar)
        bar.forceActiveFocus()
        keyClick(Qt.Key_Plus)
        compare(speedSpy.signalArguments[0][0], 0.75)
        keyClick(Qt.Key_Minus)
        compare(speedSpy.signalArguments[1][0], 0.5)
        var low = createTemporaryObject(videoBar, stage(), { speedSteps: [0.25, 0.5, 0.75], speed: 1 })
        spyOn(low)
        low.forceActiveFocus()
        keyClick(Qt.Key_Plus)
        compare(speedSpy.count, 0, "nothing above 1 in these steps")
        keyClick(Qt.Key_Minus)
        compare(speedSpy.signalArguments[0][0], 0.75)
    }

    function findSegmented(root) {
        var stack = [root]
        while (stack.length) {
            var item = stack.pop()
            if (item.model !== undefined && item.select !== undefined && item.visible) {
                return item
            }
            for (var i = 0; i < item.children.length; i++) {
                stack.push(item.children[i])
            }
        }
        return null
    }

    // After a click on a segment the row still shows the app's tempo.
    function test_segmentsFollowSpeedAfterClick() {
        var bar = createTemporaryObject(videoBar, stage(), { speed: 0.5 })
        var seg = findSegmented(bar)
        verify(seg !== null)
        compare(seg.currentIndex, 1)
        seg.select(3)                   // what a click does
        bar.speed = 1                   // the app takes the request
        compare(seg.currentIndex, 3)
        bar.speed = 0.75
        compare(seg.currentIndex, 2, "follows the app")
        bar.speed = 0.25
        compare(seg.currentIndex, 0)
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
        // Pixels in the button's ink (light or dark theme alike).
        var inkColor = on.kanteInk
        var ink = 0
        var cx = Math.round(on.width / 2), cy = Math.round(on.height / 2)
        for (var x = cx - 7; x <= cx + 7; x++) {
            for (var y = cy - 7; y <= cy + 7; y++) {
                var p = image.pixel(x, y)
                if (Math.abs(p.r - inkColor.r) + Math.abs(p.g - inkColor.g) + Math.abs(p.b - inkColor.b) < 0.15) {
                    ink++
                }
            }
        }
        verify(ink > 10, "the mark is drawn (" + ink + " ink pixels)")
        mouseClick(on)
        compare(frameSpy.signalArguments[0][0], 1)
    }

    // Right to left the transport keeps its order: frame back left of play, frame on right of it.
    function test_rightToLeftKeepsOrder() {
        var bar = createTemporaryObject(videoBar, stage(), { "LayoutMirroring.enabled": true, "LayoutMirroring.childrenInherit": true })
        waitForRendering(bar)
        var back = findByName(bar, "Bild zurück"), on = findByName(bar, "Bild vor")
        verify(back.mapToItem(bar, 0, 0).x < on.mapToItem(bar, 0, 0).x)
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

    // 1.74.3: Enter chooses a tile as Space does; a long hint shows in two lines, not cut.
    Component {
        id: enterTile
        KanteOptionTile { width: 160; text: "Eine lange Überschrift für die Kachel"; hint: "Ein Hinweis, der nicht in eine Zeile passt und trotzdem lesbar bleibt" }
    }
    function test_optionTileEnter() {
        const t = createTemporaryObject(enterTile, tc)
        verify(t)
        t.forceActiveFocus()
        keyClick(Qt.Key_Return)
        verify(t.checked)
        t.checked = false
        keyClick(Qt.Key_Enter)
        verify(t.checked)
    }
    function test_optionTileWraps() {
        const t = createTemporaryObject(enterTile, tc)
        const labels = []
        const walk = c => {
            if (c.text !== undefined && c.lineCount !== undefined && c.text.length > 0) {
                labels.push(c)
            }
            for (let i = 0; i < c.children.length; ++i) {
                walk(c.children[i])
            }
        }
        walk(t.contentItem)
        verify(labels.length >= 2)
        for (const l of labels) {
            verify(l.lineCount >= 2, l.text + ": " + l.lineCount)
            compare(l.maximumLineCount, 2)
        }
    }
}
