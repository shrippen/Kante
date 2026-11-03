import QtQuick
import QtQuick.Controls as QQC2
import QtTest
import org.kde.kirigami as Kirigami
import Kante

/**
 * Kante 1.68, from Mitori's comment page: a heading with `wrapMode` breaks its lines in Kante
 * too. Kante draws the text itself, over the hidden original; that text was one line and
 * elided a long title ("Roku-ban/ Futatsu-gachi (Futatsu-kachi): (6. Hidari-gote / 7. …").
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante168"
    width: 300
    height: 400
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }

    readonly property string longTitle: "Roku-ban/ Futatsu-gachi (Futatsu-kachi): (6. Hidari-gote / 7. Migigote)"

    Component {
        id: heading
        KanteHeading {
            width: 260
            level: 2
        }
    }

    // The text Kante draws (the label child over the hidden original).
    function drawn(h) {
        for (let i = 0; i < h.children.length; ++i) {
            if (h.children[i].objectName === "kanteText") {
                return h.children[i]
            }
        }
        return null
    }

    function test_wrapsInKante() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const h = createTemporaryObject(heading, tc, { text: longTitle, wrapMode: Text.Wrap })
        const label = drawn(h)
        verify(label && h.kanteDrawn, "Kante draws the text")
        verify(!label.truncated, "the whole title, not elided")
        verify(label.lineCount > 1, "broken into lines: " + label.lineCount)
        verify(label.width <= h.width)
        verify(h.height >= label.height - 1, "the heading as high as its lines")
    }

    // Without wrapMode it stays one line, elided as before.
    function test_oneLineByDefault() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        const h = createTemporaryObject(heading, tc, { text: longTitle })
        const label = drawn(h)
        compare(label.lineCount, 1)
        verify(label.truncated)
    }
}
