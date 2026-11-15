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

    function room(text, anchor, size) {
        return [{ kind: "polygon", points: [2, 2, 18, 2, 18, 13, 2, 13], label: "red", fill: "none",
                  text: text, textAnchor: anchor, captionSize: size, key: "room" }]
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

    // First and last row of ink of one caption at a zoom, [] for none. The plan's top left corner
    // stays at the view's, the outline lies outside the scanned area.
    function span(text, size, zoom) {
        const c = createTemporaryObject(canvasComponent, stage())
        c.zoom = zoom
        c.panX = 0
        c.panY = 0
        c.shapes = [{ kind: "polygon", points: [0, 0, 30, 0, 30, 20, 0, 20], label: "red", fill: "none",
                      text: text, textAnchor: "topLeft", captionSize: size, key: "room" }]
        wait(50)
        const rows = inkRows(c, 2, 390, 2, 290)
        return rows.length === 0 ? [] : [rows[0], rows[rows.length - 1]]
    }

    // 0.5 m at 20 px/m is 10 px, at 40 px/m 20 px: the glyphs grow with the zoom.
    function test_captionSizeScalesWithZoom() {
        const small = span("MMMM", 0.5, 20)
        const big = span("MMMM", 0.5, 40)
        verify(small.length === 2 && big.length === 2)
        verify(big[1] - big[0] > (small[1] - small[0]) * 1.6)
    }

    function test_captionSizeLinesScale() {
        const one = span("MMMM", 0.5, 20)
        const three = span("MMMM\nMMMM\nMMMM", 0.5, 20)
        const doubled = span("MMMM\nMMMM\nMMMM", 0.5, 40)
        // Lines 1.25 font sizes apart: three lines span two pitches more than one.
        const pitch = 0.5 * 20 * 1.25
        verify(Math.abs((three[1] - three[0]) - (one[1] - one[0]) - 2 * pitch) < 3)
        verify(Math.abs((doubled[1] - doubled[0]) - (three[1] - three[0]) * 2) < 6)
    }

    function test_captionSizeBelowMinimumIsLeftOut() {
        // 0.1 m at 20 px/m is 2 px.
        compare(span("MMMM", 0.1, 20).length, 0)
        verify(span("MMMM", 0.1, 60).length > 0)
    }

    // Without captionSize the caption keeps the small font at every zoom.
    function test_withoutCaptionSizeStaysFixed() {
        const a = span("MMMM", undefined, 20)
        const b = span("MMMM", undefined, 40)
        compare(a[1] - a[0], b[1] - b[0])
    }
}
