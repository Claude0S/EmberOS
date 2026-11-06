// Погода зараз + прогноз (wttr.in). Місто — widgets.json → weather.city (порожньо = за IP)
import QtQuick
import Quickshell
import Quickshell.Io

Widget {
    id: root
    cardWidth: 400
    cardHeight: 180

    readonly property bool en: Qt.locale().name.startsWith("en")
    readonly property bool ru: Qt.locale().name.startsWith("ru")
    readonly property string lang: en ? "en" : ru ? "ru" : "uk"
    property string icon: "󰖐"
    property string temp: "…"
    property string desc: en ? "Loading weather" : ru ? "Загружаю погоду" : "Завантажую погоду"
    property string sub: ""
    property var days: []

    function glyph(code) {
        code = Number(code)
        if (code === 113) return "󰖙"                                   // ясно
        if (code === 116) return "󰖕"                                   // мінлива хмарність
        if (code === 119 || code === 122) return "󰖐"                   // хмарно
        if ([143, 248, 260].indexOf(code) >= 0) return "󰖑"             // туман
        if ([200, 386, 389, 392, 395].indexOf(code) >= 0) return "󰖓"   // гроза
        if (code >= 179 && code <= 230 || code >= 323 && code <= 377) return "󰖘" // сніг
        return "󰖗"                                                     // дощ
    }

    function parse(t) {
        var j
        try { j = JSON.parse(t) } catch (e) { desc = en ? "No internet" : ru ? "Нет интернета" : "Немає інтернету"; temp = "—"; return }
        var c = j.current_condition[0]
        icon = glyph(c.weatherCode)
        temp = c.temp_C + "°"
        var l = c["lang_" + lang]
        desc = l && l.length ? l[0].value : c.weatherDesc[0].value
        var area = j.nearest_area && j.nearest_area[0] ? j.nearest_area[0].areaName[0].value : ""
        sub = area + (area ? "  ·  " : "") + (en ? "feels " : ru ? "ощущ. " : "відчув. ") + c.FeelsLikeC + "°"
        var d = []
        for (var i = 0; i < j.weather.length; i++) {
            var w = j.weather[i]
            var dt = new Date(w.date + "T12:00:00")
            d.push({ day: dt.toLocaleDateString(Qt.locale(), "ddd"), t: w.maxtempC + "°", g: glyph(w.hourly[4] ? w.hourly[4].weatherCode : 116) })
        }
        days = d
    }

    Process {
        id: proc
        command: ["curl", "-sf", "--max-time", "12",
                  "https://wttr.in/" + encodeURIComponent(root.conf.city || "") + "?format=j1&lang=" + root.lang]
        stdout: StdioCollector { onStreamFinished: root.parse(this.text) }
    }
    Timer { interval: 30 * 60 * 1000; repeat: true; running: true; triggeredOnStart: true; onTriggered: proc.running = true }

    Column {
        anchors.fill: parent
        spacing: 10
        Row {
            spacing: 16
            Text { text: root.icon; color: root.cAccent3; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 58; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.temp; color: root.cFg; font.family: "Inter"; font.pixelSize: 54; font.weight: Font.Light; anchors.verticalCenter: parent.verticalCenter }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text { text: root.desc; color: root.cFg; font.family: "Inter"; font.pixelSize: 15; font.weight: Font.Medium; width: 200; elide: Text.ElideRight }
                Text { text: root.sub; color: root.cFg; opacity: 0.6; font.family: "Inter"; font.pixelSize: 13; width: 200; elide: Text.ElideRight }
            }
        }
        Row {
            width: parent.width
            Repeater {
                model: root.days
                Column {
                    required property var modelData
                    width: parent.width / Math.max(1, root.days.length)
                    spacing: 2
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.day; color: root.cFg; opacity: 0.6; font.family: "Inter"; font.pixelSize: 13 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData.g + " " + modelData.t; color: root.cFg; font.family: "Inter"; font.pixelSize: 16; font.weight: Font.Bold }
                }
            }
        }
    }
}
