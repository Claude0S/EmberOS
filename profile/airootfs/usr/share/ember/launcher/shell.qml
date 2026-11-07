// Ember Launcher — меню програм, ігор і команд. Підлаштовується під тему (/theme, /mascot).
// Відкривається: Super+Space, Super+D, кнопка в доці (ember-launcher).
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property var th: ({})
    property var db: ({ apps: [], games: [], recent: [] })
    property string lang: "uk"
    property int tab: 0                 // 0 програми · 1 ігри · 2 недавні · 3 команди
    property string query: ""
    property int sel: 0
    property string clock: Qt.formatTime(new Date(), "HH:mm")
    property string battery: ""

    readonly property color cAccent:  th.accent  || "#e8875a"
    readonly property color cAccent2: th.accent2 || "#f3a46c"
    readonly property color cFg:      th.fg      || "#fbeee0"
    readonly property color cBg:      th.bg      || "#1a1320"
    readonly property color cSurface: th.surface || "#523049"
    readonly property string themeKey: (th.name || "Ember").toLowerCase()
    readonly property bool lite: liteFile.loaded && liteFile.text().trim() === "little"

    function tr(uk, en, ru) { return lang === "en" ? en : (lang === "ru" ? ru : uk) }
    function a(c, al) { return Qt.rgba(c.r, c.g, c.b, al) }

    readonly property var tabs: [tr("Програми", "Apps", "Программы"), tr("Ігри", "Games", "Игры"),
                                 tr("Недавні", "Recent", "Недавние"), tr("Команди", "Commands", "Команды")]

    readonly property var commands: [
        { cmd: "/antivirus", glyph: "shield",   name: tr("Антивірус", "Antivirus", "Антивирус") },
        { cmd: "/update",    glyph: "download", name: tr("Оновити систему", "Update system", "Обновить систему") },
        { cmd: "/theme ember",  glyph: "palette", name: "Тема · Ember" },
        { cmd: "/theme night",  glyph: "palette", name: "Тема · Night" },
        { cmd: "/theme cyber",  glyph: "palette", name: "Тема · Cyber" },
        { cmd: "/theme aurora", glyph: "palette", name: "Тема · Aurora" },
        { cmd: "/theme autumn", glyph: "palette", name: "Тема · Autumn" },
        { cmd: "/theme winter", glyph: "palette", name: "Тема · Winter" },
        { cmd: "/theme desert", glyph: "palette", name: "Тема · Desert" },
        { cmd: "/theme cosmos", glyph: "palette", name: "Тема · Cosmos" },
        { cmd: "/theme ocean",  glyph: "palette", name: "Тема · Ocean" },
        { cmd: "/theme forest", glyph: "palette", name: "Тема · Forest" },
        { cmd: "/theme sakura", glyph: "palette", name: "Тема · Sakura" },
        { cmd: "/theme mono",   glyph: "palette", name: "Тема · Mono" },
        { cmd: "/widgets reset", glyph: "widgets", name: tr("Віджети на місце", "Reset widgets", "Виджеты на место") },
        { cmd: "/little",    glyph: "leaf",     name: tr("Легкий режим", "Light mode", "Лёгкий режим") },
        { cmd: "/full",      glyph: "quick",    name: tr("Повний режим", "Full mode", "Полный режим") },
        { cmd: "/wifi",      glyph: "wifi",     name: "Wi-Fi" },
        { cmd: "/drivers",   glyph: "gear",     name: tr("Драйвери", "Drivers", "Драйверы") },
        { cmd: "/status",    glyph: "info",     name: tr("Стан системи", "System status", "Состояние системы") },
        { cmd: "/lang",      glyph: "globe",    name: tr("Мова", "Language", "Язык") }
    ]

    function match(it, q) {
        q = q.toLowerCase()
        return (it.name || "").toLowerCase().indexOf(q) >= 0 ||
               (it.keywords || "").indexOf(q) >= 0 ||
               (it.cmd || "").indexOf(q) >= 0
    }

    function byId(id) {
        var all = db.apps || []
        for (var i = 0; i < all.length; i++) if (all[i].id === id) return all[i]
        return null
    }

    // що показуємо зараз
    readonly property var items: {
        var q = query.trim()
        var out = []
        if (q.charAt(0) === "/") {
            out.push({ cmd: q, glyph: "terminal", name: tr("Виконати ", "Run ", "Выполнить ") + q })
            for (var c = 0; c < commands.length; c++)
                if (commands[c].cmd.indexOf(q) === 0 && commands[c].cmd !== q) out.push(commands[c])
            return out
        }
        if (q !== "") {
            var pools = [db.apps || [], db.games || [], commands]
            for (var p = 0; p < pools.length; p++)
                for (var i = 0; i < pools[p].length; i++)
                    if (match(pools[p][i], q)) out.push(pools[p][i])
            return out
        }
        if (tab === 0) return db.apps || []
        if (tab === 1) return db.games || []
        if (tab === 2) {
            var r = db.recent || []
            for (var k = 0; k < r.length; k++) { var e = byId(r[k]); if (e) out.push(e) }
            return out
        }
        return commands
    }
    readonly property bool gameGrid: query.trim() === "" && tab === 1
    readonly property var continueGames: (db.games || []).filter(function (g) { return g.last > 0 }).slice(0, 3)
    readonly property bool showContinue: query.trim() === "" && tab === 0 && continueGames.length > 0

    onItemsChanged: sel = 0
    onTabChanged: query = ""

    function launch(it) {
        if (!it) return
        if (it.cmd) Quickshell.execDetached(["ember-apps", "cmd", it.cmd])
        else Quickshell.execDetached(["ember-apps", "run", it.id])
        Qt.quit()
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/ember/theme.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.th = JSON.parse(text()) } catch (e) { root.th = ({}) } }
    }
    FileView {
        path: Quickshell.env("HOME") + "/.config/ember/lang"
        onLoaded: { var l = text().trim(); if (l === "en" || l === "ru" || l === "uk") root.lang = l }
    }
    FileView { id: liteFile; path: Quickshell.env("HOME") + "/.config/ember/mode" }

    Process {
        command: ["ember-apps", "list"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: { try { root.db = JSON.parse(this.text) } catch (e) { console.warn("ember-apps: " + e) } }
        }
    }
    Process {
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.battery = this.text.trim() }
    }
    Timer { interval: 5000; running: true; repeat: true; onTriggered: root.clock = Qt.formatTime(new Date(), "HH:mm") }

    PanelWindow {
        id: win
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "ember-launcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }

        // затемнення; клік повз меню — закрити
        Rectangle {
            anchors.fill: parent
            color: root.a(root.cBg, 0.35)
            opacity: card.opacity
            MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
        }

        Rectangle {
            id: card
            width: 860
            height: 600
            anchors.centerIn: parent
            radius: 30
            clip: true
            color: root.a(root.cBg, 0.86)
            border.width: root.themeKey === "cyber" ? 2 : 1
            border.color: root.themeKey === "cyber" ? root.cAccent : Qt.rgba(1, 1, 1, 0.12)
            opacity: 0
            scale: 0.96
            Component.onCompleted: { opacity = 1; scale = 1 }
            Behavior on opacity { enabled: !root.lite; NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { enabled: !root.lite; NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
            MouseArea { anchors.fill: parent }   // кліки всередині не закривають

            // м'яке світіння в кольорі теми
            Rectangle {
                width: 460; height: 460; radius: 230
                x: -150; y: -230
                color: root.cAccent
                opacity: 0.22
                visible: !root.lite
                layer.enabled: !root.lite
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }
            }
            // прикраси теми: сніг / зорі
            Repeater {
                model: (root.themeKey === "winter" || root.themeKey === "cosmos" || root.themeKey === "night" || root.themeKey === "aurora") && !root.lite ? 60 : 0
                Rectangle {
                    required property int index
                    readonly property real r1: Math.abs(Math.sin(index * 12.9898) * 43758.5453) % 1
                    readonly property real r2: Math.abs(Math.sin(index * 78.233) * 12345.678) % 1
                    x: r1 * card.width; y: r2 * card.height
                    width: root.themeKey === "winter" ? 2 + (index % 3) : 1.5 + (index % 2)
                    height: width; radius: width / 2
                    color: "white"
                    opacity: 0.18 + 0.4 * ((index * 7) % 10) / 10
                }
            }

            // ── верх: лисеня + пошук ──
            Row {
                id: top
                x: 30; y: 26
                spacing: 18
                Image {
                    width: 62; height: 62
                    source: root.th.fox ? "file://" + root.th.fox : "file:///usr/share/ember/icons/fox-avatar.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: false
                    sourceSize: Qt.size(124, 124)
                }
                Rectangle {
                    width: card.width - 60 - 62 - 18
                    height: 52
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 26
                    color: root.a(root.cSurface, 0.66)
                    border.width: 1.5
                    border.color: root.a(root.cAccent, input.activeFocus ? 0.75 : 0.35)
                    Icon { name: "search"; color: root.cFg; opacity: 0.7; size: 18; x: 20; anchors.verticalCenter: parent.verticalCenter }
                    TextInput {
                        id: input
                        x: 50; width: parent.width - 70
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.cFg
                        selectionColor: root.cAccent
                        font.family: "Inter"; font.pixelSize: 17
                        focus: true
                        clip: true
                        onTextChanged: root.query = text
                        Component.onCompleted: forceActiveFocus()
                        Text {
                            visible: input.text === ""
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.tr("Напиши програму, гру або /команду", "Type an app, game or /command", "Напиши программу, игру или /команду")
                            color: root.cFg; opacity: 0.45
                            font: input.font
                        }
                        Keys.onPressed: (ev) => {
                            var n = root.items.length
                            var cols = root.gameGrid ? 4 : 6
                            if (ev.key === Qt.Key_Escape) { Qt.quit(); ev.accepted = true }
                            else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) { root.launch(root.items[root.sel]); ev.accepted = true }
                            else if (ev.key === Qt.Key_Tab) { root.tab = (root.tab + 1) % 4; input.text = ""; ev.accepted = true }
                            else if (ev.key === Qt.Key_Backtab) { root.tab = (root.tab + 3) % 4; input.text = ""; ev.accepted = true }
                            else if (ev.key === Qt.Key_Right && input.text === "") { root.sel = Math.min(n - 1, root.sel + 1); ev.accepted = true }
                            else if (ev.key === Qt.Key_Left && input.text === "") { root.sel = Math.max(0, root.sel - 1); ev.accepted = true }
                            else if (ev.key === Qt.Key_Down) { root.sel = Math.min(n - 1, root.sel + cols); ev.accepted = true }
                            else if (ev.key === Qt.Key_Up) { root.sel = Math.max(0, root.sel - cols); ev.accepted = true }
                        }
                    }
                }
            }

            // ── вкладки ──
            Row {
                id: tabRow
                x: 30; y: top.y + 62 + 16
                spacing: 10
                Repeater {
                    model: root.tabs
                    Rectangle {
                        required property int index
                        required property string modelData
                        readonly property bool on: root.tab === index && root.query.trim() === ""
                        width: lbl.implicitWidth + 36; height: 34; radius: 17
                        color: on ? root.cAccent : root.a(root.cSurface, 0.4)
                        Behavior on color { ColorAnimation { duration: 140 } }
                        Text {
                            id: lbl
                            anchors.centerIn: parent
                            text: modelData
                            color: parent.on ? root.cBg : root.a(root.cFg, 0.7)
                            font.family: "Inter"; font.pixelSize: 14; font.weight: Font.DemiBold
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.tab = index; input.text = "" } }
                    }
                }
            }

            // ── сітка ──
            GridView {
                id: grid
                x: 24; y: tabRow.y + 34 + 14
                width: card.width - 48
                height: card.height - y - 54 - (root.showContinue ? 130 : 10)
                clip: true
                cellWidth: root.gameGrid ? width / 4 : width / 6
                cellHeight: root.gameGrid ? 200 : 112
                model: root.items
                currentIndex: root.sel
                highlightFollowsCurrentItem: false
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

                delegate: Item {
                    id: cell
                    required property int index
                    required property var modelData
                    readonly property bool cur: index === root.sel
                    width: grid.cellWidth; height: grid.cellHeight

                    Rectangle {
                        anchors.fill: parent; anchors.margins: 4
                        radius: 18
                        color: cell.cur ? root.a(root.cAccent, 0.18) : (ma.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                        border.width: cell.cur ? 1.5 : 0
                        border.color: root.a(root.cAccent, 0.7)
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    // звичайна плитка
                    Column {
                        visible: !root.gameGrid
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 56; height: 56; radius: 16
                            readonly property bool hasImg: !!cell.modelData.icon
                            color: hasImg ? "transparent" : root.a(root.cAccent, 0.85)
                            Image {
                                anchors.fill: parent
                                visible: parent.hasImg
                                source: cell.modelData.icon ? "file://" + cell.modelData.icon : ""
                                sourceSize: Qt.size(112, 112)
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                            }
                            Icon {
                                anchors.centerIn: parent
                                visible: !parent.hasImg
                                name: cell.modelData.glyph || "apps"
                                color: root.cBg
                                size: 28
                            }
                            scale: cell.cur ? 1.08 : 1
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: grid.cellWidth - 16
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: cell.modelData.name || ""
                            color: root.a(root.cFg, 0.88)
                            font.family: "Inter"; font.pixelSize: 13
                        }
                    }

                    // обкладинка гри
                    Rectangle {
                        visible: root.gameGrid
                        anchors.fill: parent; anchors.margins: 8
                        radius: 16
                        clip: true
                        color: root.a(root.cSurface, 0.7)
                        Image {
                            anchors.fill: parent
                            source: cell.modelData.cover ? "file://" + cell.modelData.cover : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        Icon { anchors.centerIn: parent; visible: !cell.modelData.cover; name: "gamepad"; color: root.cAccent; size: 42 }
                        Rectangle {
                            anchors.bottom: parent.bottom; width: parent.width; height: 46
                            gradient: Gradient {
                                GradientStop { position: 0; color: "transparent" }
                                GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.75) }
                            }
                            Text {
                                x: 12; anchors.bottom: parent.bottom; anchors.bottomMargin: 10
                                width: parent.width - 24; elide: Text.ElideRight
                                text: cell.modelData.name || ""
                                color: "white"; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Bold
                            }
                        }
                    }

                    MouseArea {
                        id: ma
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.sel = cell.index
                        onClicked: root.launch(cell.modelData)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.items.length === 0
                    text: root.tab === 1 && root.query === ""
                          ? root.tr("Ігор ще немає — встанови щось у Steam або Hydra", "No games yet — install something in Steam or Hydra", "Игр пока нет — установи что-нибудь в Steam или Hydra")
                          : root.tr("Нічого не знайдено", "Nothing found", "Ничего не найдено")
                    color: root.a(root.cFg, 0.5); font.family: "Inter"; font.pixelSize: 15
                }
            }

            // ── продовжити гру ──
            Column {
                visible: root.showContinue
                x: 30; y: card.height - 54 - 124
                width: card.width - 60
                spacing: 8
                Text {
                    text: root.tr("ПРОДОВЖИТИ ГРУ", "CONTINUE PLAYING", "ПРОДОЛЖИТЬ ИГРУ")
                    color: root.cAccent2; font.family: "Inter"; font.pixelSize: 12; font.weight: Font.Bold; font.letterSpacing: 1.2
                }
                Row {
                    spacing: 12
                    Repeater {
                        model: root.continueGames
                        Rectangle {
                            required property var modelData
                            width: (card.width - 60 - 24) / 3; height: 74; radius: 16; clip: true
                            color: root.a(root.cSurface, 0.7)
                            border.width: 1; border.color: Qt.rgba(1, 1, 1, 0.12)
                            Image { anchors.fill: parent; source: modelData.cover ? "file://" + modelData.cover : ""; fillMode: Image.PreserveAspectCrop; opacity: 0.85; asynchronous: true }
                            Rectangle { anchors.fill: parent; gradient: Gradient { GradientStop { position: 0.3; color: "transparent" } GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.7) } } }
                            Text { x: 14; anchors.bottom: parent.bottom; anchors.bottomMargin: 10; width: parent.width - 28; elide: Text.ElideRight
                                   text: modelData.name; color: "white"; font.family: "Inter"; font.pixelSize: 14; font.weight: Font.Bold }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.launch(modelData) }
                        }
                    }
                }
            }

            // ── низ ──
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 54
                color: root.a(root.cSurface, 0.35)
                Row {
                    x: 26; anchors.verticalCenter: parent.verticalCenter
                    spacing: 10
                    Repeater {
                        model: [
                            { icon: "power", act: function () { Quickshell.execDetached(["ember-power"]); Qt.quit() } },
                            { icon: "lock",  act: function () { Quickshell.execDetached(["hyprlock"]); Qt.quit() } },
                            { icon: "gear",  act: function () { root.tab = 3; input.text = "" } }
                        ]
                        Rectangle {
                            required property var modelData
                            width: 32; height: 32; radius: 16
                            color: bma.containsMouse ? root.a(root.cAccent, 0.35) : root.a(root.cAccent, 0.16)
                            Icon { anchors.centerIn: parent; name: modelData.icon; color: root.cAccent; size: 16 }
                            MouseArea { id: bma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: modelData.act() }
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8
                        textFormat: Text.StyledText
                        text: "<font color='" + root.cAccent + "'><b>↑↓←→</b></font> " + root.tr("вибір", "select", "выбор") +
                              " · <font color='" + root.cAccent + "'><b>Enter</b></font> " + root.tr("запуск", "launch", "запуск") +
                              " · <font color='" + root.cAccent + "'><b>Tab</b></font> " + root.tr("вкладки", "tabs", "вкладки")
                        color: root.a(root.cFg, 0.65); font.family: "Inter"; font.pixelSize: 13
                    }
                }
                Text {
                    anchors.right: parent.right; anchors.rightMargin: 26; anchors.verticalCenter: parent.verticalCenter
                    text: "Ember · " + (root.th.name || "Ember") + " · " + root.clock + (root.battery !== "" ? " · " + root.battery + "%" : "")
                    color: root.a(root.cFg, 0.65); font.family: "Inter"; font.pixelSize: 13
                }
            }
        }
    }
}
