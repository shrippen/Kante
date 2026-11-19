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

    Component {
        id: lineChart
        KanteLineChart { axis: true }
    }

    // A gap (NaN) in a line keeps the scale undefined, as before the shared step.
    function test_lineWithGapHasNoScale() {
        const chart = createTemporaryObject(lineChart, this, { series: [[1, NaN, 3]] })
        verify(isNaN(chart.scaleTop))
    }

    // A loss that stays below 1 fills the plot when `minSpan` is 0; the default keeps the floor of 1.
    function test_minSpanZeroFitsTheScaleToTheData() {
        const chart = createTemporaryObject(lineChart, this, { series: [[0.25, 0.1, 0.2]], minSpan: 0 })
        fuzzyCompare(chart.scaleTop, 0.4, 1e-9)  // a quarter of 0.25 is 0.0625: the step 0.1
        const kept = createTemporaryObject(lineChart, this, { series: [[0.25, 0.1, 0.2]] })
        compare(kept.scaleTop, 1)  // the floor of 1 stays the default
    }

    function test_noDataOrAllZeroKeepsADrawableScale() {
        verify(createTemporaryObject(lineChart, this, { series: [[0, 0]], minSpan: 0 }).scaleTop > 0)
        verify(createTemporaryObject(lineChart, this, { series: [], minSpan: 0 }).scaleTop > 0)
    }

    function test_labelsCarryTheDecimalsOfTheStep() {
        const chart = createTemporaryObject(lineChart, this,
                { series: [[1, 0.5]], minSpan: 0, locale: Qt.locale("de_DE") })
        compare(chart.stepDecimals(0.25), 2)
        compare(chart.stepDecimals(2.5), 1)
        compare(chart.stepDecimals(5), 0)
        compare(chart.stepDecimals(0.025), 3)
        compare(chart.tickText(0), "0,00")  // the scale is 0 to 1 in steps of 0.25
        compare(chart.tickText(1), "0,25")
        compare(chart.tickText(4), "1,00")
    }

    function test_readoutIsWrittenInTheLocale() {
        const chart = createTemporaryObject(lineChart, this, { unit: " px", locale: Qt.locale("de_DE") })
        compare(chart.valueText(0.25), "0,25 px")
        compare(chart.valueText(3), "3 px")
        compare(chart.valueText(0.1 + 0.2), "0,3 px")
    }
}
