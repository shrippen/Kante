import QtQuick
import QtTest
import Kante

/**
 * Kante 1.83, KanteGlassPanel: a translucent layer that slides in from an edge and blurs what
 * lies under it. Closed it costs nothing; without a GPU it is denser and unblurred.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante183"
    width: 400
    height: 300
    when: windowShown

    Component {
        id: scene
        Item {
            width: 400
            height: 300
            property alias panel: glass
            Rectangle { id: page; anchors.fill: parent; color: "red" }
            KanteGlassPanel {
                id: glass
                blurSource: page
                anchors { left: parent.left; right: parent.right; top: parent.top }
                panelSize: 120
                Rectangle { width: 10; height: 10 }
            }
        }
    }

    property var made: null

    function make(props) {
        const item = createTemporaryObject(scene, tc)
        verify(item)
        for (const k in props) {
            item.panel[k] = props[k]
        }
        return item.panel
    }
    function effects(panel) {
        return findChild(panel, "glassBlur").active
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
    }
    function cleanup() {
        KanteStyle.motion = true
    }

    function test_closedIsInvisibleAndFree() {
        const p = make({ software: false })
        compare(p.open, false)
        compare(p.shown, false)
        compare(p.blurred, false)
        compare(effects(p), false)
    }

    function test_opensWithoutMotionAtOnce() {
        const p = make({ software: false })
        p.open = true
        compare(p.slide, 1)
        compare(p.shown, true)
        compare(p.height, 120)
        compare(p.mapToItem(null, 0, 0).y, 0)
        p.open = false
        compare(p.slide, 0)
        compare(p.shown, false)
    }

    function test_slidesFromTopWithMotion() {
        KanteStyle.motion = true
        if (!KanteStyle.animate) {
            skip("platform animations are off")
        }
        const p = make({ software: false })
        p.open = true
        verify(p.moving)
        verify(p.shown)
        tryVerify(function () { return p.slide > 0.05 }, 3000)
        verify(p.mapToItem(null, 0, 0).y < 0)
        tryVerify(function () { return !p.moving }, 3000)
        fuzzyCompare(p.mapToItem(null, 0, 0).y, 0, 0.01)
        p.open = false
        tryCompare(p, "shown", false, 3000)
        compare(effects(p), false)
    }

    function test_edgesSlideOnTheirAxis() {
        const p = make({ software: false, edge: KanteGlassPanel.Edge.Left })
        p.anchors.right = undefined
        p.width = 100
        p.slide = 0.5
        verify(p.mapToItem(null, 0, 0).x < 0)
        compare(p.mapToItem(null, 0, 0).y, 0)
        p.edge = KanteGlassPanel.Edge.Bottom
        verify(p.vertical)
    }

    function test_blurWhenOpenWithGpu() {
        const p = make({ software: false })
        p.open = true
        compare(p.blurred, true)
        compare(effects(p), true)
        p.blurAllowed = false
        compare(effects(p), false)
    }

    function test_softwareHasNoBlurButDenserTint() {
        const p = make({ software: true })
        p.open = true
        compare(p.blurred, false)
        compare(effects(p), false)
        verify(KanteStyle.glassDenseColor.a > KanteStyle.glassColor.a)
    }

    function test_noSourceNoBlur() {
        const p = make({ software: false, blurSource: null })
        p.open = true
        compare(p.blurred, false)
    }

    function test_childrenStayUsable() {
        const p = make({ software: false })
        p.open = true
        compare(p.Accessible.role, Accessible.Pane)
        compare(p.content.length, 1)
    }

    function test_systemStyleTintsFromPlatform() {
        KanteStyle.kind = KanteStyle.Kind.System
        verify(KanteStyle.glassColor.a > 0)
        verify(KanteStyle.glassDenseColor.a > KanteStyle.glassColor.a)
    }

    // In slowly, out quickly (review #158: out took as long as in, the duration's binding
    // followed `open` only after the animation had started).
    function test_closesFasterThanItOpens() {
        KanteStyle.motion = true
        if (!KanteStyle.animate) {
            skip("platform animations are off")
        }
        const p = make({ software: false })
        let t = Date.now()
        p.open = true
        tryVerify(function () { return !p.moving }, 3000)
        const inMs = Date.now() - t
        t = Date.now()
        p.open = false
        tryVerify(function () { return !p.moving }, 3000)
        const outMs = Date.now() - t
        verify(outMs < inMs * 0.75, "out " + outMs + " ms, in " + inMs + " ms")
    }

    // Open and still, it draws no frames of its own (review #158: 97 frames a second while
    // nothing moved, each copying and blurring the source).
    function test_stillPanelDrawsNothing() {
        const p = make({ software: false, open: true })
        tryVerify(function () { return !p.moving }, 3000)
        wait(100)
        let frames = 0
        const count = function () { frames++ }
        tc.Window.window.frameSwapped.connect(count)
        wait(300)
        tc.Window.window.frameSwapped.disconnect(count)
        verify(frames < 3, frames + " frames while still")
    }
}
