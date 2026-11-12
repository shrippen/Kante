import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import Kante

/**
 * KanteScatterChart (from Klecks): scale and aspect, colours and legend, tooltip, keyboard,
 * hit tests and 20 000 points. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteScatter"
    width: 800
    height: 600
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    SignalSpy { id: spy }

    function stage() {
        return tc.Window.contentItem
    }

    Component {
        id: chartComponent
        KanteScatterChart {
            width: 400
            height: 300
            points: [{ x: 0, y: 0, label: "A" }, { x: 10, y: 2, label: "B" }, { x: 5, y: 1 }]
        }
    }

    function test_axesRoundOutToSteps() {
        const c = createTemporaryObject(chartComponent, stage())
        verify(c.axes.x0 <= 0 && c.axes.x1 >= 10, JSON.stringify(c.axes))
        verify(c.axes.y0 <= 0 && c.axes.y1 >= 2, JSON.stringify(c.axes))
        // Ends are whole steps, the first and last tick sit on them.
        compare(c.xTicks[0], c.axes.x0)
        compare(c.xTicks[c.xTicks.length - 1], c.axes.x1)
        // Up is larger, right is larger.
        verify(c.yOf(2) < c.yOf(0))
        verify(c.xOf(10) > c.xOf(0))
        // Every point lies inside the plot.
        for (let i = 0; i < c.points.length; i++) {
            const x = c.xOf(c.points[i].x)
            const y = c.yOf(c.points[i].y)
            verify(x >= c.padLeft && x <= c.padLeft + c.plotWidth, "x " + x)
            verify(y >= c.padTop && y <= c.padTop + c.plotHeight, "y " + y)
        }
    }

    function test_fixedEndsStay() {
        const c = createTemporaryObject(chartComponent, stage(), { xMin: -3, xMax: 13 })
        compare(c.axes.x0, -3)
        compare(c.axes.x1, 13)
    }

    function test_niceStepAndDecimals() {
        const c = createTemporaryObject(chartComponent, stage())
        compare(c.niceStep(0.7), 1)
        compare(c.niceStep(1.7), 2)
        compare(c.niceStep(2.2), 2.5)
        compare(c.niceStep(31), 50)
        compare(c.decimalsOf(2), 0)
        compare(c.decimalsOf(2.5), 1)
        compare(c.decimalsOf(0.25), 2)
    }

    function test_equalAspect() {
        const c = createTemporaryObject(chartComponent, stage(), { equalAspect: true })
        const ux = c.xOf(1) - c.xOf(0)
        const uy = c.yOf(0) - c.yOf(1)
        fuzzyCompare(ux, uy, 1e-6)
        compare(c.axes.xStep, c.axes.yStep)
        // The data still fits, the shorter axis grew around its centre.
        verify(c.axes.x0 <= 0 && c.axes.x1 >= 10)
        verify(c.axes.y0 < 0 && c.axes.y1 > 2, JSON.stringify(c.axes))
        fuzzyCompare((c.axes.y0 + c.axes.y1) / 2, 1, 1e-6)
        // A tall chart: the x axis grows instead.
        c.width = 200
        c.height = 500
        fuzzyCompare(c.xOf(1) - c.xOf(0), c.yOf(0) - c.yOf(1), 1e-6)
        verify(c.axes.x0 <= 0 && c.axes.x1 >= 10)
    }

    function test_singlePointSpansAStep() {
        const c = createTemporaryObject(chartComponent, stage(), { points: [{ x: 4, y: 4 }] })
        verify(c.axes.x1 > c.axes.x0)
        verify(c.axes.y1 > c.axes.y0)
        const x = c.xOf(4)
        verify(x > c.padLeft && x < c.padLeft + c.plotWidth)
    }

    function test_colours() {
        const c = createTemporaryObject(chartComponent, stage(), {
            valueKey: "views", minValue: 0, maxValue: 8,
            points: [{ x: 0, y: 0, views: 0 }, { x: 1, y: 1, views: 8 }, { x: 2, y: 2, series: 1 }, { x: 3, y: 3 }, { x: 4, y: 4, views: 5 }]
        })
        compare(c.levelOf(0), 1)
        compare(c.levelOf(8), 4)
        compare(c.levelOf(5), 3)
        compare(c.colorOf(0), KanteStyle.levelColor(1, 4, KanteStyle.focusColor))
        compare(c.colorOf(1), KanteStyle.focusColor)
        compare(c.colorOf(2), KanteStyle.dataColor(1))
        compare(c.colorOf(3), c.pointColor)
    }

    function test_legend() {
        const c = createTemporaryObject(chartComponent, stage(), {
            valueKey: "views", seriesNames: ["", "Kameras"],
            points: [{ x: 0, y: 0, views: 2 }, { x: 1, y: 1, views: 10 }, { x: 2, y: 2, series: 1, shape: "triangle" }]
        })
        const m = c.legendModel
        // "" leaves series 0 out of the legend.
        compare(m.length, 5)
        compare(m[0].text, "Kameras")
        compare(m[0].color, KanteStyle.dataColor(1))
        compare(m[1].text, "2–4")
        compare(m[4].text, "8–10")
        verify(c.legend)
        verify(c.legendHeight > 0)
        // Without series names and values: no legend, no room for it.
        const plain = createTemporaryObject(chartComponent, stage())
        compare(plain.legendModel.length, 0)
        compare(plain.legendHeight, 0)
    }

    function test_tooltipContent() {
        const c = createTemporaryObject(chartComponent, stage(), {
            unit: "m", valueKey: "views", valueTitle: "Ansichten",
            points: [{ x: 1.25, y: 2, label: "Kamera 3", views: 12 }, { x: 4, y: 0 }]
        })
        const lines = c.tipOf(0).split("\n")
        compare(lines.length, 3)
        compare(lines[0], "Kamera 3")
        verify(lines[1].indexOf("x ") === 0, lines[1])
        verify(lines[1].indexOf(Number(1.25).toLocaleString(Qt.locale(), 'f', c.xDecimals + 1) + " m") > 0, lines[1])
        verify(lines[1].indexOf("y " + Number(2).toLocaleString(Qt.locale(), 'f', c.yDecimals + 1)) > 0, lines[1])
        compare(lines[2], "Ansichten 12")
        // A point without label and value: only the coordinates.
        compare(c.tipOf(1).split("\n").length, 1)
        compare(c.tipOf(5), "")
        compare(c.xCaption, "m")
        c.xTitle = "Ost"
        compare(c.xCaption, "Ost (m)")
    }

    function test_hoverShowsTooltip() {
        const c = createTemporaryObject(chartComponent, stage())
        waitForRendering(c)
        const probe = findChild(c, "kanteScatterProbe")
        verify(!probe.visible)
        mouseMove(c, c.xOf(10), c.yOf(2))
        tryCompare(c, "hoverIndex", 1)
        verify(probe.visible)
        compare(probe.QQC2.ToolTip.text, c.tipOf(1))
        fuzzyCompare(probe.x + probe.width / 2, c.xOf(10), 1e-6)
        mouseMove(c, c.padLeft + 1, c.padTop + 1)
        tryCompare(c, "hoverIndex", -1)
    }

    function test_pointAt() {
        const c = createTemporaryObject(chartComponent, stage())
        compare(c.pointAt(c.xOf(5) + 2, c.yOf(1) - 2), 2)
        compare(c.pointAt(c.xOf(5) + 40, c.yOf(1)), -1)
    }

    function test_keyboard() {
        const c = createTemporaryObject(chartComponent, stage(), {
            points: [{ x: 0, y: 0 }, { x: 5, y: 0 }, { x: 10, y: 0 }, { x: 5, y: 5 }]
        })
        watch(c, "activated")
        verify(c.activeFocusOnTab)
        c.forceActiveFocus()
        compare(c.currentIndex, 0)
        const probe = findChild(c, "kanteScatterProbe")
        verify(probe.visible)
        compare(probe.QQC2.ToolTip.text, c.tipOf(0))
        keyClick(Qt.Key_Right)
        compare(c.currentIndex, 1)
        keyClick(Qt.Key_Right)
        compare(c.currentIndex, 2)
        keyClick(Qt.Key_Right)
        compare(c.currentIndex, 2, "at the edge the focus stays")
        keyClick(Qt.Key_Left)
        compare(c.currentIndex, 1)
        keyClick(Qt.Key_Up)
        compare(c.currentIndex, 3)
        keyClick(Qt.Key_Down)
        compare(c.currentIndex, 1)
        keyClick(Qt.Key_End)
        compare(c.currentIndex, 3)
        keyClick(Qt.Key_Home)
        compare(c.currentIndex, 0)
        keyClick(Qt.Key_Return)
        keyClick(Qt.Key_Space)
        compare(spy.count, 2)
        compare(spy.signalArguments[0][0], 0)
        verify(c.Accessible.description.length > 0)
    }

    function test_clickActivates() {
        const c = createTemporaryObject(chartComponent, stage())
        waitForRendering(c)
        watch(c, "activated")
        mouseClick(c, c.xOf(10), c.yOf(2))
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 1)
        compare(c.currentIndex, 1)
        verify(c.activeFocus)
    }

    function test_notInteractive() {
        const c = createTemporaryObject(chartComponent, stage(), { interactive: false })
        verify(!c.activeFocusOnTab)
    }

    function test_shapesAndSizes() {
        const c = createTemporaryObject(chartComponent, stage(), {
            points: [{ x: 0, y: 0 }, { x: 1, y: 1, shape: "triangle", angle: 30 }, { x: 2, y: 2, shape: "cross", size: 2 }, { x: 3, y: 3, shape: "star" }]
        })
        compare(c.shapeOf(0), "dot")
        compare(c.shapeOf(1), "triangle")
        compare(c.shapeOf(3), "dot")
        compare(c.markSize(0), c.pointSize)
        compare(c.markSize(1), c.pointSize * 2.5)
        compare(c.markSize(2), c.pointSize * 3)
        c.ensureLayout()
        // Groups by shape, dots first and triangles last (on top).
        compare(c._groups[0].shape, "dot")
        compare(c._groups[c._groups.length - 1].shape, "triangle")
    }

    function test_paintsMarks() {
        const c = createTemporaryObject(chartComponent, stage(), {
            pointSize: 12, pointColor: "#ff0000",
            points: [{ x: 0, y: 0 }, { x: 10, y: 2, shape: "triangle", series: 1, angle: 0 }]
        })
        const canvas = findChild(c, "kanteScatterCanvas")
        tryVerify(function () { return canvas.paints > 0 })
        waitForRendering(c)
        const img = grabImage(c)
        compare(String(img.pixel(Math.round(c.xOf(0)), Math.round(c.yOf(0)))), "#ff0000")
        // The triangle points right (angle 0): filled ahead of its centre, empty behind its base.
        const s = c.markSize(1)
        const ahead = img.pixel(Math.round(c.xOf(10) + s * 0.3), Math.round(c.yOf(2)))
        compare(String(ahead), String(KanteStyle.dataColor(1)))
        const behind = img.pixel(Math.round(c.xOf(10) - s * 0.55), Math.round(c.yOf(2)))
        verify(String(behind) !== String(KanteStyle.dataColor(1)), String(behind))
    }

    function test_manyPoints() {
        const pts = []
        for (let i = 0; i < 20000; i++) {
            pts.push({ x: Math.sin(i) * 50 + i % 7, y: Math.cos(i * 1.3) * 30, views: i % 13 })
        }
        const c = createTemporaryObject(chartComponent, stage(), { equalAspect: true, valueKey: "views" })
        waitForRendering(c)
        const canvas = findChild(c, "kanteScatterCanvas")
        const before = canvas.paints
        const t0 = Date.now()
        c.points = pts
        c.ensureLayout()
        tryVerify(function () { return canvas.paints > before }, 5000)
        const spent = Date.now() - t0
        verify(spent < 3000, "layout and paint took " + spent + " ms")
        // One group per shape and colour, not one per point.
        verify(c._groups.length <= 4, "groups " + c._groups.length)
        const i = c.pointAt(c.xOf(pts[123].x), c.yOf(pts[123].y))
        verify(i >= 0)
    }

    function test_noValueNoLegend() {
        // A fixed minimum without any value leaves `high` NaN: no "nan–nan" entries.
        const c = createTemporaryObject(chartComponent, stage(), { valueKey: "views", minValue: 0, points: [] })
        verify(!c.valued)
        compare(c.legendModel.length, 0)
        const d = createTemporaryObject(chartComponent, stage(),
                                        { valueKey: "views", minValue: 0, points: [{ x: 0, y: 0 }, { x: 1, y: 1 }] })
        verify(!d.valued)
        compare(d.legendModel.length, 0)
    }

    function legendOf(vals, extra) {
        const pts = vals.map((v, i) => ({ x: i, y: i, v: v }))
        const c = createTemporaryObject(chartComponent, stage(),
                                        Object.assign({ valueKey: "v", points: pts }, extra || {}))
        return c
    }
    function texts(c) {
        return c.legendModel.map(e => e.text.replace(/,/g, ".")).join(" | ")
    }

    function test_legendBoundsAreRound() {
        // Step = niceStep(span / levels), levels start at a multiple of the step and
        // the top bound reaches the highest value.
        compare(texts(legendOf([0, 6])), "0–2 | 2–4 | 4–6 | 6–8")
        compare(texts(legendOf([0, 10 / 3])), "0–1 | 1–2 | 2–3 | 3–4")
        compare(texts(legendOf([1], { minValue: 0, maxValue: 1000 / 7 })), "0–50 | 50–100 | 100–150 | 150–200")
        compare(texts(legendOf([1, 100])), "0–25 | 25–50 | 50–75 | 75–100")
        compare(texts(legendOf([2, 16])), "0–5 | 5–10 | 10–15 | 15–20")
        compare(texts(legendOf([4.99, 12.99])), "0–5 | 5–10 | 10–15 | 15–20")
        compare(texts(legendOf([0, 1])), "0.00–0.25 | 0.25–0.50 | 0.50–0.75 | 0.75–1.00")
    }

    function test_levelsUseLegendBounds() {
        // A value on a shown bound belongs to the level that starts there.
        const c = legendOf([0, 10 / 3])
        compare(c.levelOf(0.99), 1)
        compare(c.levelOf(1), 2)
        compare(c.levelOf(2), 3)
        compare(c.levelOf(3), 4)
        compare(c.levelOf(10 / 3), 4)
        const g = legendOf([2, 16])
        compare(g.levelOf(4.9), 1)
        compare(g.levelOf(5), 2)
        compare(g.levelOf(16), 4)
        // Decimal steps: 0.3 / 0.1 is 2.9999… and still level 4.
        const d = legendOf([0, 0.4])
        compare(d.levelOf(0.3), 4)
    }

    function test_singleValueIsTopLevel() {
        // One value (or all equal) has nothing to compare with: full colour, as before.
        compare(legendOf([5]).levelOf(5), 4)
        compare(legendOf([7, 7, 7]).levelOf(7), 4)
        // ... and the legend shows just that value in the top colour: ranges below it would
        // name values that are not there (all zeros gave −3–−2, −2–−1, …).
        compare(texts(legendOf([5])), "5")
        compare(texts(legendOf([0, 0])), "0")
        compare(legendOf([0]).legendModel[0].color, KanteStyle.levelColor(4, 4, legendOf([0]).scaleColor))
        // Same format as the tooltip: whole numbers plain, else two decimals.
        compare(texts(legendOf([1 / 3])), "0.33")
    }

    function test_fixedRangeKeepsLevelKeys() {
        // With a fixed end the points are placed on that range: keys per level, as with
        // different values, so every point's colour has a key.
        compare(legendOf([2, 2], { minValue: 5 }).legendModel.length, 4)
        compare(legendOf([0, 5, 20], { minValue: 10, maxValue: 10 }).legendModel.length, 4)
        compare(legendOf([0, 0], { minValue: 1 }).legendModel.length, 4)
    }

    function test_exactLevelStart() {
        // Default: start rounded down to a multiple of the step.
        compare(texts(legendOf([3, 60])), "0–20 | 20–40 | 40–60 | 60–80")
        // Exact: the first level starts at the lowest value.
        const c = legendOf([3, 60], { exactLevelStart: true })
        compare(texts(c), "3–23 | 23–43 | 43–63 | 63–83")
        compare(c.levelOf(3), 1)
        compare(c.levelOf(22.9), 1)
        compare(c.levelOf(23), 2)
        compare(c.levelOf(60), 3)
        // A fixed minValue sets the start; a single value keeps its one key.
        compare(texts(legendOf([5, 60], { minValue: 3, exactLevelStart: true })).split(" | ")[0], "3–23")
        compare(texts(legendOf([5], { exactLevelStart: true })), "5")
        compare(legendOf([2, 2], { minValue: 5, exactLevelStart: true }).legendModel.length, 4)
    }

    function test_openTopLevel() {
        const c = legendOf([3, 60], { openTopLevel: true })
        compare(texts(c), "0–20 | 20–40 | 40–60 | ≥ 60")
        // Values above the last bound (fixed maxValue) share the top level and its key.
        const f = legendOf([3, 100], { minValue: 3, maxValue: 60, openTopLevel: true, exactLevelStart: true })
        compare(texts(f), "3–13 | 13–23 | 23–33 | ≥ 33")
        compare(f.levelOf(100), 4)
        compare(f.levelOf(60), 4)
        compare(f.levelOf(33), 4)
        compare(f.levelOf(32.9), 3)
        compare(f.legendModel[3].color, KanteStyle.levelColor(f.levelOf(100), 4, f.scaleColor))
        // Single value: still just that value.
        compare(texts(legendOf([5], { openTopLevel: true })), "5")
    }

    function test_levelOptionsDefaultOff() {
        const c = legendOf([3, 60])
        compare(c.exactLevelStart, false)
        compare(c.openTopLevel, false)
        compare(c.levelScale.start, 0)
    }

    function test_integerLevels() {
        // Default: fractional keys for views 3..5.
        compare(texts(legendOf([3, 5], { minValue: 3, exactLevelStart: true })), "3.0–3.5 | 3.5–4.0 | 4.0–4.5 | 4.5–5.0")
        // Three integers: three levels, no fractions, the top colours.
        const c = legendOf([3, 4, 5], { integerLevels: true, exactLevelStart: true })
        compare(texts(c), "3 | 4 | 5")
        compare(c.levelOf(3), 2)
        compare(c.levelOf(4), 3)
        compare(c.levelOf(5), 4)
        compare(c.legendModel[0].color, KanteStyle.levelColor(2, 4, c.scaleColor))
        compare(c.legendModel[2].color, KanteStyle.levelColor(c.levelOf(5), 4, c.scaleColor))
        // Default start rounding keeps whole numbers too.
        compare(texts(legendOf([3, 5], { integerLevels: true })), "3 | 4 | 5")
        // A single value: one key (as without the option); fixed end 4: two.
        const one = legendOf([3], { integerLevels: true })
        compare(texts(one), "3")
        compare(one.levelOf(3), 4)
        const two = legendOf([3], { integerLevels: true, minValue: 3, maxValue: 4 })
        compare(texts(two), "3 | 4")
        compare(two.levelOf(3), 3)
        compare(two.levelOf(4), 4)
        // Wide range: whole steps, each key ends on its last integer.
        const w = legendOf([3, 60], { integerLevels: true, exactLevelStart: true })
        compare(texts(w), "3–22 | 23–42 | 43–62 | 63–82")
        compare(w.levelOf(22), 1)
        compare(w.levelOf(23), 2)
        // All three options: the open top starts at or below 60.
        const a = legendOf([3, 60, 100], { integerLevels: true, exactLevelStart: true, openTopLevel: true,
                                           minValue: 3, maxValue: 60 })
        compare(texts(a), "3–12 | 13–22 | 23–32 | ≥ 33")
        compare(a.levelOf(32), 3)
        compare(a.levelOf(33), 4)
        compare(a.levelOf(100), 4)
        // Open top on few integers.
        compare(texts(legendOf([3, 5], { integerLevels: true, openTopLevel: true })), "3 | 4 | ≥ 5")
    }

    function test_integerOpenTopTerminates() {
        // The step shrinks strictly (3 -> 2 -> 1); 2.5 rounded back up to 3 looped forever.
        const a = legendOf([0, 8], { integerLevels: true, openTopLevel: true })
        compare(texts(a), "0–1 | 2–3 | 4–5 | ≥ 6")
        compare(a.levelOf(8), 4)
        const b = legendOf([1, 9], { integerLevels: true, openTopLevel: true, exactLevelStart: true })
        compare(texts(b), "1–2 | 3–4 | 5–6 | ≥ 7")
        const c = legendOf([0, 15], { integerLevels: true, openTopLevel: true })
        verify(c.levelScale.start + 3 * c.levelStep <= 15)
        verify(Number.isInteger(c.levelStep))
    }

    function test_bigMarkHit() {
        const c = createTemporaryObject(chartComponent, stage(),
                                        { points: [{ x: 0, y: 0, shape: "triangle", size: 8 }, { x: 10, y: 10 }] })
        const half = c.markSize(0) / 2
        for (let d = 0; d < half; d += 2) {
            compare(c.pointAt(c.xOf(0) + d, c.yOf(0)), 0, "right by " + d)
        }
    }

    function test_keysStayInPlot() {
        const c = createTemporaryObject(chartComponent, stage(),
                                        { xMin: 0, xMax: 10, points: [{ x: 5, y: 0 }, { x: 50, y: 1 }] })
        c.forceActiveFocus()
        keyClick(Qt.Key_End)
        compare(c.currentIndex, 0)
        keyClick(Qt.Key_Right)
        compare(c.currentIndex, 0)
    }

    function test_fixedEndNotWidened() {
        const c = createTemporaryObject(chartComponent, stage(),
                                        { xMin: 0, points: [{ x: -5, y: 0 }, { x: -1, y: 1 }] })
        compare(c.axes.x0, 0)
        const s = createTemporaryObject(chartComponent, stage(),
                                        { yMin: 0, points: [{ x: 0, y: 0 }, { x: 1, y: 0 }] })
        compare(s.axes.y0, 0)
        verify(s.axes.y1 > 0)
        const b = createTemporaryObject(chartComponent, stage(),
                                        { yMin: 0, yMax: 5, points: [{ x: 0, y: 2 }, { x: 1, y: 2 }] })
        compare(b.axes.y0, 0)
        compare(b.axes.y1, 5)
    }

    function watch(target, name) {
        spy.signalName = ""
        spy.target = target
        spy.signalName = name
        spy.clear()
    }
}
