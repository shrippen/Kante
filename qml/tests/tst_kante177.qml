import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import QtTest
import Kante

/**
 * Kante 1.77: a stopped busy indicator leaves the window still. Material fades a stopped
 * BusyIndicator out with an OpacityAnimator, and an Animator advances only while its item is drawn:
 * an indicator hidden as it stopped never finished the fade, and the window drew at the display rate
 * (Plasmai on Android: ~90 frames a second while idle).
 * Run: tools/check-qml.sh; QT_QUICK_CONTROLS_STYLE=Material shows the frames (other styles do not fade).
 */
TestCase {
    id: tc
    name: "Kante177"
    width: 400
    height: 400
    when: windowShown

    /** A still window draws a frame or two after the last change; a running animation dozens. */
    readonly property int maxIdleFrames: 5
    property int frames: 0

    Connections {
        target: tc.Window.window
        function onFrameSwapped() { tc.frames++ }
    }

    /** Frames drawn in a second once the window had time to settle. */
    function idleFrames() {
        wait(400)
        frames = 0
        wait(1000)
        return frames
    }

    /** The BusyIndicators under `item`, built ones only. */
    function indicators(item) {
        let found = []
        for (let i = 0; i < item.children.length; i++) {
            const kid = item.children[i]
            if (kid instanceof QQC2.BusyIndicator) {
                found.push(kid)
            }
            found = found.concat(indicators(kid))
        }
        return found
    }

    Component {
        id: busyScene
        KanteBusyIndicator {
            width: 32
            height: 32
        }
    }
    Component {
        id: pullScene
        Flickable {
            id: list
            width: 300
            height: 300
            contentHeight: 600
            property alias pull: pull
            KantePullToRefresh {
                id: pull
                parent: list
                anchors.fill: parent
                flickable: list
            }
        }
    }

    // A new component is shown in the gallery (review of PR #133: it was missing there).
    function test_gallery_shows_the_busy_indicator() {
        const component = Qt.createComponent(Qt.resolvedUrl("../demo/Gallery.qml"), Component.PreferSynchronous)
        tryVerify(() => component.status !== Component.Loading)
        compare(component.status, Component.Ready, component.errorString())
        const gallery = component.createObject(null)
        verify(gallery)
        const busy = findChild(gallery, "galleryBusyIndicator")
        verify(busy, "a KanteBusyIndicator in the gallery")
        verify(busy.running && busy.indicator, "it spins there")
        gallery.destroy()
    }

    function test_busy_indicator_is_built_while_running_only() {
        const busy = createTemporaryObject(busyScene, tc.Window.contentItem, { running: false })
        compare(indicators(busy).length, 0, "nothing built while stopped")
        verify(!busy.visible)
        busy.running = true
        compare(indicators(busy).length, 1)
        verify(indicators(busy)[0].running)
        verify(busy.visible)
        busy.running = false
        compare(indicators(busy).length, 0, "stopping removes the indicator, it does not hide it")
    }

    function test_stopped_busy_indicator_leaves_the_window_still() {
        const busy = createTemporaryObject(busyScene, tc.Window.contentItem, { running: true })
        wait(300)
        busy.running = false
        const n = idleFrames()
        verify(n <= maxIdleFrames, "frames while idle: " + n)
    }

    function test_pull_to_refresh_keeps_no_stopped_indicator() {
        const scene = createTemporaryObject(pullScene, tc.Window.contentItem)
        compare(indicators(scene.pull).length, 0, "no indicator before a refresh")
        scene.pull.refreshing = true
        compare(indicators(scene.pull).length, 1)
        scene.pull.refreshing = false
        compare(indicators(scene.pull).length, 0, "no indicator after it")
    }

    function test_pull_to_refresh_leaves_the_window_still_after_a_refresh() {
        const scene = createTemporaryObject(pullScene, tc.Window.contentItem)
        scene.pull.refreshing = true
        wait(300)
        scene.pull.refreshing = false
        const n = idleFrames()
        verify(n <= maxIdleFrames, "frames while idle: " + n)
    }
}
