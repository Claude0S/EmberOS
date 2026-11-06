// Погода (wttr.in). Город — в widgets.json → weather.city (пусто = по IP)
import QtQuick
import Quickshell
import Quickshell.Io

Widget {
    id: root
    cardWidth: 300
    cardHeight: 150

    readonly property bool en: Qt.locale().name.startsWith("en")
    property string icon: "󰖐"
    property string temp: "…"
    property string desc: en ? "Loading weather" : "Завантажую погоду"
    property string place: ""

    function parse(t) {
        var p = t.trim().split("|")
        if (p.length < 4) { desc = en ? "No internet" : "Немає інтернету"; temp = "—"; return }
        icon = p[0].trim(); temp = p[1].trim(); desc = p[2].trim(); place = p[3].trim()
    }

    Process {
        id: proc
        command: ["curl", "-sf", "--max-time", "10",
                  "https://wttr.in/" + encodeURIComponent(root.conf.city || "") + "?format=%c|%t|%C|%l&lang=" + (root.en ? "en" : "uk")]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }
    Timer { interval: 30 * 60 * 1000; repeat: true; running: true; triggeredOnStart: true; onTriggered: proc.running = true }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        Text { text: root.icon; font.pixelSize: 52; anchors.verticalCenter: parent.verticalCenter }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text { text: root.temp; color: "#fbeee0"; font.family: "Inter"; font.pixelSize: 38; font.weight: Font.Bold }
            Text { text: root.desc; color: "#f3a46c"; font.family: "Inter"; font.pixelSize: 15; width: 170; elide: Text.ElideRight }
            Text { text: root.place; color: Qt.rgba(0.98, 0.93, 0.88, 0.55); font.family: "Inter"; font.pixelSize: 12; width: 170; elide: Text.ElideRight }
        }
    }
}
