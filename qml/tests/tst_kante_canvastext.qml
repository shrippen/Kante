import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas: captions of several lines, textAnchor, shapeDoubleClicked, textRotation.
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

    // Every pixel of the view as one string: equal strings are the same picture.
    function pixels(c) {
        const img = tc.grabImage(c)
        const out = []
        for (let y = 0; y < img.height; y += 2) {
            for (let x = 0; x < img.width; x += 2) {
                out.push(img.pixel(x, y).toString())
            }
        }
        return out.join("")
    }

    function note(points, rotation) {
        return [{ kind: "polygon", points: points, label: "red", fill: "none", text: "MMMMMMMM\nMMMMMMMM",
                  textAnchor: "topLeft", captionSize: 0.8, textRotation: rotation, key: "note" }]
    }

    // The card as it lies unturned and turned a quarter clockwise about its top left corner (6, 2).
    readonly property var cardFlat: [6, 2, 16, 2, 16, 6, 6, 6]
    readonly property var cardTurned: [6, 2, 6, 12, 2, 12, 2, 2]

    function test_rotationChangesPicture() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = note(tc.cardFlat, 0)
        wait(50)
        const flat = pixels(c)
        c.shapes = note(tc.cardFlat, 30)
        wait(50)
        verify(pixels(c) !== flat)
    }

    // 0 is today's picture, and so is no textRotation at all.
    function test_zeroRotationIsUnchanged() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = note(tc.cardFlat, undefined)
        wait(50)
        const without = pixels(c)
        c.shapes = note(tc.cardFlat, 0)
        wait(50)
        verify(pixels(c) === without)
    }

    // A full turn lays the caption as it was.
    function test_fullTurnIsFlat() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = note(tc.cardFlat, 0)
        wait(50)
        const flat = pixels(c)
        c.shapes = note(tc.cardFlat, 360)
        wait(50)
        verify(pixels(c) === flat)
    }

    // Box of the ink inside x0..x1, y0..y1: {l, t, r, b}, null for none.
    function inkBox(c, x0, x1, y0, y1) {
        const img = tc.grabImage(c)
        const ground = img.pixel(300, 220)
        let box = null
        for (let y = y0; y < y1; y++) {
            for (let x = x0; x < x1; x++) {
                if (Math.abs(img.pixel(x, y).r - ground.r) <= 0.05) {
                    continue
                }
                box = box === null ? { l: x, t: y, r: x, b: y }
                    : { l: Math.min(box.l, x), t: Math.min(box.t, y), r: Math.max(box.r, x), b: Math.max(box.b, y) }
            }
        }
        return box
    }

    // The card turned 90 degrees stands at x 40..120 and y 40..240 px; its top edge is the right
    // one. The caption, turned the same, runs down it, its lines stacking leftwards from there.
    function test_quarterTurnLiesAlongCard() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = note(tc.cardTurned, 90)
        wait(50)
        const box = inkBox(c, 44, 117, 44, 236)
        verify(box !== null)
        verify(box.b - box.t > 2 * (box.r - box.l))
        verify(box.r > 100)
        verify(box.l >= 44 && box.b <= 236)
    }

    // The same caption unturned on the flat card runs along it instead.
    function test_flatCaptionRunsAcross() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = note(tc.cardFlat, 0)
        wait(50)
        const box = inkBox(c, 124, 316, 44, 116)
        verify(box !== null)
        verify(box.r - box.l > 2 * (box.b - box.t))
    }

    // A turned caption whose anchor lies left of the view but whose text reaches in is drawn; one
    // far outside is skipped.
    function test_turnedCaptionCulling() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.shapes = [{ kind: "polygon", points: [-3, 5, 3, 5, 3, 9, -3, 9], label: "red", fill: "none",
                      text: "MMMMMMMM", textAnchor: "topLeft", captionSize: 1, textRotation: 45, key: "n" }]
        wait(50)
        verify(inkBox(c, 44, 356, 44, 256) !== null)
        c.shapes = [{ kind: "polygon", points: [-300, 5, -290, 5, -290, 9, -300, 9], label: "red", fill: "none",
                      text: "MMMMMMMM", textAnchor: "topLeft", captionSize: 1, textRotation: 45, key: "n" }]
        wait(50)
        compare(inkBox(c, 44, 356, 44, 256), null)
    }
}
