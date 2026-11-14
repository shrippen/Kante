import QtQuick
import QtTest
import QtQuick.Controls as QQC2
import Kante

/**
 * KanteToolButton shows its text when the icon is not found (the theme lacks the name, the url
 * does not load); an icon that is there stays alone with IconOnly.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteToolFallback"
    width: 400
    height: 300
    when: windowShown

    readonly property string found: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='8' height='8'><rect width='8' height='8'/></svg>"

    Component {
        id: button
        KanteToolButton {
            text: "Move"
            property string iconName: ""
            property url iconUrl: ""
            icon.name: iconName
            icon.source: iconUrl
            display: QQC2.AbstractButton.IconOnly
        }
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.Kante
    }

    // The visible Label that draws the text in Kante.
    function labelShown(item) {
        return shown(item, item.text)
    }
    function shown(item, text) {
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            // The platform's own content is hidden by opacity 0, not by visible.
            if (c.opacity === 0) {
                continue
            }
            if (c.text === text && c.visible && c.width > 0) {
                return true
            }
            if (c.visible && shown(c, text)) {
                return true
            }
        }
        return false
    }
    function make(props) {
        const item = createTemporaryObject(button, tc.Window.contentItem, props)
        verify(item)
        return item
    }

    function test_missing_name_shows_text() {
        const b = make({ iconName: "kante-no-such-icon" })
        tryVerify(function () { return labelShown(b) })
    }
    function test_missing_url_shows_text() {
        const b = make({ iconUrl: "file:///kante-no-such-file.svg" })
        tryVerify(function () { return labelShown(b) })
    }
    function test_found_icon_stays_alone() {
        const b = make({ iconUrl: found })
        wait(200)
        verify(!labelShown(b))
    }
    function test_text_beside_icon_shows_text() {
        const b = make({ iconUrl: found, display: QQC2.AbstractButton.TextBesideIcon })
        tryVerify(function () { return labelShown(b) })
    }
    function test_system_missing_icon_is_text_only() {
        KanteStyle.kind = KanteStyle.Kind.System
        const b = make({ iconName: "kante-no-such-icon" })
        tryCompare(b, "display", QQC2.AbstractButton.TextOnly)
    }
    function test_system_found_icon_keeps_display() {
        KanteStyle.kind = KanteStyle.Kind.System
        const b = make({ iconUrl: found })
        wait(200)
        compare(b.display, QQC2.AbstractButton.IconOnly)
    }
}
