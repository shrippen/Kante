import QtQuick
import QtQuick.Controls.impl

/**
 * A theme icon in one colour (1.73). Kirigami.Icon's isMask colours only where the platform theme
 * does it (Plasma); on Android, in an AppImage and in tests the icon stayed as it is, dark on the
 * dark Kante ground. The Controls' IconImage colours it on every platform.
 *   iconSource  a theme name ("go-next") or a url
 *   color       the colour of the symbol
 */
IconImage {
    property var iconSource: ""
    readonly property bool isUrl: /^[a-z]+:|^\//.test(String(iconSource))

    // IconImage picks the theme's file for its size once, when the name is set. In a layout the
    // size comes later: without this it keeps the file for size 0 and scales that one, grey and soft.
    name: isUrl || sourceSize.width <= 0 || sourceSize.height <= 0 ? "" : String(iconSource)
    source: isUrl ? iconSource : ""
    sourceSize.width: width
    sourceSize.height: height
}
