import QtQuick
import QtQuick.Window
import QtQuick.Controls as QQC2
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

    // 1.74.2: one tooltip and one pair of handlers for all days (a year in a few milliseconds).
    function test_hoverShowsTheDay() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday,
                         tips: { "2026-11-02": "3 techniques" } })
        mouseMove(h, h.labelWidth + h.step + h.cellSize / 2, h.labelHeight + h.cellSize / 2)
        tryCompare(h, "hoveredIndex", 7)
        const tip = findChild(h, "dayTip")
        tryVerify(() => tip.QQC2.ToolTip.text.indexOf("3 techniques") > 0)
        compare(tip.x, h.labelWidth + h.step, "at its day")
        // Between the days and on a day still to come: none.
        mouseMove(h, h.labelWidth + h.cellSize + h.spacing / 2, h.labelHeight + 1)
        tryCompare(h, "hoveredIndex", -1)
        mouseMove(h, h.labelWidth + h.step + h.cellSize / 2, h.labelHeight + h.step + h.cellSize / 2)
        compare(h.cellAt(h.labelWidth + h.step + 1, h.labelHeight + h.step + 1), -1, "3 Nov is still to come")
    }

    function test_tapRightToLeft() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday })
        h.LayoutMirroring.enabled = true
        mouseClick(h, h.width - h.labelWidth - h.step - h.cellSize / 2, h.labelHeight + h.cellSize / 2)
        compare(h.tappedIndex, 7)
    }

    function test_tapBesideADayClears() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday })
        mouseClick(h, h.labelWidth + h.cellSize / 2, h.labelHeight + h.cellSize / 2)
        compare(h.tappedIndex, 0)
        mouseClick(h, 1, 1)
        compare(h.tappedIndex, -1)
    }

    // Every day still has its own name for a screen reader, and its level's colour.
    function test_cellsKeepTheirName() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 1, firstDayOfWeek: Locale.Monday,
                         levels: { "2026-11-02": 4 }, tips: { "2026-11-02": "3 techniques" } })
        const cells = []
        for (let i = 0; i < h.children.length; i++) {
            if (h.children[i].Accessible.role === Accessible.StaticText) {
                cells.push(h.children[i])
            }
        }
        compare(cells.length, 7)
        verify(cells[0].Accessible.name.indexOf("3 techniques") > 0, cells[0].Accessible.name)
        verify(cells[0].visible && !cells[1].visible)
        compare(String(cells[0].color), String(KanteStyle.levelColor(4, 4)))
    }

    // Levels 1–3 are translucent over a ground that may be too: the same colour as two layers.
    function test_levelColoursAreTheTwoLayers() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 1, firstDayOfWeek: Locale.Monday })
        for (const l of [1, 2, 3]) {
            const u = KanteStyle.sunkenColor, c = KanteStyle.levelColor(l, 4), got = h.levelColors[l]
            const rest = u.a * (1 - c.a), a = c.a + rest
            fuzzyCompare(got.r, (c.r * c.a + u.r * rest) / a, 0.01)
            fuzzyCompare(got.g, (c.g * c.a + u.g * rest) / a, 0.01)
            fuzzyCompare(got.b, (c.b * c.a + u.b * rest) / a, 0.01)
            fuzzyCompare(got.a, a, 0.01)
        }
    }

    // Fading out it still names its day, at its day.
    function test_tipStaysWhileFading() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday,
                         tips: { "2026-11-02": "3 techniques" } })
        mouseMove(h, h.labelWidth + h.step + h.cellSize / 2, h.labelHeight + h.cellSize / 2)
        tryCompare(h, "hoveredIndex", 7)
        mouseMove(h, 1, 1)
        tryCompare(h, "hoveredIndex", -1)
        const tip = findChild(h, "dayTip")
        verify(tip.QQC2.ToolTip.text.indexOf("3 techniques") > 0, tip.QQC2.ToolTip.text)
        compare(tip.x, h.labelWidth + h.step)
    }

    function test_tapShowsItAtOnce() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 2, firstDayOfWeek: Locale.Monday })
        mouseClick(h, h.labelWidth + h.cellSize / 2, h.labelHeight + h.cellSize / 2)
        compare(findChild(h, "dayTip").QQC2.ToolTip.delay, 0)
    }

    function test_fewerWeeksAfterATap() {
        failOnWarning(/undefined/)
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        mouseClick(h, h.labelWidth + 2 * h.step + h.cellSize / 2, h.labelHeight + h.step + h.cellSize / 2)
        compare(h.tappedIndex, 15)
        h.weeks = 1
        compare(h.tappedIndex, -1)
    }

    function test_rightToLeft() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        const ltr = h.lead(h.labelWidth, h.cellSize)
        h.LayoutMirroring.enabled = true
        const rtl = h.lead(h.labelWidth, h.cellSize)
        compare(ltr, h.labelWidth)
        compare(rtl, h.implicitWidth - h.labelWidth - h.cellSize, "the oldest week at the right")
    }

    // 1.62.1: mirrored at the width it gets (wider than its implicit width in a layout), and a
    // single week names the month of its last drawn day.
    function test_edges() {
        const h = make({ endDate: new Date(2026, 10, 2), weeks: 4, firstDayOfWeek: Locale.Monday })
        h.width = h.implicitWidth + 100
        h.LayoutMirroring.enabled = true
        compare(h.lead(h.labelWidth, h.cellSize), h.width - h.labelWidth - h.cellSize, "the grid at the right edge")
        // Monday 30 Nov 2026, one week: only that Monday is drawn, November it is.
        const one = make({ endDate: new Date(2026, 10, 30), weeks: 1, firstDayOfWeek: Locale.Monday })
        compare(one.monthLabels().map(m => m.month), [10])
    }

    function test_size() {
        const h = make({ weeks: 26 })
        compare(h.implicitWidth, h.labelWidth + 26 * h.step - h.spacing)
        compare(h.implicitHeight, h.labelHeight + 7 * h.step - h.spacing)
    }
}
