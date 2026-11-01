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

    function cells(picker) {
        var row = picker.children[1]
        var list = []
        for (var i = 0; i < row.children.length; i++) {
            if (row.children[i].level !== undefined) {
                list.push(row.children[i])
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
        verify(picker.cellWidth > KanteStyle.unit(56) || picker.implicitWidth >= 4 * KanteStyle.unit(56))
        var long = createTemporaryObject(pickerComponent, stage(), { names: ["", "a", "b", "c", "a very long word for four"] })
        verify(long.implicitWidth > picker.implicitWidth)
    }
}
