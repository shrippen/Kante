import QtQuick
import QtQuick.Layouts
import QtTest
import Kante

/**
 * KanteStickyHeader and KanteSettingGroup: a header with title and tabs over a scrolling page,
 * the tab of the section at the top follows the scrolling, a tap scrolls to the section.
 * Also KanteTabBar's Underline look and KanteFocusFollow's topInset.
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteStickyHeader"
    width: 500
    height: 400
    visible: true
    when: windowShown

    Component {
        id: scene
        Item {
            id: root
            width: 500
            height: 400
            property alias header: head
            property alias view: flick
            property alias follow: follower
            property alias groups: reps
            property alias bare: bareGroup
            Flickable {
                id: flick
                anchors.fill: parent
                contentWidth: width
                contentHeight: col.implicitHeight
                clip: true
                ColumnLayout {
                    id: col
                    width: flick.width
                    spacing: 16
                    Item { Layout.preferredHeight: head.expandedHeight }
                    Repeater {
                        id: reps
                        model: 4
                        delegate: KanteSettingGroup {
                            required property int index
                            objectName: "group" + index
                            Layout.fillWidth: true
                            title: "Gruppe " + index
                            countText: count + " Einstellungen"
                            KanteSettingRow {
                                Layout.fillWidth: true
                                title: "A" + index
                                KanteButton { objectName: "first" + index; text: "x" }
                            }
                            KanteSettingRow {
                                Layout.fillWidth: true
                                visible: index !== 1
                                title: "B" + index
                                KanteButton { text: "y" }
                            }
                            Item { Layout.preferredHeight: 260 }
                        }
                    }
                    KanteSettingGroup {
                        id: bareGroup
                        objectName: "bare"
                        Layout.fillWidth: true
                        title: "Ohne"
                        Item { Layout.preferredHeight: 600 }
                    }
                }
            }
            KanteStickyHeader {
                id: head
                anchors { left: parent.left; right: parent.right; top: parent.top }
                flickable: flick
                title: "Einstellungen"
                tabsName: "Abschnitte"
                model: ["Null", "Eins", "Zwei", "Drei", "Ohne"]
            }
            KanteFocusFollow { id: follower; flickable: flick; topInset: head.height }
        }
    }

    function init() {
        KanteStyle.kind = KanteStyle.Kind.Kante
        KanteStyle.motion = false
    }
    function cleanup() {
        KanteStyle.motion = true
    }

    function make() {
        const item = createTemporaryObject(scene, tc)
        verify(item)
        // Layouts settle, then the tiles' positions are known.
        wait(50)
        const g = item.groups
        item.header.targets = [g.itemAt(0), g.itemAt(1), g.itemAt(2), g.itemAt(3), item.bare]
        return item
    }

    function test_groupCountsVisibleSettings() {
        const s = make()
        const g0 = findChild(s, "group0")
        const g1 = findChild(s, "group1")
        tryCompare(g0, "count", 2)
        // Row B1 is hidden.
        tryCompare(g1, "count", 1)
        compare(findChild(g0, "groupCount").text, "2 Einstellungen")
        compare(g0.Accessible.name, "Gruppe 0")
        compare(g0.Accessible.role, Accessible.Grouping)
    }

    function test_countFollowsVisibility() {
        const s = make()
        const g1 = findChild(s, "group1")
        tryCompare(g1, "count", 1)
        g1.content[0].visible = false
        tryCompare(g1, "count", 0)
    }

    function test_noCountNoLabel() {
        const s = make()
        const bare = findChild(s, "bare")
        bare.countText = ""
        compare(findChild(bare, "groupCount").visible, false)
    }

    function test_shrinksWhenScrolled() {
        const s = make()
        compare(s.header.compact, false)
        compare(s.header.height, s.header.expandedHeight)
        s.view.contentY = s.header.shrinkAt + 10
        compare(s.header.compact, true)
        compare(s.header.height, s.header.compactHeight)
        verify(s.header.compactHeight < s.header.expandedHeight)
        s.view.contentY = 0
        compare(s.header.height, s.header.expandedHeight)
    }

    function test_shrinkAnimatesOnlyWithMotion() {
        KanteStyle.motion = true
        const s = make()
        s.view.contentY = 200
        // Mid-way, not yet there (needs Kirigami's durations to be non-zero).
        if (KanteStyle.animate) {
            verify(s.header.height > s.header.compactHeight)
        }
        tryCompare(s.header, "height", s.header.compactHeight)
        KanteStyle.motion = false
        s.view.contentY = 0
        compare(s.header.height, s.header.expandedHeight)
    }

    function test_spyFollowsScrolling() {
        const s = make()
        compare(s.header.currentIndex, 0)
        const g2 = findChild(s, "group2")
        s.view.contentY = g2.y - s.header.compactHeight
        compare(s.header.currentIndex, 2)
        s.view.contentY = 0
        compare(s.header.currentIndex, 0)
    }

    function test_endOfPageIsTheLastTab() {
        const s = make()
        s.view.contentY = s.view.contentHeight - s.view.height
        compare(s.header.currentIndex, 4)
    }

    function test_scrollToPutsSectionBelowHeader() {
        const s = make()
        const g2 = findChild(s, "group2")
        s.header.scrollTo(2)
        tryCompare(s.view, "contentY", g2.y - s.header.compactHeight - s.header.gap)
        compare(s.header.currentIndex, 2)
        // The spy keeps it, and the header is the shrunk one.
        compare(s.header.compact, true)
        const under = g2.mapToItem(s, 0, 0).y
        verify(under >= s.header.height)
    }

    function test_scrollToFirstStaysAtTop() {
        const s = make()
        s.header.scrollTo(0)
        wait(50)
        // At most the nudge of the focus follower; the big header stays.
        verify(s.view.contentY <= s.header.shrinkAt)
        compare(s.header.compact, false)
        compare(s.header.currentIndex, 0)
        verify(findChild(s, "group0").mapToItem(s, 0, 0).y >= s.header.height)
    }

    function test_scrollToFocusesFirstControl() {
        const s = make()
        s.header.scrollTo(2)
        tryCompare(findChild(s, "first2"), "activeFocus", true)
    }

    function test_sectionWithoutControlKeepsFocusOut() {
        const s = make()
        const before = findChild(s.header, "headerTabs")
        before.forceActiveFocus()
        s.header.scrollTo(4)
        wait(300)
        verify(!findChild(s, "first3").activeFocus)
        compare(before.activeFocus, true)
    }

    function test_tapOnTabScrolls() {
        const s = make()
        const bar = findChild(s.header, "headerTabs")
        const target = findChild(s, "group1")
        // Second tab: some way in from the left.
        mouseClick(bar, bar.width * 0.2, bar.height / 2)
        tryCompare(s.header, "currentIndex", 1)
        verify(s.view.contentY > 0)
        compare(s.view.contentY, Math.max(0, target.y - s.header.compactHeight - s.header.gap))
    }

    function test_keyboardOnTabs() {
        const s = make()
        const bar = findChild(s.header, "headerTabs")
        bar.forceActiveFocus()
        keyClick(Qt.Key_Right)
        tryCompare(s.header, "currentIndex", 1)
        verify(s.view.contentY > 0)
        // The bar and the header stay in step after the bar changed its own index.
        s.view.contentY = 0
        compare(s.header.currentIndex, 0)
        compare(bar.currentIndex, 0)
    }

    function test_tabBarRoleAndName() {
        const s = make()
        const bar = findChild(s.header, "headerTabs")
        compare(bar.Accessible.role, Accessible.PageTabList)
        compare(bar.Accessible.name, "Abschnitte")
        compare(bar.look, KanteTabBar.Look.Underline)
    }

    function test_focusFollowKeepsFocusBelowHeader() {
        const s = make()
        s.view.contentY = 400
        const b = findChild(s, "first1")
        const y = b.mapToItem(s.view.contentItem, 0, 0).y
        // An item just under the header's edge: the view scrolls up until it is below it.
        s.view.contentY = y - s.header.compactHeight + 10
        s.follow.reveal(b)
        const shown = b.mapToItem(s, 0, 0).y
        verify(shown >= s.header.height, "focused item at " + shown + " is under the header")
    }

    function test_focusFollowWithoutInsetIsUnchanged() {
        const s = make()
        s.follow.topInset = 0
        s.view.contentY = 400
        const b = findChild(s, "first1")
        const y = b.mapToItem(s.view.contentItem, 0, 0).y
        s.view.contentY = y - 4
        s.follow.reveal(b)
        compare(s.view.contentY, Math.max(0, y - s.follow.margin))
    }
}
