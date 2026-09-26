import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Loads the Kante QML module, creates every component in both kinds and
 * checks that System forwards Kirigami.Theme while Kante uses the palette.
 * Run: tools/check-qml.sh (qmltestrunner, offscreen).
 */
TestCase {
    id: tc
    name: "Kante"
    width: 400
    height: 400
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.preferDark = false
    }

    function test_systemForwardsPlatformTheme() {
        KanteStyle.kind = KanteStyle.Kind.System
        verify(!KanteStyle.active)
        compare(KanteStyle.textColor, Kirigami.Theme.textColor)
        compare(KanteStyle.highlightColor, Kirigami.Theme.highlightColor)
        compare(KanteStyle.chamfer, 0)
        compare(KanteStyle.monoFamily, "monospace")
    }

    function test_kanteUsesPalette() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        verify(KanteStyle.active)
        verify(!KanteStyle.light)
        compare(KanteStyle.textColor, KantePalette.dark.text)
        compare(KanteStyle.accentColor, KantePalette.dark.accent)
        compare(String(KantePalette.dark.accent), "#fabd2f")
        verify(KanteStyle.chamfer > 0)
        // surfaces are translucent tints
        verify(KanteStyle.cardColor.a < 1)
        verify(KanteStyle.sunkenColor.a < 1)
    }

    // Kante Light: Kante shapes and type, every color live from the platform theme.
    function test_kanteLightKeepsThemeColors() {
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        verify(KanteStyle.active)
        verify(!KanteStyle.themed)
        compare(KanteStyle.textColor, Kirigami.Theme.textColor)
        compare(KanteStyle.backgroundColor, Kirigami.Theme.backgroundColor)
        compare(KanteStyle.accentColor, Kirigami.Theme.highlightColor)
        compare(KanteStyle.negativeTextColor, Kirigami.Theme.negativeTextColor)
        verify(KanteStyle.chamfer > 0)
        compare(KanteStyle.titleFont(12).capitalization, Font.AllUppercase)
        verify(KanteStyle.headingFont(12).capitalization !== Font.AllUppercase)
    }

    Component {
        id: buttonComponent
        KanteButton { text: "Start" }
    }

    // Controls stay the platform's in Kante Light: no Kante frame, platform background visible.
    function test_kanteLightKeepsPlatformControls() {
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        var b = createTemporaryObject(buttonComponent, tc)
        verify(b.background === null || b.background.opacity === 1)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(b.background === null || b.background.opacity === 0)
    }

    // Kante Light: section labels and the page title are Kante, other headings the platform's.
    function test_kanteLightHeadings() {
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        var section = createTemporaryObject(headingComponent, tc)
        verify(section.kanteDrawn)
        compare(section.color.a, 0)
        var sub = createTemporaryObject(level2Component, tc)
        verify(!sub.kanteDrawn)
        verify(sub.color.a > 0)
        var title = createTemporaryObject(titleComponent, tc)
        verify(title.kanteDrawn)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(sub.kanteDrawn)
    }

    Component {
        id: level2Component
        KanteHeading { level: 2; text: "Week" }
    }

    Component {
        id: titleComponent
        KanteHeading { level: 3; pageTitle: true; text: "Plasmai" }
    }

    function test_fontsLoad() {
        tryVerify(function() { return KanteStyle.headingFace.status === FontLoader.Ready }, 3000)
        tryVerify(function() { return KanteStyle.monoFace.status === FontLoader.Ready }, 3000)
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(KanteStyle.headingFont(12).capitalization, Font.AllUppercase)
        compare(KanteStyle.monoFamily, KanteStyle.monoFace.font.family)
    }

    Component {
        id: gallery
        Column {
            KanteScope { target: parent }
            KanteCard { width: 100; height: 40; barColor: KanteStyle.accentColor }
            KanteButton { text: "Start"; emphasis: KanteButton.Emphasis.Primary }
            KanteButton { text: "Stop"; emphasis: KanteButton.Emphasis.Destructive }
            KanteToolButton { icon.name: "document-edit" }
            KanteTextField { text: "Rohschnitt" }
            KanteHeading { level: 4; text: "Recent" }
            QQC2.CheckBox {
                checked: true
                KanteCheckSkin { control: parent }
            }
            QQC2.Switch {
                KanteCheckSkin { control: parent; shape: KanteCheckSkin.Shape.Switch }
            }
            QQC2.ComboBox {
                model: ["System", "Kante"]
                KanteFieldSkin { control: parent }
            }
            QQC2.SpinBox {
                KanteFieldSkin { control: parent }
            }
            QQC2.Slider {
                KanteSliderSkin { control: parent }
            }
            Kirigami.InlineMessage {
                text: "Error"
                type: Kirigami.MessageType.Error
                visible: true
                KanteMessageSkin { message: parent }
            }
            KanteDialog { id: dlg; title: "Title" }
            QQC2.Menu { id: menu; QQC2.MenuItem { text: "Item" } }
            KantePopupSkin { popup: menu }
        }
    }

    function test_componentsInBothKinds() {
        var kinds = [KanteStyle.Kind.System, KanteStyle.Kind.Kante, KanteStyle.Kind.System]
        var g = createTemporaryObject(gallery, tc)
        verify(g !== null)
        for (var i = 0; i < kinds.length; i++) {
            KanteStyle.kind = kinds[i]
            wait(50)
            verify(g.children.length > 10)
        }
    }

    Component {
        id: headingComponent
        KanteHeading { level: 4; text: "Recent" }
    }

    // Switching back to System must restore the heading exactly (overlay pattern).
    function test_headingRestoresAfterKante() {
        KanteStyle.kind = KanteStyle.Kind.System
        var h = createTemporaryObject(headingComponent, tc)
        var colorBefore = String(h.color)
        var fontBefore = h.font.family
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(h.color.a, 0)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(String(h.color), colorBefore)
        compare(h.font.family, fontBefore)
    }
}
