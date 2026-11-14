import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * Kante 1.81, for Klappe: KantePopover.openAtPoint and closeOnOutside, KanteCommandPalette.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante181"
    width: 600
    height: 500
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    // --- Popover at a point

    Component {
        id: popoverComponent
        Item {
            anchors.fill: parent
            property alias popover: popover
            property alias plan: plan
            property alias other: other
            Item { id: plan; x: 0; y: 0; width: parent.width; height: parent.height }
            Item { id: other; x: 10; y: 10; width: 30; height: 30 }
            KantePopover {
                id: popover
                title: "Figur"
                KanteSwitch { text: "Sichtbar" }
            }
        }
    }

    // The card's top left corner in the window.
    function cardAt(o) {
        return o.popover.background.mapToItem(null, 0, 0)
    }

    function test_popoverPointRight() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.x >= 100 + o.popover.pointerLength, "clear of the point: " + card.x)
        compare(o.popover.pointerSide, "left")
        verify(o.popover.pointer.visible)
        // Top near the point, the pointer's tip level with it.
        verify(card.y <= 120 && card.y > 120 - o.popover.height, "beside the point: " + card.y)
        fuzzyCompare(card.y + o.popover.pointerY, 120, 1)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverPointLeftAtTheEdge() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(tc.width - 20, 120, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.x + o.popover.width <= tc.width - 20 - o.popover.pointerLength + 1, "left of the point: " + card.x)
        verify(card.x >= 0)
        compare(o.popover.pointerSide, "right")
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverPointKeptInWindow() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, tc.height - 5, o.plan)
        tryVerify(() => o.popover.opened)
        const card = cardAt(o)
        verify(card.y >= 0, "inside the window: " + card.y)
        verify(card.y + o.popover.height <= tc.height + 1, "inside the window: " + (card.y + o.popover.height))
        // The pointer stays on the card.
        verify(o.popover.pointerY > 0 && o.popover.pointerY < o.popover.height)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverOpenAtHasNoPointer() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        o.popover.close()
        tryVerify(() => !o.popover.visible)
        o.popover.openAt(o.other)
        tryVerify(() => o.popover.opened)
        compare(o.popover.pointerSide, "")
        verify(!o.popover.pointer.visible)
        o.popover.close()
    }

    function test_popoverOutsideClick() {
        const o = createTemporaryObject(popoverComponent, stage())
        compare(o.popover.closeOnOutside, true)
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        mouseClick(stage(), 500, 400)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverStaysOpenOutside() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.closeOnOutside = false
        o.popover.openAtPoint(100, 120, o.plan)
        tryVerify(() => o.popover.opened)
        mouseClick(stage(), 500, 400)
        wait(100)
        verify(o.popover.visible, "a press outside leaves it open")
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    // --- Command palette

    SignalSpy { id: spy }

    Component {
        id: paletteComponent
        KanteCommandPalette {
            commands: [
                { id: "save", text: "Speichern", group: "Datei", keys: "Strg+S" },
                { id: "open", text: "Öffnen", group: "Datei", keys: ["Strg", "O"] },
                { id: "zoom", text: "Zoom einpassen", group: "Ansicht", keys: "0" },
                { id: "grid", text: "Raster zeigen", group: "Ansicht", enabled: false },
                { id: "wall", text: "Wand zeichnen", group: "Datei" },
                { id: "help", text: "Hilfe" }
            ]
        }
    }

    // keyClick takes one key; type a text letter by letter.
    function type(text) {
        for (const ch of text) {
            keyClick(ch)
        }
    }

    function ids(p) {
        return p.entries.map(c => c.id)
    }

    function openPalette() {
        const p = createTemporaryObject(paletteComponent, stage())
        p.open()
        tryVerify(() => p.opened)
        return p
    }

    function test_paletteListsAllGrouped() {
        const p = openPalette()
        // No group first, then the groups as they first appear; stable within.
        compare(ids(p), ["help", "save", "open", "wall", "zoom", "grid"])
        compare(p.rows.filter(r => r.header).map(r => r.text), ["Datei", "Ansicht"])
        // The first enabled entry is the current one.
        compare(p.current, 0)
        p.close()
    }

    function test_paletteFilter() {
        const p = openPalette()
        type("W")
        compare(ids(p), ["wall"], "part of a word, any case")
        compare(p.current, 0)
        p.close()
    }

    function test_paletteFilterByGroupAndWords() {
        const p = openPalette()
        type("ansicht")
        compare(ids(p), ["zoom", "grid"], "the group is searched")
        keyClick(Qt.Key_Space)
        type("EIN")
        compare(ids(p), ["zoom"], "every word must match")
        p.close()
    }

    function test_paletteNoMatch() {
        const p = openPalette()
        type("xyz")
        compare(p.entries.length, 0)
        compare(p.current, -1)
        spy.target = p
        spy.signalName = "triggered"
        spy.clear()
        keyClick(Qt.Key_Return)
        compare(spy.count, 0)
        verify(p.opened, "Enter with nothing to fire leaves it open")
        p.close()
    }

    function test_paletteArrowsSkipDisabled() {
        const p = openPalette()
        type("ansicht")
        compare(p.current, 0)
        keyClick(Qt.Key_Down)
        compare(p.current, 0, "grid is disabled: round to zoom")
        p.close()
    }

    function test_paletteArrowsMove() {
        const p = openPalette()
        compare(p.entries[p.current].id, "help")
        keyClick(Qt.Key_Down)
        compare(p.entries[p.current].id, "save")
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Down)
        compare(p.entries[p.current].id, "zoom")
        keyClick(Qt.Key_Down)
        compare(p.entries[p.current].id, "help", "round at the end, grid skipped")
        keyClick(Qt.Key_Up)
        compare(p.entries[p.current].id, "zoom")
        p.close()
    }

    function test_paletteEnterTriggers() {
        const p = openPalette()
        spy.target = p
        spy.signalName = "triggered"
        spy.clear()
        keyClick(Qt.Key_Down)
        keyClick(Qt.Key_Return)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "save")
        tryVerify(() => !p.visible)
    }

    function test_paletteDisabledDoesNotFire() {
        const p = openPalette()
        spy.target = p
        spy.signalName = "triggered"
        spy.clear()
        p.current = 5
        p.fire()
        compare(spy.count, 0)
        verify(p.opened)
        p.close()
    }

    function test_paletteEscapeCloses() {
        const p = openPalette()
        keyClick(Qt.Key_Escape)
        tryVerify(() => !p.visible)
    }

    function test_paletteClickFires() {
        const p = openPalette()
        spy.target = p
        spy.signalName = "triggered"
        spy.clear()
        // The row of "Öffnen": the list's items, found by their accessible name.
        const list = p.contentItem.children.find(c => c.positionViewAtIndex !== undefined)
        verify(list !== undefined, "the list")
        tryVerify(() => list.contentItem.children.length > list.count)
        let target = null
        for (const item of list.contentItem.children) {
            if (item.modelData && item.modelData.command && item.modelData.command.id === "open") {
                target = item
            }
        }
        verify(target !== null)
        mouseClick(target)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], "open")
    }

    function test_paletteKeycaps() {
        const p = openPalette()
        const list = p.contentItem.children.find(c => c.positionViewAtIndex !== undefined)
        tryVerify(() => list.contentItem.children.length > list.count)
        const rowOf = id => list.contentItem.children.find(c => c.modelData && c.modelData.command && c.modelData.command.id === id)
        compare(rowOf("save").keys, ["Strg+S"])
        compare(rowOf("open").keys, ["Strg", "O"])
        compare(rowOf("wall").keys, [])
        p.close()
    }

    function test_paletteOpensClean() {
        const p = openPalette()
        type("zoom")
        p.close()
        tryVerify(() => !p.visible)
        p.open()
        tryVerify(() => p.opened)
        compare(p.query, "")
        compare(p.entries.length, 6)
        p.close()
    }

    // --- Floating panel

    Component {
        id: panelComponent
        KanteFloatingPanel {
            x: 20
            y: 20
            title: "Werkzeuge"
            property alias tool: tool
            KanteButton { id: tool; text: "Wand" }
        }
    }

    function headOf(p) {
        return p.children.find(c => c.activeFocusOnTab === true)
    }

    function test_panelFoldsAndUnfolds() {
        const p = createTemporaryObject(panelComponent, stage())
        verify(!p.collapsed)
        verify(p.height > p.headerHeight, "open: head and content")
        const open = p.height
        p.collapsed = true
        compare(p.height, p.headerHeight, "folded: the head only")
        p.collapsed = false
        compare(p.height, open)
        p.toggle()
        verify(p.collapsed)
        p.toggle()
        verify(!p.collapsed)
    }

    function test_panelFoldedHidesContent() {
        const p = createTemporaryObject(panelComponent, stage())
        verify(p.tool.visible)
        p.collapsed = true
        verify(!p.tool.visible)
    }

    function test_panelKeyboard() {
        const p = createTemporaryObject(panelComponent, stage())
        const head = headOf(p)
        verify(head !== undefined, "the head takes Tab")
        head.forceActiveFocus()
        keyClick(Qt.Key_Space)
        verify(p.collapsed)
        keyClick(Qt.Key_Return)
        verify(!p.collapsed)
        keyClick(Qt.Key_Enter)
        verify(p.collapsed)
    }

    function test_panelClickHead() {
        const p = createTemporaryObject(panelComponent, stage())
        mouseClick(headOf(p))
        verify(p.collapsed)
        mouseClick(headOf(p))
        verify(!p.collapsed)
    }

    function test_panelGrowsWithContent() {
        const p = createTemporaryObject(panelComponent, stage())
        verify(p.width >= p.implicitWidth)
        verify(p.implicitWidth >= 2 * p.pad + 1)
    }
}
