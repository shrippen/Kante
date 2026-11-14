import QtQuick
import QtTest
import Kante

/**
 * From Klappe (floor plans for a film shoot): KanteTrackTimeline and KanteShapeCanvas.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteKlappe"
    width: 800
    height: 600
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    SignalSpy { id: spy }

    function stage() {
        return tc.Window.contentItem
    }

    function watch(target, name) {
        spy.signalName = ""
        spy.target = target
        spy.signalName = name
        spy.clear()
    }

    Component {
        id: timelineComponent
        KanteTrackTimeline {
            width: 700
            height: 200
            duration: 20
            position: 5
            labelWidth: 100
            hideText: "Ausblenden"
            showText: "Einblenden"
            tracks: [
                { name: "Spur 1", label: "blue", shown: true,
                  segments: [{ from: 2, to: 6, text: "Gehen", selected: false }, { from: 8, to: 12, text: "Halt", selected: true }],
                  markers: [{ at: 7, text: "Schnitt" }] },
                { name: "Spur 2", label: "", shown: false, segments: [{ from: 0, to: 20, text: "Ton" }], markers: [] }
            ]
        }
    }

    Component {
        id: canvasComponent
        KanteShapeCanvas {
            width: 400
            height: 300
            contentWidth: 10
            contentHeight: 8
            gridStep: 1
            fitOnLoad: false
            zoom: 20
            shapes: [
                { kind: "polygon", points: [0, 0, 10, 0, 10, 8, 0, 8], label: "muted", fill: "tint", key: "room" },
                { kind: "circle", points: [5, 4], radius: 1, label: "red", fill: "solid", key: "disc", text: "A" },
                { kind: "line", points: [1, 1, 4, 1], width: 0.1, label: "accent", stroke: "dashed", key: "wall" },
                { kind: "polyline", points: [1, 6, 3, 6, 3, 7], label: "green", stroke: "dotted", key: "path", selected: true },
                { kind: "polygon", points: [6, 1, 9, 1, 9, 3, 6, 3], label: "blue", fill: "none", key: "frame" }
            ]
        }
    }

    // --- Timeline

    function test_timelineMapsTime() {
        const t = createTemporaryObject(timelineComponent, stage())
        // 600 px for 20 s.
        compare(t.pixelsPerSecond, 30)
        compare(t.xAt(10), 100 + 300)
        compare(t.timeAt(t.xAt(7.5)), 7.5)
        compare(t.timeAt(-50), 0)
        compare(t.timeAt(5000), 20)
    }

    function test_timelineTickStep() {
        const t = createTemporaryObject(timelineComponent, stage())
        verify(t.tickStep * t.pixelsPerSecond >= KanteStyle.unit(56))
        t.duration = 600
        verify(t.tickStep >= 30)
        t.duration = 4
        compare(t.tickStep, 1)
    }

    function test_timelineClickSeeks() {
        const t = createTemporaryObject(timelineComponent, stage())
        watch(t, "seek")
        // On the ruler, 10 s in.
        mouseClick(t, t.xAt(10), 5)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 10)
    }

    function test_timelineDragSeeks() {
        const t = createTemporaryObject(timelineComponent, stage())
        watch(t, "seek")
        mousePress(t, t.xAt(4), 5)
        mouseMove(t, t.xAt(9), 5)
        mouseRelease(t, t.xAt(9), 5)
        verify(spy.count >= 2)
        compare(spy.signalArguments[spy.count - 1][0], 9)
    }

    function test_timelineHitsSegmentAndMarker() {
        const t = createTemporaryObject(timelineComponent, stage())
        const y0 = t.rulerHeight + t.trackHeight / 2
        const y1 = y0 + t.trackHeight
        compare(t.segmentAt(t.xAt(10), y0).index, 1)
        compare(t.segmentAt(t.xAt(10), y0).track, 0)
        compare(t.segmentAt(t.xAt(7), y0), null)
        compare(t.segmentAt(t.xAt(3), y1).track, 1)
        compare(t.segmentAt(t.xAt(3), 5), null)
        compare(t.segmentAt(t.xAt(3), y1 + t.trackHeight), null)
        compare(t.markerAt(t.xAt(7), y0).index, 0)
        compare(t.markerAt(t.xAt(9), y0), null)
    }

    function test_timelineSegmentClick() {
        const t = createTemporaryObject(timelineComponent, stage())
        watch(t, "segmentClicked")
        mouseClick(t, t.xAt(4), t.rulerHeight + t.trackHeight / 2)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 0)
        compare(spy.signalArguments[0][1], 0)
    }

    function test_timelineToggle() {
        const t = createTemporaryObject(timelineComponent, stage())
        const b = findChild(t, "toggle1")
        verify(b)
        compare(b.text, "Einblenden: Spur 2")
        compare(findChild(t, "toggle0").text, "Ausblenden: Spur 1")
        watch(t, "toggleShown")
        mouseClick(b)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 1)
    }

    function test_timelineKeyboard() {
        const t = createTemporaryObject(timelineComponent, stage())
        t.forceActiveFocus()
        watch(t, "seek")
        keyClick(Qt.Key_Right)
        compare(spy.signalArguments[0][0], 6)
        keyClick(Qt.Key_Left)
        compare(spy.signalArguments[1][0], 4)
        keyClick(Qt.Key_Home)
        compare(spy.signalArguments[2][0], 0)
        keyClick(Qt.Key_End)
        compare(spy.signalArguments[3][0], 20)
        t.position = 0
        keyClick(Qt.Key_Left)
        compare(spy.signalArguments[4][0], 0)
    }

    // --- Shape canvas

    function test_canvasMapping() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.panX = 30
        c.panY = 10
        const p = c.mapFromModel(2, 3)
        compare(p.x, 30 + 40)
        compare(p.y, 10 + 60)
        const m = c.mapToModel(p.x, p.y)
        compare(m.x, 2)
        compare(m.y, 3)
    }

    function test_canvasFit() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.fit()
        const a = c.mapFromModel(0, 0)
        const b = c.mapFromModel(10, 8)
        // Whole plan inside, centred.
        verify(a.x >= 0 && a.y >= 0 && b.x <= c.width && b.y <= c.height)
        fuzzyCompare(a.x + b.x, c.width, 0.001)
        fuzzyCompare(a.y + b.y, c.height, 0.001)
    }

    function test_canvasFitOnLoad() {
        const c = createTemporaryObject(canvasComponent, stage(), { fitOnLoad: true })
        const b = c.mapFromModel(10, 8)
        verify(b.x <= c.width && b.y <= c.height)
        verify(c.zoom !== 20)
    }

    function test_canvasFitFollowsLayoutUntilTouched() {
        const c = createTemporaryObject(canvasComponent, stage(), { fitOnLoad: true })
        c.width = 800
        const b = c.mapFromModel(10, 8)
        const a = c.mapFromModel(0, 0)
        fuzzyCompare(a.x + b.x, 800, 0.001)
        // Once moved by the user, a resize leaves the view alone.
        mouseWheel(c, 100, 100, 0, 120)
        const z = c.zoom
        c.width = 500
        compare(c.zoom, z)
    }

    function test_canvasHitTest() {
        const c = createTemporaryObject(canvasComponent, stage())
        const at = function (x, y) {
            const p = c.mapFromModel(x, y)
            return c.keyAt(p.x, p.y)
        }
        // Circle over the room: topmost wins.
        compare(at(5, 4), "disc")
        compare(at(5.9, 4), "disc")
        compare(at(7, 6), "room")
        // Unfilled polygon is hit at its edge only; the room (filled) lies below it.
        compare(at(7.5, 2), "room")
        compare(at(7.5, 1), "frame")
        // Line and polyline within a few pixels, not far from it.
        compare(at(2, 1), "wall")
        compare(at(2, 1.1), "wall")
        compare(at(2, 1.5), "room")
        compare(at(3, 6.5), "path")
        // Outside everything.
        compare(at(-1, -1), "")
        compare(at(11, 4), "")
    }

    function test_canvasClickAndHover() {
        const c = createTemporaryObject(canvasComponent, stage())
        const p = c.mapFromModel(5, 4)
        watch(c, "shapeClicked")
        mouseClick(c, p.x, p.y)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "disc")
        fuzzyCompare(spy.signalArguments[0][1], 5, 0.001)
        fuzzyCompare(spy.signalArguments[0][2], 4, 0.001)

        watch(c, "shapeHovered")
        mouseMove(c, p.x, p.y)
        verify(spy.count >= 1)
        compare(spy.signalArguments[spy.count - 1][0], "disc")
        const n = spy.count
        mouseMove(c, 390, 290)
        compare(spy.count, n + 1)
        compare(spy.signalArguments[n][0], "")
    }

    function test_canvasDragPansFromEmptyGround() {
        const c = createTemporaryObject(canvasComponent, stage())
        watch(c, "shapeClicked")
        const x0 = c.panX
        mousePress(c, 390, 290)
        mouseMove(c, 370, 280)
        mouseMove(c, 350, 270)
        mouseRelease(c, 350, 270)
        compare(c.panX, x0 - 40)
        compare(c.panY, 0 - 20)
        // A drag is not a click.
        compare(spy.count, 0)
    }

    function test_canvasDragOnShapeDoesNotPan() {
        const c = createTemporaryObject(canvasComponent, stage())
        const p = c.mapFromModel(5, 4)
        mousePress(c, p.x, p.y)
        mouseMove(c, p.x + 30, p.y + 30)
        mouseRelease(c, p.x + 30, p.y + 30)
        compare(c.panX, 0)
    }

    function test_canvasEditingDragsAShape() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.editing = true
        watch(c, "shapeDragged")
        const p = c.mapFromModel(5, 4)
        mousePress(c, p.x, p.y)
        mouseMove(c, p.x + 20, p.y)
        mouseMove(c, p.x + 40, p.y + 20)
        mouseRelease(c, p.x + 40, p.y + 20)

        verify(spy.count >= 2)
        const last = spy.signalArguments[spy.count - 1]
        compare(last[0], "disc")
        fuzzyCompare(last[1], 5, 1e-9)
        fuzzyCompare(last[2], 4, 1e-9)
        fuzzyCompare(last[3], 7, 1e-9)
        fuzzyCompare(last[4], 5, 1e-9)
        compare(last[5], true)
        compare(spy.signalArguments[0][5], false)
        compare(c.panX, 0)
    }

    // Review of PR 175: panning with the keys mid-drag moved the reported start.
    function test_canvasEditingKeepsTheStartWhenTheViewMoves() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.editing = true
        watch(c, "shapeDragged")
        const p = c.mapFromModel(5, 4)
        mousePress(c, p.x, p.y)
        mouseMove(c, p.x + 20, p.y)
        keyClick(Qt.Key_Right)
        mouseMove(c, p.x + 30, p.y)
        mouseRelease(c, p.x + 30, p.y)

        const last = spy.signalArguments[spy.count - 1]
        compare(last[5], true)
        fuzzyCompare(last[1], 5, 1e-9)
        fuzzyCompare(last[2], 4, 1e-9)
    }

    // Review of PR 175: a second finger took the drag over and the app never got done.
    function test_canvasEditingEndsWhenAPinchTakesOver() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.editing = true
        watch(c, "shapeDragged")
        const p = c.mapFromModel(5, 4)
        const touch = touchEvent(c)
        touch.press(0, c, p.x, p.y).commit()
        touch.move(0, c, p.x + 30, p.y).commit()
        touch.stationary(0).press(1, c, p.x + 80, p.y).commit()
        touch.move(0, c, p.x - 20, p.y).move(1, c, p.x + 140, p.y).commit()
        touch.release(0, c, p.x - 20, p.y).release(1, c, p.x + 140, p.y).commit()

        verify(spy.count > 0)
        compare(spy.signalArguments[spy.count - 1][5], true)
    }

    function test_canvasEditingDrawsFromEmptyGround() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.editing = true
        watch(c, "shapeDragged")
        mousePress(c, 390, 290)
        mouseMove(c, 370, 280)
        mouseRelease(c, 350, 270)

        compare(c.panX, 0)
        compare(c.panY, 0)
        const last = spy.signalArguments[spy.count - 1]
        compare(last[0], "")
        compare(last[5], true)
    }

    function test_canvasEditingStillPansWithMiddleButton() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.editing = true
        watch(c, "shapeDragged")
        mousePress(c, 390, 290, Qt.MiddleButton)
        mouseMove(c, 370, 280, -1, Qt.MiddleButton)
        mouseRelease(c, 370, 280, Qt.MiddleButton)

        compare(c.panX, -20)
        compare(spy.count, 0)
    }

    function test_canvasWithoutEditingReportsNoDrag() {
        const c = createTemporaryObject(canvasComponent, stage())
        watch(c, "shapeDragged")
        const p = c.mapFromModel(5, 4)
        mousePress(c, p.x, p.y)
        mouseMove(c, p.x + 30, p.y + 30)
        mouseRelease(c, p.x + 30, p.y + 30)

        compare(spy.count, 0)
    }

    function test_canvasWheelZoomsAboutPointer() {
        const c = createTemporaryObject(canvasComponent, stage())
        const before = c.mapToModel(150, 100)
        mouseWheel(c, 150, 100, 0, 120)
        verify(c.zoom > 20)
        const after = c.mapToModel(150, 100)
        fuzzyCompare(after.x, before.x, 0.0001)
        fuzzyCompare(after.y, before.y, 0.0001)
        mouseWheel(c, 150, 100, 0, -240)
        verify(c.zoom < 20 * Math.pow(1.0015, 120))
    }

    function test_canvasZoomWriteKeepsCentre() {
        const c = createTemporaryObject(canvasComponent, stage())
        const before = c.mapToModel(c.width / 2, c.height / 2)
        c.zoom = 40
        const after = c.mapToModel(c.width / 2, c.height / 2)
        fuzzyCompare(after.x, before.x, 0.0001)
        fuzzyCompare(after.y, before.y, 0.0001)
    }

    function test_canvasKeyboard() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.forceActiveFocus()
        keyClick(Qt.Key_Plus)
        compare(c.zoom, 25)
        keyClick(Qt.Key_Minus)
        fuzzyCompare(c.zoom, 20, 0.0001)
        keyClick(Qt.Key_0)
        verify(c.zoom !== 20)
    }

    function test_canvasPaintsManyShapes() {
        const list = []
        for (let i = 0; i < 500; i++) {
            list.push({ kind: "circle", points: [i % 25, Math.floor(i / 25)], radius: 0.3, label: "cyan", fill: "tint", key: "s" + i, text: "s" + i })
        }
        const c = createTemporaryObject(canvasComponent, stage(), { shapes: list })
        wait(50)
        compare(c.keyAt(c.mapFromModel(3, 2).x, c.mapFromModel(3, 2).y), "s53")
    }

    // --- Review fixes

    function test_canvasKeyZeroIsAKey() {
        const c = createTemporaryObject(canvasComponent, stage(),
            { shapes: [{ kind: "circle", points: [5, 4], radius: 1, fill: "solid", key: 0 }] })
        const p = c.mapFromModel(5, 4)
        compare(c.keyAt(p.x, p.y), "0")
    }

    Component { id: otherItem; Item { width: 10; height: 10; focus: true } }

    function test_canvasSpaceResetsOnFocusLoss() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.forceActiveFocus()
        keyPress(Qt.Key_Space)
        verify(c._spaceDown)
        const o = createTemporaryObject(otherItem, stage())
        o.forceActiveFocus()
        verify(!c.activeFocus)
        verify(!c._spaceDown)
    }

    function test_timelineLabelRoles() {
        const t = createTemporaryObject(timelineComponent, stage())
        compare(t._labelColor("accent"), KanteStyle.accentColor)
        compare(t._labelColor("focus"), KanteStyle.focusColor)
        compare(t._labelColor("warning"), KanteStyle.warningColor)
        compare(t._labelColor("muted"), KanteStyle.mutedTextColor)
        compare(t._labelColor("text"), KanteStyle.textColor)
        compare(t._labelColor("unknown"), KanteStyle.textColor)
        compare(t._labelColor(""), KanteStyle.textColor)
        compare(t._labelColor("blue"), KanteStyle.labelColor("blue"))
    }

    function test_timelineHoverResetsWithTracks() {
        const t = createTemporaryObject(timelineComponent, stage())
        t.hovered = { track: 1, index: 0 }
        t.tracks = [t.tracks[0]]
        compare(t.hovered, null)
    }
}
