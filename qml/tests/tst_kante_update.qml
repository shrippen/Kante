import QtQuick
import QtTest
import Kante

/**
 * Kante 1.22: KanteUpdateCheck. Version comparison, reading versions.json (format 1 only,
 * https links only), the hint after a newer version, dismissing it until the next one, and
 * the remembered answer that keeps a restart from asking again. No network: enabled is
 * false or the answer is fed through receive(). Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "KanteUpdate"

    readonly property string file: JSON.stringify({ format: 1, projects: { "plasmai": {
        version: "2.5.3", date: "2026-10-06", url: "https://github.com/shrippen/Plasmai/releases/tag/v2.5.3" } } })

    Component {
        id: checkComponent
        KanteUpdateCheck { project: "plasmai"; version: "2.5.2"; enabled: false }
    }

    function make(props) {
        return createTemporaryObject(checkComponent, tc, props || {})
    }

    function test_compare() {
        var c = make()
        compare(c.compareVersions("0.10.0", "0.9.3"), 1)
        compare(c.compareVersions("v1.2", "1.2.0"), 0)
        compare(c.compareVersions("1.2.0-beta1", "1.2.0"), 0)
        compare(c.compareVersions("2.5.2", "2.5.10"), -1)
    }

    function test_newer_version_available() {
        var c = make()
        c.enabled = true
        c.receive(file)
        compare(c.latestVersion, "2.5.3")
        compare(c.latestDate, "2026-10-06")
        compare(c.latestUrl, "https://github.com/shrippen/Plasmai/releases/tag/v2.5.3")
        verify(c.available)
        c.enabled = false
        verify(!c.available, "off means no hint")
    }

    function test_same_version_no_hint() {
        var c = make({ version: "2.5.3" })
        c.enabled = true
        c.receive(file)
        verify(!c.available)
    }

    function test_dismiss_until_next_version() {
        var c = make()
        c.enabled = true
        c.receive(file)
        c.dismiss()
        verify(!c.available)
        c.receive(file.replace(/2\.5\.3/g, "2.6.0"))
        verify(c.available, "a newer version shows again")
    }

    function test_rejects_unknown_format_and_links() {
        var c = make()
        c.enabled = true
        c.receive(JSON.stringify({ format: 2, projects: { plasmai: { version: "9.0", url: "https://x" } } }))
        verify(!c.available)
        c.receive(JSON.stringify({ format: 1, projects: { plasmai: { version: "9.0", url: "javascript:alert(1)" } } }))
        verify(!c.available)
        c.receive("not json")
        verify(!c.available)
        compare(c.latestVersion, "")
    }

    function test_memory_keeps_restart_quiet() {
        var first = make()
        first.enabled = true
        first.receive(file)
        var memory = first.memory
        verify(memory.length > 0)
        var second = make({ memory: memory })
        second.enabled = true
        second.check(false)
        compare(second._request, null, "fresh answer: no request")
        verify(second.available)
    }
}
