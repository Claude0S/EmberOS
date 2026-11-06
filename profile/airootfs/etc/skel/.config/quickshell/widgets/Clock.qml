import QtQuick
import Quickshell

Widget {
    id: root
    cardWidth: 320
    cardHeight: 170

    SystemClock { id: clock; precision: SystemClock.Seconds }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        Text {
            text: Qt.formatTime(clock.date, "HH:mm")
            color: root.cFg
            font.family: "Inter"
            font.pixelSize: 68
            font.weight: Font.Bold
        }
        Text {
            text: clock.date.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
            color: root.cAccent2
            font.family: "Inter"
            font.pixelSize: 18
        }
    }
}
