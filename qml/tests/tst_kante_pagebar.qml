import QtQuick
import QtTest
import Kante

/**
 * KantePageBar (for lmix): pages at the foot of the window, busy dots, keys, trailing items,
 * accessibility; and the stage roles (picture areas stay dark in every kind and scheme).
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KantePageBar"
    width: 800
    height: 200
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    Component {
        id: barComponent
        KantePageBar {
            width: 700
            model: ["Inputs", "Audio", "Outputs", "Setup"]
            tooltips: ["Quellen", "", "", ""]
            busy: [false, true, true, true]
            busyKinds: [0, KantePageBar.Kind.Info, KantePageBar.Kind.Warning, KantePageBar.Kind.Error]
            Rectangle { objectName: "program"; implicitWidth: 64; implicitHeight: 24; color: KanteStyle.stageColor }
        }
    }

    function findAll(item, pred) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            let c = item.children[i]
            if (pred(c)) out.push(c)
            out = out.concat(findAll(c, pred))
        }
        return out
    }
    function tabs(b) {
        return findAll(b, function (c) { return c.Accessible.role === Accessible.PageTab })
    }
    function named(item, name) {
        return findAll(item, function (c) { return c.objectName === name })
    }

    function test_tabs_and_accessibility() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        compare(b.count, 4)
        let t = tabs(b)
        compare(t.length, 4)
        compare(t[0].Accessible.name, "Inputs")
        verify(t[0].Accessible.selected)
        verify(!t[1].Accessible.selected)
        compare(t[1].Accessible.description, "Info")
        compare(t[3].Accessible.description, "Fehler")
        compare(t[0].Accessible.description, "Quellen")
        compare(b.Accessible.role, Accessible.PageTabList)
    }

    function test_click_selects_and_emits() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        let spy = createTemporaryObject(signalSpyComponent, tc, { target: b, signalName: "activated" })
        let t = tabs(b)
        mouseClick(t[2])
        compare(b.currentIndex, 2)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 2)
        mouseClick(t[2])
        compare(spy.count, 1, "the current page again does not fire")
        verify(t[2].Accessible.selected)
    }

    function test_keys() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        b.forceActiveFocus()
        keyClick(Qt.Key_Right)
        compare(b.currentIndex, 1)
        keyClick(Qt.Key_End)
        compare(b.currentIndex, 3)
        keyClick(Qt.Key_Right)
        compare(b.currentIndex, 3, "stops at the last page")
        keyClick(Qt.Key_Home)
        compare(b.currentIndex, 0)
        keyClick(Qt.Key_Left)
        compare(b.currentIndex, 0)
        // the focus frame shows on the current tab only while the bar has focus
        let frames = named(b, "kantePageFocus").filter(function (f) { return f.visible })
        compare(frames.length, 1)
    }

    function test_current_tab_is_raised_with_marker() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        let b = createTemporaryObject(barComponent, tc.Window.contentItem, { currentIndex: 1 })
        wait(10)
        let raised = named(b, "kantePageTab").filter(function (p) { return p.visible })
        compare(raised.length, 1)
        compare(raised[0].fillColor, KanteStyle.cardColor)
        compare(raised[0].cutTopRight, KanteStyle.chamferSmall)
        let markers = named(b, "kantePageMarker").filter(function (m) { return m.visible })
        compare(markers.length, 1)
        compare(markers[0].color, KanteStyle.focusColor)
        compare(markers[0].y, 0)
        verify(markers[0].parent === tabs(b)[1])
    }

    function test_busy_dots_by_kind() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        let dots = named(b, "kantePageBusy")
        compare(dots.length, 4)
        verify(!dots[0].visible)
        verify(dots[1].visible && dots[2].visible && dots[3].visible)
        compare(dots[1].color, KanteStyle.infoColor)
        compare(dots[2].color, KanteStyle.warningColor)
        compare(dots[3].color, KanteStyle.negativeTextColor)
        // not colour alone: warning and error are diamonds, info round
        compare(dots[1].rotation, 0)
        compare(dots[2].rotation, 45)
        compare(dots[3].rotation, 45)
        compare(b.kindOf(9), KantePageBar.Kind.Normal)
        compare(b.kindColor(KantePageBar.Kind.Normal), KanteStyle.accentTextColor)
    }

    function test_trailing_items_at_right_end() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        wait(10)
        let p = named(b, "program")
        compare(p.length, 1)
        let r = p[0].mapToItem(b, 0, 0)
        fuzzyCompare(r.x + p[0].width, b.width - KanteStyle.unit(8), 1)
        // the tabs end before the trailing items
        let t = tabs(b)
        let last = t[t.length - 1].mapToItem(b, 0, 0)
        verify(last.x + t[t.length - 1].width <= r.x)
    }

    function test_overflow_keeps_current_in_view() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem, { width: 260 })
        b.currentIndex = 3
        wait(300)
        let t = tabs(b)[3]
        let flick = t.parent.parent.parent
        verify(t.x + t.width <= flick.contentX + flick.width + 1)
        verify(t.x >= flick.contentX - 1)
    }

    // Restored at start-up (currentIndex set at creation, narrow bar): the tab is in view once laid out.
    function test_initial_page_in_view() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem, { width: 260, currentIndex: 3 })
        wait(300)
        let t = tabs(b)[3]
        let flick = t.parent.parent.parent
        verify(flick.contentX > 0, "scrolled to the last tab")
        verify(t.x + t.width <= flick.contentX + flick.width + 1)
        verify(t.x >= flick.contentX - 1)
    }

    // The trailing items grow: the tab area shrinks and the current tab stays in view.
    function test_trailing_growth_keeps_current_in_view() {
        let b = createTemporaryObject(barComponent, tc.Window.contentItem, { width: 520, currentIndex: 3 })
        wait(300)
        named(b, "program")[0].implicitWidth = 300
        wait(300)
        let t = tabs(b)[3]
        let flick = t.parent.parent.parent
        verify(flick.width < row(b).width)
        verify(t.x + t.width <= flick.contentX + flick.width + 1)
    }
    function row(b) {
        return tabs(b)[0].parent
    }

    Component {
        id: crowdedComponent
        KantePageBar {
            model: ["Inputs", "Audio", "Outputs", "Setup"]
            Text { text: "PROGRAMM" }
            Rectangle { implicitWidth: 120; implicitHeight: 24; color: KanteStyle.stageColor }
            Rectangle { implicitWidth: 90; implicitHeight: 24; color: KanteStyle.stageColor }
        }
    }

    // Created narrower than its trailing items (a layout not yet sized, as in lmix) with a later
    // page, then widened while the scroll still runs, so every tab fits: the tabs start at the
    // left edge again, none scrolled away. Kind Kante: the scroll animates there.
    function test_narrow_start_then_wide_data() {
        return [
            { tag: "tab area below zero", narrow: 193, after: 30 },
            { tag: "tab area below zero, at once", narrow: 193, after: 0 },
            { tag: "tab area small", narrow: 360, after: 30 },
            { tag: "tab area small, at once", narrow: 360, after: 0 }
        ]
    }
    function test_narrow_start_then_wide(data) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        let b = createTemporaryObject(crowdedComponent, tc.Window.contentItem, { width: data.narrow, currentIndex: 2 })
        wait(data.after)
        b.width = 780
        wait(400)
        let t = tabs(b)
        let flick = t[0].parent.parent.parent
        verify(flick.width >= row(b).width, "all tabs fit")
        compare(flick.contentX, 0)
        for (let i = 0; i < t.length; i++) {
            verify(t[i].inView, "tab " + i + " in view")
        }
    }

    function test_builds_in_every_kind() {
        let kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]
        let b = createTemporaryObject(barComponent, tc.Window.contentItem)
        for (let i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(10)
            compare(tabs(b).length, 4)
            verify(b.implicitHeight === KanteStyle.heightMedium)
        }
    }

    // Picture areas stay dark: Kante dark and Leinen, Kante Light and System alike.
    function test_stage_stays_dark() {
        let kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]
        let darks = [true, false]
        for (let i = 0; i < kinds.length; i++) {
            for (let j = 0; j < darks.length; j++) {
                KanteStyle.kind = kinds[i]
                KanteStyle.preferDark = darks[j]
                verify(KanteStyle.relLum(KanteStyle.stageColor) < 0.05, "stage dark in kind " + kinds[i])
                compare(KanteStyle.stageColor.a, 1)
                verify(KanteStyle.contrastOf(KanteStyle.stageTextColor, KanteStyle.stageColor) >= 4.5)
            }
        }
        compare(String(KantePalette.light.stage), String(KantePalette.dark.stage))
        compare(String(KantePalette.dark.stage), "#282828")
        compare(String(KantePalette.light.stageText), String(KantePalette.dark.stageText))
    }

    Component { id: signalSpyComponent; SignalSpy { } }
}
