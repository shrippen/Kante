import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas leaves out captions outside the view; one whose end still shows at the edge
 * must stay, also with wide glyphs (CJK). From the review of Kante #187.
 */
TestCase {
    id: tc
    name: "KanteCanvasEdge"
    width: 800
    height: 600
    when: windowShown

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
            shapes: [{ kind: "circle", points: [0, 5], radius: 0, label: "text", fill: "none",
                       text: "日本語の字幕", key: "caption" }]
        }
    }

    // Leftmost and rightmost column where the caption changes the picture: the canvas with the
    // caption against the same canvas without it.
    function inkSpan(c) {
        const text = c.shapes[0].text
        c.shapes = [Object.assign({}, c.shapes[0], { text: "" })]
        wait(50)
        const plain = tc.grabImage(c)
        c.shapes = [Object.assign({}, c.shapes[0], { text: text })]
        wait(50)
        const img = tc.grabImage(c)

        let left = -1
        let right = -1
        for (let x = 0; x < c.width; x++) {
            for (let y = 0; y < c.height; y++) {
                if (!Qt.colorEqual(img.pixel(x, y), plain.pixel(x, y))) {
                    left = left < 0 ? x : left
                    right = x
                    break
                }
            }
        }
        return { left: left, right: right }
    }

    function test_wideCaptionEndStaysAtLeftEdge() {
        const c = createTemporaryObject(canvasComponent, stage())
        c.panX = 150
        const whole = inkSpan(c)
        verify(whole.left > 0 && whole.right > whole.left, "caption drawn in view: " + JSON.stringify(whole))

        // Only the last two columns of the caption stay in view.
        c.panX = 150 - (whole.right - 1)
        const edge = inkSpan(c)
        verify(edge.left === 0 && edge.right >= 0 && edge.right <= 2,
               "end of the caption at the left edge: " + JSON.stringify(edge))
    }
}
