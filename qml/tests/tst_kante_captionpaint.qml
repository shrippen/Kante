import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas: captions must not slow the canvas paint. Drawn with fillText (about 45 us each)
 * 272 captions on 610 shapes quadrupled the paint; as Text items they cost the paint nothing. Compared
 * as a ratio (paint with captions over paint without, same shapes, runs interleaved, medians), so
 * machine load cancels out.
 */
TestCase {
    id: tc
    name: "KanteCaptionPaint"
    width: 1000
    height: 700
    when: windowShown

    readonly property int paints: 10
    readonly property int rounds: 7
    readonly property real maxRatio: 2.0

    // 50 rooms, 300 walls, 260 discs; with captions on about 270 of them.
    function plan(captions) {
        const list = []
        for (let i = 0; i < 610; i++) {
            const x = (i % 40) * 2.2
            const y = Math.floor(i / 40) * 2.2
            const s = { key: "k" + i, label: "red" }
            if (i < 50) {
                s.kind = "polygon"
                s.points = [x, y, x + 2, y, x + 2, y + 2, x, y + 2]
                s.fill = "tint"
            } else if (i < 350) {
                s.kind = "line"
                s.points = [x, y, x + 1.5, y + 0.5]
                s.width = 0.1
            } else {
                s.kind = "circle"
                s.points = [x + 1, y + 1]
                s.radius = 0.4
            }
            if (captions && (i % 7 < 3 && i % 40 !== 0 || i < 30)) {
                s.text = "Obj " + i
            }
            list.push(s)
        }
        return list
    }

    function canvasOf(item) {
        for (let i = 0; i < item.children.length; i++) {
            if (typeof item.children[i].getContext === "function") {
                return item.children[i]
            }
        }
        return null
    }

    // Ms per paint handler run (the drawing is recorded, not rendered).
    function msPaint(view) {
        const canvas = canvasOf(view)
        const rect = Qt.rect(0, 0, canvas.width, canvas.height)
        const t0 = Date.now()
        for (let i = 0; i < paints; i++) {
            view.panX += 1
            canvas.paint(rect)
        }
        return (Date.now() - t0) / paints
    }

    function median(list) {
        list.sort(function (a, b) { return a - b })
        return list[Math.floor(list.length / 2)]
    }

    Component {
        id: viewComponent
        KanteShapeCanvas {
            width: 900
            height: 600
            contentWidth: 90
            contentHeight: 40
            gridStep: 1
            fitOnLoad: false
            zoom: 10
        }
    }

    function test_captionsKeepPaintCheap() {
        const plain = createTemporaryObject(viewComponent, tc)
        const texted = createTemporaryObject(viewComponent, tc)
        plain.shapes = plan(false)
        texted.shapes = plan(true)
        tryVerify(function () { return canvasOf(plain).available && canvasOf(texted).available })
        msPaint(plain)
        msPaint(texted)

        const without = []
        const withText = []
        for (let r = 0; r < rounds; r++) {
            without.push(msPaint(plain))
            withText.push(msPaint(texted))
        }
        const ratio = median(withText) / median(without)
        console.log("paint ms: plain " + median(without).toFixed(2) + ", captions "
                    + median(withText).toFixed(2) + ", ratio " + ratio.toFixed(2))
        verify(ratio <= maxRatio, "paint with captions " + ratio.toFixed(2) + "x the paint without (max "
               + maxRatio + "x)")
    }
}
