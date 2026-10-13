import QtQuick
import QtTest
import Kante

/**
 * Kante 1.33, words to look up in KanteRubyText (Kaiwa /LF112/): segments with the same
 * `word` form one word; with `interactive` a click, Enter or Space fire wordActivated, Left /
 * Right / Home / End move the focused word, and a text without `interactive` stays as before.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante133"
    width: 600
    height: 300
    when: windowShown

    Component {
        id: rubyComponent
        KanteRubyText {
            width: 600
            interactive: true
            // 駅 | まで | は | 歩いて (two segments, one word) | 五分 | です | 。 (no word)
            segments: [
                { text: "駅", reading: "えき", word: 0 },
                { text: "まで", word: 1 },
                { text: "は", word: 2 },
                { text: "歩", reading: "ある", isNew: true, word: 3 },
                { text: "いて", word: 3 },
                { text: "五分", reading: "ごふん", word: 4 },
                { text: "です", word: 5 },
                { text: "。" }
            ]
        }
    }
    SignalSpy { id: spy; signalName: "wordActivated" }

    function make(props) {
        var r = createTemporaryObject(rubyComponent, tc.Window.contentItem, props || {})
        spy.clear()
        spy.target = r
        waitForRendering(r)
        return r
    }

    function test_words_group_segments() {
        var r = make()
        compare(r.words, [0, 1, 2, 3, 4, 5])
        compare(r.wordText(3), "歩いて")
        compare(r.wordText(4), "五分")
        compare(r.wordText(9), "")
        compare(r.text, "駅までは歩いて五分です。")
    }

    function test_click_activates_the_word_under_the_pointer() {
        var r = make()
        var box = r.wordRect(3)
        verify(box.width > 0 && box.height > 0)
        mouseClick(r, box.x + box.width - 2, box.y + box.height - 4)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 3)
        compare(r.focusWord, 3)
    }

    function test_click_on_text_without_word_does_nothing() {
        var r = make()
        var last = r.wordRect(5)
        mouseClick(r, last.x + last.width + 4, last.y + last.height - 4)
        compare(spy.count, 0)
    }

    function test_keyboard_moves_and_activates() {
        var r = make()
        r.forceActiveFocus()
        compare(r.focusWord, 0)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Right)
        compare(r.focusWord, 2)
        keyClick(Qt.Key_End)
        compare(r.focusWord, 5)
        keyClick(Qt.Key_Right)
        compare(r.focusWord, 5)
        keyClick(Qt.Key_Home)
        keyClick(Qt.Key_Space)
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 0)
        keyClick(Qt.Key_Right)
        keyClick(Qt.Key_Return)
        compare(spy.signalArguments[1][0], 1)
        verify(r.Accessible.description.indexOf("まで") === 0)
    }

    function test_not_interactive_stays_a_static_text() {
        var r = make({ interactive: false })
        verify(!r.activeFocusOnTab)
        var box = r.wordRect(0)
        mouseClick(r, box.x + box.width / 2, box.y + box.height - 4)
        compare(spy.count, 0)
        compare(r.Accessible.role, Accessible.StaticText)
    }

    function test_markup_without_words_is_not_focusable() {
        var r = make({ segments: [], markup: "{駅|えき}までは" })
        compare(r.words, [])
        verify(!r.activeFocusOnTab)
    }
}
