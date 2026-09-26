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
        KanteStyle.materialStyle = false
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

    Component {
        id: spinSkinComponent
        QQC2.SpinBox {
            property alias skin: spinSkin
            KanteFieldSkin { id: spinSkin; control: parent }
        }
    }

    // A spin box keeps its own text and has no drop-down arrow.
    function test_fieldSkinSpinBoxIsNoCombo() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var spin = createTemporaryObject(spinSkinComponent, tc)
        verify(!spin.skin.comboBox)
        compare(spin.skin.control.contentItem.opacity, 1)
    }

    Component {
        id: textAreaSkinComponent
        QQC2.TextArea {
            property alias skin: areaSkin
            KanteFieldSkin { id: areaSkin; control: parent }
        }
    }

    // A text area has no contentItem: the skin must not bind to it (was
    // "Unable to assign [undefined] to QObject*" in every kind).
    function test_fieldSkinTextAreaNoWarning() {
        failOnWarning(/Unable to assign/)
        KanteStyle.kind = KanteStyle.Kind.Kante
        var area = createTemporaryObject(textAreaSkinComponent, tc)
        verify(area !== null)
        verify(!area.skin.comboBox)
        KanteStyle.kind = KanteStyle.Kind.System
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    function test_cardIsSquare() {
        var card = createTemporaryObject(cardComponent, tc)
        compare(card.radius, 0)
    }

    Component {
        id: cardComponent
        KanteCard { width: 40; height: 20 }
    }

    Component {
        id: textInputsComponent
        Column {
            property alias field: field
            property alias area: area
            KanteTextField { id: field; text: "09:00" }
            QQC2.TextArea { id: area; text: "Notiz"; KanteFieldSkin { control: parent } }
        }
    }

    // org.kde.desktop does not draw the text of a text field or area that has a
    // hidden child below it (z < 0); in System the Kante parts must hide inside it.
    function test_textInputsHaveNoHiddenChildBelow() {
        var c = createTemporaryObject(textInputsComponent, tc)
        tc.visible = true
        verify(c.field.visible)
        var inputs = [c.field, c.area]
        for (var i = 0; i < inputs.length; i++) {
            var kids = inputs[i].children
            for (var k = 0; k < kids.length; k++) {
                if (kids[k] === inputs[i].background) {
                    continue
                }
                verify(!(kids[k].z < 0 && !kids[k].visible), "hidden item below the text of input " + i)
            }
        }
    }

    Component {
        id: placeholderComponent
        Column {
            property alias field: phField
            property alias area: phArea
            KanteTextField { id: phField; placeholderText: "09:00"; text: "17:00" }
            QQC2.TextArea { id: phArea; placeholderText: "Note"; text: "Hi"; KanteFieldSkin { control: parent } }
        }
    }

    // Material floats the placeholder above a filled field; Kante draws its own
    // frame, so a filled field shows no placeholder. System keeps the style's.
    function test_placeholderOnlyWhenEmpty() {
        var c = createTemporaryObject(placeholderComponent, tc)
        compare(c.field.placeholderText, "09:00")
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(c.field.placeholderText, "")
        compare(c.area.placeholderText, "")
        c.field.text = ""
        compare(c.field.placeholderText, "09:00")
        KanteStyle.kind = KanteStyle.Kind.System
        compare(c.area.placeholderText, "Note")
    }

    Component {
        id: scopeComponent
        Item {
            id: outer
            property alias inner: inner
            Kirigami.Theme.inherit: false
            Kirigami.Theme.textColor: "red"
            Item {
                id: inner
                KanteScope { target: inner }
            }
        }
    }

    // The scope must never detach the target (inherit = false): under the Plasma theme the
    // children keep the detached colour table, and after leaving Kante it is empty, so their
    // text turns invisible. Custom colours apply while inheriting, so detaching is not needed.
    function test_scopeKeepsInheriting() {
        var o = createTemporaryObject(scopeComponent, tc)
        verify(o.inner.Kirigami.Theme.inherit)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(o.inner.Kirigami.Theme.inherit)
        compare(o.inner.Kirigami.Theme.textColor, KanteStyle.textColor)
        KanteStyle.kind = KanteStyle.Kind.System
        verify(o.inner.Kirigami.Theme.inherit)
    }

    // After Kante the scope inherits again: later theme changes reach it
    // (a restored value would freeze the old colors).
    function test_scopeInheritsAfterKante() {
        var o = createTemporaryObject(scopeComponent, tc)
        compare(String(o.inner.Kirigami.Theme.textColor), "#ff0000")
        KanteStyle.kind = KanteStyle.Kind.Kante
        compare(o.inner.Kirigami.Theme.textColor, KanteStyle.textColor)
        KanteStyle.kind = KanteStyle.Kind.System
        o.Kirigami.Theme.textColor = "blue"
        compare(String(o.inner.Kirigami.Theme.textColor), "#0000ff")
    }

    // With the Material style the scope leaves Kirigami.Theme alone.
    function test_scopeOffWithMaterialStyle() {
        KanteStyle.materialStyle = true
        var o = createTemporaryObject(scopeComponent, tc)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(o.inner.Kirigami.Theme.inherit)
        compare(String(o.inner.Kirigami.Theme.textColor), "#ff0000")
        KanteStyle.materialStyle = false
    }

    Component {
        id: wideButtonComponent
        // style content narrower than Kante's label (as with Material)
        KanteButton { text: "Verwenden und speichern"; contentItem: Item { implicitWidth: 10; implicitHeight: 10 } }
    }

    // The uppercase Rajdhani label fits: the button grows for it in Kante.
    function test_buttonFitsKanteLabel() {
        var b = createTemporaryObject(wideButtonComponent, tc)
        var systemWidth = b.implicitWidth
        KanteStyle.kind = KanteStyle.Kind.Kante
        tryVerify(function() { return KanteStyle.headingFace.status === FontLoader.Ready }, 3000)
        tryVerify(function() { return b.implicitWidth > systemWidth }, 2000)
        var label = b.children.filter(function(c) { return c.toString().indexOf("RowLayout") >= 0 })[0]
        verify(b.implicitWidth >= label.implicitWidth + b.leftPadding + b.rightPadding)
        KanteStyle.kind = KanteStyle.Kind.System
        compare(b.implicitWidth, systemWidth)
    }

    Component {
        id: paddedHeadingComponent
        KanteHeading { level: 4; text: "Section"; topPadding: 20 }
    }

    // Space above a section (topPadding) keeps the Kante label on the text line.
    function test_headingPaddingKeepsLabelOnText() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        var h = createTemporaryObject(paddedHeadingComponent, tc)
        var label = h.children.filter(function(c) { return c.text === "Section" })[0]
        var labelMid = label.y + label.height / 2
        var textMid = h.topPadding + (h.height - h.topPadding - h.bottomPadding) / 2
        verify(Math.abs(labelMid - textMid) <= 1, labelMid + " vs " + textMid)
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
