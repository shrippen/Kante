import QtQuick
import QtTest
import Kante

/**
 * Kante 1.69, from Mitori's grade chips: a chip that is one choice of a set the app holds
 * (`choice`) keeps the app's binding of `checked`. A tap toggled it in JS and broke the binding
 * ("5. Kyu" stayed chosen after "4. Kyu"; a second tap on the chosen one emptied the set).
 * Run: tools/check-qml.sh.
 */
TestCase {
    id: tc
    name: "Kante169"
    width: 400
    height: 200
    when: windowShown

    property string grade: "a"

    Component {
        id: chips
        Row {
            property alias a: a
            property alias b: b
            KanteChip { id: a; text: "A"; checkable: true; choice: true; checked: tc.grade === "a"; onClicked: tc.grade = "a" }
            KanteChip { id: b; text: "B"; checkable: true; choice: true; checked: tc.grade === "b"; onClicked: tc.grade = "b" }
        }
    }

    function test_choiceKeepsBinding() {
        tc.grade = "a"
        const row = createTemporaryObject(chips, tc)
        row.b.activate()
        compare(tc.grade, "b")
        verify(row.b.checked && !row.a.checked, "only the chosen one")
        row.b.activate()                // the chosen one again: stays chosen
        verify(row.b.checked)
        row.a.activate()
        verify(row.a.checked && !row.b.checked)
    }

    // A filter chip (without `choice`) still toggles itself.
    function test_filterToggles() {
        const c = createTemporaryObject(Qt.createComponent("../Kante/KanteChip.qml"), tc, { checkable: true })
        c.activate()
        verify(c.checked)
        c.activate()
        verify(!c.checked)
    }
}
