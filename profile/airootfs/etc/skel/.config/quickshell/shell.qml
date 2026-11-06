// Ember OS — виджеты рабочего стола (Quickshell)
// Настройки: ~/.config/ember/widgets.json  (или команда /widgets)
// Виджеты можно перетаскивать мышкой — позиция сохраняется сама.
import QtQuick
import Quickshell
import Quickshell.Io
import "widgets"

ShellRoot {
    id: root

    property var cfg: defaults()
    property var th: ({})

    function defaults() {
        return {
            clock:   { enabled: true, anchor: "left",  x: 60, y: 80,  scale: 1.0, opacity: 0.55 },
            music:   { enabled: true, anchor: "left",  x: 60, y: 300, scale: 1.0, opacity: 0.55 },
            system:  { enabled: true, anchor: "right", x: 60, y: 80,  scale: 1.0, opacity: 0.55 },
            weather: { enabled: true, anchor: "right", x: 60, y: 270, scale: 1.0, opacity: 0.55, city: "" }
        }
    }

    function applyText(t) {
        var d = defaults()
        var o
        try { o = JSON.parse(t) } catch (e) { console.warn("widgets.json: " + e); o = {} }
        for (var k in d) {
            if (typeof o[k] !== "object" || o[k] === null) o[k] = d[k]
            for (var p in d[k]) if (o[k][p] === undefined) o[k][p] = d[k][p]
        }
        cfg = o
    }

    function setPos(key, x, y) {
        var o = JSON.parse(JSON.stringify(cfg))
        o[key].x = Math.round(x)
        o[key].y = Math.round(y)
        cfg = o
        cfgFile.setText(JSON.stringify(o, null, 2) + "\n")
    }

    FileView {
        id: cfgFile
        path: Quickshell.env("HOME") + "/.config/ember/widgets.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyText(text())
        onLoadFailed: cfgFile.setText(JSON.stringify(root.defaults(), null, 2) + "\n")
    }

    FileView {
        id: thFile
        path: Quickshell.env("HOME") + "/.config/ember/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.th = JSON.parse(text()) } catch (e) { root.th = ({}) } }
    }

    Clock      { conf: root.cfg.clock;   th: root.th; onMoved: (x, y) => root.setPos("clock", x, y) }
    Music      { conf: root.cfg.music;   th: root.th; onMoved: (x, y) => root.setPos("music", x, y) }
    SystemInfo { conf: root.cfg.system;  th: root.th; onMoved: (x, y) => root.setPos("system", x, y) }
    Weather    { conf: root.cfg.weather; th: root.th; onMoved: (x, y) => root.setPos("weather", x, y) }
}
