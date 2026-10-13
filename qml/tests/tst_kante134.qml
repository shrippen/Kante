import QtQuick
import QtTest
import Kante

/**
 * Kante 1.34, a Japanese family for text split into pieces (Kaiwa): KanteStyle.japaneseFamily
 * is the first installed family of japaneseFamilies (else the default font's), and
 * KanteRubyText, KanteDiffText and the morae of KantePitchCurve use it.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante134"
    width: 600
    height: 300
    when: windowShown

    Component { id: rubyComponent; KanteRubyText { markup: "どちらから{来|き}ましたか。" } }
    Component { id: diffComponent; KanteDiffText { parts: [{ text: "コーヒー" }, { text: "を", kind: "removed" }, { text: "が", kind: "added" }] } }
    Component { id: pitchComponent; KantePitchCurve { width: 400; height: 160; morae: ["た", "べ", "る"]; target: [0, 1, 0]; kernel: 1 } }

    function findAll(item, pred) {
        var out = []
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (pred(c)) out.push(c)
            out = out.concat(findAll(c, pred))
        }
        return out
    }

    function test_family_is_installed_japanese_or_default() {
        var f = KanteStyle.japaneseFamily
        verify(f.length > 0)
        var installed = Qt.fontFamilies()
        if (KanteStyle.japaneseFamilies.indexOf(f) >= 0) {
            verify(installed.indexOf(f) >= 0, f + " is installed")
            // No earlier family of the list is installed.
            for (var i = 0; i < KanteStyle.japaneseFamilies.indexOf(f); i++)
                verify(installed.indexOf(KanteStyle.japaneseFamilies[i]) < 0)
        } else {
            compare(f, KanteStyle.defaultFont.family)
        }
    }

    function test_japanese_font_keeps_size() {
        var b = Qt.font({ family: "Sans", pointSize: 17, bold: true })
        var j = KanteStyle.japaneseFont(b)
        compare(j.family, KanteStyle.japaneseFamily)
        compare(j.pointSize, 17)
        verify(j.bold)
        compare(KanteStyle.japaneseFont().pointSize, KanteStyle.defaultFont.pointSize)
    }

    function test_components_use_it() {
        var r = createTemporaryObject(rubyComponent, tc)
        compare(r.font.family, KanteStyle.japaneseFamily)
        compare(r.readingFont.family, KanteStyle.japaneseFamily)
        var d = createTemporaryObject(diffComponent, tc)
        compare(d.font.family, KanteStyle.japaneseFamily)
        var p = createTemporaryObject(pitchComponent, tc)
        var mora = findAll(p, function (c) { return c.text === "べ" })
        verify(mora.length > 0)
        compare(mora[0].font.family, KanteStyle.japaneseFamily)
    }
}
