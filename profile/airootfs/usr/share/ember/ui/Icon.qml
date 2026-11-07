// Іконка-лінія Ember (SVG-шлях, фарбується в будь-який колір теми)
import QtQuick

Image {
    id: ic
    property string name: "search"
    property color color: "white"
    property real size: 18
    property real stroke: 2

    readonly property var paths: ({
        "search": "M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM20 20l-4-4",
        "power": "M12 3v8M7 6a8 8 0 1 0 10 0",
        "lock": "M6 11h12v9H6zM8 11V8a4 4 0 0 1 8 0v3",
        "gear": "M12 9a3 3 0 1 0 0 6 3 3 0 0 0 0-6zM12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M5 19l2-2M17 7l2-2",
        "quick": "M13 2L4 14h7l-1 8 9-12h-7z",
        "shield": "M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6z",
        "folder": "M3 7h7l2 2h9v10H3z",
        "refresh": "M20 12a8 8 0 1 1-3-6.2M20 4v5h-5",
        "trash": "M4 7h16M6 7l1 13h10l1-13M9 7V4h6v3",
        "wall": "M3 5h18v14H3zM3 10h18M3 15h18M9 5v5M15 10v5M9 15v4",
        "back": "M15 6l-6 6 6 6",
        "check": "M5 12l5 5 9-10",
        "warn": "M12 8v5M12 16v.5M10.3 3.9L2 18a2 2 0 0 0 1.7 3h16.6a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z",
        "restore": "M4 12a8 8 0 1 0 3-6.2M4 4v5h5",
        "x": "M6 6l12 12M18 6L6 18",
        "stop": "M7 7h10v10H7z",
        "play": "M8 5l11 7-11 7z",
        "terminal": "M5 8l4 4-4 4M11 16h7",
        "palette": "M12 3a9 9 0 1 0 0 18c1 0 1.5-.8 1.5-1.5 0-1.2-1-1.3-1-2.5S13.5 15 15 15h2a4 4 0 0 0 4-4c0-4.4-4-8-9-8zM7.5 11.5h.01M10 7.5h.01M15 7.5h.01",
        "gamepad": "M6 9h12a4 4 0 0 1 0 8l-2-2H8l-2 2a4 4 0 0 1 0-8zM8 11v3M6.5 12.5h3M15.5 12h.01M17.5 13.5h.01",
        "apps": "M5 5h4v4H5zM15 5h4v4h-4zM5 15h4v4H5zM15 15h4v4h-4z",
        "clock": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 7v5l3 2",
        "download": "M12 4v11M7 10l5 5 5-5M5 20h14",
        "wifi": "M2 9a15 15 0 0 1 20 0M5 12.5a10 10 0 0 1 14 0M8.5 16a5 5 0 0 1 7 0M12 19.5h.01",
        "leaf": "M5 19c0-8 6-14 15-14 0 9-6 15-14 15M5 19l7-7",
        "widgets": "M4 4h7v7H4zM13 4h7v4h-7zM13 10h7v10h-7zM4 13h7v7H4z",
        "info": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 11v6M12 7.5h.01",
        "globe": "M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"
    })

    function hx(c) {
        function h(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s }
        return "#" + h(c.r) + h(c.g) + h(c.b)
    }

    width: size
    height: size
    sourceSize: Qt.size(size * 2, size * 2)
    smooth: true
    source: "data:image/svg+xml;utf8," + encodeURIComponent(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="' + (paths[name] || paths["info"]) +
        '" fill="none" stroke="' + hx(color) + '" stroke-width="' + stroke +
        '" stroke-linecap="round" stroke-linejoin="round"/></svg>')
}
