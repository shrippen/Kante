import QtQuick
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.62, from Mitori: KanteCalendarHeatmap (practice days with weekday and month labels and
 * a tooltip per day). Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante162"
    width: 800
    height: 600
    when: windowShown

    Component {
        id: heatComponent
        KanteCalendarHeatmap {}
    }

    function make(props) {
        const h = createTemporaryObject(heatComponent, tc.Window.contentItem, props)
        verify(h)
        return h
    }

    function test_gridEndsOnTheLastDay() {
        // Monday 2 Nov 2026, weeks starting Monday: the last column holds only that Monday.
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        compare(h.isoDay(h.dayAt(3, 0)), "2026-11-02")
        compare(h.isoDay(h.dayAt(0, 0)), "2026-10-12", "four weeks back to a Monday")
        compare(h.isoDay(h.dayAt(2, 6)), "2026-11-01")
        verify(!h.shown(3, 1), "days after the end are not drawn")
        verify(h.shown(3, 0))
        // Sunday first: the same Monday is the second row.
        const s = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Sunday })
        compare(s.isoDay(s.dayAt(1, 1)), "2026-11-02")
        compare(s.isoDay(s.dayAt(1, 0)), "2026-11-01")
    }

    function test_levelsAndTips() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday,
                         levels: { "2026-11-01": 3, "2026-10-28": 9 }, tips: { "2026-11-01": "5 techniques" } })
        compare(h.levelOf(h.dayAt(0, 6)), 3)
        compare(h.levelOf(h.dayAt(0, 2)), 4, "clamped to 4")
        compare(h.levelOf(h.dayAt(0, 0)), 0, "missing is 0")
        verify(h.tipOf(h.dayAt(0, 6)).indexOf("5 techniques") > 0, h.tipOf(h.dayAt(0, 6)))
        verify(h.tipOf(h.dayAt(0, 0)).length > 0, "a day without a tip still names its date")
    }

    function test_axisLabels() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 10, firstDayOfWeek: Locale.Monday })
        // The weeks a month begins in carry its name: October (week of 1 Oct) and November.
        const months = h.monthLabels()
        compare(months.map(m => m.month), [9, 10])
        verify(months.every(m => m.text.length > 0))
        // Weekday names on every second row, starting with the second (Tue, Thu, Sat for Monday first).
        const rows = h.weekdayLabels()
        compare(rows.length, 7)
        compare(rows.filter(r => r !== "").length, 3)
        compare(rows[0], "")
        compare(rows[1], Qt.locale().dayName(2, Locale.ShortFormat))
    }

    function test_size() {
        const h = make({ weeks: 26 })
        verify(h.implicitWidth > 26 * h.cellSize)
        verify(h.implicitHeight > 7 * h.cellSize)
    }
}
