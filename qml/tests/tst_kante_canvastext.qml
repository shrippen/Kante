import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas: captions of several lines, textAnchor, shapeDoubleClicked.
 */
TestCase {
    id: tc
    name: "KanteCanvasText"
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

    Component {
        id: canvasComponent
        KanteShapeCanvas {
            width: 400
            height: 300
            contentWidth: 20
            contentHeight: 15
            fitOnLoad: false
            zoom: 20
            panX: 0
            panY: 0
        }
    }

    // Rows of the image, from y0 up to y1, that hold any ink (a pixel unlike the ground) in x0..x1.
    function inkRows(c, x0, x1, y0, y1) {
        const img = tc.grabImage(c)
        // Inside the room, below and right of any caption.
        const ground = img.pixel(300, 220)
        const rows = []
        for (let y = y0; y < y1; y++) {
            for (let x = x0; x < x1; x += 2) {
                if (Math.abs(img.pixel(x, y).r - ground.r) > 0.05) {
                    rows.push(y)
                    break
                }
            }
        }
        return rows
    }

    // Number of separate bands of consecutive rows.
    function bands(rows) {
        let n = 0
        for (let i = 0; i < rows.length; i++) {
            if (i === 0 || rows[i] !== rows[i - 1] + 1) {
                n++
            }
        }
        return n
    }

    function room(text, anchor) {
        return [{ kind: "polygon", points: [2, 2, 18, 2, 18, 13, 2, 13], label: "red", fill: "none",
                  text: text, textAnchor: anchor, key: "room" }]
    }

    // The outline sits at x 40, 360 and y 40, 260: stay inside it.
    function test_linesDrawnApart() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = room("MMMM\nMMMM\nMMMM", "topLeft")
        wait(50)
        compare(bands(inkRows(c, 44, 356, 44, 256)), 3)
    }

    function test_oneLineIsOneBand() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = room("MMMM", "topLeft")
        wait(50)
        compare(bands(inkRows(c, 44, 356, 44, 256)), 1)
    }

    function test_topLeftHangsFromTop() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = room("MMMM\nMMMM", "topLeft")
        wait(50)
        const rows = inkRows(c, 44, 356, 44, 256)
        verify(rows[0] < 44 + KanteStyle.unit(12))
        // Left aligned: nothing right of the first columns.
        compare(inkRows(c, 200, 356, 44, 256).length, 0)
    }

    function test_centredByDefault() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = room("MMMM\nMMMM", "")
        wait(50)
        const rows = inkRows(c, 44, 356, 44, 256)
        const mid = (rows[0] + rows[rows.length - 1]) / 2
        verify(Math.abs(mid - 150) < 4)
    }

    function test_doubleClickOnShape() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = [{ kind: "circle", points: [10, 7], radius: 2, label: "red", fill: "solid", key: "disc" }]
        spy.target = c
        spy.signalName = "shapeDoubleClicked"
        spy.clear()
        mouseDoubleClickSequence(c, 200, 140)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "disc")
        compare(spy.signalArguments[0][1], 10)
        compare(spy.signalArguments[0][2], 7)
    }

    // Both clicks of a double click still report shapeClicked, as before the signal came.
    function test_doubleClickKeepsBothClicks() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = [{ kind: "circle", points: [10, 7], radius: 2, label: "red", fill: "solid", key: "disc" }]
        spy.target = c
        spy.signalName = "shapeClicked"
        spy.clear()
        mouseDoubleClickSequence(c, 200, 140)
        compare(spy.count, 2)
    }

    function test_doubleClickOnGround() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = [{ kind: "circle", points: [10, 7], radius: 2, label: "red", fill: "solid", key: "disc" }]
        spy.target = c
        spy.signalName = "shapeDoubleClicked"
        spy.clear()
        mouseDoubleClickSequence(c, 20, 20)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "")
    }
}
