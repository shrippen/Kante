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

    // Kante 1.76.3: a button builds its three hopping squares while busy only. Every button
    // carried them hidden: 2860 of 20650 objects at the start of the Plasmai widget.
    function test_button_builds_its_loader_while_busy() {
        function loaders(item) {
            let n = item.size !== undefined && item.running !== undefined && item.color !== undefined ? 1 : 0
            for (let i = 0; i < item.children.length; i++) {
                n += loaders(item.children[i])
            }
            return n
        }
        const b = createTemporaryObject(buttonScene, stage())
        compare(loaders(b), 0, "idle: no loader")
        b.busy = true
        compare(loaders(b), 1, "busy: the loader")
        b.busy = false
        compare(loaders(b), 0, "done: gone again")
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
                property int picks: 0
                onNameChanged: if (name !== "") { sizeAtName = sourceSize.height; picks++ }
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

    // 1.74.1: IconImage picks the theme's file when the name is set. Set before the layout has sized
    // it, a scaled file for the wrong size stayed: on Plasma grey and soft, seen only on the screen.
    function test_icon_named_once_its_size_is_known() {
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        compare(row.icon.name, "go-next")
        compare(row.icon.sourceSize.width, 22)
    }

    function test_icon_picks_again_at_a_new_size() {
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        row.icon.Layout.preferredWidth = 32
        row.icon.Layout.preferredHeight = 32
        tryCompare(row.icon, "sizeAtName", 32)
        row.icon.iconSource = "qrc:/x.svg"
        compare(row.icon.name, "", "a url is no theme name")
    }

    // 1.76.3: every set name is a lookup in the icon theme, several ms on Plasma; a layout settles
    // width and height one after the other, and each change looked the icon up again.
    function test_icon_picks_once_per_new_size() {
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        wait(50)
        const before = row.icon.picks
        row.icon.Layout.preferredWidth = 32
        row.icon.Layout.preferredHeight = 32
        tryCompare(row.icon, "sizeAtName", 32)
        wait(50)
        compare(row.icon.picks - before, 1, "one lookup for width and height")
        row.icon.Layout.preferredWidth = 32
        wait(50)
        compare(row.icon.picks - before, 1, "the same size: no lookup")
    }

    // 1.76.3: a url icon is drawn at the item's size, also after a new one (review of PR #133:
    // the key of a url was always "", so pick() stopped before it set sourceSize).
    function test_url_icon_takes_its_size() {
        const svg = "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='8' height='8'><rect width='8' height='8'/></svg>"
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        row.icon.iconSource = svg
        tryCompare(row.icon.sourceSize, "width", 22)
        row.icon.Layout.preferredWidth = 48
        row.icon.Layout.preferredHeight = 48
        tryCompare(row.icon.sourceSize, "width", 48)
        compare(row.icon.sourceSize.height, 48)
        compare(row.icon.name, "", "a url is no theme name")
        const icon = createTemporaryObject(iconScene, stage(), { iconSource: svg, width: 48, height: 48 })
        tryCompare(icon.sourceSize, "width", 48)
    }

    // 1.76.3: an IconImage without name and source looks up "" in the icon theme, uncached,
    // ~6.5 ms each on Plasma: buttons were ten times slower to create than before 1.73.
    function test_icon_never_without_a_source() {
        const icon = createTemporaryObject(iconScene, stage(), { width: 0, height: 0 })
        compare(icon.name, "", "no size: no theme name")
        verify(String(icon.source) !== "", "a placeholder instead")
        const row = createTemporaryObject(iconInLayoutScene, stage())
        tryCompare(row.icon, "sizeAtName", 22)
        verify(String(row.icon.source) !== "", "a named icon keeps it as fallback")
    }

    Component {
        id: narrowIconScene
        KanteButton {
            width: 28
            padding: 0
            icon.name: "go-next"
            display: QQC2.AbstractButton.IconOnly
        }
    }

    function test_narrow_icon_button_keeps_the_symbol_in_the_middle() {
        // padding: 0 does not lower every style's side padding (Material keeps 16): the middle holds anyway
        for (const props of [{}, { display: QQC2.AbstractButton.TextBesideIcon, text: "" }]) {
            const button = createTemporaryObject(narrowIconScene, stage(), props)
            waitForRendering(button)
            const symbol = findIcon(button)
            verify(symbol, "the symbol")
            const left = symbol.mapToItem(button, 0, 0).x
            const right = button.width - (left + symbol.width)
            verify(Math.abs(left - right) < 1, "left " + left + ", right " + right)
            verify(left >= 0, "inside the button: " + left)
        }
    }

    function findIcon(item) {
        for (let i = 0; i < item.children.length; i++) {
            const child = item.children[i]
            if (child.iconSource !== undefined && child.visible) {
                return child
            }
            const inner = findIcon(child)
            if (inner) {
                return inner
            }
        }
        return null
    }

    function test_narrow_button_keeps_its_margin() {
        const button = createTemporaryObject(unpaddedButtonScene, stage(), { width: 120 })
        waitForRendering(button)
        let content = null
        for (let i = 0; i < button.children.length; i++) {
            if (button.children[i].toString().indexOf("RowLayout") >= 0) {
                content = button.children[i]
            }
        }
        verify(content, "the drawn content")
        verify(content.x >= KanteStyle.unit(8) - 0.5, "left " + content.x)
        verify(content.x + content.width <= 120 - KanteStyle.unit(8) + 0.5, "right " + (content.x + content.width))
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
