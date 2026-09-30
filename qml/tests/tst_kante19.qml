import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.9: popups of the date, time and search fields stay inside the window, the
 * 12-hour time field, search combo sections, coloured tag suggestions, the bar chart
 * read-out, the list row (count kind, trailing slot, click through to a delegate), readable
 * check box / radio / switch labels on any platform scheme and the page title's width.
 * Run also with the real Plasma style (/tmp/realplasma.sh, REALPLASMA_SCHEME=BreezeLight
 * and BreezeDark): the label colours come from org.kde.desktop there.
 * Run: kante/tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "Kante19"
    width: 600
    height: 500
    when: windowShown

    /** TestCase itself is invisible: parts that must lay out or take input go on the window. */
    function stage() {
        return tc.Window.contentItem
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    /** Scene rectangle of an open popup (its popup item, where Qt placed it). */
    function popupRect(owner) {
        var popup = findChild(owner, "popup")
        verify(popup !== null, "popup found")
        var item = popup.contentItem.parent
        var p = item.mapToItem(null, 0, 0)
        return { x: p.x, y: p.y, width: item.width, height: item.height, popup: popup }
    }
    function verifyInside(r) {
        var w = stage().width
        var h = stage().height
        verify(r.x >= 0 && r.x + r.width <= w, "inside horizontally: " + r.x + " + " + r.width + " <= " + w)
        verify(r.y >= 0 && r.y + r.height <= h, "inside vertically: " + r.y + " + " + r.height + " <= " + h)
    }

    // ── Placement helper ────────────────────────────────────────────────
    Component {
        id: anchorComponent
        Rectangle { width: 100; height: 30 }
    }

    function test_popupPlace() {
        var a = createTemporaryObject(anchorComponent, stage(), { x: 20, y: 20 })
        var p = KanteStyle.popupPlace(a, 200, 100, undefined)
        verify(!p.above)
        compare(p.x, 0)
        compare(p.y, a.height + KanteStyle.unit(2))
        // Right edge: shifted left, flush with the window margin.
        a.x = stage().width - 110
        p = KanteStyle.popupPlace(a, 200, 100, undefined)
        compare(a.x + p.x + 200, stage().width - KanteStyle.unit(4))
        // Bottom: above, capped to the room.
        a.y = stage().height - 40
        p = KanteStyle.popupPlace(a, 200, 100, undefined)
        verify(p.above)
        compare(p.y, -100 - KanteStyle.unit(2))
        verify(p.room > 100)
        // Forced side.
        p = KanteStyle.popupPlace(a, 200, 100, false)
        verify(!p.above)
        a.y = 20
        p = KanteStyle.popupPlace(a, 200, 100, true)
        verify(p.above)
        verify(p.room < 100, "forced: the small room above")
    }

    // ── Date field ──────────────────────────────────────────────────────
    Component {
        id: dateComponent
        KanteDateField { width: 170 }
    }

    function test_dateFieldOpenCloseInside() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var f = createTemporaryObject(dateComponent, stage(), { x: stage().width - 175, y: stage().height - 45 })
        f.open()
        tryVerify(function () { return f.popupOpen })
        var r
        tryVerify(function () { r = popupRect(f); return r.height > 100 })
        wait(20)
        r = popupRect(f)
        verify(r.popup.place.above, "no room below: above")
        verifyInside(r)
        verify(r.y + r.height <= f.mapToItem(null, 0, 0).y, "above the field")
        f.close()
        tryVerify(function () { return !f.popupOpen })
        // Top left: below, not shifted.
        f.x = 10
        f.y = 10
        f.open()
        tryVerify(function () { return f.popupOpen })
        wait(20)
        r = popupRect(f)
        verify(!r.popup.place.above)
        compare(r.x, 10)
        verify(r.y >= 10 + f.height)
        verifyInside(r)
        f.close()
    }

    // ── Time field ──────────────────────────────────────────────────────
    Component {
        id: timeComponent
        KanteTimeField { width: 120; amText: "AM"; pmText: "PM" }
    }

    function test_timeFieldRightEdge() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var f = createTemporaryObject(timeComponent, stage(), { x: stage().width - 125, y: 10, twelveHour: false })
        f.open()
        tryVerify(function () { return f.popupOpen })
        wait(20)
        var r = popupRect(f)
        verify(r.width > f.width, "the popup is wider than the field")
        verify(!r.popup.place.above)
        verifyInside(r)
        f.close()
        tryVerify(function () { return !f.popupOpen })
    }

    function test_timeFieldTwelveHour() {
        var f = createTemporaryObject(timeComponent, tc)
        compare(f.twelveHour, /a/i.test(Qt.locale().timeFormat(Locale.ShortFormat)))
        compare(f.parse("9:30 pm").hour, 21)
        compare(f.parse("9:30pm").minute, 30)
        compare(f.parse("9p").hour, 21)
        compare(f.parse("12 am").hour, 0)
        compare(f.parse("12:15 PM").hour, 12)
        compare(f.parse("7 a.m.").hour, 7)
        compare(f.parse("13 pm"), undefined)
        compare(f.parse("0 am"), undefined)
        compare(f.parse("21:30").hour, 21, "24 h still reads")
        f.twelveHour = false
        f.hour = 21
        f.minute = 5
        compare(f.textOf(21, 5), "21:05")
        f.twelveHour = true
        compare(f.textOf(21, 5), "9:05 PM")
        compare(f.textOf(0, 0), "12:00 AM")
        compare(f.textOf(12, 30), "12:30 PM")
        compare(f.placeholderText, "HH:MM AM")
        verify(f.implicitWidth > KanteStyle.unit(120))
    }

    function test_timeFieldTwelveHourPopup() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var f = createTemporaryObject(timeComponent, stage(), { x: 10, y: 10, twelveHour: true, hour: 21, minute: 0 })
        f.open()
        tryVerify(function () { return f.popupOpen })
        var popup = findChild(f, "popup")
        verify(popup.draftPm)
        compare(popup.draftHour, 21)
        popup.setPm(false)
        compare(popup.draftHour, 9)
        popup.setPm(true)
        compare(popup.draftHour, 21)
        f.close()
        tryVerify(function () { return !f.popupOpen })
    }

    // ── Search combo: sections, side, close ─────────────────────────────
    Component {
        id: comboComponent
        KanteSearchCombo {
            width: 220
            textRole: "name"
            colorRole: "color"
            sectionRole: "customer"
            model: [
                { name: "Website", customer: "Kader" }, { name: "Shop", customer: "Kader" },
                { name: "Archiv", customer: "Kurrent" }, { name: "Intern" }
            ]
        }
    }

    function test_searchComboSections() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(comboComponent, stage(), { x: 10, y: 10 })
        compare(c.sectionAt(0), "Kader")
        compare(c.sectionAt(3), "")
        verify(c.startsSection(0))
        verify(!c.startsSection(1))
        verify(c.startsSection(2))
        verify(!c.startsSection(3), "no section: no heading")
        compare(c.listHeight(4), 4 * c.rowHeight + 2 * c.headingHeight)
        c.sectionRole = ""
        compare(c.listHeight(4), 4 * c.rowHeight)
        c.sectionRole = "customer"
        // Filtering keeps the heading of the first match.
        c.forceActiveFocus()
        keyClick("s"); keyClick("h")
        tryVerify(function () { return c.popupOpen })
        compare(c.matches, [1])
        verify(c.startsSection(0))
        c.close()
        tryVerify(function () { return !c.popupOpen })
        verify(!c.filtering)
    }

    function test_searchComboOpensUp() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(comboComponent, stage(), { x: stage().width - 100, y: stage().height - 40 })
        c.forceActiveFocus()
        c.openList()
        tryVerify(function () { return c.popupOpen })
        wait(20)
        var r = popupRect(c)
        verify(r.popup.place.above)
        verifyInside(r)
        c.close()
        tryVerify(function () { return !c.popupOpen })
        // Forced below: capped to the room there (at least one row).
        c.popupAbove = false
        c.y = stage().height - 200
        c.openList()
        tryVerify(function () { return c.popupOpen })
        wait(20)
        r = popupRect(c)
        verify(!r.popup.place.above)
        verifyInside(r)
        c.close()
    }

    // ── Tag picker: colour squares, side ────────────────────────────────
    Component {
        id: tagComponent
        KanteTagPicker {
            width: 200
            tags: ["urlaub"]
            suggestions: ["urlaub", { name: "archiv", color: "#5ccfc4" }, "1998"]
            onEdited: function (t) { tags = t }
        }
    }

    function test_tagPickerSuggestionColors() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var p = createTemporaryObject(tagComponent, stage(), { x: 10, y: stage().height - 50 })
        compare(p.search.colorRole, "color")
        compare(String(p.search.colorAt(1)), "#5ccfc4")
        compare(p.search.colorAt(2), KanteStyle.tagColor)
        compare(p.search.matches, [1, 2])
        tryVerify(function () { return p.search.y > 0 }, 1000, "narrow: the field on a line of its own")
        p.width = 320
        tryVerify(function () { return p.search.y === 0 }, 1000, "the field fills the rest of the chips' line")
        p.width = 200
        tryVerify(function () { return p.search.y > 0 })
        p.search.forceActiveFocus()
        p.search.openList()
        tryVerify(function () { return p.search.popupOpen })
        wait(20)
        var r = popupRect(p.search)
        verify(r.popup.place.above, "at the bottom: above")
        verify(r.y + r.height <= p.mapToItem(null, 0, 0).y, "above the whole picker, not over its chips")
        verifyInside(r)
        keyClick(Qt.Key_Return)
        compare(p.tagNames, ["urlaub", "archiv"])
        compare(String(p.colorOf(p.tags[1])), "#5ccfc4", "the picked suggestion keeps its colour")
        p.popupAbove = false
        compare(p.search.popupAbove, false)
    }

    // ── Bar chart read-out ──────────────────────────────────────────────
    Component {
        id: barComponent
        KanteBarChart {
            width: 300
            height: 120
            values: [[2, 3], [1, 1], [4, 0]]
            labels: ["Mo", "Di", "Mi"]
            partNames: ["Kader", "Andon"]
            valueFormat: KanteBarChart.ValueFormat.Hours
        }
    }

    function visibleTexts(item) {
        var out = []
        if (!item.visible) {
            return out
        }
        if (item.text !== undefined && typeof item.text === "string" && item.text.length > 0 && item.font !== undefined) {
            out.push(item.text)
        }
        for (var i = 0; i < item.children.length; i++) {
            out = out.concat(visibleTexts(item.children[i]))
        }
        return out
    }

    function test_barChartReadout() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(barComponent, stage(), { x: 0, y: 0 })
        compare(c.barAt(10), 0)
        compare(c.barAt(150), 1)
        compare(c.barAt(299), 2)
        compare(c.barAt(-1), -1)
        compare(c.totalOf(0), 5)
        // Bar 0: 0..2 Kader, 2..5 Andon on a scale of 5.
        compare(c.partAt(0, c.plotHeight - 1), 0)
        compare(c.partAt(0, c.plotHeight * 0.3), 1)
        compare(c.partAt(1, c.plotHeight * 0.1), -1, "above the bar")
        mouseMove(c, 50, c.plotHeight - 5)
        tryCompare(c, "hoverIndex", 0)
        compare(c.hoverPart, 0)
        mouseMove(c, 250, c.plotHeight - 5)
        tryCompare(c, "hoverIndex", 2)
        // Bar 2 has no Andon part: the read-out does not list "Andon 0:00".
        var shown = visibleTexts(c).join("|")
        verify(shown.indexOf("Kader") >= 0, shown)
        verify(shown.indexOf("Andon") < 0, shown)
        c.readout = false
        c.hoverIndex = -1
        mouseMove(c, 50, 50)
        wait(20)
        compare(c.hoverIndex, -1, "readout off: no hover")
    }

    // ── List row ────────────────────────────────────────────────────────
    Component {
        id: rowComponent
        KanteListRow {
            width: 300
            text: "Kader"
            count: "2"
            trailing: Rectangle { objectName: "arrow"; width: 12; height: 12 }
        }
    }
    Component {
        id: delegateComponent
        QQC2.ItemDelegate {
            width: 300
            height: 40
            contentItem: KanteListRow { text: "Kader"; count: "3"; focusOnClick: false }
        }
    }
    SignalSpy { id: delegateSpy; signalName: "clicked" }
    SignalSpy { id: rowSpy; signalName: "clicked" }

    function test_listRowCountKindAndTrailing() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var r = createTemporaryObject(rowComponent, stage())
        var arrow = findChild(r, "arrow")
        verify(arrow !== null)
        tryVerify(function () { return arrow.mapToItem(r, 0, 0).x > r.width / 2 }, 1000, "trailing sits at the right end")
        compare(r.countKind, KanteListRow.CountKind.Quiet)
        r.countKind = KanteListRow.CountKind.Error
        compare(r.countKind, KanteListRow.CountKind.Error)
    }

    function test_listRowInDelegate() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var d = createTemporaryObject(delegateComponent, stage())
        delegateSpy.target = d
        delegateSpy.clear()
        rowSpy.target = d.contentItem
        rowSpy.clear()
        mouseClick(d, 100, 20)
        compare(delegateSpy.count, 1, "the delegate gets the click")
        compare(rowSpy.count, 1, "the row too")
        // A drag is no tap.
        mousePress(d, 100, 20)
        mouseMove(d, 200, 22)
        mouseRelease(d, 200, 22)
        compare(rowSpy.count, 1)
    }

    function test_listRowTouch() {
        var r = createTemporaryObject(rowComponent, stage())
        rowSpy.target = r
        rowSpy.clear()
        var t = touchEvent(r)
        t.press(0, r, 30, 10).commit()
        t.release(0, r, 30, 10).commit()
        compare(rowSpy.count, 1)
    }

    // ── Check labels readable on any platform scheme ────────────────────
    function luminance(c) {
        function ch(v) {
            return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b)
    }
    function contrast(a, b) {
        var la = luminance(a)
        var lb = luminance(b)
        return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05)
    }

    Component {
        id: checksComponent
        Column {
            property alias scoped: scope.enabled
            KanteScope { id: scope; target: parent }
            QQC2.CheckBox { objectName: "check"; text: "Behalten"; KanteCheckSkin { control: parent } }
            QQC2.RadioButton { objectName: "radio"; text: "Manuell"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Radio } }
            QQC2.Switch { objectName: "switch"; text: "Staub"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Switch } }
        }
    }
    Component {
        id: bareChecksComponent
        Column {
            QQC2.CheckBox { objectName: "check"; text: "Behalten"; KanteCheckSkin { control: parent } }
            QQC2.RadioButton { objectName: "radio"; text: "Manuell"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Radio } }
            QQC2.Switch { objectName: "switch"; text: "Staub"; KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Switch } }
        }
    }

    function test_checkLabelsReadable_data() {
        return [
            { tag: "dark, scope", component: checksComponent, dark: true },
            { tag: "leinen, scope", component: checksComponent, dark: false },
            { tag: "dark, no scope", component: bareChecksComponent, dark: true },
            { tag: "leinen, no scope", component: bareChecksComponent, dark: false }
        ]
    }
    function test_checkLabelsReadable(data) {
        KanteStyle.kind = KanteStyle.Kind.Kante
        // Leinen follows a light platform; a dark platform always gives Kante dark.
        if (!data.dark && !KanteStyle.light) {
            skip("platform scheme is dark: no Leinen")
        }
        KanteStyle.preferDark = data.dark
        var g = createTemporaryObject(data.component, stage())
        var names = ["check", "radio", "switch"]
        for (var i = 0; i < names.length; i++) {
            var control = findChild(g, names[i])
            var label = control.contentItem
            tryVerify(function () { return contrast(label.color, KanteStyle.backgroundColor) >= 4.5 }, 1000,
                      names[i] + " label " + label.color + " on " + KanteStyle.backgroundColor)
        }
        // Back to System: the platform colour again.
        KanteStyle.kind = KanteStyle.Kind.System
        var sys = findChild(g, "check").contentItem
        tryVerify(function () { return contrast(sys.color, tc.Window.contentItem.Kirigami.Theme.backgroundColor) >= 4.5 }, 1000, "System: platform colours")
    }

    // ── Spin box text readable (desktop style uses the View colour set) ─
    Component {
        id: spinComponent
        QQC2.SpinBox { value: 42; KanteFieldSkin { control: parent } }
    }

    function test_spinBoxTextReadable() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        var s = createTemporaryObject(spinComponent, stage())
        var text = s.contentItem
        tryVerify(function () { return contrast(text.color, KanteStyle.sunkenColor) >= 4.5 }, 1000,
                  "spin box text " + text.color + " on " + KanteStyle.sunkenColor)
        KanteStyle.kind = KanteStyle.Kind.System
        tryVerify(function () { return !Qt.colorEqual(text.color, KanteStyle.palette.text) || KanteStyle.light }, 1000, "System: style colour again")
    }

    // ── Page title is not elided ────────────────────────────────────────
    Component {
        id: titleComponent
        Column {
            KanteHeading { objectName: "title"; text: "Kante"; pageTitle: true }
            KanteHeading { objectName: "section"; text: "Eingaben"; level: 4 }
        }
    }

    function test_pageTitleNotElided() {
        var kinds = [KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight, KanteStyle.Kind.System]
        var g = createTemporaryObject(titleComponent, stage())
        var title = findChild(g, "title")
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(20)
            var shown = title.children[0]
            if (!shown.visible) {
                continue
            }
            verify(!shown.truncated, "kind " + kinds[i] + ": title not elided")
        }
    }

    // ── Sticker ink readable in every kind ──────────────────────────────
    Component {
        id: stickerComponent
        KanteSticker { text: "v0.4.0" }
    }

    function test_stickerInkReadable() {
        var s = createTemporaryObject(stickerComponent, stage())
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight]
        var darks = [false, true]
        for (var i = 0; i < kinds.length; i++) {
            for (var k = 0; k < darks.length; k++) {
                KanteStyle.kind = kinds[i]
                KanteStyle.preferDark = darks[k]
                verify(contrast(s.ink, s.paper) >= 4.5, "kind " + kinds[i] + " dark " + darks[k] + ": " + s.ink + " on " + s.paper)
            }
        }
    }
}
