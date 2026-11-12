import QtQuick
import QtTest
import Kante

/**
 * From Klecks: threshold lines and axis captions in `KanteLineChart`, `KanteFileDrop`, the image
 * and placeholder of `KanteTile`, clickable steps and error steps in `KanteSteps`.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteKlecks"
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

    // tc itself is not visible; items need the window's content item to be.
    function stage() {
        return tc.Window.contentItem
    }

    Component {
        id: chartComponent
        KanteLineChart { width: 240; height: 140; series: [[1, 3, 2, 5, 4]] }
    }

    // Aims the shared spy at a signal (the old signal first: a spy keeps one).
    function watch(target, name) {
        spy.signalName = ""
        spy.target = target
        spy.signalName = name
        spy.clear()
    }

    function limits(chart) {
        const found = []
        for (let i = 0; i < chart.children.length; i++) {
            if (chart.children[i].objectName === "kanteThreshold") {
                found.push(chart.children[i])
            }
        }
        return found
    }

    function test_thresholdSitsAtItsValue() {
        const c = createTemporaryObject(chartComponent, stage())
        c.thresholds = [{ value: 3, label: "Limit" }]
        const found = limits(c)
        compare(found.length, 1)
        compare(found[0].lineY, c.yOf(3))
        verify(found[0].visible)
        // The point with value 3 lies on the line.
        compare(c.pointsOf([3])[0].y, c.yOf(3))
    }

    function thresholdLabel(limit) {
        for (let i = 0; i < limit.children.length; i++) {
            if (limit.children[i].text !== undefined) {
                return limit.children[i]
            }
        }
        return null
    }

    function test_thresholdLabelStaysInside_data() {
        return [
            { tag: "above data", props: { thresholds: [{ value: 8, label: "Limit" }] } },
            { tag: "at data max", props: { thresholds: [{ value: 5, label: "Limit" }] } },
            { tag: "above data, axis", props: { axis: true, thresholds: [{ value: 8, label: "Limit" }] } },
            { tag: "at data max, axis", props: { axis: true, thresholds: [{ value: 5, label: "Limit" }] } }
        ]
    }

    function test_thresholdLabelStaysInside(data) {
        const c = createTemporaryObject(chartComponent, stage(), data.props)
        const label = thresholdLabel(limits(c)[0])
        verify(label.visible)
        verify(label.y >= 0, "label y " + label.y)
        verify(label.y + label.height <= c.height, "label bottom " + (label.y + label.height))
    }

    function test_thresholdColours() {
        const c = createTemporaryObject(chartComponent, stage())
        c.thresholds = [{ value: 2 }, { value: 3, series: 1 }, { value: 4, color: "#112233" }]
        const found = limits(c)
        compare(found.length, 3)
        compare(found[0].tone, KanteStyle.accentColor)
        compare(found[1].tone, KanteStyle.dataColor(1))
        compare(String(found[2].tone), "#112233")
    }

    function test_thresholdAboveDataGrowsTheScale() {
        const c = createTemporaryObject(chartComponent, stage())
        compare(c.scaleTop, 5)
        c.thresholds = [{ value: 8 }]
        compare(c.scaleTop, 8)
        c.maxValue = 6
        verify(!limits(c)[0].visible, "above a fixed scale: not drawn")
    }

    function test_captionsReserveRoom() {
        const c = createTemporaryObject(chartComponent, stage())
        compare(c.padTop, 0)
        compare(c.padBottom, 0)
        compare(c.plotHeight, c.height)
        c.xStart = "Start"
        c.xEnd = "Ende"
        const oneRow = c.padBottom
        verify(oneRow > 0)
        c.xTitle = "Zeit"
        verify(c.padBottom > oneRow)
        c.yTitle = "Breite"
        verify(c.padTop > 0)
        compare(c.plotHeight, c.height - c.padTop - c.padBottom)
        // Every point stays inside the plot.
        const p = c.pointsOf([1, 5])
        verify(p[0].y <= c.padTop + c.plotHeight)
        verify(p[1].y >= c.padTop)
    }

    function test_compactIgnoresCaptions() {
        const c = createTemporaryObject(chartComponent, stage(), { compact: true, xStart: "a", yTitle: "b" })
        compare(c.padTop, 0)
        compare(c.padBottom, 0)
    }

    function test_chartDefaultsUnchanged() {
        const c = createTemporaryObject(chartComponent, stage())
        compare(c.yOf(1), c.pointsOf([1])[0].y)
        compare(c.pointsOf([0])[0].y, c.height - c.mark / 2)
    }

    // --- KanteFileDrop

    Component {
        id: dropComponent
        KanteFileDrop { width: 300; height: 80; hint: "Hierher ziehen"; chooseText: "Auswählen" }
    }

    function test_fileDropEmitsUrls() {
        const d = createTemporaryObject(dropComponent, stage())
        watch(d, "dropped")
        d.take([])
        compare(spy.count, 0, "nothing dropped")
        d.take(["file:///a.mp4", "file:///dir"])
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0].length, 2)
    }

    function test_fileDropKeyboardAndButton() {
        const d = createTemporaryObject(dropComponent, stage())
        watch(d, "chooseRequested")
        verify(d.activeFocusOnTab)
        d.forceActiveFocus()
        keyClick(Qt.Key_Return)
        keyClick(Qt.Key_Space)
        compare(spy.count, 2)
        mouseClick(findChild(d, "chooseButton"))
        compare(spy.count, 3)
        compare(d.dragOver, false)
    }

    function test_fileDropWithoutButton() {
        const d = createTemporaryObject(dropComponent, stage(), { chooseText: "" })
        watch(d, "chooseRequested")
        d.forceActiveFocus()
        keyClick(Qt.Key_Enter)
        compare(spy.count, 1)
    }

    // --- KanteTile image

    Component {
        id: tileComponent
        KanteTile { width: 180; name: "IMG_1" }
    }

    function placeholderOf(t) {
        return findChild(t, "kantePlaceholder")
    }

    function test_tilePlaceholderWithoutImage() {
        const t = createTemporaryObject(tileComponent, stage())
        verify(placeholderOf(t).visible)
        t.placeholder = false
        verify(!placeholderOf(t).visible)
    }

    function test_tileShowsItsSource() {
        const t = createTemporaryObject(tileComponent, stage(), { source: Qt.resolvedUrl("../../docs/icon.svg") })
        const img = findChild(t, "kanteTileImage")
        tryVerify(function () { return img.shown })
        verify(!placeholderOf(t).visible)
        t.source = ""
        verify(placeholderOf(t).visible)
    }

    function test_tileBrokenSourceKeepsPlaceholder() {
        ignoreWarning(new RegExp("Cannot open"))
        const t = createTemporaryObject(tileComponent, stage(), { source: "file:///no/such.png" })
        wait(50)
        verify(placeholderOf(t).visible)
    }

    function test_tileWithoutCaption() {
        const t = createTemporaryObject(tileComponent, stage())
        const withCaption = t.implicitHeight
        t.name = ""
        verify(!t.captioned)
        verify(t.implicitHeight < withCaption)
        t.figure = "98 %"
        compare(t.implicitHeight, withCaption)
    }

    // --- KanteSteps

    Component {
        id: stepsComponent
        KanteSteps { model: ["Eins", "Zwei", "Drei"]; current: 1 }
    }

    function stepItems(s) {
        const items = []
        const row = s.children[0]
        for (let i = 0; i < row.children.length; i++) {
            if (row.children[i].stateKey !== undefined) {
                items.push(row.children[i])
            }
        }
        return items
    }

    function test_stepsNotClickableByDefault() {
        const s = createTemporaryObject(stepsComponent, stage())
        waitForRendering(s)
        watch(s, "activated")
        const items = stepItems(s)
        compare(items.length, 3)
        verify(!items[0].activeFocusOnTab)
        mouseClick(items[0])
        compare(spy.count, 0)
    }

    function test_stepsClickAndKeys() {
        const s = createTemporaryObject(stepsComponent, stage(), { clickable: true })
        waitForRendering(s)
        watch(s, "activated")
        const items = stepItems(s)
        verify(items[2].activeFocusOnTab)
        mouseClick(items[0])
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 0)
        verify(items[0].activeFocus)
        items[2].forceActiveFocus()
        keyClick(Qt.Key_Return)
        keyClick(Qt.Key_Space)
        compare(spy.count, 3)
        compare(spy.signalArguments[2][0], 2)
    }

    function test_stepsFailedCurrentAnnouncesBoth() {
        const s = createTemporaryObject(stepsComponent, stage(), { errors: [1] })
        waitForRendering(s)
        const name = stepItems(s)[1].Accessible.name
        verify(name.indexOf("aktuell") > 0, name)
        verify(name.indexOf("Fehler") > 0, name)
    }

    function test_stepsRoleFollowsClickable() {
        const s = createTemporaryObject(stepsComponent, stage())
        waitForRendering(s)
        compare(stepItems(s)[0].Accessible.role, Accessible.ListItem)
        s.clickable = true
        compare(stepItems(s)[0].Accessible.role, Accessible.Button)
    }

    function test_stepsErrorState() {
        const s = createTemporaryObject(stepsComponent, stage(), { errors: [0, 2] })
        waitForRendering(s)
        const items = stepItems(s)
        compare(items[0].stateKey, "error")
        verify(!items[0].done, "a failed passed step shows no check")
        compare(items[1].stateKey, "current")
        compare(items[2].stateKey, "error")
        verify(items[0].Accessible.name.indexOf("Fehler") > 0, items[0].Accessible.name)
        s.errors = []
        compare(items[0].stateKey, "done")
    }
}
