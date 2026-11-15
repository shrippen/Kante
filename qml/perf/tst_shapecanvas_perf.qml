import QtQuick
import QtTest
import Kante

/**
 * Draw time of KanteShapeCanvas at Klappe's size (610 shapes, 272 captions). Not in the normal
 * suite (timings flicker). Run:
 *   QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import qml -input qml/perf
 * Prints ms per paint with the shapes and with none.
 */
TestCase {
    id: tc
    name: "ShapeCanvasPerf"
    width: 1000
    height: 700
    when: windowShown

    readonly property int rooms: 50

    // 50 rooms, 300 walls, 250 discs; about 270 of them carry a caption.
    function plan() {
        const list = []
        const labels = ["red", "green", "blue", "accent", "muted", "orange"]
        for (let i = 0; i < 610; i++) {
            const x = (i % 40) * 2.2
            const y = Math.floor(i / 40) * 2.2
            const s = { key: "k" + i, label: labels[i % labels.length] }
            if (i < rooms) {
                s.kind = "polygon"
                s.points = [x, y, x + 2, y, x + 2, y + 2, x, y + 2]
                s.fill = "tint"
            } else if (i < 350) {
                s.kind = "line"
                s.points = [x, y, x + 1.5, y + 0.5]
                s.width = 0.1
                s.stroke = i % 3 === 0 ? "dashed" : "solid"
            } else {
                s.kind = "circle"
                s.points = [x + 1, y + 1]
                s.radius = 0.4
                s.fill = i % 2 === 0 ? "solid" : "none"
            }
            if (i % 7 < 3 && i % 40 !== 0 || i < 30) {
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

    // Ms per paint handler run (recording the drawing, not rendering it): 20 runs per round, the
    // fastest of 5 rounds, as other load only ever adds time.
    function msPaint(view) {
        const canvas = canvasOf(view)
        tryVerify(function () { return canvas.available })
        const rect = Qt.rect(0, 0, canvas.width, canvas.height)
        let best = Infinity
        for (let round = 0; round < 5; round++) {
            const t0 = Date.now()
            for (let i = 0; i < 20; i++) {
                view.panX += 1
                canvas.paint(rect)
            }
            best = Math.min(best, (Date.now() - t0) / 20)
        }
        return best
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

    function test_drawTime() {
        const view = createTemporaryObject(viewComponent, tc)
        const shapes = plan()
        let captions = 0
        for (const s of shapes) {
            captions += s.text ? 1 : 0
        }
        compare(shapes.length, 610)

        const empty = msPaint(view)
        view.shapes = shapes
        const full = msPaint(view)
        console.log("PERF shapes=610 captions=" + captions + " paint=" + full.toFixed(1)
                    + " ms (no shapes " + empty.toFixed(1) + " ms)")

        // Zoomed in three times: a ninth of the plan is in view.
        view.zoom = 30
        view.panX = -200
        view.panY = -100
        console.log("PERF zoomed in: paint=" + msPaint(view).toFixed(1) + " ms")
        verify(full > 0)
    }
}
