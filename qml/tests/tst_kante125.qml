import QtQuick
import QtTest
import Kante

/**
 * Kante 1.25, the conversation components for Kaiwa: ruby text, heard line, talk button,
 * diff text, hint card, pitch curve, learning path and goal meter. Each in System, Kante
 * and Kante Light. Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante125"
    width: 900
    height: 700
    when: windowShown

    function stage() {
        return tc.Window.contentItem
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    Component { id: rubyComponent; KanteRubyText { width: 400 } }
    Component { id: heardComponent; KanteHeardLine { width: 400 } }
    Component { id: talkComponent; KanteTalkButton {} }
    Component { id: diffComponent; KanteDiffText { width: 400 } }
    Component { id: hintComponent; KanteHintCard { width: 420 } }
    Component { id: pitchComponent; KantePitchCurve { width: 420; height: 170 } }
    Component { id: pathComponent; KantePath { width: 360 } }
    Component { id: goalComponent; KanteGoalMeter {} }
    Component {
        id: diffTitle
        KanteDiffText { parts: [{ text: "コーヒー" }, { text: "を", kind: "removed" }, { text: "が", kind: "added" }, { text: "好きです" }] }
    }

    SignalSpy { id: spy }

    function test_rubyParsesMarkup() {
        var r = createTemporaryObject(rubyComponent, stage(), { markup: "{駅|えき}までは{歩|ある|new}いて" })
        compare(r.text, "駅までは歩いて")
        // 駅 and 歩 are pieces with a reading; the plain runs are split per character.
        compare(r.pieces.length, 1 + 3 + 1 + 2)
        compare(r.pieces[0].reading, "えき")
        verify(r.pieces[4].isNew)
        compare(r.Accessible.name, "駅までは歩いて")
    }

    function test_rubyDensityKeepsHeight() {
        var r = createTemporaryObject(rubyComponent, stage(), { markup: "{駅|えき}までは{歩|ある|new}いて{五分|ごふん}です。" })
        waitForRendering(r)
        var h = r.height
        verify(h > 0)
        r.density = KanteRubyText.Density.New
        waitForRendering(r)
        compare(r.height, h)
        r.density = KanteRubyText.Density.None
        waitForRendering(r)
        compare(r.height, h)
    }

    function test_rubySegmentsWrap() {
        var run = ""
        for (var i = 0; i < 40; i++) run += "あ"
        var r = createTemporaryObject(rubyComponent, stage(), { segments: [{ text: run }], width: 120 })
        waitForRendering(r)
        var single = createTemporaryObject(rubyComponent, stage(), { segments: [{ text: "あ" }] })
        waitForRendering(single)
        verify(r.height > single.height * 2, "a long run wraps onto several lines")
    }

    function test_heardLineOffersActionWhenUnsure() {
        var l = createTemporaryObject(heardComponent, stage(), { text: "ふくろ(?)いりません" })
        verify(l.Accessible.name.indexOf("gehört als") === 0)
        l.unsure = true
        verify(l.Accessible.name.indexOf("unsicher") === 0)
        spy.clear(); spy.signalName = ""; spy.target = l; spy.signalName = "misheard"
        // The action is the last Text; tap it.
        var texts = []
        for (var i = 0; i < l.children.length; i++) if (l.children[i].text !== undefined) texts.push(l.children[i])
        var link = texts[texts.length - 1]
        verify(link.visible)
        mouseClick(link)
        compare(spy.count, 1)
    }

    function test_talkHoldMode() {
        var b = createTemporaryObject(talkComponent, stage())
        verify(b.height >= KanteStyle.heightLarge)
        var started = 0, ended = 0
        b.talkStarted.connect(function () { started++; b.talkState = KanteTalkButton.State.Listening })
        b.talkEnded.connect(function () { ended++; b.talkState = KanteTalkButton.State.Thinking })
        mousePress(b)
        compare(started, 1)
        compare(b.title, "Hört zu")
        mouseRelease(b)
        compare(ended, 1)
        compare(b.Accessible.name, "Denkt nach")
        // Thinking takes no action.
        mouseClick(b)
        compare(started, 1)
        compare(ended, 1)
    }

    function test_talkToggleKeyboardAndOtherStates() {
        var b = createTemporaryObject(talkComponent, stage(), { mode: KanteTalkButton.Mode.Toggle })
        var started = 0, ended = 0, interrupted = 0, fixed = 0
        b.talkStarted.connect(function () { started++; b.talkState = KanteTalkButton.State.Listening })
        b.talkEnded.connect(function () { ended++; b.talkState = KanteTalkButton.State.Speaking })
        b.interruptRequested.connect(function () { interrupted++; b.talkState = KanteTalkButton.State.Error })
        b.errorActionRequested.connect(function () { fixed++ })
        b.forceActiveFocus()
        keyClick(Qt.Key_Space)
        compare(started, 1)
        keyClick(Qt.Key_Space)
        compare(ended, 1)
        keyClick(Qt.Key_Return)
        compare(interrupted, 1)
        compare(b.title, "Kein Mikrofon")
        compare(b.hintText, "Einstellungen öffnen")
        mouseClick(b)
        compare(fixed, 1)
    }

    function test_talkHintOverride() {
        var b = createTemporaryObject(talkComponent, stage(), { talkState: KanteTalkButton.State.Thinking, hint: "1,2 s" })
        compare(b.Accessible.description, "1,2 s")
    }

    function test_diffSpokenAndPieces() {
        var d = createTemporaryObject(diffComponent, stage(), { parts: [{ text: "コーヒー" }, { text: "を", kind: "removed" }, { text: "が", kind: "added" }, { text: "好きです" }] })
        compare(d.pieces.length, 4 + 1 + 1 + 4)
        compare(d.Accessible.name, "コーヒー, gestrichen を, neu が, 好きです")
    }

    function test_hintCardWithDiffTitle() {
        var t = createTemporaryObject(diffTitle, stage())
        var c = createTemporaryObject(hintComponent, stage(), { tier: KanteHintCard.Tier.Yellow, tierText: "Falsch", meta: "Partikel", titleItem: t, text: "好き verlangt が." })
        waitForRendering(c)
        verify(c.Accessible.name.indexOf("Falsch: コーヒー") === 0, c.Accessible.name)
        verify(c.height > t.height)
        compare(t.width, c.width - 2 * c.pad - KanteStyle.unit(4))
        c.compact = true
        waitForRendering(c)
        verify(c.height < 200)
        compare(c.Accessible.description, "Partikel. 好き verlangt が.")
    }

    function test_pitchSummary() {
        var p = createTemporaryObject(pitchComponent, stage(), { morae: ["は", "し", "(が)"], target: [1, 0, 0], kernel: 0, actual: [0.2, 0.4, 0.7, 0.9, 1] })
        compare(p.summary, "Abfall nach は")
        p.missAt = 1
        compare(p.summary, "Abfall nach は, abweichend bei し")
        p.kernel = -1
        p.missAt = -1
        compare(p.Accessible.description, "flach, ohne Abfall")
    }

    function test_pathActivatesUnlockedOnly() {
        var p = createTemporaryObject(pathComponent, stage(), { model: [
            { title: "Begrüßung", meta: "N5-01", state: "done" },
            { title: "Wiederholung", meta: "8 fällig", state: "review" },
            { title: "Konbini", meta: "N5-03", state: "current" },
            { title: "Weg", meta: "N5-04", state: "locked" }] })
        waitForRendering(p)
        spy.clear(); spy.signalName = ""; spy.target = p; spy.signalName = "activated"
        var nodes = []
        for (var i = 0; i < p.children.length; i++) if (p.children[i].st !== undefined) nodes.push(p.children[i])
        compare(nodes.length, 4)
        mouseClick(nodes[2])
        compare(spy.count, 1)
        compare(spy.signalArguments[0][0], 2)
        mouseClick(nodes[3])
        compare(spy.count, 1, "a locked node does nothing")
        verify(nodes[3].Accessible.name.indexOf("gesperrt") > 0)
        verify(nodes[1].x === nodes[0].x && nodes[1].indent > 0, "review is indented")
        nodes[0].forceActiveFocus()
        keyClick(Qt.Key_Return)
        compare(spy.count, 2)
    }

    function test_goalMeterLit() {
        var g = createTemporaryObject(goalComponent, stage(), { value: 0.6, label: "12 T" })
        compare(g.lit, 3)
        g.value = 1.4
        compare(g.lit, 5)
        g.value = 0
        compare(g.lit, 0)
        verify(g.Accessible.description.indexOf("12 T") > 0)
    }

    function test_allKindsLoad_data() {
        return [
            { tag: "system", kind: KanteStyle.Kind.System },
            { tag: "kante", kind: KanteStyle.Kind.Kante },
            { tag: "light", kind: KanteStyle.Kind.KanteLight }
        ]
    }
    function test_allKindsLoad(data) {
        KanteStyle.kind = data.kind
        var items = [
            createTemporaryObject(rubyComponent, stage(), { markup: "{駅|えき}です" }),
            createTemporaryObject(heardComponent, stage(), { text: "はい", unsure: true }),
            createTemporaryObject(talkComponent, stage(), { talkState: KanteTalkButton.State.Listening, level: 0.5 }),
            createTemporaryObject(diffComponent, stage(), { parts: [{ text: "が", kind: "added" }] }),
            createTemporaryObject(hintComponent, stage(), { tier: KanteHintCard.Tier.Red, titleText: "とうだいもり", compact: true }),
            createTemporaryObject(pitchComponent, stage(), { morae: ["あ", "め"], target: [1, 0], kernel: 0 }),
            createTemporaryObject(pathComponent, stage(), { model: [{ title: "A", state: "current" }] }),
            createTemporaryObject(goalComponent, stage(), { value: 0.4 })
        ]
        for (var i = 0; i < items.length; i++) {
            verify(items[i] !== null, "item " + i)
            var it = items[i]
            tryVerify(function () { return it.width > 0 && it.height > 0 }, 1000, "item " + i + " has a size")
        }
    }
}
