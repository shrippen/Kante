import QtQuick
import QtTest
import Kante

/** KanteStyle.niceStep: the axis step shared by the bar, line and scatter charts. */
TestCase {
    name: "KanteNiceStep"

    function test_roundsUpToOneTwoTwoFiveFive() {
        compare(KanteStyle.niceStep(0.7), 1)
        compare(KanteStyle.niceStep(1), 1)
        compare(KanteStyle.niceStep(1.7), 2)
        compare(KanteStyle.niceStep(2.2), 2.5)
        compare(KanteStyle.niceStep(4), 5)
        compare(KanteStyle.niceStep(31), 50)
        compare(KanteStyle.niceStep(60), 100)
    }

    function test_scalesWithPowerOfTen() {
        fuzzyCompare(KanteStyle.niceStep(0.023), 0.025, 1e-12)
        fuzzyCompare(KanteStyle.niceStep(0.0004), 0.0005, 1e-15)
        fuzzyCompare(KanteStyle.niceStep(1.2e9), 2e9, 1)
    }

    function test_noPositiveInputGivesOne() {
        compare(KanteStyle.niceStep(0), 1)
        compare(KanteStyle.niceStep(-5), 1)
        compare(KanteStyle.niceStep(NaN), 1)
    }
}
