import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.78, from Mitori on Android: Kirigami's global toolbar of an ApplicationWindow
 * (a page's bar, the page stack's bar) sets the Header colour set itself and so never took
 * the colours of a KanteScope on the window's contentItem: it showed the platform's. A
 * KanteWindowScope themes the bars too, in every bar style, on the first page and a pushed
 * one, and gives them back to the platform when Kante is switched off.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante178"
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    property bool darkBefore: false
    function init() {
        kindBefore = KanteStyle.kind
        darkBefore = KanteStyle.preferDark
        failOnWarning(/TypeError/)
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
        KanteStyle.preferDark = darkBefore
    }

    Component {
        id: windowComponent
        Kirigami.ApplicationWindow {
            id: win
            width: 800
            height: 600
            visible: true
            property Component second: Kirigami.Page {
                title: "Second"
            }
            KanteWindowScope { window: win }
            pageStack.initialPage: Kirigami.Page {
                title: "First"
            }
        }
    }

    // The bars are the items of the page stack with a ground of their own: each page's
    // ToolBarPageHeader and the stack's PageRowGlobalToolBarUI.
    function allItems(item) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            out.push(item.children[i])
            out = out.concat(allItems(item.children[i]))
        }
        return out
    }
    function findAll(item, pred) {
        return allItems(item).filter(pred)
    }
    function bars(win) {
        return allItems(win.pageStack).filter(c => c.visible && c.background
                                              && c.maximumHeight !== undefined && c.separatorVisible !== undefined)
    }

    function verifyBars(win, label) {
        tryVerify(() => bars(win).length > 0, 2000, label + ": no bar")
        tryVerify(() => bars(win).every(b => Qt.colorEqual(b.background.color, KanteStyle.backgroundColor)), 2000,
                  label + ": ground " + bars(win).map(b => b.background.color) + ", expected " + KanteStyle.backgroundColor)
        for (const b of bars(win)) {
            verify(Qt.colorEqual(b.Kirigami.Theme.textColor, KanteStyle.textColor),
                   label + ": text " + b.Kirigami.Theme.textColor + ", expected " + KanteStyle.textColor)
        }
    }

    function test_bars_data() {
        return [
            { tag: "ToolBar", style: Kirigami.ApplicationHeaderStyle.ToolBar },
            { tag: "Titles", style: Kirigami.ApplicationHeaderStyle.Titles },
            { tag: "Breadcrumb", style: Kirigami.ApplicationHeaderStyle.Breadcrumb }
        ]
    }

    function test_bars(data) {
        for (const dark of [true, false]) {
            KanteStyle.kind = KanteStyle.Kind.Kante
            KanteStyle.preferDark = dark
            const win = createTemporaryObject(windowComponent, tc)
            verify(win, "window")
            win.pageStack.globalToolBar.style = data.style
            verifyBars(win, data.tag + (dark ? " dark" : " Leinen") + " first page")
            win.pageStack.push(win.second)
            verifyBars(win, data.tag + (dark ? " dark" : " Leinen") + " pushed page")
            win.pageStack.pop()
            verifyBars(win, data.tag + (dark ? " dark" : " Leinen") + " popped")
            win.destroy()
        }
    }

    // The bar scopes only dress the bar itself: its children inherit its colours. A scope that
    // watched the bar's subtree (every item, enabled and children signals) made a change of
    // style slower by the number of bars and items (Mitori: +75 ms CPU in Debug).
    function test_bar_scopes_watch_nothing() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        const win = createTemporaryObject(windowComponent, tc)
        win.pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.ToolBar
        win.pageStack.push(win.second)
        verifyBars(win, "bars")
        const scopes = findAll(win.pageStack, c => c.objectName === "kanteBarScope")
        verify(scopes.length >= 2, "a scope on each bar: " + scopes.length)
        for (const scope of scopes) {
            compare(scope.watchedCount, 0, "items the scope of " + scope.target + " watches")
        }
    }

    // A bar that is disabled (the bar of the page below a pushed one, Mitori) has a colour table
    // of its own in the platform's colours: its ground still is Kante's.
    function test_disabled_bar() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = false
        const win = createTemporaryObject(windowComponent, tc)
        win.pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.ToolBar
        verifyBars(win, "bars")
        for (const bar of bars(win)) {
            bar.enabled = false
        }
        verifyBars(win, "disabled bars")
        for (const bar of bars(win)) {
            bar.enabled = true
        }
        verifyBars(win, "enabled again")
    }

    // A page on the layers (a modal page over the page row) has a bar of its own.
    function test_layers_bars_data() {
        return [
            { tag: "ToolBar", style: Kirigami.ApplicationHeaderStyle.ToolBar },
            { tag: "Titles", style: Kirigami.ApplicationHeaderStyle.Titles }
        ]
    }

    function test_layers_bars(data) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        const win = createTemporaryObject(windowComponent, tc)
        win.pageStack.globalToolBar.style = data.style
        verifyBars(win, data.tag + " before layer")
        win.pageStack.layers.push(win.second)
        tryCompare(win.pageStack.layers, "depth", 2)
        verifyBars(win, data.tag + " layer")
        win.pageStack.layers.pop()
        tryCompare(win.pageStack.layers, "depth", 1)
        verifyBars(win, data.tag + " layer popped")
        win.pageStack.layers.push(win.second)
        tryCompare(win.pageStack.layers, "depth", 2)
        verifyBars(win, data.tag + " layer again")
    }

    // Kante off: the bars show the platform's Header colours again, not the window's.
    function test_bars_back_to_platform() {
        KanteStyle.kind = KanteStyle.Kind.System
        const win = createTemporaryObject(windowComponent, tc)
        win.pageStack.globalToolBar.style = Kirigami.ApplicationHeaderStyle.ToolBar
        tryVerify(() => bars(win).length > 0, 2000)
        const header = createTemporaryObject(probeComponent, win.contentItem)
        const platform = header.Kirigami.Theme.backgroundColor
        tryVerify(() => bars(win).every(b => Qt.colorEqual(b.background.color, platform)), 2000, "System before")

        KanteStyle.kind = KanteStyle.Kind.Kante
        tryVerify(() => bars(win).every(b => Qt.colorEqual(b.background.color, KanteStyle.backgroundColor)), 2000, "Kante")
        KanteStyle.kind = KanteStyle.Kind.System
        tryVerify(() => bars(win).every(b => Qt.colorEqual(b.background.color, platform)), 2000,
                  "System after: " + bars(win).map(b => b.background.color) + ", expected " + platform)
    }

    // A new element is shown in the gallery.
    function test_gallery_shows_the_window_scope() {
        const component = Qt.createComponent(Qt.resolvedUrl("../demo/Gallery.qml"), Component.PreferSynchronous)
        tryVerify(() => component.status !== Component.Loading)
        compare(component.status, Component.Ready, component.errorString())
        const gallery = component.createObject(null)
        verify(gallery)
        verify(findChild(gallery, "galleryWindowBar"), "the window bar in the gallery")
        gallery.destroy()
    }

    Component {
        id: probeComponent
        Item {
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
        }
    }
}
