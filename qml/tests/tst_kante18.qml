import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.8: day strip sky and work band, stacked hours chart, week timeline,
 * the input fields (date, time, search combo, tag picker) and the map roles.
 * Run: kante/tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "Kante18"
    width: 600
    height: 500
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    function test_mapRoles() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        compare(KanteStyle.mapMarkerColor, KanteStyle.focusColor)
        compare(KanteStyle.mapRouteColor, KanteStyle.accentColor)
        compare(KanteStyle.entityFallbackColor, KanteStyle.disabledTextColor)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(KanteStyle.mapMarkerColor, Kirigami.Theme.focusColor)
        compare(KanteStyle.entityFallbackColor, Kirigami.Theme.disabledTextColor)
    }

    // ── Day strip ───────────────────────────────────────────────────────
    Component {
        id: stripComponent
        KanteDayStrip {
            width: 240
            segments: [{ from: 9, to: 12, kind: "work", color: "#83a598" }, { from: 13, to: 14, kind: "work" }]
        }
    }

    function test_dayStripSkyAndWork() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(stripComponent, tc)
        var plain = s.implicitHeight
        verify(!s.hasSky)
        verify(!s.hasWork)
        s.sunrise = 6.5
        s.sunset = 19.75
        verify(s.hasSky)
        verify(s.implicitHeight > plain)
        var sky = s.implicitHeight
        s.workFrom = 8
        s.workTo = 17
        verify(s.hasWork)
        verify(s.implicitHeight > sky)
        compare(s.spanWidth(6, 18), 120)
        compare(s.spanWidth(-2, 3), 30)
        s.sunset = 5
        verify(!s.hasSky, "sunset before sunrise: no sky")
    }

    function test_dayStripSegmentColor() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(stripComponent, tc)
        compare(String(s.toneOf(s.segments[0])), "#83a598")
        compare(s.toneOf(s.segments[1]), KanteStyle.accentColor)
        compare(s.toneOf({ from: 1, to: 2, kind: "event" }), KanteStyle.focusColor)
    }

    // ── Bar chart: stacks and duration axis ────────────────────────────
    Component {
        id: hoursChart
        KanteBarChart {
            width: 300; height: 140
            values: [[2, 1.5], [3, 4.25]]
            stackColors: ["#d3869b", "#8ec07c"]
            axis: true
            valueFormat: KanteBarChart.ValueFormat.Hours
        }
    }

    function test_barChartHoursAxis() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(hoursChart, tc)
        compare(c.dataMax, 7.25)
        compare(c.axisStep, 2)
        compare(c.scaleMax, 8)
        compare(c.gridLines, 5)
        compare(c.format(7.5), "7:30")
        compare(c.format(0.25), "0:15")
        verify(c.padLeft > 0)
        compare(String(c.partColor(1)), "#8ec07c")
        compare(c.partColor(2), KanteStyle.dataColor(2))
        c.valueFormat = KanteBarChart.ValueFormat.Number
        compare(c.axisStep, 2)
        c.formatter = function (v) { return v + " h" }
        compare(c.format(3), "3 h")
        c.axis = false
        compare(c.scaleMax, 7.25)
        compare(c.padLeft, 0)
    }

    function test_barChartNiceSteps() {
        var c = createTemporaryObject(hoursChart, tc)
        compare(c.niceStep(0.2), 0.25)
        compare(c.niceStep(3), 4)
        compare(c.niceStep(30), 48)
        c.valueFormat = KanteBarChart.ValueFormat.Number
        compare(c.niceStep(3), 5)
        compare(c.niceStep(0.13), 0.2)
        compare(c.niceStep(140), 200)
    }

    // ── Week timeline ───────────────────────────────────────────────────
    Component {
        id: timelineComponent
        KanteWeekTimeline {
            width: 480
            today: 1
            now: 11
            entries: [{ day: 0, start: 8, end: 12.5, color: "#83a598", title: "a" },
                      { day: 0, start: 13, end: 16, title: "b" },
                      { day: 1, start: 9, end: 10.25, title: "c" }]
        }
    }

    function test_weekTimeline() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var t = createTemporaryObject(timelineComponent, tc)
        compare(t.dayTotal(0), 7.5)
        compare(t.hoursText(t.dayTotal(0)), "7:30")
        compare(t.hoursText(t.dayTotal(1)), "1:15")
        compare(t.dayTotal(5), 0)
        compare(t.xOf(0), t.gutter)
        compare(t.xOf(24), t.gutter + t.trackWidth)
        compare(t.xOf(30), t.gutter + t.trackWidth)
        compare(t.rowY(1) - t.rowY(0), t.rowHeight + KanteStyle.unit(3))
        t.totals = false
        compare(t.trackWidth, 480 - t.gutter)
        verify(t.implicitHeight > 7 * t.rowHeight)
    }

    // ── Date field ──────────────────────────────────────────────────────
    Component {
        id: dateComponent
        KanteDateField { width: 200 }
    }
    SignalSpy { id: dateSpy; signalName: "dateEdited" }

    function test_dateFieldParse() {
        var f = createTemporaryObject(dateComponent, tc)
        var d = f.parse("1.10.2026")
        compare(d.getFullYear(), 2026)
        compare(d.getMonth(), 9)
        compare(d.getDate(), 1)
        compare(f.parse("2026-10-03").getDate(), 3)
        compare(f.parse("5.3.26").getFullYear(), 2026)
        compare(f.parse("5.3.").getFullYear(), new Date().getFullYear())
        compare(f.parse(""), null)
        compare(f.parse("31.02.2026"), undefined)
        compare(f.parse("morgen"), undefined)
    }

    function test_dateFieldTypedAndPicked() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var f = createTemporaryObject(dateComponent, tc)
        dateSpy.target = f
        dateSpy.clear()
        f.forceActiveFocus()
        keyClick("1"); keyClick("."); keyClick("1"); keyClick("0"); keyClick("."); keyClick("2"); keyClick("6")
        keyClick(Qt.Key_Return)
        compare(dateSpy.count, 1)
        compare(f.date.getDate(), 1)
        compare(f.date.getMonth(), 9)
        verify(!f.invalid)
        // Unreadable: stays, field marked.
        f.forceActiveFocus()
        keyClick("x")
        keyClick(Qt.Key_Return)
        verify(f.invalid)
        compare(dateSpy.count, 1)
        // Set from outside: no signal, text follows.
        tc.forceActiveFocus()
        f.date = new Date(2026, 0, 2)
        compare(dateSpy.count, 1)
        verify(!f.invalid)
        // Popup opens on Down.
        f.forceActiveFocus()
        keyClick(Qt.Key_Down)
        tryVerify(function () { return f.popupOpen })
        keyClick(Qt.Key_Escape)
        tryVerify(function () { return !f.popupOpen })
    }

    // ── Time field ──────────────────────────────────────────────────────
    Component {
        id: timeComponent
        KanteTimeField { width: 140 }
    }
    SignalSpy { id: timeSpy; signalName: "timeEdited" }

    function test_timeField() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var f = createTemporaryObject(timeComponent, tc)
        compare(f.parse("9:30").minute, 30)
        compare(f.parse("930").hour, 9)
        compare(f.parse("1230").hour, 12)
        compare(f.parse("9").minute, 0)
        compare(f.parse("9h05").minute, 5)
        compare(f.parse("24:00"), undefined)
        compare(f.parse(""), null)
        verify(!f.hasTime)
        timeSpy.target = f
        timeSpy.clear()
        f.forceActiveFocus()
        keyClick("9"); keyClick("3"); keyClick("0")
        keyClick(Qt.Key_Return)
        compare(f.hour, 9)
        compare(f.minute, 30)
        compare(timeSpy.count, 1)
        verify(f.hasTime)
        keyClick(Qt.Key_Down)
        tryVerify(function () { return f.popupOpen })
    }

    // ── Search combo ────────────────────────────────────────────────────
    Component {
        id: comboComponent
        KanteSearchCombo {
            width: 220
            textRole: "name"
            colorRole: "color"
            model: [{ name: "Kimai", color: "#fabd2f" }, { name: "Andon" }, { name: "Kader", color: "#5ccfc4" }, { name: "Kurrent" }]
        }
    }
    SignalSpy { id: activatedSpy; signalName: "activated" }
    SignalSpy { id: newSpy; signalName: "newEntered" }

    function test_searchComboFilters() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(comboComponent, tc)
        compare(c.matches.length, 4)
        compare(c.colorAt(1), KanteStyle.entityFallbackColor)
        compare(String(c.colorAt(0)), "#fabd2f")
        activatedSpy.target = c
        activatedSpy.clear()
        c.forceActiveFocus()
        keyClick("k"); keyClick("a")
        tryVerify(function () { return c.popupOpen })
        compare(c.matches, [2])
        keyClick(Qt.Key_Return)
        compare(activatedSpy.count, 1)
        compare(activatedSpy.signalArguments[0][0], 2)
        compare(c.currentIndex, 2)
        compare(c.currentText, "Kader")
        compare(c.editText, "Kader")
        verify(!c.popupOpen)
    }

    function test_searchComboKeysAndNew() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(comboComponent, tc)
        c.exclude = ["Andon"]
        compare(c.matches, [0, 2, 3])
        c.forceActiveFocus()
        keyClick(Qt.Key_Down)
        tryVerify(function () { return c.popupOpen })
        keyClick(Qt.Key_Down)
        compare(c.highlighted, 1)
        keyClick(Qt.Key_Return)
        compare(c.currentIndex, 2)
        // A new name.
        c.allowNew = true
        newSpy.target = c
        newSpy.clear()
        c.forceActiveFocus()
        keyClick(Qt.Key_A, Qt.ControlModifier)
        keyClick("z"); keyClick("x")
        verify(c.offersNew)
        compare(c.rowCount, 1)
        keyClick(Qt.Key_Return)
        compare(newSpy.count, 1)
        compare(newSpy.signalArguments[0][0], "zx")
        // Escape restores the current text.
        c.forceActiveFocus()
        keyClick("q")
        keyClick(Qt.Key_Escape)
        compare(c.editText, c.currentText)
    }

    // ── Tag picker ──────────────────────────────────────────────────────
    Component {
        id: tagComponent
        KanteTagPicker {
            width: 320
            tags: ["urlaub", { name: "archiv", color: "#5ccfc4" }]
            suggestions: ["urlaub", "archiv", "rolle-12", "1998"]
            onEdited: function (t) { tags = t }
        }
    }

    function test_tagPicker() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var p = createTemporaryObject(tagComponent, tc)
        compare(p.tagNames, ["urlaub", "archiv"])
        compare(p.colorOf(p.tags[0]), KanteStyle.tagColor)
        compare(String(p.colorOf(p.tags[1])), "#5ccfc4")
        compare(p.search.matches, [2, 3], "picked tags are not offered")
        p.search.forceActiveFocus()
        keyClick("1"); keyClick("9")
        keyClick(Qt.Key_Return)
        compare(p.tagNames, ["urlaub", "archiv", "1998"])
        compare(p.search.editText, "")
        // New text.
        keyClick("n"); keyClick("e"); keyClick("u")
        keyClick(Qt.Key_Return)
        compare(p.tagNames.length, 4)
        compare(p.tagNames[3], "neu")
        // Backspace in the empty field drops the last tag.
        keyClick(Qt.Key_Backspace)
        compare(p.tagNames.length, 3)
        // Duplicates are ignored.
        p.add("urlaub")
        compare(p.tagNames.length, 3)
        p.remove(0)
        compare(p.tagNames, ["archiv", "1998"])
    }

    Component {
        id: all
        Column {
            KanteDayStrip { width: 300; sunrise: 7; sunset: 19; workFrom: 8; workTo: 17; now: 12 }
            KanteBarChart { width: 200; height: 100; values: [[1, 2]]; axis: true; valueFormat: KanteBarChart.ValueFormat.Hours }
            KanteWeekTimeline { width: 400; entries: [{ day: 2, start: 9, end: 11 }] }
            KanteDateField { }
            KanteTimeField { }
            KanteSearchCombo { model: ["a", "b"] }
            KanteTagPicker { tags: ["a"]; suggestions: ["b"] }
        }
    }

    function test_buildInAllKinds() {
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight, KanteStyle.Kind.System]
        var g = createTemporaryObject(all, tc)
        verify(g !== null)
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(30)
            compare(g.children.length, 7)
        }
    }
}
