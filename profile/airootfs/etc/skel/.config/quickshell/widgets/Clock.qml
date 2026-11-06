// Великий годинник просто на обоях (без картки)
import QtQuick
import Quickshell

Widget {
    id: root
    cardless: true
    cardWidth: 460
    cardHeight: 200

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: -6
        Text {
            text: Qt.formatTime(clock.date, "HH:mm")
            color: root.cFg
            font.family: "Inter"
            font.pixelSize: 128
            font.weight: Font.ExtraLight
            font.letterSpacing: -4
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.25)
        }
        Text {
            leftPadding: 6
            text: {
                var s = clock.date.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
                return s.charAt(0).toUpperCase() + s.slice(1)
            }
            color: root.cAccent2
            font.family: "Inter"
            font.pixelSize: 26
            font.weight: Font.Medium
            style: Text.Raised
            styleColor: Qt.rgba(0, 0, 0, 0.25)
        }
    }
}
