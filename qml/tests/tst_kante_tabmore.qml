import QtQuick
import QtTest
import Kante

/**
 * Tabs that do not fit show an arrow on each side with hidden tabs, and a tap on it scrolls
 * that way (Kontra QA 14.11.: at 200 % the last settings tab ended in "Taste…" with nothing
 * saying more came). Run: tools/check-qml.sh.
 */
Item {
    id: stage
    width: 900
    height: 200

    TestCase {
        id: tc
        name: "KanteTabMore"
        when: windowShown

        readonly property var labels: ["Audio", "Instrument", "Anzeige", "Bewertung", "Üben", "Mixer",
            "Sprache und Stil", "Deine Daten", "Zwischenspeicher", "Über Kontra", "Tastenkürzel"]

        Component { id: barComponent; KanteTabBar { model: tc.labels } }

        function test_aNarrowBarShowsWhereTabsAreHidden() {
            var bar = createTemporaryObject(barComponent, stage, { width: 300 })
            waitForRendering(bar)
            var before = findChild(bar, "moreBefore")
            var after = findChild(bar, "moreAfter")
            verify(!before.visible, "nothing hidden on the left at the start")
            verify(after.visible, "tabs hidden on the right")

            mouseClick(after, after.width / 2, after.height / 2)
            tryVerify(function() { return before.visible }, 2000, "scrolled: tabs hidden on the left")
            // The tap is the arrow's alone: the tab under it is not chosen (Kontra, 14.11.).
            compare(bar.currentIndex, 0)
        }

        function test_aWideBarShowsNoArrow() {
            var bar = createTemporaryObject(barComponent, stage, { width: 1600 })
            waitForRendering(bar)
            verify(!findChild(bar, "moreBefore").visible)
            verify(!findChild(bar, "moreAfter").visible)
        }

        function test_theLastTabSelectedLeavesNoArrowRight() {
            var bar = createTemporaryObject(barComponent, stage, { width: 300 })
            bar.currentIndex = tc.labels.length - 1
            tryVerify(function() { return !findChild(bar, "moreAfter").visible }, 2000)
            verify(findChild(bar, "moreBefore").visible)
        }
    }
}
