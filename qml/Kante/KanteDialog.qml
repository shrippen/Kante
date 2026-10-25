import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import "."

/**
 * Dialog.
 *   System  a plain dialog (unchanged).
 *   Kante   nearly opaque panel with cut top-right and bottom-left corners, an accent bar
 *           on top, an uppercase title, Kante colors inside and Kante
 *           buttons in the footer (the accept button filled).
 * Accept button (Kante 1.43, from lmix): `acceptText` names it after what it does ("Add
 * input" instead of OK), `acceptEnabled` locks it while the form is incomplete. Both hold
 * for the footer of every style, also after a switch at run time (Kante has its own footer;
 * a text or lock set on the button itself was lost there).
 */
QQC2.Dialog {
    id: control

    /** Color of the bar on top in Kante (accent; negative for destructive questions). */
    property color kanteBarColor: KanteStyle.accentColor
    /** Text of the accept button (Ok, Save, Apply, Yes); "": the standard one. */
    property string acceptText: ""
    /** The accept button can be pressed. */
    property bool acceptEnabled: true

    /** The accept button of the footer shown now, or null. */
    function acceptButton() {
        for (const b of [QQC2.Dialog.Ok, QQC2.Dialog.Save, QQC2.Dialog.Apply, QQC2.Dialog.Yes]) {
            const button = standardButton(b)
            if (button) {
                return button
            }
        }
        return null
    }
    function applyAccept() {
        const button = acceptButton()
        if (!button) {
            return
        }
        if (acceptText.length > 0) {
            button.text = acceptText
        }
        button.enabled = acceptEnabled
    }
    onAcceptTextChanged: applyAccept()
    onAcceptEnabledChanged: applyAccept()
    onStandardButtonsChanged: Qt.callLater(applyAccept)
    Component.onCompleted: applyAccept()

    KanteScope { target: control.contentItem }

    // Not children: only handed to background/header/footer while Kante is on.
    readonly property Item kanteBackground: KanteCard {
        color: KanteStyle.dialogColor
        barColor: control.kanteBarColor
        chamferBottom: KanteStyle.chamfer
    }

    readonly property Item kanteHeader: QQC2.Label {
        visible: control.title.length > 0
        text: control.title
        font: KanteStyle.headingFont(KanteStyle.defaultFont.pointSize * 1.2)
        color: KanteStyle.strongTextColor
        elide: Text.ElideRight
        leftPadding: control.leftPadding
        rightPadding: control.rightPadding
        topPadding: control.topPadding + 3
    }

    readonly property Item kanteFooter: QQC2.DialogButtonBox {
        visible: count > 0
        standardButtons: control.standardButtons
        alignment: Qt.AlignRight
        spacing: Kirigami.Units.smallSpacing
        padding: control.padding
        background: null
        delegate: KanteButton {
            emphasis: QQC2.DialogButtonBox.buttonRole === QQC2.DialogButtonBox.AcceptRole
                      ? KanteButton.Emphasis.Primary : KanteButton.Emphasis.Normal
        }
    }

    // Qt hides a replaced background, header or footer and does not show it again when
    // the platform's comes back (Kante -> Kante Light or System at run time, also when the
    // saved style is applied after start): the dialog stood without a ground. Shown again,
    // and the background takes the dialog's size again.
    function kanteRestored(item, own) {
        if (KanteStyle.themed || !item || item === own) {
            return false
        }
        item.visible = true
        return true
    }
    onBackgroundChanged: {
        if (kanteRestored(background, kanteBackground)) {
            background.width = Qt.binding(() => control.width)
            background.height = Qt.binding(() => control.height)
        }
    }
    onHeaderChanged: kanteRestored(header, kanteHeader)
    onFooterChanged: {
        kanteRestored(footer, kanteFooter)
        // The other footer has its own buttons: name and lock them too.
        Qt.callLater(applyAccept)
    }

    // The dim behind the dialog is Kante's scrim role (best effort: only when the style
    // provides the overlay attached object).
    Binding {
        target: control.QQC2.Overlay
        property: "modal"
        value: control.kanteScrim
        when: KanteStyle.themed && control.QQC2.Overlay !== null
        restoreMode: Binding.RestoreBindingOrValue
    }
    readonly property Component kanteScrim: Component { Rectangle { color: KanteStyle.scrimColor } }
    Binding {
        target: control
        property: "background"
        value: control.kanteBackground
        when: KanteStyle.themed
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: control
        property: "header"
        value: control.kanteHeader
        when: KanteStyle.themed
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: control
        property: "footer"
        value: control.kanteFooter
        when: KanteStyle.themed
        restoreMode: Binding.RestoreBindingOrValue
    }
}
