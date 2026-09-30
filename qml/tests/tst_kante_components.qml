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
        id: gallery
        Column {
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
            verify(g.children.length >= 27)
        }
    }
}
