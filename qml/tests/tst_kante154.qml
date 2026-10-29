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

    Component {
        id: leadingComponent
        KantePageBar {
            width: 700
            model: ["Mix", "Show", "Ton"]
            leading: [Rectangle { implicitWidth: 120; implicitHeight: 24 }]
        }
    }

    // Hidden in Band, the leading items left a gap of their width before the segments.
    function test_bandStartsAtTheEdge() {
        const b = createTemporaryObject(leadingComponent, tc.Window.contentItem, { density: KantePageBar.Density.Band })
        waitForRendering(b)
        const segments = named(b, "kantePageSegment").filter(visibleNow)
        compare(segments.length, 3)
        verify(segments[0].mapToItem(b, 0, 0).x < 40, "first segment at " + segments[0].mapToItem(b, 0, 0).x)
        const normal = createTemporaryObject(leadingComponent, tc.Window.contentItem)
        verify(b.implicitWidth < normal.implicitWidth, "Band leaves the leading items out of its width")
    }

    Component {
        id: tallTrailingComponent
        KantePageBar {
            width: 700
            model: ["Mix", "Show", "Ton"]
            density: KantePageBar.Density.Compact
            Rectangle { objectName: "trailing"; implicitWidth: 64; implicitHeight: KanteStyle.heightSmall }
        }
    }

    // Compact was three quarters of heightSmall whatever it held: a small button at the end
    // stuck out over the top line and below the bar.
    function test_compactGrowsForItsItems() {
        const b = createTemporaryObject(tallTrailingComponent, tc.Window.contentItem)
        waitForRendering(b)
        verify(b.implicitHeight >= KanteStyle.heightSmall, "Compact is " + b.implicitHeight)
        const item = named(b, "trailing")[0]
        const top = item.mapToItem(b, 0, 0).y
        verify(top >= 0 && top + item.height <= b.height, "item from " + top + " to " + (top + item.height) + " in " + b.height)
    }

    // The segments are the only mark of a page in Band, and where to click: in tint1 on
    // the sunken ground they read at about 1.2:1, below the 3:1 of WCAG 1.4.11.
    function test_bandSegmentsStandOut() {
        const low = []
        try {
            for (const kind of [KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]) {
                for (const dark of [true, false]) {
                    KanteStyle.kind = kind
                    KanteStyle.preferDark = dark
                    const b = createTemporaryObject(barComponent, tc.Window.contentItem, {
                        density: KantePageBar.Density.Band, busy: [] })
                    waitForRendering(b)
                    const idle = named(b, "kantePageSegment").filter(visibleNow)[1]
                    // As drawn: roles may have alpha (tints, Kante Light's platform roles);
                    // the bar is sunken on the window's ground.
                    const ground = Qt.tint(KanteStyle.backgroundColor, KanteStyle.sunkenColor)
                    const drawn = Qt.tint(ground, idle.color)
                    const ratio = KanteStyle.contrastOf(drawn, ground)
                    if (ratio < 3) {
                        low.push("kind " + kind + (dark ? " dark" : " light") + ": " + ratio.toFixed(2)
                                 + " (" + drawn + " on " + ground + ")")
                    }
                }
            }
        } finally {
            KanteStyle.kind = KanteStyle.Kind.System
            KanteStyle.preferDark = false
        }
        verify(low.length === 0, low.join(", "))
    }

    // With tooltips of its own, Band showed only the tip, the page's name nowhere.
    function test_bandTooltipKeepsTheName() {
        const b = createTemporaryObject(barComponent, tc.Window.contentItem, {
            density: KantePageBar.Density.Band, tooltips: ["Bild und Ton", "", ""] })
        const t = tabs(b)
        compare(t[0].shownTip, "Mix\nBild und Ton")
        compare(t[1].shownTip, "Show")
        b.density = KantePageBar.Density.Normal
        compare(t[0].shownTip, "Bild und Ton")
    }
}
