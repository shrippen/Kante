import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
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
        failOnWarning(/Binding loop/)   // the runner only prints it; the apps' tests fail on it
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

    Component {
        id: iconInLayoutScene
        RowLayout {
            property alias icon: laidOutIcon
            KanteIcon {
                id: laidOutIcon
                property real sizeAtName: -1
                onNameChanged: if (name !== "") sizeAtName = sourceSize.height
                iconSource: "go-next"
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
            }
        }
    }
    Component {
        id: unpaddedButtonScene
        KanteButton {
            text: "A label longer than any style's minimum width"
            padding: 0      // the desktop style (Plasma): its native button draws the margin itself
        }
    }

    // 1.73.1: IconImage picks the theme's file when the name is set. Set before the layout has sized
    // it, a scaled file for the wrong size stayed: on Plasma grey and soft, seen only on the screen.
    function test_icon_named_once_its_size_is_known() {
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        compare(row.icon.name, "go-next")
        compare(row.icon.sourceSize.width, 22)
    }

    function test_icon_picks_again_at_a_new_size() {
        const icon = createTemporaryObject(iconScene, stage())
        icon.width = 32
        icon.height = 32
        compare(icon.name, "go-next")
        compare(icon.sourceSize.width, 32)
        icon.iconSource = "qrc:/x.svg"
        compare(icon.name, "", "a url is no theme name")
    }

    function test_button_keeps_a_margin_without_padding() {
        const button = createTemporaryObject(unpaddedButtonScene, stage())
        waitForRendering(button)
        let content = null
        for (let i = 0; i < button.children.length; i++) {
            if (button.children[i].toString().indexOf("RowLayout") >= 0) {
                content = button.children[i]
            }
        }
        verify(content, "the drawn content")
        const margin = (button.implicitWidth - content.implicitWidth) / 2
        verify(margin >= KanteStyle.unit(8) - 0.5, "margin " + margin)
        verify(content.x >= KanteStyle.unit(8) - 0.5, "left " + content.x)
    }

    Component {
        id: skinnedFieldScene
        QQC2.TextField {
            height: 60
            placeholderText: "Hint"
            KanteFieldSkin { control: parent }
        }
    }
    Component {
        id: skinnedAreaScene
        QQC2.TextArea {
            height: 100
            placeholderText: "Hint"
            KanteFieldSkin { control: parent }
        }
    }

    function test_skin_placeholder_place() {
        const field = createTemporaryObject(skinnedFieldScene, stage())
        const inField = findChild(field, "kantePlaceholder")
        verify(Math.abs(inField.y + inField.height / 2 - 30) < 1, "a line in its middle: " + inField.y)
        const area = createTemporaryObject(skinnedAreaScene, stage())
        const inArea = findChild(area, "kantePlaceholder")
        compare(inArea.y, area.topPadding, "a text area from the top")
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
