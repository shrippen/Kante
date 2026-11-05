import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.73: what sits where. Icons take their colour on every platform, a button's content is in
 * its middle, a text field's placeholder stays inside the box, a slider's track can take a colour.
 * Run: tools/check-qml.sh (QT_QUICK_CONTROLS_STYLE=Material shows the floating placeholder).
 */
TestCase {
    id: tc
    name: "Kante173"
    width: 400
    height: 400
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    Component {
        id: buttonScene
        KanteButton {
            text: "Save"
            topPadding: 10      // a style's uneven padding
            bottomPadding: 6
        }
    }
    Component {
        id: fieldScene
        KanteTextField {
            width: 120
            placeholderText: "A long hint that does not fit into the field at all"
        }
    }
    Component {
        id: iconScene
        KanteIcon {
            width: 22
            height: 22
            iconSource: "go-next"
            color: "#ff0000"
        }
    }
    Component {
        id: sliderScene
        QQC2.Slider {
            id: slider
            width: 200
            property alias skin: skin
            KanteSliderSkin {
                id: skin
                control: slider
                trackColor: "#112233"
            }
        }
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    function test_button_content_in_the_middle() {
        const button = createTemporaryObject(buttonScene, stage())
        waitForRendering(button)
        let content = null
        for (let i = 0; i < button.children.length; i++) {
            if (button.children[i].toString().indexOf("RowLayout") >= 0) {
                content = button.children[i]
            }
        }
        verify(content, "the drawn content")
        const centre = content.y + content.height / 2
        verify(Math.abs(centre - button.height / 2) < 0.75, "centre " + centre + " of " + button.height)
    }

    function test_placeholder_inside_the_field() {
        const field = createTemporaryObject(fieldScene, stage())
        field.forceActiveFocus()
        waitForRendering(field)
        const hint = findChild(field, "kantePlaceholder")
        verify(hint.visible, "seen in the empty field with the focus")
        verify(hint.y >= 0 && hint.y + hint.height <= field.height, "inside the box: " + hint.y)
        verify(hint.x + hint.width <= field.width, "a long one is cut: " + hint.width)
        compare(field.placeholderTextColor.a, 0, "the style's own is not seen")
        field.text = "x"
        verify(!hint.visible)
    }

    function test_icon_takes_its_colour() {
        const icon = createTemporaryObject(iconScene, stage())
        compare(icon.name, "go-next")
        verify(Qt.colorEqual(icon.color, "#ff0000"))
        const url = createTemporaryObject(iconScene, stage(), { iconSource: "qrc:/x.svg" })
        compare(url.name, "")
        compare(String(url.source), "qrc:/x.svg")
    }

    // No test loaded the gallery: a typo in it went unseen.
    function test_gallery_loads() {
        const gallery = Qt.createComponent(Qt.resolvedUrl("../demo/Gallery.qml"), Component.PreferSynchronous)
        tryVerify(() => gallery.status !== Component.Loading)
        compare(gallery.status, Component.Ready, gallery.errorString())
    }

    function test_slider_track_colour() {
        const slider = createTemporaryObject(sliderScene, stage())
        const track = findChild(slider, "kanteSliderTrack")
        verify(Qt.colorEqual(track.color, "#112233"))
    }
}
