// Базовая «карточка» виджета: стекло, скругление, перетаскивание.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: w

    property var conf: ({})
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
        radius: 22
        color: Qt.rgba(0.102, 0.075, 0.125, conf.opacity !== undefined ? conf.opacity : 0.7)
        border.width: 1
        border.color: Qt.rgba(0.94, 0.63, 0.44, 0.30)

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: 18
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
