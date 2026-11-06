// Базовая «карточка» виджета: стекло, скругление, перетаскивание.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: w

    property var conf: ({})
    property var th: ({})
    readonly property color cAccent:  th.accent  || "#e8875a"
    readonly property color cAccent2: th.accent2 || "#f3a46c"
    readonly property color cAccent3: th.accent3 || "#f2c37a"
    readonly property color cFg:      th.fg      || "#fbeee0"
    readonly property color cBg:      th.bg      || "#1a1320"
    readonly property string foxAvatar: th.foxAvatar || "/usr/share/ember/icons/fox-avatar.png"
    property bool cardless: false      // віджет без картки (великий годинник)
    property real cardWidth: 300
    property real cardHeight: 160
    default property alias content: inner.data

    readonly property bool rightSide: conf.anchor === "right"
    readonly property real s: conf.scale > 0 ? conf.scale : 1.0
    property real posX: conf.x !== undefined ? conf.x : 60
    property real posY: conf.y !== undefined ? conf.y : 100

    signal moved(real x, real y)

    visible: conf.enabled !== false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "ember-widget"

    anchors {
        top: true
        left: !w.rightSide
        right: w.rightSide
    }
    margins {
        top: w.posY
        left: w.rightSide ? 0 : w.posX
        right: w.rightSide ? w.posX : 0
    }

    implicitWidth: cardWidth * s
    implicitHeight: cardHeight * s

    Rectangle {
        id: card
        width: w.cardWidth
        height: w.cardHeight
        transformOrigin: Item.TopLeft
        scale: w.s
        radius: 28
        color: w.cardless ? "transparent" : Qt.rgba(w.cBg.r, w.cBg.g, w.cBg.b, conf.opacity !== undefined ? conf.opacity : 0.55)
        border.width: w.cardless ? 0 : 1
        border.color: Qt.rgba(1, 1, 1, 0.13)

        // скляний відблиск зверху
        Rectangle {
            visible: !w.cardless
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
            height: parent.height * 0.55
            radius: parent.radius
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.10) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
            }
        }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: w.cardless ? 0 : 22
        }

        // Перетаскивание мышкой
        MouseArea {
            anchors.fill: parent
            z: -1
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.ArrowCursor
            property real px: 0
            property real py: 0
            onPressed: (m) => { px = m.x; py = m.y }
            onPositionChanged: (m) => {
                if (!pressed) return
                var dx = (m.x - px) * w.s
                var dy = (m.y - py) * w.s
                w.posX = Math.max(0, w.posX + (w.rightSide ? -dx : dx))
                w.posY = Math.max(0, w.posY + dy)
            }
            onReleased: w.moved(w.posX, w.posY)
        }
    }
}
