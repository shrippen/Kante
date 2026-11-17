import QtQuick
import QtTest
import Kante

/**
 * KanteStyle.studyFont (the Japanese family, larger, for text the learner studies) and
 * KanteAudioMeter.scaleUnit (a unit after each scale label).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteStudyFont"
    width: 600
    height: 300
    when: windowShown

    Component { id: meterComponent; KanteAudioMeter { showScale: true } }

    // The scale labels the meter keeps, in order (a dropped one has no start).
    function texts(m) {
        var all = findAll(m, c => c.text !== undefined && c.font !== undefined)
        return all.filter((c, i) => m.scaleStarts[i] >= 0).map(c => c.text)
    }
    function findAll(item, pred) {
        var out = []
        for (var i = 0; i < item.children.length; i++) {
            var c = item.children[i]
            if (pred(c))
                out.push(c)
            out = out.concat(findAll(c, pred))
        }
        return out
    }
    function test_study_font_point_size() {
        var f = KanteStyle.studyFont(Qt.font({ family: "Sans", pointSize: 10, bold: true }))
        compare(f.family, KanteStyle.japaneseFamily)
        compare(f.pointSize, 10 * KanteStyle.studyScale)
        verify(f.bold)
        compare(KanteStyle.studyScale, 1.35)
    }

    function test_study_font_pixel_size() {
        // 17 px is 12.75 pt; rounded down on the way it grew to 21 px instead of 23.
        const f = KanteStyle.studyFont(Qt.font({ family: "Sans", pixelSize: 17 }))
        compare(f.family, KanteStyle.japaneseFamily)
        fuzzyCompare(f.pointSize, 12.75 * KanteStyle.studyScale, 0.01)
        verify(!f.bold)
    }

    function test_study_font_keeps_fractions() {
        // Qt.font() itself rounds a point size down; a font keeps 9.75 when it is assigned.
        const b = Qt.font({ family: "Sans", pointSize: 10 })
        b.pointSize = 9.75
        const f = KanteStyle.studyFont(b)
        fuzzyCompare(f.pointSize, 9.75 * KanteStyle.studyScale, 0.01)
    }

    function test_study_font_default_base() {
        var f = KanteStyle.studyFont()
        compare(f.family, KanteStyle.japaneseFamily)
        verify(f.pointSize > KanteStyle.defaultFont.pointSize)
    }

    function test_scale_unit_shows_after_labels() {
        var m = createTemporaryObject(meterComponent, tc, { width: 1000, scaleUnit: "dB" })
        var t = texts(m)
        verify(t.indexOf("0 dB") >= 0, t.join("|"))
        verify(t.indexOf("-60 dB") >= 0, t.join("|"))
        compare(t.length, 4)
    }

    function test_scale_unit_drops_labels_when_narrow() {
        var plain = createTemporaryObject(meterComponent, tc, { width: 130 })
        var unit = createTemporaryObject(meterComponent, tc, { width: 130, scaleUnit: "dB" })
        var kept = s => s.scaleStarts.filter(v => v >= 0).length
        verify(kept(unit) < kept(plain), kept(unit) + " vs " + kept(plain))
        verify(unit.scaleStarts[0] >= 0, "floor stays")
        verify(unit.scaleStarts[3] >= 0, "0 stays")
    }

    function test_without_unit_labels_unchanged() {
        var m = createTemporaryObject(meterComponent, tc, { width: 1000 })
        compare(texts(m).join("|"), "-60|-18|-6|0")
        compare(m.scaleUnit, "")
    }
}
