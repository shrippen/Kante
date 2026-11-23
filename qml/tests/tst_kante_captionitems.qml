import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas: captions are Text items over the canvas (position, turn, colour, opacity,
 * culling, no mouse input).
 */
TestCase {
    id: tc
    name: "KanteCaptionItems"
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

    // The caption Text items of a view, in shape order.
    function texts(item) {
        const found = []
        const walk = function (it) {
            for (let i = 0; i < it.children.length; i++) {
                const child = it.children[i]
                if (child.lineHeightMode !== undefined) {
                    found.push(child)
                }
                walk(child)
            }
        }
        walk(item)
        return found
    }

    function make(shapes) {
        const c = createTemporaryObject(canvasComponent, tc.Window.contentItem)
        c.shapes = shapes
        wait(20)
        return c
    }

    // Where a point of the Text lies in the view.
    function inView(c, t, x, y) {
        return t.mapToItem(c, x, y)
    }

    function test_oneItemPerCaption() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" },
                        { kind: "circle", points: [9, 5], radius: 1, label: "red" },
                        { kind: "line", points: [1, 10, 4, 10], label: "red", text: "B" }])
        const t = texts(c)
        compare(t.length, 2)
        compare(t[0].text, "A")
        compare(t[1].text, "B")
    }

    // Plain text: markup is shown as it is.
    function test_textIsPlain() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "<b>A</b>" }])
        compare(texts(c)[0].textFormat, Text.PlainText)
    }

    // A circle's caption stands right of its edge, its middle on the circle's centre line.
    function test_circleCaptionBesideEdge() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" }])
        const t = texts(c)[0]
        const p = inView(c, t, 0, t.height / 2)
        // Edge at 120 px, gap 4 px.
        fuzzyCompare(p.x, 5 * 20 + 20 + KanteStyle.unit(4), 0.5)
        fuzzyCompare(p.y, 100, 3)
    }

    function test_centredCaptionOnPolygon() {
        const c = make([{ kind: "polygon", points: [2, 2, 8, 2, 8, 6, 2, 6], label: "red", text: "Room" }])
        const t = texts(c)[0]
        const p = inView(c, t, t.width / 2, t.height / 2)
        fuzzyCompare(p.x, 100, 1)
        fuzzyCompare(p.y, 80, 3)
    }

    // Moving the view moves the captions with it, and the caption stays the same item.
    function test_panMovesCaption() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" }])
        const t = texts(c)[0]
        const before = inView(c, t, 0, 0)
        c.panX = 30
        c.panY = 10
        const after = inView(c, t, 0, 0)
        compare(texts(c)[0], t)
        fuzzyCompare(after.x - before.x, 30, 0.01)
        fuzzyCompare(after.y - before.y, 10, 0.01)
    }

    // Shapes of the same count keep their caption items (no new ones for every change).
    function test_sameCountKeepsItems() {
        const shapes = [{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" }]
        const c = make(shapes)
        const t = texts(c)[0]
        shapes[0].text = "B"
        c.shapes = shapes.slice()
        compare(texts(c)[0], t)
        compare(t.text, "B")
    }

    // The anchor item carries the turn: clockwise degrees about the anchor.
    function test_rotationAboutAnchor() {
        const c = make([{ kind: "polygon", points: [6, 2, 16, 2, 16, 6, 6, 6], label: "red", text: "MMMM",
                          textAnchor: "topLeft", captionSize: 0.8, textRotation: 90 }])
        const t = texts(c)[0]
        compare(t.parent.rotation, 90)
        // Anchor: the first point, (120, 40). A turned quarter clockwise, the text runs down from it.
        const a = inView(c, t, 0, 0)
        const b = inView(c, t, t.width, 0)
        verify(b.y - a.y > t.width * 0.9)
        verify(Math.abs(b.x - a.x) < 1)
        verify(a.x <= 120 + 1 && a.y >= 40 - 1)
    }

    function test_colourIsReadableLabelColour() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" },
                        { kind: "circle", points: [9, 5], radius: 1, label: "muted", text: "B" }])
        const t = texts(c)
        compare(String(t[0].color), String(KanteStyle.readable(KanteStyle.namedColor("red"), KanteStyle.backgroundColor)))
        compare(String(t[1].color), String(KanteStyle.readable(KanteStyle.namedColor("muted"), KanteStyle.backgroundColor)))
    }

    function test_opacityFadesCaption() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A", opacity: 0.4 },
                        { kind: "circle", points: [9, 5], radius: 1, label: "red", text: "B" }])
        const t = texts(c)
        fuzzyCompare(t[0].parent.opacity, 0.4, 0.001)
        compare(t[1].parent.opacity, 1)
    }

    // Out of view captions are hidden; panning back shows them.
    function test_outOfViewIsHidden() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" },
                        { kind: "circle", points: [500, 5], radius: 1, label: "red", text: "B" }])
        const t = texts(c)
        verify(t[0].visible)
        verify(!t[1].visible)
        c.panX = -9900
        verify(!t[0].visible)
        verify(t[1].visible)
    }

    function test_turnedCaptionReachesIn() {
        const c = make([{ kind: "polygon", points: [-3, 5, 3, 5, 3, 9, -3, 9], label: "red", text: "MMMMMMMM",
                          textAnchor: "topLeft", captionSize: 1, textRotation: 45 },
                        { kind: "polygon", points: [-300, 5, -290, 5, -290, 9, -300, 9], label: "red", text: "MMMMMMMM",
                          textAnchor: "topLeft", captionSize: 1, textRotation: 45 }])
        const t = texts(c)
        verify(t[0].visible)
        verify(!t[1].visible)
    }

    // Below 4 px a caption sized in model units is left out, and returns when zoomed in.
    function test_tooSmallIsHidden() {
        // At the middle of the view, which a zoom keeps in place.
        const c = make([{ kind: "circle", points: [10, 7.5], radius: 1, label: "red", text: "A", captionSize: 0.1 }])
        const t = texts(c)[0]
        verify(!t.visible)
        c.zoom = 60
        verify(t.visible)
    }

    // The caption grows with the zoom when sized in model units, else keeps the small font.
    function test_sizeFollowsZoom() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A", captionSize: 0.5 },
                        { kind: "circle", points: [9, 5], radius: 1, label: "red", text: "B" }])
        const t = texts(c)
        const fixed = t[1].font.pixelSize > 0 ? t[1].font.pixelSize : t[1].font.pointSize
        const x1 = t[0].font.pixelSize * t[0].parent.scale
        c.zoom = 40
        fuzzyCompare(t[0].font.pixelSize * t[0].parent.scale, x1 * 2, 0.01)
        compare(t[1].font.pixelSize > 0 ? t[1].font.pixelSize : t[1].font.pointSize, fixed)
    }

    // Lines are 1.25 font sizes apart.
    function test_lineSpacing() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A\nB\nC", captionSize: 0.5 }])
        const t = texts(c)[0]
        compare(t.lineHeightMode, Text.FixedHeight)
        fuzzyCompare(t.lineHeight, t.font.pixelSize * 1.25, 0.001)
        compare(t.lineCount, 3)
    }

    // The captions take no mouse input: a click over one reaches the shape under it.
    function test_clickPassesThroughCaption() {
        const c = make([{ kind: "polygon", points: [2, 2, 8, 2, 8, 6, 2, 6], label: "red", fill: "tint", text: "Room", key: "room" }])
        spy.target = c
        spy.signalName = "shapeClicked"
        spy.clear()
        mouseClick(c, 100, 80)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "room")
    }

    function test_captionsAreHiddenFromReaders() {
        const c = make([{ kind: "circle", points: [5, 5], radius: 1, label: "red", text: "A" }])
        verify(texts(c)[0].Accessible.ignored)
    }
}
