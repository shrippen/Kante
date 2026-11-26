import QtQuick
import QtTest
import Kante

/**
 * Revision colours: the nine page colours of screenplay revisions in their fixed order. Data
 * colours like the labels: the same in System; light theme has the darker reading.
 */
TestCase {
    id: tc
    name: "KanteRevision"
    width: 200
    height: 100
    when: windowShown

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = false
    }

    function test_order() {
        compare(KanteStyle.revisions.join(), "white,blue,pink,yellow,green,goldenrod,buff,salmon,cherry")
        for (let i = 0; i < KanteStyle.revisions.length; i++) {
            verify(KanteStyle.revisionColor(KanteStyle.revisions[i]).a > 0)
        }
        compare(String(KanteStyle.revisionColor("nope")), "transparent")
    }

    function test_dark() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = true
        compare(String(KanteStyle.revisionColor("blue")), "#6e9df0")
        KanteStyle.kind = KanteStyle.Kind.System
        compare(String(KanteStyle.revisionColor("blue")), "#6e9df0")
    }

    function test_light() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.preferDark = false
        KanteStyle.preferLight = true
        compare(String(KanteStyle.revisionColor("white")), "#717171")
        KanteStyle.preferLight = false
    }
}
