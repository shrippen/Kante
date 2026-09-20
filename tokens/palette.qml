pragma Singleton
import QtQuick 2.15

/*
 * shrippen Design Default — QML palette reference.
 * https://github.com/shrippen/shrippen.github.io
 *
 * In Plasma widgets, use Kirigami.Theme.* for all dynamic/interactive colors.
 * Use these only for brand accent elements (icon fills, priority bands,
 * project hashes, version badges, About header).
 */
QtObject {
    // Brand
    readonly property color accent:  "#e8dcc4"

    // Gruvbox backgrounds (for reference / non-Plasma contexts)
    readonly property color bgHard:  "#1d2021"
    readonly property color bg0:     "#282828"
    readonly property color bg1:     "#3c3836"
    readonly property color bg2:     "#504945"

    // Gruvbox foregrounds
    readonly property color fg0:     "#fbf1c7"
    readonly property color fg1:     "#ebdbb2"
    readonly property color fg2:     "#d5c4a1"
    readonly property color fg3:     "#a89984"

    // Semantic (bright variants)
    readonly property color blue:    "#83a598"
    readonly property color aqua:    "#8ec07c"
    readonly property color green:   "#b8bb26"
    readonly property color yellow:  "#fabd2f"
    readonly property color orange:  "#fe8019"
    readonly property color red:     "#fb4934"
    readonly property color purple:  "#d3869b"

    // Semantic (neutral variants — quieter)
    readonly property color blueN:   "#458588"
    readonly property color aquaN:   "#689d6a"
    readonly property color greenN:  "#98971a"
    readonly property color yellowN: "#d79921"
    readonly property color orangeN: "#d65d0e"
    readonly property color redN:    "#cc241d"
    readonly property color purpleN: "#b16286"
}
