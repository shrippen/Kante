import QtQuick
import QtTest
import Kante

/**
 * Kante 1.36, KanteKpi for screen readers (Kontra's start page, persona P7): one name of
 * label and value, the change as description; the texts inside are not read again.
 * Run: kante/tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante136"
    width: 400
    height: 300
    when: windowShown

    Component { id: kpiComponent; KanteKpi {} }

    function test_name() {
        var kpi = createTemporaryObject(kpiComponent, tc, { value: "7 min", label: "Practised", delta: "+2 min", trend: 1 })
        verify(kpi)
        compare(kpi.Accessible.role, Accessible.StaticText)
        compare(kpi.Accessible.name, "Practised: 7 min")
        compare(kpi.Accessible.description, "+2 min")
    }

    function test_without_label() {
        var kpi = createTemporaryObject(kpiComponent, tc, { value: "13" })
        compare(kpi.Accessible.name, "13")
    }
}
