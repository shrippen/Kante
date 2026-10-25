import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.43, the parts lmix was missing (QA of its Mix page, 25.10.2026): split handle,
 * keycap, menu item with value and shortcut, menu section, popover, swatch picker, table
 * header, option tile, toast action; and sheet and message skins that keep the platform
 * background (they hid it like the popup skin before 1.42).
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante143"
    width: 600
    height: 500
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    // --- Split handle

    Component {
        id: splitComponent
        KanteSplitHandle {
            width: 300
            from: 100
            to: 400
            defaultValue: 250
            value: 200
            onMoved: (v) => value = v
        }
    }

    function test_splitHandleDrag() {
        const h = createTemporaryObject(splitComponent, stage())
        mouseDrag(h, h.width / 2, h.height / 2, 0, 60)
        tryCompare(h, "value", 260, 1000)
        // limits hold
        mouseDrag(h, h.width / 2, h.height / 2, 0, 500)
        tryCompare(h, "value", 400, 1000)
    }

    function test_splitHandleInverted() {
        const h = createTemporaryObject(splitComponent, stage(), { orientation: Qt.Horizontal, inverted: true, width: 12, height: 300 })
        mouseDrag(h, h.width / 2, h.height / 2, -50, 0)
        tryCompare(h, "value", 250, 1000)
    }

    function test_splitHandleKeys() {
        const h = createTemporaryObject(splitComponent, stage(), { step: 10 })
        h.forceActiveFocus()
        keyClick(Qt.Key_Down)
        compare(h.value, 210)
        keyClick(Qt.Key_Up)
        keyClick(Qt.Key_Up)
        compare(h.value, 190)
        keyClick(Qt.Key_End)
        compare(h.value, 400)
        keyClick(Qt.Key_Home)
        compare(h.value, 100)
        keyClick(Qt.Key_Delete)
        compare(h.value, 250)
    }

    function test_splitHandleTellsItsValue() {
        const h = createTemporaryObject(splitComponent, stage())
        compare(h.Accessible.description, "200 px")
        h.forceActiveFocus()
        keyClick(Qt.Key_Down)
        compare(h.Accessible.description, "216 px")
    }

    function test_splitHandleDoubleClickResets() {
        const h = createTemporaryObject(splitComponent, stage())
        mouseDoubleClickSequence(h, h.width / 2, h.height / 2)
        tryCompare(h, "value", 250, 1000)
    }

    // --- Keycap

    function test_keycap() {
        const cap = createTemporaryQmlObject('import Kante; KanteKeycap { text: "Ctrl+S" }', tc)
        verify(cap.implicitWidth > 20)
        compare(cap.Accessible.name, "Ctrl+S")
    }

    // --- Menu item and section

    Component {
        id: menuComponent
        Item {
            property alias menu: menu
            property alias valued: valued
            property alias keyed: keyed
            property alias section: section
            QQC2.Menu {
                id: menu
                KanteMenuSection { id: section; text: "Show"; rule: false }
                KanteMenuItem { id: keyed; text: "Save"; icon.name: "document-save"; shortcutText: "Ctrl+S" }
                KanteMenuItem { id: valued; text: "When the signal is lost"; valueText: "Hold last frame" }
                KanteMenuSection { text: "Settings" }
                KanteMenuItem { text: "Factory settings"; destructive: true }
            }
            KantePopupSkin { popup: menu }
        }
    }

    function findKeycap(item) {
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (c.hasOwnProperty("text") && c.toString().indexOf("KanteKeycap") === 0) {
                return c
            }
            const f = findKeycap(c)
            if (f) {
                return f
            }
        }
        return null
    }

    function test_menuItemShowsValueAndKeycap() {
        const o = createTemporaryObject(menuComponent, stage())
        o.menu.open()
        tryVerify(() => o.menu.opened)
        const cap = findKeycap(o.keyed.contentItem)
        verify(cap, "a keycap in Kante")
        verify(cap.visible)
        compare(cap.text, "Ctrl+S")
        compare(o.valued.Accessible.description, "Hold last frame")
        // the value is not cut off: the menu is wide enough for text and value
        verify(o.menu.width >= o.valued.implicitWidth, o.menu.width + " < " + o.valued.implicitWidth)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(!cap.visible, "System shows plain text")
    }

    function test_menuItemInkOnHighlight() {
        const o = createTemporaryObject(menuComponent, stage())
        o.menu.open()
        tryVerify(() => o.menu.opened)
        verify(!Qt.colorEqual(o.keyed.ink, o.keyed.Kirigami.Theme.highlightedTextColor))
        // keyboard or hover highlight: the highlight's ink, not the plain text colour
        keyClick(Qt.Key_Down)
        verify(o.keyed.highlighted)
        verify(Qt.colorEqual(o.keyed.ink, o.keyed.Kirigami.Theme.highlightedTextColor), "ink on the highlight")
        // the value too
        verify(Qt.colorEqual(o.valued.valueLabel.color, KanteStyle.mutedTextColor))
        keyClick(Qt.Key_Down)
        verify(o.valued.highlighted)
        verify(Qt.colorEqual(o.valued.valueLabel.color, o.valued.ink), "the value in the highlight's ink")
    }

    function test_menuSectionIsSkipped() {
        const o = createTemporaryObject(menuComponent, stage())
        o.menu.open()
        tryVerify(() => o.menu.opened)
        // keyboard: Down goes to the first item, past the section
        keyClick(Qt.Key_Down)
        compare(o.menu.currentIndex, 1)
        keyClick(Qt.Key_Down)
        compare(o.menu.currentIndex, 2)
        keyClick(Qt.Key_Down)
        compare(o.menu.currentIndex, 4, "the second section is skipped too")
        compare(o.section.Accessible.role, Accessible.Heading)
    }

    // --- Popover

    Component {
        id: popoverComponent
        Item {
            anchors.fill: parent
            property alias popover: popover
            property alias button: button
            property alias toggle: toggle
            QQC2.Button { id: button; text: "View"; x: parent.width - width - 4; y: parent.height - height - 4 }
            KantePopover {
                id: popover
                title: "View"
                KanteSwitch { id: toggle; text: "Audio at the edge" }
            }
        }
    }

    function test_popoverOpensInsideWindowAndCloses() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.openAt(o.button)
        tryVerify(() => o.popover.opened)
        // the button sits at the bottom right: the popover opens above it and stays inside
        const card = o.popover.background.mapToItem(null, 0, 0)
        const button = o.button.mapToItem(null, 0, 0)
        verify(card.y + o.popover.height <= button.y + 1, "above the button: " + card.y + " + " + o.popover.height + " > " + button.y)
        verify(card.x >= 0, "inside the window: " + card.x)
        verify(card.x + o.popover.width <= stage().width + 1, "inside the window: " + (card.x + o.popover.width))
        verify(o.toggle.visible)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverIsAsWideAsALongTitle() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.popover.title = "A title much longer than the switch below it"
        o.popover.openAt(o.button)
        tryVerify(() => o.popover.opened)
        const label = o.popover.contentItem.children[0]
        verify(o.popover.availableWidth >= label.implicitWidth - 1,
               "room for the title: " + o.popover.availableWidth + " < " + label.implicitWidth)
        keyClick(Qt.Key_Escape)
        tryVerify(() => !o.popover.visible)
    }

    function test_popoverButtonClosesIt() {
        const o = createTemporaryObject(popoverComponent, stage())
        o.button.clicked.connect(() => o.popover.openAt(o.button))
        mouseClick(o.button)
        tryVerify(() => o.popover.opened)
        // a press on its button closes it; the click must not open it again
        mouseClick(o.button)
        tryVerify(() => !o.popover.visible)
        wait(50)
        verify(!o.popover.visible)
    }

    // --- Swatch picker

    Component {
        id: swatchComponent
        KanteSwatchPicker {
            colors: ["#9d0006", "#3a6e4e", "#0f6b66"]
            names: ["Red", "Green", "Teal"]
            noneText: "None"
            currentIndex: 1
            onPicked: (i) => currentIndex = i
        }
    }

    function test_swatchPickerClickAndKeys() {
        const p = createTemporaryObject(swatchComponent, stage())
        compare(p.count, 4)
        compare(p.focusIndex, 2, "declared with none: the frame on the chosen colour")
        // click the third swatch (index 2 of the colours, cell 3 with "none" first)
        const cellW = p.width / 4
        mouseClick(p, cellW * 3.5, p.height / 2)
        compare(p.currentIndex, 2)
        p.forceActiveFocus()
        keyClick(Qt.Key_Left)
        keyClick(Qt.Key_Left)
        keyClick(Qt.Key_Left)
        keyClick(Qt.Key_Space)
        compare(p.currentIndex, -1, "none")
        // the app chooses another colour: the keyboard frame follows, Space keeps it
        p.currentIndex = 1
        keyClick(Qt.Key_Space)
        compare(p.currentIndex, 1)
        // fewer colours: the frame stays on a cell that is there
        p.focusIndex = 3
        p.colors = ["#9d0006"]
        compare(p.focusIndex, 1)
        // "none" from the start: the frame starts on the chosen colour
        const q = createTemporaryObject(swatchComponent, stage(), { noneText: "None", currentIndex: 2 })
        compare(q.focusIndex, 3)
        // "none" taken away and back: the frame stays on the same colour
        p.colors = ["#9d0006", "#3a6e4e", "#0f6b66"]
        p.focusIndex = 3
        p.noneText = ""
        compare(p.focusIndex, 2)
        p.noneText = "None"
        compare(p.focusIndex, 3)
    }

    // --- Table header

    function test_tableHeaderColumns() {
        const h = createTemporaryQmlObject('import Kante; KanteTableHeader { width: 400; spacing: 10; columns: [{ title: "", width: 16 }, { title: "Target", width: 0 }, { title: "Format", width: 90 }, { title: "State", width: 70, align: 2 }] }', tc)
        compare(h.columnX(0), 0)
        compare(h.columnWidth(0), 16)
        compare(h.columnX(1), 26)
        compare(h.columnWidth(1), 400 - 16 - 90 - 70 - 30)
        compare(h.columnX(3) + h.columnWidth(3), 400)
    }

    // --- Option tile

    Component {
        id: tilesComponent
        Row {
            property alias a: a
            property alias b: b
            KanteOptionTile { id: a; text: "Camera"; hint: "Capture, webcam"; icon.name: "camera-web"; checked: true }
            KanteOptionTile { id: b; text: "Video"; hint: "File" }
        }
    }

    function test_optionTilesExclusive() {
        const r = createTemporaryObject(tilesComponent, stage())
        verify(r.a.checked)
        mouseClick(r.b)
        verify(r.b.checked)
        verify(!r.a.checked)
        compare(r.b.Accessible.role, Accessible.RadioButton)
        compare(r.b.Accessible.description, "File")
    }

    function test_optionTileFocusRingWhenChosen() {
        const r = createTemporaryObject(tilesComponent, stage())
        r.a.forceActiveFocus(Qt.TabFocusReason)
        verify(r.a.visualFocus)
        verify(r.a.checked)
        let ring = null
        for (let i = 0; i < r.a.background.children.length; i++) {
            const c = r.a.background.children[i]
            if (c.lineWidth === 1 && c.visible) {
                ring = c
            }
        }
        verify(ring, "a focus ring on the chosen tile")
        compare(ring.inset, 4, "inside the selection frame")
    }

    function test_optionTileOutlineSquareWithoutCut() {
        // System: no cut corner, the ring is a plain rectangle (no loop in the corner)
        KanteStyle.kind = KanteStyle.Kind.System
        const r = createTemporaryObject(tilesComponent, stage())
        let ring = null
        for (let i = 0; i < r.a.background.children.length; i++) {
            const c = r.a.background.children[i]
            if (c.lineWidth === 1) {
                ring = c
            }
        }
        verify(ring)
        compare(ring.c, 0)
        compare(ring.e, 0)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(ring.c > 0, "the card's cut corner reaches the outline")
        verify(ring.e > 0)
    }

    // --- Toast action

    Component {
        id: toastComponent
        KanteToast {
            width: 400
            text: "Input 3 removed"
            actionText: "Undo"
            actionShortcut: "Ctrl+Z"
            life: 0
        }
    }

    function test_toastAction() {
        const t = createTemporaryObject(toastComponent, stage())
        const spy = createTemporaryObject(spyComponent, stage(), { target: t, signalName: "actionTriggered" })
        t.show()
        tryVerify(() => t.shown)
        let found = null
        function walk(item) {
            for (let i = 0; i < item.children.length; i++) {
                const c = item.children[i]
                if (c.text === "Undo" && c.clicked !== undefined) {
                    found = c
                    return
                }
                walk(c)
            }
        }
        walk(t)
        verify(found, "an Undo button")
        mouseClick(found)
        compare(spy.count, 1)
        verify(!t.shown)
    }

    function test_toastFocusedActionDoesNotHoldTheNextShow() {
        const t = createTemporaryObject(toastComponent, stage(), { life: 1200 })
        t.show()
        wait(400)
        let button = null
        function walk(item) {
            for (let i = 0; i < item.children.length; i++) {
                const c = item.children[i]
                if (c.text === "Undo" && c.clicked !== undefined) {
                    button = c
                    return
                }
                walk(c)
            }
        }
        walk(t)
        verify(button, "an Undo button")
        button.forceActiveFocus(Qt.TabFocusReason)
        tryVerify(() => t.held, 1000, "held with the action focused")
        // the app hides it (its own Ctrl+Z), later a new message
        t.hide()
        wait(450)
        t.show()
        verify(!t.held, "the button did not take the focus back")
        tryVerify(() => !t.shown, 3000)
    }

    function test_toastHiddenByShownDropsTheFocus() {
        // as above, but the app sets shown itself instead of calling hide()
        const t = createTemporaryObject(toastComponent, stage(), { life: 1200 })
        t.show()
        wait(400)
        let button = null
        function walk(item) {
            for (let i = 0; i < item.children.length; i++) {
                const c = item.children[i]
                if (c.text === "Undo" && c.clicked !== undefined) {
                    button = c
                    return
                }
                walk(c)
            }
        }
        walk(t)
        verify(button, "an Undo button")
        button.forceActiveFocus(Qt.TabFocusReason)
        tryVerify(() => t.held, 1000, "held with the action focused")
        t.shown = false
        wait(450)
        t.show()
        verify(!t.held, "the button did not take the focus back")
        tryVerify(() => !t.shown, 3000)
    }

    function test_toastStaysUnderThePointer() {
        const t = createTemporaryObject(toastComponent, stage(), { life: 800 })
        t.show()
        wait(450) // slid in
        mouseMove(t, 10, 10)
        wait(900)
        verify(t.shown, "held under the pointer")
        mouseMove(stage(), stage().width - 2, stage().height - 2)
        tryVerify(() => !t.shown, 2000)
    }

    function test_toastShownUnderThePointerWaits() {
        const t = createTemporaryObject(toastComponent, stage(), { life: 300 })
        t.show()
        wait(450)
        mouseMove(t, 10, 10)
        tryVerify(() => t.held)
        // a new message while the pointer is on it: it stays until let go
        t.text = "Input 4 removed"
        t.show()
        wait(700)
        verify(t.shown, "waits under the pointer")
        mouseMove(stage(), stage().width - 2, stage().height - 2)
        tryVerify(() => !t.shown, 2000)
    }

    Component { id: spyComponent; SignalSpy {} }

    // --- Dialog accept button

    Component {
        id: dialogComponent
        KanteDialog {
            title: "Add input"
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            acceptText: "Add input"
            acceptEnabled: false
        }
    }

    Component {
        id: ownBindingDialog
        KanteDialog {
            id: own
            property bool complete: false
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            Component.onCompleted: standardButton(QQC2.Dialog.Ok).enabled = Qt.binding(() => own.complete)
        }
    }

    function test_dialogKeepsTheAppsOwnBinding() {
        // lmix binds the button itself and never sets acceptEnabled: its binding stays
        KanteStyle.kind = KanteStyle.Kind.System
        const d = createTemporaryObject(ownBindingDialog, stage())
        d.open()
        tryVerify(() => d.opened)
        wait(50)
        verify(!d.standardButton(QQC2.Dialog.Ok).enabled, "still locked")
        d.complete = true
        verify(d.standardButton(QQC2.Dialog.Ok).enabled, "the binding follows")
    }

    function test_dialogAcceptTextBackToStandard() {
        KanteStyle.kind = KanteStyle.Kind.System
        const d = createTemporaryObject(dialogComponent, stage())
        d.open()
        tryVerify(() => d.opened)
        tryCompare(d.acceptButton(), "text", "Add input")
        d.acceptText = ""
        verify(d.acceptButton().text !== "Add input", "the standard text again: " + d.acceptButton().text)
    }

    function test_dialogAcceptEnabledUnsetFreesTheButton() {
        KanteStyle.kind = KanteStyle.Kind.System
        const d = createTemporaryObject(dialogComponent, stage())
        d.open()
        tryVerify(() => d.opened)
        tryVerify(() => !d.acceptButton().enabled, 1000, "locked")
        d.acceptEnabled = undefined
        verify(d.acceptButton().enabled, "free again once unset")
    }

    function test_dialogAcceptEnabledUnsetFreesEveryFooter() {
        // locked in Kante, then System: unset there, back in Kante the button is free too
        KanteStyle.kind = KanteStyle.Kind.Kante
        const d = createTemporaryObject(dialogComponent, stage())
        d.open()
        tryVerify(() => d.opened)
        tryVerify(() => !d.acceptButton().enabled, 1000, "locked in Kante")
        KanteStyle.kind = KanteStyle.Kind.System
        tryVerify(() => !d.acceptButton().enabled, 1000, "locked in System")
        d.acceptEnabled = undefined
        verify(d.acceptButton().enabled, "free in System")
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryVerify(() => d.acceptButton().enabled, 1000, "free again in Kante")
    }

    function test_dialogAcceptButtonNamedAndLocked() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const d = createTemporaryObject(dialogComponent, stage())
        d.open()
        tryVerify(() => d.opened)
        tryCompare(d.acceptButton(), "text", "Add input")
        verify(!d.acceptButton().enabled, "check 1")
        // another style, another footer: the same name and lock
        KanteStyle.kind = KanteStyle.Kind.System
        tryCompare(d.acceptButton(), "text", "Add input")
        tryVerify(() => !d.acceptButton().enabled, 1000, "check 2")
        d.acceptEnabled = true
        verify(d.acceptButton().enabled, "check 3")
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryCompare(d.acceptButton(), "text", "Add input")
        tryVerify(() => d.acceptButton().enabled, 1000, "check 4")
    }

    // --- Sheet and message skins keep the platform background

    Component {
        id: sheetComponent
        Item {
            property alias popup: sheet
            property alias skin: skin
            QQC2.Popup {
                id: sheet
                width: 200
                height: 120
                contentItem: Text { text: "Sheet" }
            }
            KanteSheetSkin { id: skin; popup: sheet }
        }
    }

    function test_sheetSkinRestoresPlatformBackground() {
        KanteStyle.kind = KanteStyle.Kind.System
        const o = createTemporaryObject(sheetComponent, stage())
        const platform = o.popup.background
        verify(platform)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(o.popup.background, platform, "not replaced")
        compare(platform.opacity, 0)
        o.popup.open()
        tryVerify(() => o.popup.opened)
        verify(o.skin.kanteBackground.visible)
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        compare(platform.opacity, 1)
        verify(platform.visible)
        verify(!o.skin.kanteBackground.visible)
        compare(platform.width, o.popup.width)
    }

    Component {
        id: messageComponent
        Kirigami.InlineMessage {
            id: message
            width: 300
            visible: true
            text: "Recording runs"
            property alias skin: skin
            KanteMessageSkin { id: skin; message: message }
        }
    }

    function test_messageSkinRestoresPlatformBackground() {
        KanteStyle.kind = KanteStyle.Kind.System
        const m = createTemporaryObject(messageComponent, stage())
        const platform = m.background
        verify(platform)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(m.background, platform, "not replaced")
        verify(m.skin.kanteBackground.visible)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(platform.visible)
        compare(platform.opacity, 1)
        verify(!m.skin.kanteBackground.visible)
    }
}
