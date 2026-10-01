import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.10: the conversation message (web `.thread > .msg`). The other side sits left
 * with the info bar, your own messages sit right of an indent with the accent bar on the
 * right, a system line carries no surface; head items and children take room only when
 * there; it restores in System. The chip as a plain label, and its hover state for an own
 * tooltip. The compact bar chart (bar sparkline), stacked parts of a progress bar and the
 * section label. The dialog skin's title causes no binding loop. Run: kante/tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "Kante110"
    width: 500
    height: 400
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: messageComponent
        KanteMessage { width: 400 }
    }
    Component {
        id: withChildComponent
        KanteMessage {
            width: 400
            text: "Mit Anhang"
            Rectangle { implicitWidth: 40; implicitHeight: 30 }
        }
    }

    /** The surface (x offset), the bar and the text of a speech message. */
    function parts(m) {
        var surface = m.children[0]
        return { surface: surface, ground: surface.children[0], bar: surface.children[1] }
    }

    function test_other_left_with_info_bar() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var m = createTemporaryObject(messageComponent, stage(), { author: "KI", time: "09:12", text: "Hallo" })
        var p = parts(m)
        compare(p.surface.x, 0)
        compare(p.surface.width, m.width)
        compare(p.bar.x, 0)
        compare(p.bar.color, KanteStyle.infoColor)
        compare(p.ground.color, KanteStyle.cardColor)
        verify(m.implicitHeight > 0)
        compare(m.Accessible.name, "KI, 09:12: Hallo")
    }

    function test_own_right_with_accent_bar() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var m = createTemporaryObject(messageComponent, stage(), { from: KanteMessage.From.Own, author: "Du", text: "Ja" })
        var p = parts(m)
        compare(p.surface.x, m.ownIndent)
        compare(p.surface.width, m.width - m.ownIndent)
        compare(p.bar.x + p.bar.width, p.surface.width)
        compare(p.bar.color, KanteStyle.accentColor)
        compare(p.ground.color, KanteStyle.tint1Color)
        // A narrow message keeps three quarters for the text.
        m.width = 120
        compare(p.surface.x, 30)
    }

    function test_system_line_has_no_surface() {
        var m = createTemporaryObject(messageComponent, stage(), { from: KanteMessage.From.System, time: "09:15", text: "Neue Version" })
        verify(!m.children[0].visible)
        verify(m.children[1].visible)
        compare(m.implicitHeight, m.children[1].implicitHeight)
    }

    function test_child_takes_room() {
        var plain = createTemporaryObject(messageComponent, stage(), { text: "Mit Anhang" })
        var withChild = createTemporaryObject(withChildComponent, stage())
        verify(withChild.implicitHeight >= plain.implicitHeight + 30, withChild.implicitHeight + " vs " + plain.implicitHeight)
    }

    function test_system_kind_is_rounded_and_kante_square() {
        var m = createTemporaryObject(messageComponent, stage(), { text: "x" })
        verify(parts(m).ground.radius > 0, "System: platform-like rounded surface")
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(parts(m).ground.radius, 0)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(parts(m).ground.radius > 0, "switching back restores")
    }

    Component {
        id: chipComponent
        KanteChip { text: "Änderung 2" }
    }

    function test_chip_label_takes_no_input() {
        var c = createTemporaryObject(chipComponent, stage(), { interactive: false })
        var clicked = 0
        c.clicked.connect(function() { clicked++ })
        verify(!c.activeFocusOnTab)
        mouseClick(c)
        compare(clicked, 0)
        compare(c.Accessible.role, Accessible.StaticText)
        c.interactive = true
        verify(c.activeFocusOnTab)
        mouseClick(c)
        compare(clicked, 1)
    }

    function test_chip_hover_for_tooltip() {
        var c = createTemporaryObject(chipComponent, stage(), { toolTip: "IT/Dienste/Nextcloud.md", x: 10, y: 10 })
        verify(!c.hovered)
        mouseMove(c, c.width / 2, c.height / 2)
        tryVerify(function() { return c.hovered })
        compare(c.toolTip, "IT/Dienste/Nextcloud.md")
    }

    Component {
        id: barsComponent
        KanteBarChart { compact: true; width: 120; height: 32; values: [0.2, 0.5, 0.9]; highlight: 2; labels: ["Mo", "Di", "Mi"] }
    }
    Component {
        id: partsComponent
        KanteProgressBar { width: 200 }
    }
    Component {
        id: sectionComponent
        KanteSectionLabel { text: "Befunde" }
    }

    function test_compact_bars_use_the_full_height() {
        var c = createTemporaryObject(barsComponent, stage(), { x: 50, y: 100 })
        compare(c.labelHeight, 0)
        compare(c.plotHeight, c.height)
        compare(c.implicitHeight, KanteStyle.unit(32))
        // The read-out still names the bar and opens above the chart.
        mouseMove(c, c.width * 5 / 6, c.height - 2)
        tryCompare(c, "hoverIndex", 2)
    }

    function test_progress_parts_stack() {
        var p = createTemporaryObject(partsComponent, stage(), { parts: [{ value: 0.25, color: "green" }, { value: 0.5, color: "red" }] })
        var row = p.children[0].children[0]
        verify(row.visible)
        compare(row.children[0].width, 50)
        compare(row.children[1].width, 100)
        verify(!p.children[0].children[1].visible, "the single value bar steps aside")
    }

    function test_section_label_follows_the_kind() {
        var l = createTemporaryObject(sectionComponent, stage())
        verify(l.font.bold, "System: small bold")
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(l.font.family, KanteStyle.labelFont().family)
        compare(l.color, KanteStyle.mutedTextColor)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(l.font.bold, "switching back restores")
    }

    Component {
        id: dialogComponent
        Kirigami.Dialog {
            id: dlg
            title: "Änderung ablehnen"
            standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
            QQC2.Label { text: "Grund" }
            KanteDialogSkin { dialog: dlg }
        }
    }

    function test_dialog_title_has_no_binding_loop() {
        failOnWarning(/Binding loop/)
        KanteStyle.kind = KanteStyle.Kind.Kante
        var d = createTemporaryObject(dialogComponent, stage())
        d.open()
        wait(200)
        verify(d.header !== null && d.header.text === "Änderung ablehnen")
        d.close()
    }

    function test_chip_short_name_shows() {
        var c = createTemporaryObject(chipComponent, stage(), { text: "IT" })
        verify(c.textShown, "a short name at its natural width is shown")
        c.width = KanteStyle.unit(20)
        verify(!c.textShown, "squeezed: only the square")
    }

    Component {
        id: chipRowComponent
        RowLayout {
            width: 380
            KanteChip { text: "IT" }
            KanteChip { text: "Netzwerk"; interactive: false }
            Flow { Layout.fillWidth: true; KanteChip { text: "Secrets" } }
        }
    }

    function test_chips_in_layouts_have_no_binding_loop() {
        failOnWarning(/Binding loop/)
        var r = createTemporaryObject(chipRowComponent, stage())
        wait(50)
        verify(r.children[0].textShown)
    }
}
