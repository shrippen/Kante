import QtQuick
import QtTest
import Kante

/**
 * Kante 1.50, rehearsal marks (Kontra round 16): a bar's `section` names the part that starts
 * there (Intro, Strophe, Refrain, or a letter); lanes and staffs show it in a framed box above
 * the bar, several names of one bar joined ("Refrain · B"), a long name cut short instead of
 * running into the next. Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante150"
    width: 800
    height: 600
    when: windowShown

    readonly property var sectionBars: [
        { time: 0, section: "Intro" },
        { time: 2 },
        { time: 4, section: ["Refrain", "B", "Refrain", ""] },
        { time: 6 }
    ]
    readonly property var plainBars: [{ time: 0 }, { time: 2 }, { time: 4 }, { time: 6 }]
    readonly property var tabNotes: [
        { time: 0, duration: 0.5, beats: 1, string: 0, fret: 3 },
        { time: 2.5, duration: 0.5, beats: 1, string: 1, fret: 5 },
        { time: 4.5, duration: 0.5, beats: 1, string: 2, fret: 7 },
        { time: 6.5, duration: 0.5, beats: 1, string: 3, fret: 2 }
    ]
    readonly property var midiNotes: [
        { time: 0, duration: 0.5, beats: 1, midi: 40 },
        { time: 2.5, duration: 0.5, beats: 1, midi: 45 },
        { time: 4.5, duration: 0.5, beats: 1, midi: 50 },
        { time: 6.5, duration: 0.5, beats: 1, midi: 43 }
    ]

    Component { id: markComponent; KanteRehearsalMark {} }
    Component { id: laneComponent; KanteTabLane { width: 700; height: 220; pixelsPerSecond: 80; playLine: 0 } }
    Component { id: keyLaneComponent; KanteKeyLane { width: 600; height: 400; pixelsPerSecond: 40; playLine: 0.05 } }
    Component { id: tabStaffComponent; KanteTabStaff { width: 760; barsPerSystem: 4 } }
    Component { id: bassStaffComponent; KanteBassStaff { width: 760; barsPerSystem: 4 } }

    function findAll(item, pred) {
        let out = []
        for (let i = 0; i < item.children.length; i++) {
            const c = item.children[i]
            if (pred(c)) {
                out.push(c)
            }
            out = out.concat(findAll(c, pred))
        }
        return out
    }
    function marksOf(item) {
        return findAll(item, function (c) { return c.objectName === "kanteRehearsalMark" && c.visible })
    }
    function xIn(m, root) {
        return m.mapToItem(root, 0, 0).x
    }
    function texts(list) {
        return list.map(function (m) { return m.text })
    }

    function cleanup() {
        KanteStyle.kind = KanteStyle.Kind.System
    }

    function test_joinsNames() {
        compare(KanteStyle.rehearsalText("Intro"), "Intro")
        compare(KanteStyle.rehearsalText(["Refrain", "B"]), "Refrain · B")
        compare(KanteStyle.rehearsalText(["A", "", "A", " B "]), "A · B")
        compare(KanteStyle.rehearsalText(undefined), "")
        compare(KanteStyle.rehearsalText(null), "")
        compare(KanteStyle.rehearsalText([]), "")
    }

    function test_markBox() {
        const m = createTemporaryObject(markComponent, tc.Window.contentItem, { text: "Strophe" })
        verify(m.implicitWidth > 0)
        verify(m.implicitHeight > 0)
        compare(m.Accessible.name, "Teil Strophe")
        verify(!m.truncated)

        // A long name is cut short to the room it has; screen readers still hear all of it.
        const long = "Refrain mit sehr langem Namen · B"
        m.text = long
        const full = m.implicitWidth
        m.maximumWidth = full / 2
        verify(m.width <= full / 2)
        verify(m.truncated)
        compare(m.Accessible.name, "Teil " + long)
    }

    function test_markShape() {
        const m = createTemporaryObject(markComponent, tc.Window.contentItem, { text: "A" })
        // System: square, as the platform; Kante and Kante Light: the small cut.
        compare(m.cut, 0)
        KanteStyle.kind = KanteStyle.Kind.Kante
        verify(m.cut > 0)
        KanteStyle.kind = KanteStyle.Kind.KanteLight
        verify(m.cut > 0)
    }

    function test_tabLane() {
        const plain = createTemporaryObject(laneComponent, tc.Window.contentItem, { notes: tabNotes, bars: plainBars })
        const lane = createTemporaryObject(laneComponent, tc.Window.contentItem, { notes: tabNotes, bars: sectionBars })
        compare(marksOf(plain).length, 0)
        // The marks get a row of their own above the bar numbers.
        verify(lane.topPad > plain.topPad)
        tryVerify(function () { return marksOf(lane).length === 2 })
        compare(texts(marksOf(lane)), ["Intro", "Refrain · B"])
        verify(lane.Accessible.description.indexOf("Teil Intro") >= 0)
        lane.position = 3
        verify(lane.Accessible.description.indexOf("Teil Intro") >= 0)
        lane.position = 4.2
        verify(lane.Accessible.description.indexOf("Teil Refrain · B") >= 0)
    }

    function test_keyLane() {
        const lane = createTemporaryObject(keyLaneComponent, tc.Window.contentItem, { notes: midiNotes, bars: sectionBars })
        tryVerify(function () { return marksOf(lane).length === 2 })
        compare(texts(marksOf(lane)), ["Intro", "Refrain · B"])
        lane.position = 4.2
        verify(lane.Accessible.description.indexOf("Teil Refrain · B") >= 0)
    }

    function test_tabStaff() {
        const plain = createTemporaryObject(tabStaffComponent, tc.Window.contentItem, { notes: tabNotes, bars: plainBars })
        const staff = createTemporaryObject(tabStaffComponent, tc.Window.contentItem, { notes: tabNotes, bars: sectionBars })
        compare(marksOf(plain).length, 0)
        verify(staff.staffTop > plain.staffTop)
        compare(texts(marksOf(staff)), ["Intro", "Refrain · B"])
        // Over the first bar of its part.
        const m = marksOf(staff)
        verify(Math.abs(xIn(m[0], staff) - staff.headerWidth) < staff.barWidth / 4)
        verify(Math.abs(xIn(m[1], staff) - (staff.headerWidth + 2 * staff.barWidth)) < staff.barWidth / 4)
        staff.position = 2.5
        verify(staff.Accessible.description.indexOf("Teil Intro") >= 0)
        staff.position = 4.5
        verify(staff.Accessible.description.indexOf("Teil Refrain · B") >= 0)
    }

    function test_bassStaff() {
        const plain = createTemporaryObject(bassStaffComponent, tc.Window.contentItem, { notes: midiNotes, bars: plainBars })
        const staff = createTemporaryObject(bassStaffComponent, tc.Window.contentItem, { notes: midiNotes, bars: sectionBars })
        compare(marksOf(plain).length, 0)
        verify(staff.staffTop > plain.staffTop)
        compare(texts(marksOf(staff)), ["Intro", "Refrain · B"])
        staff.position = 4.5
        verify(staff.Accessible.description.indexOf("Teil Refrain · B") >= 0)
    }

    // Parts in neighbouring bars: a long name stops before the next mark.
    function test_longNameDoesNotOverlap() {
        const bars = [
            { time: 0, section: "Intro mit einem sehr, sehr langen Namen" },
            { time: 2, section: "A" },
            { time: 4 },
            { time: 6 }
        ]
        const staff = createTemporaryObject(tabStaffComponent, tc.Window.contentItem, { notes: tabNotes, bars: bars })
        const m = marksOf(staff)
        compare(m.length, 2)
        verify(m[0].truncated)
        verify(xIn(m[0], staff) + m[0].width < xIn(m[1], staff))

        const lane = createTemporaryObject(laneComponent, tc.Window.contentItem, { notes: tabNotes, bars: bars })
        tryVerify(function () { return marksOf(lane).length === 2 })
        const lm = marksOf(lane)
        verify(lm[0].truncated)
        verify(xIn(lm[0], lane) + lm[0].width < xIn(lm[1], lane))
    }
}
