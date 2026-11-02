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
        // The weeks a month begins in carry its name: October (week of 1 Oct) and November; the
        // first column (31 Aug to 6 Sep) names September, four weeks before October.
        const months = h.monthLabels()
        compare(months.map(m => m.month), [8, 9, 10])
        verify(months.every(m => m.text.length > 0))
        // Weekday names on every second row, starting with the second (Tue, Thu, Sat for Monday first).
        const rows = h.weekdayLabels()
        compare(rows.length, 7)
        compare(rows.filter(r => r !== "").length, 3)
        compare(rows[0], "")
        compare(rows[1], Qt.locale().dayName(2, Locale.ShortFormat))
    }

    // Day after day without a gap or a double, across summer time (29 Mar, 25 Oct 2026) and the
    // new year, for weeks starting on Sunday, Monday and Saturday.
    function test_daysFollowEachOther() {
        for (const first of [Locale.Sunday, Locale.Monday, Locale.Saturday]) {
            const h = make({ endDate: new Date(2027, 0, 10, 23, 59, 59), weeks: 53, firstDayOfWeek: first })
            compare(h.dayAt(0, 0).getDay(), first)
            for (let i = 1; i < 53 * 7; i++) {
                const a = h.dayAt(Math.floor((i - 1) / 7), (i - 1) % 7), b = h.dayAt(Math.floor(i / 7), i % 7)
                const next = new Date(a.getFullYear(), a.getMonth(), a.getDate() + 1, 12)
                compare(h.isoDay(b), h.isoDay(next))
            }
            verify(h.shown(Math.floor(h.weeks - 1), (new Date(2027, 0, 10).getDay() - first + 7) % 7), "the end day is drawn")
        }
        // An end late at night or just after midnight is that day.
        const late = make({ endDate: new Date(2026, 10, 2, 0, 0, 1), weeks: 1, firstDayOfWeek: Locale.Monday })
        compare(late.isoDay(late.lastDay), "2026-11-02")
    }

    function test_firstColumnNamesItsMonth() {
        // 1 Oct 2026 is a Thursday in the first of six columns: October is named there.
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 6, firstDayOfWeek: Locale.Monday })
        compare(h.monthLabels().map(m => [m.week, m.month]), [[0, 9], [4, 10]])
        // A grid in which no month begins names the month of its first column.
        const s = make({ endDate: new Date(2026, 10, 25), weeks: 2, firstDayOfWeek: Locale.Monday })
        compare(s.monthLabels().map(m => [m.week, m.month]), [[0, 10]])
        // Not when the next name is closer than three weeks (12 Oct, November in column 2).
        const c = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        compare(c.monthLabels().map(m => [m.week, m.month]), [[2, 10]])
    }

    function test_tapShowsTheTip() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday,
                         tips: { "2026-11-02": "3 techniques" } })
        // The first cell of the last week (2 Nov) at its position.
        const x = h.labelWidth + h.step + h.cellSize / 2, y = h.labelHeight + h.cellSize / 2
        mouseClick(h, x, y)
        compare(h.tappedIndex, 7)
        verify(h.tipOf(h.dayAt(1, 0), Locale.LongFormat).indexOf("3 techniques") > 0)
        tryCompare(h, "tappedIndex", -1, 5000)
    }

    function test_rightToLeft() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        const ltr = h.lead(h.labelWidth, h.cellSize)
        h.LayoutMirroring.enabled = true
        const rtl = h.lead(h.labelWidth, h.cellSize)
        compare(ltr, h.labelWidth)
        compare(rtl, h.implicitWidth - h.labelWidth - h.cellSize, "the oldest week at the right")
    }

    function test_size() {
        const h = make({ weeks: 26 })
        compare(h.implicitWidth, h.labelWidth + 26 * h.step - h.spacing)
        compare(h.implicitHeight, h.labelHeight + 7 * h.step - h.spacing)
    }
}
