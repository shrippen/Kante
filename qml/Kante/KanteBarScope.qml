import QtQuick
import "."

/**
 * The Kante colours for one Kirigami global toolbar (a page's bar, the page stack's bar):
 * a KanteScope with the page ground as the bar's ground, which gives the platform's Header
 * colours back when Kante is off. It does not watch the bar's items (`shallow`): a disabled
 * item in the bar keeps the platform's disabled colour. Used by KanteWindowScope; make it a child of the bar
 * (`createObject(bar, { target: bar })`), so both go together.
 */
KanteScope {
    backgroundRole: "backgroundColor"
    restorePlatform: true
    shallow: true
}
