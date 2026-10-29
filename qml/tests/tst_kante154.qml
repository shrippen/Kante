import QtQuick
import QtTest
import Kante

/**
 * Kante 1.54: KantePageBar's density. Compact is lower with smaller labels; Band is a strip
 * with one segment per page, which still takes a click, keeps the labels for screen readers
 * and hides the trailing items. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante154"
    width: 800
    height: 200
    when: windowShown

    Component {
        id: barComponent
        KantePageBar {
            width: 700
            model: ["Mix", "Show", "Ton"]
            busy: [false, false, true]
            Rectangle { objectName: "trailing"; implicitWidth: 64; implicitHeight: 24 }
        }
    }

    function findAll(item, pred) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (pred(c)) out.push(c)
            out = out.concat(findAll(c, pred))
        }
        return out
    }
    function tabs(b) {
        return findAll(b, c => c.Accessible.role === Accessible.PageTab)
    }
    function named(b, name) {
        return findAll(b, c => c.objectName === name)
    }
    function visibleNow(item) {
        for (let i = item; i; i = i.parent) {
            if (!i.visible) return false
        }
        return true
    }

    function test_heightsByDensity() {
        const normal = createTemporaryObject(barComponent, tc.Window.contentItem)
        const compact = createTemporaryObject(barComponent, tc.Window.contentItem, { density: KantePageBar.Density.Compact })
        const band = createTemporaryObject(barComponent, tc.Window.contentItem, { density: KantePageBar.Density.Band })
        verify(compact.implicitHeight < normal.implicitHeight, "Compact is lower")
        compare(band.implicitHeight, KanteStyle.unit(8))
        verify(compact.tabFont.pointSize < normal.tabFont.pointSize, "Compact has smaller labels")
    }

    function test_bandTakesAClickAndKeepsTheNames() {
        const b = createTemporaryObject(barComponent, tc.Window.contentItem, { density: KantePageBar.Density.Band })
        let picked = -1
        b.activated.connect(i => picked = i)
        waitForRendering(b)
        const t = tabs(b)
        compare(t.length, 3)
        compare(t[1].Accessible.name, "Show")
        verify(!visibleNow(named(b, "trailing")[0]), "trailing items hidden in Band")
        const segments = named(b, "kantePageSegment").filter(visibleNow)
        compare(segments.length, 3)
        compare(segments[0].color, KanteStyle.focusColor)
        mouseClick(t[1], t[1].width / 2, t[1].height / 2)
        compare(b.currentIndex, 1)
        compare(picked, 1)
        compare(segments[1].color, KanteStyle.focusColor)
    }

    function test_normalHasNoSegments() {
        const b = createTemporaryObject(barComponent, tc.Window.contentItem)
        compare(named(b, "kantePageSegment").filter(visibleNow).length, 0)
        verify(visibleNow(named(b, "trailing")[0]))
    }
}
