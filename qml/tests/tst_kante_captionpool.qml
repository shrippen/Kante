import QtQuick
import QtTest
import Kante

/**
 * KanteShapeCanvas: a frame that changes the number of captions keeps the existing caption items
 * and only adds or removes the difference. Recreating all of them (about 270 in a big plan) made
 * such a frame 45 ms against 22 ms. Each item is marked by its objectName; one that survives the
 * change was not recreated.
 */
TestCase {
    id: tc
    name: "KanteCaptionPool"
    width: 800
    height: 600
    when: windowShown

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

    function captioned(n) {
        const list = []
        for (let i = 0; i < n; i++) {
            list.push({ kind: "circle", points: [1 + i, 5], radius: 0.4, label: "red", text: "T" + i })
        }
        return list
    }

    function marked(c) {
        const t = texts(c)
        for (let i = 0; i < t.length; i++) {
            t[i].objectName = "mark" + i
        }
        return t.length
    }

    function survivors(c) {
        return texts(c).filter(t => t.objectName !== "").length
    }

    function test_keepsItemsOnMoreCaptions() {
        const c = createTemporaryObject(canvasComponent, tc)
        c.shapes = captioned(5)
        wait(20)
        compare(marked(c), 5)

        c.shapes = captioned(8)
        wait(50)
        compare(texts(c).length, 8)
        compare(survivors(c), 5)
    }

    function test_keepsItemsOnFewerCaptions() {
        const c = createTemporaryObject(canvasComponent, tc)
        c.shapes = captioned(8)
        wait(20)
        compare(marked(c), 8)

        c.shapes = captioned(6)
        wait(50)
        compare(texts(c).length, 6)
        compare(survivors(c), 6)
        compare(texts(c)[5].text, "T5")
    }
}
