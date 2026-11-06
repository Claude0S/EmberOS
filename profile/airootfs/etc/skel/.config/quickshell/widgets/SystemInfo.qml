// Процесор, памʼять, батарея (або диск) — кільця
import QtQuick
import Quickshell
import Quickshell.Io

Widget {
    id: root
    cardWidth: 400
    cardHeight: 170

    readonly property bool en: Qt.locale().name.startsWith("en")
    readonly property bool ru: Qt.locale().name.startsWith("ru")
    property real cpu: 0
    property real mem: 0
    property int battery: -1
    property real disk: 0
    property var lastCpu: null

    function parse(t) {
        var lines = t.trim().split("\n")
        var c = lines[0].split(/\s+/).slice(1).map(Number)
        var idle = c[3] + c[4]
        var total = c.reduce(function (a, b) { return a + b }, 0)
        if (lastCpu) {
            var dt = total - lastCpu.total
            if (dt > 0) cpu = Math.max(0, Math.min(1, 1 - (idle - lastCpu.idle) / dt))
        }
        lastCpu = { idle: idle, total: total }
        var memTotal = 0, memAvail = 0
        for (var i = 1; i < lines.length; i++) {
            var p = lines[i].split(/\s+/)
            if (p[0] === "MemTotal:") memTotal = Number(p[1])
            else if (p[0] === "MemAvailable:") memAvail = Number(p[1])
            else if (p[0] === "BAT:") battery = Number(p[1])
            else if (p[0] === "DISK:") disk = Number(p[1]) / 100
        }
        if (memTotal > 0) mem = 1 - memAvail / memTotal
    }

    Process {
        id: proc
        command: ["sh", "-c", "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; b=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1); [ -n \"$b\" ] && echo \"BAT: $b\"; echo \"DISK: $(df --output=pcent / | tail -1 | tr -dc 0-9)\"; true"]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }
    Timer { interval: 2000; repeat: true; running: true; triggeredOnStart: true; onTriggered: proc.running = true }

    component Ring: Item {
        id: ring
        property real value: 0
        property string label
        property color c1: "#e8875a"
        property color c2: "#f2c37a"
        property color fg: "#fbeee0"
        width: 96; height: 126
        onValueChanged: cv.requestPaint()
        onC1Changed: cv.requestPaint()
        Canvas {
            id: cv
            width: 96; height: 96
            property real shown: ring.value
            Behavior on shown { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
            onShownChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d"); ctx.reset()
                var cx = width / 2, cy = height / 2, r = 38
                ctx.lineWidth = 9; ctx.lineCap = "round"
                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.12)
                ctx.beginPath(); ctx.arc(cx, cy, r, 0, 2 * Math.PI); ctx.stroke()
                var g = ctx.createLinearGradient(0, 0, width, height)
                g.addColorStop(0, ring.value > 0.85 ? "#ff7a6b" : ring.c1)
                g.addColorStop(1, ring.value > 0.85 ? "#ff9b8a" : ring.c2)
                ctx.strokeStyle = g
                ctx.beginPath(); ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.max(0.001, shown)); ctx.stroke()
            }
            Text {
                anchors.centerIn: parent
                text: Math.round(ring.value * 100) + "%"
                color: ring.fg; font.family: "Inter"; font.pixelSize: 18; font.weight: Font.Bold
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: ring.label
            color: ring.fg; opacity: 0.7; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Medium
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 30
        Ring { value: root.cpu; label: root.en ? "CPU" : root.ru ? "Процессор" : "Процесор"; c1: root.cAccent; c2: root.cAccent3; fg: root.cFg }
        Ring { value: root.mem; label: root.en ? "Memory" : root.ru ? "Память" : "Памʼять"; c1: root.cAccent2; c2: root.cAccent; fg: root.cFg }
        Ring {
            value: root.battery >= 0 ? root.battery / 100 : root.disk
            label: root.battery >= 0 ? (root.en ? "Battery" : "Батарея") : (root.en ? "Disk" : "Диск")
            c1: "#9bc48a"; c2: "#c8e0a0"; fg: root.cFg
        }
    }
}
