import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Templates as T
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.51, from Kontra's QA of 28.10.2026 (P7 at 200 % with deuteranopia and a screen
 * reader, P4 at the beamer in Kante Light, P1 on a light Breeze theme): disabled items under a
 * KanteScope, a drawer's ground, a focus trap for sheets in the page, a callout with a title
 * only, string colours on a light ground and histogram bars for screen readers.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante151"
    width: 640
    height: 480
    when: windowShown
    // The focus trap follows visibility: the case is shown, as a page is.
    visible: true

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    // ── 1. Disabled items under a KanteScope ────────────────────────────

    Component {
        id: scopeComponent
        Item {
            id: area
            width: 300
            height: 200
            property alias box: box
            property alias inner: inner
            property alias plain: plain
            KanteScope { target: area }
            Item {
                id: box
                enabled: false
                // Reads the theme as a control's skin does.
                Rectangle {
                    id: inner
                    width: 10
                    height: 10
                    color: Kirigami.Theme.backgroundColor
                    property color ink: Kirigami.Theme.textColor
                }
            }
            Rectangle {
                id: plain
                width: 10
                height: 10
                color: Kirigami.Theme.backgroundColor
                property color ink: Kirigami.Theme.textColor
            }
        }
    }
    Component {
        id: lateChild
        Rectangle {
            width: 10
            height: 10
            enabled: false
            color: Kirigami.Theme.backgroundColor
            property color ink: Kirigami.Theme.textColor
        }
    }

    // Kirigami gives a disabled item the platform's colours whatever its parents set (on a
    // light system: white separators and entries in the dark Kante drawer, 1.7:1).
    function test_scopeDisabledKante() {
        const area = createTemporaryObject(scopeComponent, tc)
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(area.plain, "color", KanteStyle.dialogColor)
        tryCompare(area.inner, "color", KanteStyle.dialogColor)
        compare(area.inner.ink, KanteStyle.disabledTextColor)
    }

    // Items created later, and items that change `enabled`, follow too.
    function test_scopeDisabledLater() {
        const area = createTemporaryObject(scopeComponent, tc)
        KanteStyle.kind = KanteStyle.Kind.Kante
        const late = createTemporaryObject(lateChild, area)
        tryCompare(late, "color", KanteStyle.dialogColor)
        compare(late.ink, KanteStyle.disabledTextColor)

        // Enabled again: the enabled text colour.
        area.box.enabled = true
        tryCompare(area.inner, "ink", KanteStyle.textColor)
        area.box.enabled = false
        tryCompare(area.inner, "ink", KanteStyle.disabledTextColor)
        compare(area.inner.color, KanteStyle.dialogColor)
    }

    // System and Kante Light keep the platform's disabled colours, also after Kante.
    function test_scopeDisabledSystem() {
        const area = createTemporaryObject(scopeComponent, tc)
        const platform = String(area.inner.color)
        const platformInk = String(area.inner.ink)
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(area.inner, "color", KanteStyle.dialogColor)
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        tryVerify(function() { return String(area.inner.color) === platform })
        compare(String(area.inner.ink), platformInk)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(String(area.inner.color), platform)
    }

    Component {
        id: drawerComponent
        Item {
            id: host
            width: 400
            height: 300
            property alias drawer: drawer
            QQC2.Drawer {
                id: drawer
                width: 200
                height: host.height
                modal: false
                // A platform drawer's ground reads the theme (Kirigami's drawers do).
                background: Rectangle { color: Kirigami.Theme.backgroundColor }
                contentItem: Column {
                    QQC2.Label { text: "Start" }
                }
            }
            KanteScope { target: drawer.contentItem; popup: drawer }
        }
    }

    // A drawer's ground lies beside its content: white below the entries, "close sidebar"
    // at 1.4:1. `popup` themes it with the content.
    function test_scopePopupBackground() {
        const host = createTemporaryObject(drawerComponent, tc)
        host.drawer.open()
        tryCompare(host.drawer, "opened", true)
        const platform = String(host.drawer.background.color)
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(host.drawer.background, "color", KanteStyle.dialogColor)
        KanteStyle.kind = KanteStyle.Kind.System
        tryVerify(function() { return String(host.drawer.background.color) === platform })
    }

    // A real Kirigami drawer: a disabled entry and a separator in Kante's colours.
    Component {
        id: globalDrawerComponent
        Item {
            width: 400
            height: 300
            property alias drawer: gd
            Kirigami.GlobalDrawer {
                id: gd
                modal: false
                isMenu: false
                actions: [
                    Kirigami.Action { text: "home" },
                    Kirigami.Action { separator: true },
                    Kirigami.Action { text: "locked"; enabled: false }
                ]
            }
            KanteScope { target: gd.contentItem; popup: gd }
        }
    }
    function find(item, test) {
        if (!item) {
            return null
        }
        if (test(item)) {
            return item
        }
        for (let i = 0; i < item.children.length; i++) {
            const found = find(item.children[i], test)
            if (found) {
                return found
            }
        }
        return null
    }
    function test_scopeGlobalDrawer() {
        const host = createTemporaryObject(globalDrawerComponent, tc)
        KanteStyle.kind = KanteStyle.Kind.Kante
        host.drawer.open()
        let locked = null
        tryVerify(function() {
            locked = find(host.drawer.contentItem, function(it) { return it instanceof T.AbstractButton && it.tAction && it.tAction.text === "locked" })
            return locked !== null
        })
        tryCompare(locked.Kirigami.Theme, "backgroundColor", KanteStyle.dialogColor)
        compare(locked.Kirigami.Theme.textColor, KanteStyle.disabledTextColor)
        tryCompare(host.drawer.background, "color", KanteStyle.dialogColor)
    }

    // ── 2. Focus trap ───────────────────────────────────────────────────

    Component {
        id: trapComponent
        Item {
            id: page
            width: 640
            height: 480
            property alias before: before
            property alias after: after
            property alias sheet: sheet
            property alias first: first
            property alias last: last
            property alias trap: trap
            property alias content: content
            property alias play: play

            Column {
                id: content
                // The app's own binding: the trap must hand it back.
                enabled: true
                QQC2.Button { id: before; text: "before" }
                QQC2.Button { id: play; text: "play" }
            }
            Item {
                id: sheet
                y: 100
                width: 300
                height: 200
                visible: false
                QQC2.Button { id: first; text: "close" }
                QQC2.Button { id: last; y: 60; text: "last" }
            }
            QQC2.Button {
                id: after
                y: 360
                text: "after"
                property int touched: 0
                onActiveFocusChanged: {
                    if (activeFocus) {
                        touched++
                    }
                }
            }
            KanteFocusTrap {
                id: trap
                area: sheet
                behind: [content]
                returnTo: play
            }
        }
    }

    function test_trapFocusOnOpen() {
        const page = createTemporaryObject(trapComponent, tc)
        page.sheet.visible = true
        tryVerify(function() { return page.first.activeFocus })
        verify(page.trap.trapped)
    }

    function test_trapTabWraps() {
        const page = createTemporaryObject(trapComponent, tc)
        page.sheet.visible = true
        tryVerify(function() { return page.first.activeFocus })
        keyClick(Qt.Key_Tab)
        verify(page.last.activeFocus, "focus on " + page.Window.activeFocusItem)
        keyClick(Qt.Key_Tab)
        verify(page.first.activeFocus, "focus on " + page.Window.activeFocusItem)
        compare(page.after.touched, 0)
        keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
        verify(page.last.activeFocus, "focus on " + page.Window.activeFocusItem)
    }

    // The page behind takes no focus and no click while the sheet is open, and gets its
    // own binding back after.
    function test_trapBehind() {
        const page = createTemporaryObject(trapComponent, tc)
        page.sheet.visible = true
        tryCompare(page.content, "enabled", false)
        page.sheet.visible = false
        tryCompare(page.content, "enabled", true)
        compare(page.trap.trapped, false)
    }

    function test_trapHideBehind() {
        const page = createTemporaryObject(trapComponent, tc)
        page.trap.behindMode = KanteFocusTrap.Behind.Hide
        page.sheet.visible = true
        tryCompare(page.content, "visible", false)
        compare(page.content.enabled, true)
        page.sheet.visible = false
        tryCompare(page.content, "visible", true)
    }

    // Closed: the focus goes where the app said, and Tab leaves the area again.
    function test_trapReturn() {
        const page = createTemporaryObject(trapComponent, tc)
        page.sheet.visible = true
        tryVerify(function() { return page.first.activeFocus })
        keyClick(Qt.Key_Tab)
        page.sheet.visible = false
        tryVerify(function() { return page.play.activeFocus }, 1000, "focus on " + page.Window.activeFocusItem)
        compare(page.last.KeyNavigation.tab, null)
        compare(page.first.KeyNavigation.backtab, null)
    }

    // ── 3. Callout with a title only ────────────────────────────────────

    Component { id: calloutComponent; KanteCallout { width: 320 } }
    Component { id: lineComponent; Text { text: "x"; font: KanteStyle.defaultFont } }

    function test_calloutTitleOnly() {
        const both = createTemporaryObject(calloutComponent, tc, { title: "Titel", text: "Text" })
        const titleOnly = createTemporaryObject(calloutComponent, tc, { title: "Titel" })
        const line = createTemporaryObject(lineComponent, tc)
        // One line of text and the column's spacing less, not the same height.
        compare(both.implicitHeight - titleOnly.implicitHeight, line.implicitHeight + 2)
    }

    // ── 4. String colours on a light ground ─────────────────────────────

    // Machado et al. 2009, deuteranopia (severity 1), on linear RGB.
    function lin(v) { return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4) }
    function deutan(c) {
        const r = lin(c.r), g = lin(c.g), b = lin(c.b)
        return [0.367322 * r + 0.860646 * g - 0.227968 * b,
                0.280085 * r + 0.672501 * g + 0.047413 * b,
                -0.011820 * r + 0.042940 * g + 0.968881 * b].map(function(v) { return Math.max(0, Math.min(1, v)) })
    }
    // CIELAB (D65) of linear RGB.
    function lab(l) {
        const f = function(t) { return t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116 }
        const x = (0.4124 * l[0] + 0.3576 * l[1] + 0.1805 * l[2]) / 0.95047
        const y = 0.2126 * l[0] + 0.7152 * l[1] + 0.0722 * l[2]
        const z = (0.0193 * l[0] + 0.1192 * l[1] + 0.9505 * l[2]) / 1.08883
        return [116 * f(y) - 16, 500 * (f(x) - f(y)), 200 * (f(y) - f(z))]
    }
    function distance(a, b) {
        const p = lab(a), q = lab(b)
        return Math.hypot(p[0] - q[0], p[1] - q[1], p[2] - q[2])
    }

    function test_stringsKanteLight_data() {
        return [{ tag: "Kante Light", kind: KanteStyle.Kind.KanteLight }, { tag: "Leinen", kind: KanteStyle.Kind.Kante }]
    }
    // Lines need 3:1, the fret digits drawn in the string colour 4.5:1 (P4 at the beamer:
    // the A string was 1.7:1). Apart from each other also under deuteranopia (P7).
    function test_stringsKanteLight(row) {
        KanteStyle.kind = row.kind
        verify(KanteStyle.light, "the test platform is light")
        const bg = KanteStyle.backgroundColor
        for (let s = 0; s < 6; s++) {
            const c = KanteStyle.stringColor(s, "kante")
            verify(KanteStyle.contrastOf(c, Qt.rgba(bg.r, bg.g, bg.b, 1)) >= 4.5, "string " + s + " " + c + " on " + bg)
        }
        // The four strings of a bass: well apart, as seen and with deuteranopia.
        for (let i = 0; i < 4; i++) {
            for (let j = i + 1; j < 4; j++) {
                const a = KanteStyle.stringColor(i, "kante"), b = KanteStyle.stringColor(j, "kante")
                const seen = distance([lin(a.r), lin(a.g), lin(a.b)], [lin(b.r), lin(b.g), lin(b.b)])
                const deut = distance(deutan(a), deutan(b))
                verify(seen >= 25, "strings " + i + "/" + j + " " + seen.toFixed(1))
                verify(deut >= 20, "strings " + i + "/" + j + " with deuteranopia " + deut.toFixed(1))
            }
        }
    }

    Component { id: tabStaffComponent; KanteTabStaff { width: 600; barsPerSystem: 2 } }

    // The tab's string lines are what the A string was measured on (1.7:1): 3:1 on a light ground.
    function test_tabLinesKanteLight_data() {
        return [{ tag: "Kante Light", kind: KanteStyle.Kind.KanteLight }, { tag: "Leinen", kind: KanteStyle.Kind.Kante }]
    }
    function test_tabLinesKanteLight(row) {
        KanteStyle.kind = row.kind
        const staff = createTemporaryObject(tabStaffComponent, tc, {
            notes: [{ time: 0, duration: 0.5, beats: 1, string: 0, fret: 3 }, { time: 1, duration: 0.5, beats: 1, string: 3, fret: 2 }],
            bars: [{ time: 0 }, { time: 2 }]
        })
        const bg = KanteStyle.backgroundColor
        const ground = Qt.rgba(bg.r, bg.g, bg.b, 1)
        let lines = 0
        const walk = function(item) {
            for (let i = 0; i < item.children.length; i++) {
                const c = item.children[i]
                if (c.modelData && c.modelData.kind === "line") {
                    const a = c.opacity * c.color.a
                    const seen = Qt.rgba(a * c.color.r + (1 - a) * ground.r, a * c.color.g + (1 - a) * ground.g,
                                         a * c.color.b + (1 - a) * ground.b, 1)
                    verify(KanteStyle.contrastOf(seen, ground) >= 3, "string " + c.modelData.str + " line " + seen)
                    lines++
                }
                walk(c)
            }
        }
        walk(staff)
        verify(lines >= 4)
    }

    // Dark Kante keeps its string colours.
    function test_stringsDarkUnchanged() {
        KanteStyle.preferDark = true
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(KanteStyle.stringColor(0, "kante"), KanteStyle.tagColor)
        compare(KanteStyle.stringColor(1, "kante"), KanteStyle.focusColor)
        compare(KanteStyle.stringColor(2, "kante"), KanteStyle.accentTextColor)
        compare(KanteStyle.stringColor(3, "kante"), KanteStyle.strongTextColor)
        KanteStyle.preferDark = false
    }

    // ── 6. A list row with a focusable trailing control ─────────────────

    Component {
        id: rowsComponent
        Column {
            width: 400
            property alias before: before
            property alias first: first
            property alias tip: tip
            property alias second: second
            KanteButton { id: before; text: "before" }
            KanteListRow {
                id: first
                width: parent.width
                text: "first"
                trailing: Row { KanteInfoTip { id: tip; term: "Beat"; info: "Schlag" } }
            }
            KanteListRow { id: second; width: parent.width; text: "second" }
        }
    }

    // Kontra's exercise list (QA 28.10. B5, P7): once the "?" had the focus, the row (a focus
    // scope) handed Tab straight on to it, and Shift+Tab passed over the row.
    function test_rowTrailingFocus() {
        const rows = createTemporaryObject(rowsComponent, tc)
        const focused = function() { return rows.Window.activeFocusItem }
        rows.before.forceActiveFocus(Qt.TabFocusReason)
        keyClick(Qt.Key_Tab)
        verify(focused() === rows.first, "row first, focus on " + focused())
        keyClick(Qt.Key_Tab)
        verify(focused() === rows.tip, "the ?, focus on " + focused())
        keyClick(Qt.Key_Tab)
        verify(focused() === rows.second, "row second, focus on " + focused())

        keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
        verify(focused() === rows.tip, "the ? again, focus on " + focused())
        keyClick(Qt.Key_Backtab, Qt.ShiftModifier)
        verify(focused() === rows.first, "its row by Shift+Tab, focus on " + focused())

        // The next round still stops at the row, not at the "?" that had the focus.
        rows.before.forceActiveFocus(Qt.TabFocusReason)
        keyClick(Qt.Key_Tab)
        verify(focused() === rows.first, "row first again, focus on " + focused())
    }

    // ── 5. Histogram bars for screen readers ────────────────────────────

    Component {
        id: histComponent
        KanteTimingHistogram {
            width: 420
            height: 200
            counts: [0, 3, 1]
            firstBinMs: -20
            binMs: 10
        }
    }
    function test_histogramBarNames() {
        const hist = createTemporaryObject(histComponent, tc)
        const names = []
        const walk = function(item) {
            for (let i = 0; i < item.children.length; i++) {
                const c = item.children[i]
                if (c.objectName === "kanteHistogramBar") {
                    names.push(c.Accessible.name)
                }
                walk(c)
            }
        }
        walk(hist)
        compare(names, ["−20 bis −10 ms: 0 Noten", "−10 bis 0 ms: 3 Noten", "0 bis +10 ms: 1 Noten"])

        // App-translated words.
        hist.binText = "%1 to %2 %3: %4"
        hist.countText = "%1 notes"
        names.length = 0
        walk(hist)
        compare(names[1], "−10 to 0 ms: 3 notes")
    }
}
