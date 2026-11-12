import QtQuick
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.60, from Mitori: KanteLevelDots (a level as dots) and KanteLevelPicker (pick 1..4).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante160"
    width: 800
    height: 600
    when: windowShown

    property int kindBefore: KanteStyle.Kind.System
    function init() {
        kindBefore = KanteStyle.kind
        KanteStyle.kind = KanteStyle.Kind.Kante
    }
    function cleanup() {
        KanteStyle.kind = kindBefore
    }
    function stage() {
        return tc.Window.contentItem
    }

    readonly property var words: ["open", "seen", "with help", "sure", "exam-ready"]

    Component {
        id: dotsComponent
        KanteLevelDots { names: tc.words }
    }
    Component {
        id: pickerComponent
        KanteLevelPicker { width: 400; names: tc.words }
    }
    SignalSpy { id: pickSpy; signalName: "picked" }
    Component {
        id: wordComponent
        Text { font: KanteStyle.labelFont() }
    }

    function test_dotsFillToValue() {
        var dots = createTemporaryObject(dotsComponent, stage(), { value: 3 })
        compare(dots.children.length - 1, 4, "four dots (and the repeater)")
        var filled = 0
        for (var i = 0; i < dots.children.length; i++) {
            if (dots.children[i].filled) {
                filled++
            }
        }
        compare(filled, 3)
        compare(dots.Accessible.name, "sure")
        dots.value = 0
        compare(dots.Accessible.name, "open")
        dots.names = []
        compare(dots.Accessible.name, "0 / 4")
    }

    // The level buttons: children of the picker's row.
    function cells(picker) {
        var list = []
        for (var r = 0; r < picker.children.length; r++) {
            var row = picker.children[r]
            for (var i = 0; i < row.children.length; i++) {
                if (row.children[i].level !== undefined) {
                    list.push(row.children[i])
                }
            }
        }
        return list
    }

    function test_tapPicksAlsoTheChosenLevel() {
        var picker = createTemporaryObject(pickerComponent, stage(), { value: 2 })
        pickSpy.clear()
        pickSpy.target = picker
        var c = cells(picker)
        compare(c.length, 4)
        verify(Math.abs(c[0].width - c[3].width) < 0.5, "equal cells")
        mouseClick(c[2])
        compare(pickSpy.signalArguments[0][0], 3)
        compare(picker.value, 2, "presentational: the app sets the value")
        mouseClick(c[1])
        compare(pickSpy.count, 2, "a tap on the chosen level picks it again")
        compare(pickSpy.signalArguments[1][0], 2)
    }

    function test_keyboard() {
        var picker = createTemporaryObject(pickerComponent, stage(), { value: 0 })
        pickSpy.clear()
        pickSpy.target = picker
        picker.forceActiveFocus()
        compare(picker.focusLevel, 1)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Space)
        compare(pickSpy.signalArguments[0][0], 3)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        compare(picker.focusLevel, 4, "stops at the last level")
        keyClick(Qt.Key_Return)
        compare(pickSpy.signalArguments[1][0], 4)
        picker.value = 2
        compare(picker.focusLevel, 2, "focus follows a new value")
    }

    function test_accessibleNames() {
        var picker = createTemporaryObject(pickerComponent, stage(), { value: 3 })
        var c = cells(picker)
        compare(c[2].Accessible.role, Accessible.RadioButton)
        compare(c[2].Accessible.name, "3 sure")
        verify(c[2].Accessible.checked)
        verify(!c[0].Accessible.checked)
    }

    function test_cellsMakeRoomForTheWidestWord() {
        var picker = createTemporaryObject(pickerComponent, stage(), { width: undefined })
        var wide = createTemporaryObject(pickerComponent, stage(), { width: undefined, names: ["", "a", "b", "c", "a very long word for four"] })
        verify(wide.implicitWidth > picker.implicitWidth, "a longer word widens every cell")
        // By pixels, not letters: the cell follows the widest word as drawn (in System's
        // proportional font eleven i are narrower than nine W; Kante's labels are monospaced).
        KanteStyle.kind = KanteStyle.Kind.System
        var byPixels = createTemporaryObject(pickerComponent, stage(), { width: undefined, names: ["", "iiiiiiiiiii", "WWWWWWWWW", "", ""] })
        var i = createTemporaryObject(wordComponent, stage(), { text: "iiiiiiiiiii" })
        var w = createTemporaryObject(wordComponent, stage(), { text: "WWWWWWWWW" })
        tryCompare(byPixels, "widestWord", Math.max(i.implicitWidth, w.implicitWidth))
    }

    // Narrower than its words: each word stays inside its button.
    function test_narrowKeepsWordsInside() {
        var picker = createTemporaryObject(pickerComponent, stage(), { width: 240, value: 4, names: ["offen", "gesehen", "mit Hilfe", "sicher", "prüfungsreif"] })
        waitForRendering(picker)
        var c = cells(picker)
        for (var i = 0; i < c.length; i++) {
            var word = c[i].children[0].children[1]
            verify(word.paintedWidth <= c[i].width, "word " + (i + 1) + " fits (" + word.paintedWidth + " > " + c[i].width + ")")
        }
    }

    // A small phone (Mitori at 360 px: the picker 344 px wide): the words show whole. Without
    // room for the letter spacing they set tight; only narrower still they elide.
    function test_smallPhoneShowsWholeWords() {
        var picker = createTemporaryObject(pickerComponent, stage(), { width: 344, names: ["offen", "gesehen", "mit Hilfe", "sicher", "prüfungsreif"] })
        waitForRendering(picker)
        var c = cells(picker)
        for (var i = 0; i < c.length; i++) {
            var word = c[i].children[0].children[1]
            verify(!word.truncated, "word " + (i + 1) + " whole: " + word.text)
        }
        verify(picker.tight, "set tight")
        picker.width = 600
        verify(!picker.tight, "with room: the letter spacing back")
    }

    // Right to left: the arrow keys stay within 1..count.
    Component {
        id: mirroredPicker
        Item {
            property alias picker: inner
            width: 400; height: 60
            LayoutMirroring.enabled: true
            LayoutMirroring.childrenInherit: true
            KanteLevelPicker { id: inner; anchors.fill: parent; names: tc.words }
        }
    }
    function test_rightToLeftStaysInRange() {
        var holder = createTemporaryObject(mirroredPicker, stage())
        var picker = holder.picker
        picker.forceActiveFocus()
        for (var i = 0; i < 6; i++) {
            keyClick(Qt.Key_Left)
        }
        compare(picker.focusLevel, 4)
        for (i = 0; i < 8; i++) {
            keyClick(Qt.Key_Right)
        }
        compare(picker.focusLevel, 1)
    }

    // Fewer levels at run time: the keyboard focus stays on one of them.
    function test_fewerLevelsKeepFocusInRange() {
        var picker = createTemporaryObject(pickerComponent, stage(), { value: 4 })
        compare(picker.focusLevel, 4)
        picker.count = 2
        compare(picker.focusLevel, 2)
    }

    // The dots are square in both Kante styles, round in System.
    function test_dotShapePerStyle() {
        var dots = createTemporaryObject(dotsComponent, stage(), { value: 2 })
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        compare(dots.children[0].radius, 0, "Kante Light: square")
        KanteStyle.kind = KanteStyle.Kind.System
        verify(dots.children[0].radius > 0, "System: round")
    }
}
