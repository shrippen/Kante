import QtQuick
import org.kde.kirigami as Kirigami
import Kante

Item {
    property alias dialog: d
    Kirigami.PromptDialog {
        id: d
        title: "x"
        subtitle: "y"
        standardButtons: Kirigami.Dialog.NoButton
        customFooterActions: [Kirigami.Action { text: "A" }, Kirigami.Action { text: "B" }]
    }
    KanteDialogSkin { dialog: d }
}
