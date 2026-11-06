// Процессор, память, батарея
import QtQuick
import Quickshell
import Quickshell.Io

Widget {
    id: root
    cardWidth: 300
    cardHeight: 170

    readonly property bool en: Qt.locale().name.startsWith("en")
    readonly property bool ru: Qt.locale().name.startsWith("ru")
    property real cpu: 0
    property real mem: 0
    property int battery: -1
    property var lastCpu: null

    function parse(t) {
        var lines = t.trim().split("\n")
        var c = lines[0].split(/\s+/).slice(1).map(Number)
        var idle = c[3] + c[4]
        var total = c.reduce(function (a, b) { return a + b }, 0)
        if (lastCpu) {
            var dt = total - lastCpu.total
            if (dt > 0) cpu = 1 - (idle - lastCpu.idle) / dt
        }
        lastCpu = { idle: idle, total: total }
        var memTotal = 0, memAvail = 0
        for (var i = 1; i < lines.length; i++) {
            var p = lines[i].split(/\s+/)
            if (p[0] === "MemTotal:") memTotal = Number(p[1])
            else if (p[0] === "MemAvailable:") memAvail = Number(p[1])
            else if (p[0] === "BAT:") battery = Number(p[1])
        }
        if (memTotal > 0) mem = 1 - memAvail / memTotal
    }

    Process {
        id: proc
        command: ["sh", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; b=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1); [ -n \"$b\" ] && echo \"BAT: $b\"; true"]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }
    Timer { interval: 2000; repeat: true; running: true; triggeredOnStart: true; onTriggered: proc.running = true }

    // Кольори передаються явно: вбудований компонент не бачить id файлу
    component Bar: Column {
        property color cFg: "#fbeee0"
        property color cAc: "#e8875a"
        property color cAc2: "#f3a46c"
        property string label
        property real value
        property string valueText
        width: parent.width
        spacing: 5
        Row {
            width: parent.width
            Text { text: label; color: cFg; font.family: "Inter"; font.pixelSize: 14; width: parent.width - 60 }
            Text { text: valueText; color: cAc2; font.family: "Inter"; font.pixelSize: 14; width: 60; horizontalAlignment: Text.AlignRight }
        }
        Rectangle {
            width: parent.width; height: 6; radius: 3; color: Qt.rgba(1, 1, 1, 0.12)
            Rectangle {
                height: parent.height; radius: 3
                width: parent.width * Math.max(0, Math.min(1, value))
                color: value > 0.85 ? "#ff7a6b" : cAc
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: 14
        Bar { cFg: root.cFg; cAc: root.cAccent; cAc2: root.cAccent2; label: root.en ? "󰻠  CPU" : root.ru ? "󰻠  Процессор" : "󰻠  Процесор"; value: root.cpu; valueText: Math.round(root.cpu * 100) + "%" }
        Bar { cFg: root.cFg; cAc: root.cAccent; cAc2: root.cAccent2; label: root.en ? "󰍛  Memory" : root.ru ? "󰍛  Память" : "󰍛  Памʼять";    value: root.mem; valueText: Math.round(root.mem * 100) + "%" }
        Bar {
            cFg: root.cFg; cAc: root.cAccent; cAc2: root.cAccent2
            visible: root.battery >= 0
            label: root.en ? "󰁹  Battery" : "󰁹  Батарея"; value: root.battery / 100; valueText: root.battery + "%"
        }
    }
}
