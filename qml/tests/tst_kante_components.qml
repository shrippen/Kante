import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * The Kante 1.4 components: roles and sizes, the button variants, tabs,
 * toast, counters, and that every new component builds in System and Kante.
 * Run: kante/tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "KanteComponents"
    width: 500
    height: 400
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
        KanteStyle.motion = true
    }

    function test_newRoles() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        compare(KanteStyle.focusColor, KantePalette.dark.focus)
        compare(String(KantePalette.dark.focus), "#5ccfc4")
        compare(String(KantePalette.dark.info), "#5ccfc4")
        compare(String(KantePalette.dark.warning), "#fe8019")
        compare(String(KantePalette.light.accent), "#fabd2f")
        compare(KanteStyle.selectionColor, KantePalette.dark.selection)
        verify(KanteStyle.accentHoverColor !== KanteStyle.accentColor)
    }

    function test_sizesAndCuts() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(KanteStyle.heightSmall, KanteStyle.unit(32))
        compare(KanteStyle.heightMedium, KanteStyle.unit(40))
        compare(KanteStyle.heightLarge, KanteStyle.unit(48))
        verify(KanteStyle.cutSmall < KanteStyle.chamferSmall)
        verify(KanteStyle.chamferSmall < KanteStyle.chamfer)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(KanteStyle.cutSmall, 0)
        verify(!KanteStyle.animate)
    }

    function test_motionSwitch() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = true
        compare(KanteStyle.durationFast, 120)
        compare(KanteStyle.duration, 200)
        compare(KanteStyle.durationSlow, 450)
        KanteStyle.motion = false
        compare(KanteStyle.durationFast, 0)
        compare(KanteStyle.duration, 0)
    }

    Component {
        id: buttonComponent
        KanteButton { text: "Start" }
    }

    function test_buttonHeightsRestore() {
        KanteStyle.kind = KanteStyle.Kind.System
        var b = createTemporaryObject(buttonComponent, tc)
        var systemHeight = b.implicitHeight
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(b.implicitHeight, KanteStyle.heightMedium)
        b.size = KanteButton.Size.Small
        compare(b.implicitHeight, KanteStyle.heightSmall)
        b.size = KanteButton.Size.Large
        compare(b.implicitHeight, KanteStyle.heightLarge)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(b.implicitHeight, systemHeight)
    }

    function test_buttonVariants() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var b = createTemporaryObject(buttonComponent, tc)
        verify(!b.filled)
        b.emphasis = KanteButton.Emphasis.Primary
        verify(b.filled)
        compare(b.kanteInk, KanteStyle.accentForegroundColor)
        b.emphasis = KanteButton.Emphasis.Destructive
        compare(b.kanteInk, KanteStyle.onStateColor)
        b.emphasis = KanteButton.Emphasis.Data
        verify(!b.filled)
        compare(b.kanteInk, KanteStyle.focusColor)
        b.busy = true
        b.raised = true
        wait(20)
        verify(b.width > 0)
    }

    Component {
        id: tabsComponent
        KanteTabBar { model: ["Alle", "Prüfen", "Fertig"]; counts: [42, 7, 35] }
    }

    function test_tabBarSlidesAndSelects() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var t = createTemporaryObject(tabsComponent, tc)
        var spy = createTemporaryObject(spyComponent, tc, { target: t, signalName: "activated" })
        compare(t.currentIndex, 0)
        t.select(2)
        compare(t.currentIndex, 2)
        compare(spy.count, 1)
        t.select(2)
        compare(spy.count, 1)
        t.currentIndex = 0
        compare(t.currentIndex, 0)
    }

    Component {
        id: spyComponent
        SignalSpy { }
    }

    Component {
        id: segmentedComponent
        KanteSegmented { model: ["Raster", "Liste"] }
    }

    function test_segmentedSelects() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(segmentedComponent, tc)
        s.select(1)
        compare(s.currentIndex, 1)
    }

    Component {
        id: toastComponent
        KanteToast { title: "Fertig"; text: "42 Bilder"; life: 150 }
    }

    function test_toastShowsAndHides() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
        var t = createTemporaryObject(toastComponent, tc)
        var spy = createTemporaryObject(spyComponent, tc, { target: t, signalName: "closed" })
        verify(!t.shown)
        t.show()
        verify(t.shown)
        tryVerify(function() { return !t.shown }, 2000)
        compare(spy.count, 1)
    }

    Component {
        id: odometerComponent
        KanteOdometer { value: 7; digits: 3 }
    }

    function test_odometerPadsDigits() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var o = createTemporaryObject(odometerComponent, tc)
        compare(o.padded, "007")
        o.value = 42
        compare(o.padded, "042")
        o.value = -3
        compare(o.padded, "000")
    }

    Component {
        id: pillComponent
        KantePill { text: "Fertig"; state: KantePill.State.Done }
    }

    function test_pillTone() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var p = createTemporaryObject(pillComponent, tc)
        compare(p.tone, KanteStyle.positiveTextColor)
        p.state = KantePill.State.Failed
        compare(p.tone, KanteStyle.negativeTextColor)
        p.state = KantePill.State.Locked
        compare(p.tone, KanteStyle.warningColor)
        verify(p.implicitWidth > 0)
    }

    Component {
        id: cardComponent
        KanteCard { width: 100; height: 60 }
    }

    function test_cardLiftOnlyWhenInteractive() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(cardComponent, tc)
        compare(c.grow, 0)
        compare(c.chamferBottom, 0)
        c.chamferBottom = 12
        compare(c.chamferBottom, 12)
    }

    Component {
        id: liveTextComponent
        KanteLiveText { text: "1 687" }
    }

    function test_liveTextCountsUp() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var t = createTemporaryObject(liveTextComponent, tc)
        compare(t.shown, "1 687")
        t.text = "1 802"
        tryCompare(t, "shown", "1 802", 3000)
        // no whole number: the text just changes
        t.text = "ok"
        compare(t.shown, "ok")
    }

    function test_liveTextWithoutMotion() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
        var t = createTemporaryObject(liveTextComponent, tc)
        t.text = "1 900"
        compare(t.shown, "1 900")
    }

    Component {
        id: liveTileComponent
        KanteTile { name: "Nextcloud"; figure: "OK"; width: 180 }
    }

    function test_tileLiveStates() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
        var t = createTemporaryObject(liveTileComponent, tc)
        verify(!t.stale)
        t.stale = true
        t.staleText = "12 min"
        verify(t.stale)
        t.editing = true
        verify(t._editShown)
        t.editing = false
        verify(!t._editShown)
        t.picked = true
        t.fresh()
        verify(t.picked)
    }

    Component {
        id: liveLineComponent
        Item { width: 100; height: 40; property alias line: l; KanteLiveLine { id: l } }
    }

    function test_liveLineDimsWhenStale() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var o = createTemporaryObject(liveLineComponent, tc)
        compare(o.line.dim, 1)
        compare(o.line.height, KanteStyle.unit(2))
        o.line.stale = true
        compare(o.line.dim, 0.55)
        compare(o.line.height, KanteStyle.unit(4))
    }

    Component {
        id: dropComponent
        KanteDropZone { width: 60; height: 40 }
    }

    function test_dropZoneTones() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var z = createTemporaryObject(dropComponent, tc)
        compare(z.tone, KanteStyle.focusColor)
        z.kind = KanteDropZone.Kind.Cell
        compare(z.tone, KanteStyle.frameColor)
    }

    Component {
        id: settleComponent
        Item {
            width: 200; height: 100
            property alias piece: p
            property alias settler: s
            Rectangle { id: p; x: 100; y: 20; width: 40; height: 30 }
            KanteSettle { id: s; target: p }
        }
    }

    function test_settleEndsInPlace() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var o = createTemporaryObject(settleComponent, tc)
        o.settler.settle(0, 0)
        tryCompare(o.piece, "x", 100, 2000)
        tryCompare(o.piece, "y", 20, 2000)
    }

    // ── Kante 1.5 ────────────────────────────────────────────────────────
    function test_scrimAndTintsAndData() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        compare(KanteStyle.scrimColor, KantePalette.dark.scrim)
        verify(KanteStyle.scrimColor.a > 0.5)
        verify(KanteStyle.tint1Color.a < KanteStyle.tint2Color.a)
        verify(KanteStyle.tintHighlightColor.a < KanteStyle.tintHighlight2Color.a)
        compare(KanteStyle.dataColor(0), KanteStyle.focusColor)
        compare(KanteStyle.dataColor(1), KanteStyle.accentColor)
        // wraps around, also for negative numbers
        compare(KanteStyle.dataColor(6), KanteStyle.dataColor(0))
        compare(KanteStyle.dataColor(-1), KanteStyle.dataColor(5))
    }

    Component {
        id: dialogComponent
        Item {
            width: 200; height: 200
            property alias dialog: d
            QQC2.Dialog { id: d; title: "x" }
            KanteDialogSkin { dialog: d }
        }
    }

    // The skin is a QtObject: it must not count as content of the dialog.
    function test_dialogSkinIsNoContent() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var o = createTemporaryObject(dialogComponent, tc)
        verify(o.dialog.background !== null)
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component {
        id: scrimDialogComponent
        KanteDialog { title: "x" }
    }

    function test_dialogUsesScrimRole() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var d = createTemporaryObject(scrimDialogComponent, tc)
        verify(d.QQC2.Overlay.modal === d.kanteScrim)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(d.QQC2.Overlay.modal !== d.kanteScrim)
    }

    Component {
        id: chipComponent
        KanteChip { text: "urlaub"; checkable: true }
    }

    function test_chipToggles() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(chipComponent, tc)
        var spy = createTemporaryObject(spyComponent, tc, { target: c, signalName: "clicked" })
        verify(!c.checked)
        c.forceActiveFocus()
        keyClick(Qt.Key_Space)
        verify(c.checked)
        compare(spy.count, 1)
        keyClick(Qt.Key_Space)
        verify(!c.checked)
    }

    Component {
        id: settingComponent
        KanteSettingRow { title: "Schwelle"; hint: "62 °C" }
    }

    function test_settingRowReset() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var r = createTemporaryObject(settingComponent, tc)
        var spy = createTemporaryObject(spyComponent, tc, { target: r, signalName: "resetRequested" })
        verify(!r.modified)
        r.modified = true
        verify(r.height > 0)
        compare(spy.count, 0)
    }

    Component {
        id: calendarComponent
        KanteCalendarGrid { year: 2026; month: 10; holidays: [3]; absences: [3, 13]; selectedDay: 5 }
    }

    function test_calendarGridGeometry() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(calendarComponent, tc)
        // 1 October 2026 is a Thursday: three empty cells before it (Monday first), 31 days
        compare(c.offset, 3)
        compare(c.days, 31)
        c.month = 2
        compare(c.days, 28)
        c.month = 3
        compare(c.offset, 6)
    }

    Component {
        id: barChartComponent
        KanteBarChart { width: 200; height: 100; values: [3, 5, 2]; labels: ["A", "B", "C"]; goal: 4 }
    }

    function test_barChartScale() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(barChartComponent, tc)
        compare(c.scaleMax, 5)
        c.values = [[1, 2], [3, 4]]
        compare(c.scaleMax, 7)
        c.maxValue = 10
        compare(c.scaleMax, 10)
    }

    Component {
        id: lineChartComponent
        KanteLineChart { width: 200; height: 100; series: [[1, 3, 2], [2, 2, 4]] }
    }

    function test_lineChartPoints() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(lineChartComponent, tc)
        compare(c.pointsOf([1, 2, 3]).length, 3)
        compare(c.scaleTop, 4)
        var p = c.pointsOf([0, 4])
        verify(p[0].x < p[1].x)
        verify(p[0].y > p[1].y)
    }

    Component {
        id: statusComponent
        KanteStatusLight { name: "Jellyfin" }
    }

    function test_statusLightUptimeTiers() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(statusComponent, tc)
        compare(s.stateForUptime(99.95), KanteStatusLight.State.Ok)
        compare(s.stateForUptime(99.5), KanteStatusLight.State.Warn)
        compare(s.stateForUptime(98), KanteStatusLight.State.Bad)
        s.state = KanteStatusLight.State.Bad
        compare(s.tone, KanteStyle.negativeTextColor)
    }

    Component {
        id: tabsIconComponent
        KanteTabBar { width: 120; model: ["Alle", "Prüfen", "Fertig", "Archiv", "Mehr"]; counts: [1, 2, 3, 4, 5]; countKinds: [0, 2, 0, 0, 0]; badges: true }
    }

    function test_tabBarOverflowKeepsSelectionInView() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
        var t = createTemporaryObject(tabsIconComponent, tc)
        t.select(4)
        compare(t.currentIndex, 4)
        verify(t.implicitWidth > t.width)
    }

    Component {
        id: dayStripComponent
        KanteDayStrip { width: 240; segments: [{ from: 9, to: 12, kind: "work" }, { from: 10, to: 11, kind: "event" }]; now: 10.5 }
    }

    function test_dayStripMapsHours() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var s = createTemporaryObject(dayStripComponent, tc)
        compare(s.xOf(0), 0)
        compare(s.xOf(24), 240)
        compare(s.xOf(12), 120)
    }

    Component {
        id: curveComponent
        KanteCurveEditor {
            width: 300; height: 180
            xMin: 0; xMax: 100; yMin: 0; yMax: 100; step: 5
            points: [{ x: 20, y: 20 }, { x: 50, y: 50 }, { x: 80, y: 80 }]
            onEdited: function (p) { points = p }
        }
    }

    function test_curveEditor() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(curveComponent, tc)
        // Neighbours limit the move; monotonic keeps y between them.
        c.setPoint(1, 95, 5)
        compare(c.points[1].x, 75)
        compare(c.points[1].y, 20)
        c.setPoint(1, 50, 50)
        compare(c.addPoint(60, 60), 2)
        compare(c.points.length, 4)
        compare(c.addPoint(60, 60), -1)
        c.removePoint(2)
        compare(c.points.length, 3)
        c.removePoint(0)
        c.removePoint(0)
        compare(c.points.length, 2)
    }

    function test_curveEditorKeys() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(curveComponent, tc)
        c.forceActiveFocus()
        c.current = 1
        keyClick(Qt.Key_Right)
        compare(c.points[1].x, 55)
        keyClick(Qt.Key_Up)
        compare(c.points[1].y, 55)
        keyClick(Qt.Key_BracketRight)
        compare(c.current, 2)
    }

    Component {
        id: bandComponent
        KanteBandEditor {
            min: 0; max: 100
            bands: [{ value: 0, color: "#111111" }, { value: 50, color: "#222222" }]
            onEdited: function (b) { bands = b }
        }
    }

    function test_bandEditor() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var b = createTemporaryObject(bandComponent, tc)
        b.addBand()
        compare(b.bands.length, 3)
        b.setValue(0, 90)
        compare(b.bands[2].value, 90)
        b.setValue(0, 500)
        verify(b.bands[b.bands.length - 1].value <= 100)
        b.removeBand(0)
        compare(b.bands.length, 2)
        b.removeBand(0)
        b.removeBand(0)
        compare(b.bands.length, 1)
    }

    function test_lineChartReadout() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var c = createTemporaryObject(lineChartComponent, tc)
        compare(c.nearest(0), 0)
        compare(c.nearest(c.width), 2)
        compare(c.nearest(c.width / 2), 1)
        compare(c.hoverIndex, -1)
    }

    Component {
        id: weekComponent
        KanteWeekView {
            width: 420
            events: [{ day: 1, start: 9, end: 10, title: "a", kind: "warn" }, { day: 3, start: 20, end: 22, title: "b", kind: "" }]
        }
    }

    function test_weekView() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var w = createTemporaryObject(weekComponent, tc)
        compare(w.height, w.headHeight + 10 * w.hourHeight)
        compare(w.toneOf("warn"), KanteStyle.warningColor)
    }

    Component {
        id: gallery
        Column {
            KanteChip { text: "x" }
            KanteSwatch { }
            KanteKpi { value: "1"; label: "x"; delta: "+1"; trend: 1 }
            KanteBulkBar { count: 2; width: 300 }
            KanteSettingRow { title: "x"; width: 300 }
            KanteCommandBox { text: "cmd" }
            KanteStatusLight { name: "x" }
            KanteListRow { text: "x" }
            KanteBarChart { values: [1, 2]; width: 100; height: 60 }
            KanteLineChart { series: [[1, 2]]; width: 100; height: 60 }
            KanteSparkline { values: [1, 2, 3] }
            KanteHeatmap { levels: [0, 1, 2, 3, 4] }
            KanteCalendarGrid { width: 280 }
            KanteCurveEditor { points: [{ x: 10, y: 10 }, { x: 90, y: 90 }] }
            KanteBandEditor { bands: [{ value: 0, color: "red" }] }
            KanteWeekView { width: 300 }
            KanteAgenda { days: [{ label: "MO", today: true, entries: [{ time: "9:00", title: "x", kind: "" }] }] }
            KanteDayStrip { width: 200 }
            KanteClock { running: false }
            KanteLiveText { text: "1 687" }
            Item { width: 100; height: 20; KanteLiveLine { } }
            KanteDropZone { width: 40; height: 30 }
            KanteSettle { }
            KanteBanner { title: "Not finished"; width: 200 }
            KanteBrackets { width: 40; height: 40; active: true }
            KanteCallout { title: "Note"; text: "Text"; width: 200 }
            KanteCounter { text: "7" }
            KanteEmptyState { title: "Empty"; width: 200 }
            KanteHazard { width: 100; height: 8 }
            KanteHud { fullText: "// hud"; typing: true }
            KanteLamp { rhythm: KanteLamp.Rhythm.Tick }
            KanteLoader { }
            KanteOdometer { value: 42 }
            KantePill { text: "Fertig"; state: KantePill.State.Done }
            KanteProgressBar { value: 0.5 }
            KanteProgressBar { segments: 8; value: 0.5 }
            KanteProgressBar { indeterminate: true }
            KanteReveal { width: 100; height: 30; Rectangle { anchors.fill: parent } }
            KanteAppear { width: 100; height: 30; Rectangle { anchors.fill: parent } }
            KanteRunner { width: 100; height: 40 }
            KanteScrollMeter { width: 100 }
            KanteSegmented { model: ["A", "B"] }
            KanteSkeleton { width: 100 }
            KanteSteps { model: ["A", "B"]; current: 1 }
            KanteSticker { text: "v1" }
            KanteTabBar { model: ["A", "B"] }
            KanteTile { name: "IMG"; figure: "99 %" }
            KanteTube { width: 100; height: 40; Rectangle { anchors.fill: parent } }
            KanteToast { title: "Toast"; width: 200 }
            KanteTick { width: 20; height: 20; checked: true }
            KantePolygon { width: 40; height: 40; fillColor: "red"; cutBottomLeft: 8 }
        }
    }

    function test_newComponentsInBothKinds() {
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.KanteLight, KanteStyle.Kind.System]
        var g = createTemporaryObject(gallery, tc)
        verify(g !== null)
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(30)
            verify(g.children.length >= 46)
        }
    }
}
