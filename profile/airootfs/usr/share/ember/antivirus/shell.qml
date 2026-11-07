// Ember Антивірус (/antivirus) — вікно в стилі теми. Робота — в ember-av (ClamAV + ufw).
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property var th: ({})
    property string lang: "uk"
    property var st: ({})
    property var qlist: []
    property string page: "main"          // main | quarantine
    property int sel: 0
    property int qsel: 0

    readonly property color cAccent:  th.accent  || "#e8875a"
    readonly property color cAccent2: th.accent2 || "#f3a46c"
    readonly property color cFg:      th.fg      || "#fbeee0"
    readonly property color cBg:      th.bg      || "#1a1320"
    readonly property color cSurface: th.surface || "#523049"
    readonly property color cRed: "#ff6b6b"
    readonly property color cGood: "#7fd18a"
    readonly property color cWarn: "#f2c37a"

    function tr(uk, en, ru) { return lang === "en" ? en : (lang === "ru" ? ru : uk) }
    function a(c, al) { return Qt.rgba(c.r, c.g, c.b, al) }
    function when(t) {
        if (!t) return ""
        var d = new Date(t * 1000), now = new Date()
        var day = d.toDateString() === now.toDateString() ? tr("сьогодні", "today", "сегодня")
                : Qt.formatDate(d, "dd.MM")
        return day + ", " + Qt.formatTime(d, "HH:mm")
    }
    function dur(s) { s = s || 0; return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2) }
    function n(x) { return (x || 0).toLocaleString(Qt.locale("uk_UA"), "f", 0) }

    readonly property var scan: st.scan || null
    readonly property bool scanning: !!scan && (scan.state === "loading" || scan.state === "running")
    readonly property var job: st.job && st.job.state === "running" ? st.job : null
    readonly property bool threat: !!scan && scan.state === "done" && (scan.found || []).length > 0
                                   && (Date.now() / 1000 - (scan.started || 0)) < 86400

    readonly property var items: [
        scanning ? { key: "stop", icon: "stop", name: tr("Зупинити перевірку", "Stop scan", "Остановить проверку"), sub: "" }
                 : { key: "quick", icon: "quick", name: tr("Швидка перевірка", "Quick scan", "Быстрая проверка"),
                     sub: tr("Завантаження, робочий стіл, .exe", "Downloads, desktop, .exe", "Загрузки, рабочий стол, .exe") },
        { key: "full", icon: "shield", name: tr("Повна перевірка", "Full scan", "Полная проверка"),
          sub: tr("Уся домашня папка", "Whole home folder", "Вся домашняя папка") },
        { key: "folder", icon: "folder", name: tr("Перевірити папку…", "Scan a folder…", "Проверить папку…"), sub: "" },
        { key: "update", icon: "refresh", name: st.installed ? tr("Оновити бази", "Update databases", "Обновить базы")
                                                         : tr("Встановити антивірус", "Install antivirus", "Установить антивирус"),
          sub: st.db ? when(st.dbTime) : tr("≈ 300 МБ", "≈ 300 MB", "≈ 300 МБ") },
        { key: "quarantine", icon: "trash", name: tr("Карантин", "Quarantine", "Карантин"),
          sub: st.quarantine ? (st.quarantine + " " + tr("файл(ів)", "file(s)", "файл(ов)")) : tr("порожньо", "empty", "пусто") },
        { key: "firewall", icon: "wall", name: tr("Файрвол", "Firewall", "Файрвол"),
          sub: st.firewall ? tr("увімкнено", "on", "включён") : tr("вимкнено", "off", "выключен") },
        { key: "back", icon: "back", name: tr("Закрити", "Close", "Закрыть"), sub: "" }
    ]

    function act(key) {
        if (key === "quick" || key === "full") run(["ember-av", "scan", key])
        else if (key === "stop") run(["ember-av", "cancel"])
        else if (key === "folder") { picker.running = true }
        else if (key === "update") run(["ember-av", st.installed ? "update" : "install"])
        else if (key === "quarantine") { page = "quarantine"; qsel = 0; qProc.running = true }
        else if (key === "firewall") run(["ember-av", "firewall", st.firewall ? "off" : "on"])
        else if (key === "back") Qt.quit()
        poll.restart()
    }
    function run(cmd) { Quickshell.execDetached(cmd); refreshSoon.restart() }

    // стан
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
    Process {
        id: statusProc
        command: ["ember-av", "status"]
        running: true
        stdout: StdioCollector { onStreamFinished: { try { root.st = JSON.parse(this.text) } catch (e) {} } }
    }
    Process {
        id: qProc
        command: ["ember-av", "quarantine"]
        stdout: StdioCollector { onStreamFinished: { try { root.qlist = JSON.parse(this.text) } catch (e) { root.qlist = [] } } }
    }
    Process {
        id: picker
        command: ["zenity", "--file-selection", "--directory", "--title=Ember"]
        stdout: StdioCollector {
            onStreamFinished: { var p = this.text.trim(); if (p !== "") root.run(["ember-av", "scan", p]) }
        }
    }
    Timer { id: poll; interval: root.scanning || root.job ? 600 : 2000; running: true; repeat: true
            onTriggered: if (!statusProc.running) statusProc.running = true }
    Timer { id: refreshSoon; interval: 400; onTriggered: { statusProc.running = true; if (root.page === "quarantine") qProc.running = true } }

    PanelWindow {
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "ember-antivirus"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors { top: true; bottom: true; left: true; right: true }

        Rectangle {
            anchors.fill: parent
            color: root.a(root.cBg, 0.35)
            opacity: card.opacity
            MouseArea { anchors.fill: parent; onClicked: Qt.quit() }
        }

        Rectangle {
            id: card
            width: 560
            height: 680
            anchors.centerIn: parent
            radius: 30
            clip: true
            color: root.a(root.cBg, 0.88)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.12)
            opacity: 0
            scale: 0.96
            Component.onCompleted: { opacity = 1; scale = 1; forceActiveFocus() }
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
            MouseArea { anchors.fill: parent }

            // «пульс» під час перевірки
            property real pulse: 0
            SequentialAnimation on pulse {
                running: root.scanning
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: 1; duration: 900; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1; to: 0; duration: 900; easing.type: Easing.InOutSine }
            }

            focus: true
            Keys.onPressed: (ev) => {
                if (root.page === "quarantine") {
                    var qn = root.qlist.length
                    if (ev.key === Qt.Key_Escape || ev.key === Qt.Key_Backspace) root.page = "main"
                    else if (ev.key === Qt.Key_Down) root.qsel = Math.min(qn - 1, root.qsel + 1)
                    else if (ev.key === Qt.Key_Up) root.qsel = Math.max(0, root.qsel - 1)
                    else if ((ev.key === Qt.Key_R) && qn) root.run(["ember-av", "restore", root.qlist[root.qsel].id])
                    else if ((ev.key === Qt.Key_Delete || ev.key === Qt.Key_D) && qn) root.run(["ember-av", "delete", root.qlist[root.qsel].id])
                    ev.accepted = true
                    return
                }
                if (ev.key === Qt.Key_Escape) Qt.quit()
                else if (ev.key === Qt.Key_Down || ev.key === Qt.Key_Tab) root.sel = (root.sel + 1) % root.items.length
                else if (ev.key === Qt.Key_Up || ev.key === Qt.Key_Backtab) root.sel = (root.sel + root.items.length - 1) % root.items.length
                else if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter || ev.key === Qt.Key_Space) root.act(root.items[root.sel].key)
                ev.accepted = true
            }

            // ореол за лисеням: колір теми, червоний при загрозі
            Rectangle {
                width: 340; height: 340; radius: 170
                anchors.horizontalCenter: parent.horizontalCenter
                y: -150
                color: root.threat ? root.cRed : root.cAccent
                opacity: root.scanning ? 0.25 + 0.15 * card.pulse : 0.3
                Behavior on color { ColorAnimation { duration: 400 } }
                layer.enabled: true
                layer.effect: MultiEffect { blurEnabled: true; blur: 1.0; blurMax: 64 }
            }

            Column {
                id: head
                width: parent.width
                y: 26
                spacing: 8
                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 118; height: 118
                    source: root.th.fox ? "file://" + root.th.fox : "file:///usr/share/ember/icons/fox-avatar.png"
                    sourceSize: Qt.size(236, 236)
                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    // лисеня «нюхає», поки йде перевірка
                    rotation: root.scanning ? 4 * Math.sin(card.pulse * Math.PI * 2) : 0
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    textFormat: Text.StyledText
                    text: "Ember <font color='" + root.cAccent + "'>" + root.tr("Антивірус", "Antivirus", "Антивирус") + "</font>"
                    color: root.cFg; font.family: "Inter"; font.pixelSize: 24; font.weight: Font.ExtraBold
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 7
                    readonly property var info: {
                        if (root.job) {
                            var w = { install: root.tr("Встановлюю антивірус і бази…", "Installing antivirus and databases…", "Устанавливаю антивирус и базы…"),
                                      update: root.tr("Оновлюю бази…", "Updating databases…", "Обновляю базы…"),
                                      firewall: root.tr("Налаштовую файрвол…", "Setting up firewall…", "Настраиваю файрвол…") }
                            return { icon: "refresh", color: root.cAccent2, text: w[root.job.action] || "…" }
                        }
                        if (root.scanning) return { icon: "search", color: root.cAccent2,
                            text: root.scan.state === "loading" ? root.tr("Готую перевірку…", "Preparing scan…", "Готовлю проверку…")
                                                               : root.tr("Перевіряю… ", "Scanning… ", "Проверяю… ") + root.n(root.scan.done) + " / " + root.n(root.scan.total) }
                        if (root.threat) return { icon: "warn", color: root.cRed,
                            text: root.tr("Знайдено загроз: ", "Threats found: ", "Найдено угроз: ") + root.scan.found.length + root.tr(" → у карантині", " → quarantined", " → в карантине") }
                        if (!root.st.installed) return { icon: "info", color: root.cWarn,
                            text: root.tr("Антивірус ще не встановлено — натисни перевірку", "Not installed yet — press a scan to set it up", "Антивирус ещё не установлен — нажми проверку") }
                        if (root.st.last) return { icon: "check", color: root.cGood,
                            text: root.tr("Захищено · остання перевірка ", "Protected · last scan ", "Защищено · последняя проверка ") + root.when(root.st.last.time) }
                        return { icon: "info", color: root.cAccent2, text: root.tr("Ще не перевірялось — почни зі швидкої перевірки", "Never scanned — start with a quick scan", "Ещё не проверялось — начни с быстрой проверки") }
                    }
                    Icon { name: parent.info.icon; color: parent.info.color; size: 16; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: parent.info.text; color: parent.info.color; font.family: "Inter"; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            // прогрес перевірки
            Column {
                id: prog
                visible: root.scanning || root.threat
                x: 40; y: head.y + head.height + 14
                width: parent.width - 80
                spacing: 6
                Rectangle {
                    width: parent.width; height: 8; radius: 4
                    color: root.a(root.cSurface, 0.7)
                    Rectangle {
                        height: parent.height; radius: 4
                        width: parent.width * (root.scan && root.scan.total ? root.scan.done / root.scan.total : 0)
                        Behavior on width { NumberAnimation { duration: 500 } }
                        gradient: Gradient { orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: root.cAccent }
                            GradientStop { position: 1; color: root.threat ? root.cRed : root.cAccent2 } }
                    }
                }
                Item {
                    width: parent.width; height: 16
                    Text {
                        width: parent.width - 90
                        elide: Text.ElideMiddle
                        text: root.scanning ? (root.scan.current || "") : root.n(root.scan ? root.scan.total : 0) + root.tr(" файлів перевірено", " files scanned", " файлов проверено")
                        color: root.a(root.cFg, 0.6); font.family: "Inter"; font.pixelSize: 12
                    }
                    Text {
                        anchors.right: parent.right
                        text: root.scan ? (root.scanning ? "" : root.tr("за ", "in ", "за ")) + root.dur(root.scan.elapsed) : ""
                        color: root.a(root.cFg, 0.6); font.family: "Inter"; font.pixelSize: 12
                    }
                }
            }

            // ── головне меню ──
            Column {
                visible: root.page === "main"
                x: 26; width: parent.width - 52
                y: (prog.visible ? prog.y + prog.height : head.y + head.height) + 18
                spacing: 5
                Repeater {
                    model: root.items
                    Rectangle {
                        id: row
                        required property int index
                        required property var modelData
                        readonly property bool cur: root.sel === index
                        width: parent.width; height: 48; radius: 15
                        color: cur ? root.a(root.cAccent, 0.18) : (rma.containsMouse ? Qt.rgba(1, 1, 1, 0.04) : "transparent")
                        border.width: cur ? 1.5 : 0
                        border.color: root.a(root.cAccent, 0.7)
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Rectangle {
                            id: ib
                            x: 14; anchors.verticalCenter: parent.verticalCenter
                            width: 32; height: 32; radius: 10
                            color: row.cur ? root.cAccent : root.a(root.cSurface, 0.6)
                            Icon { anchors.centerIn: parent; name: row.modelData.icon; size: 17; color: row.cur ? root.cBg : root.cAccent }
                        }
                        Text {
                            x: ib.x + 46; anchors.verticalCenter: parent.verticalCenter
                            text: row.modelData.name
                            color: root.cFg; font.family: "Inter"; font.pixelSize: 15; font.weight: Font.DemiBold
                        }
                        Row {
                            anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { anchors.verticalCenter: parent.verticalCenter; text: row.modelData.sub; color: root.a(root.cFg, 0.55); font.family: "Inter"; font.pixelSize: 12 }
                            Rectangle {       // кількість у карантині
                                visible: row.modelData.key === "quarantine" && root.st.quarantine > 0
                                anchors.verticalCenter: parent.verticalCenter
                                width: Math.max(22, bt.implicitWidth + 12); height: 20; radius: 10; color: root.cRed
                                Text { id: bt; anchors.centerIn: parent; text: root.st.quarantine || 0; color: "white"; font.family: "Inter"; font.pixelSize: 12; font.weight: Font.Bold }
                            }
                            Rectangle {       // перемикач файрволу
                                visible: row.modelData.key === "firewall"
                                anchors.verticalCenter: parent.verticalCenter
                                width: 40; height: 22; radius: 11
                                color: root.st.firewall ? root.cAccent : root.a(root.cSurface, 0.9)
                                Behavior on color { ColorAnimation { duration: 160 } }
                                Rectangle { width: 16; height: 16; radius: 8; y: 3; x: root.st.firewall ? 21 : 3; color: root.cBg
                                            Behavior on x { NumberAnimation { duration: 160 } } }
                            }
                        }
                        MouseArea { id: rma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onEntered: root.sel = row.index; onClicked: root.act(row.modelData.key) }
                    }
                }
            }

            // ── карантин ──
            Column {
                visible: root.page === "quarantine"
                x: 26; width: parent.width - 52
                y: (prog.visible ? prog.y + prog.height : head.y + head.height) + 18
                spacing: 6
                Text {
                    text: root.tr("Карантин", "Quarantine", "Карантин") + " · " + root.qlist.length
                    color: root.cAccent2; font.family: "Inter"; font.pixelSize: 13; font.weight: Font.Bold; leftPadding: 6
                }
                Text {
                    visible: root.qlist.length === 0
                    text: root.tr("Порожньо — жодного підозрілого файлу 🦊", "Empty — no suspicious files 🦊", "Пусто — ни одного подозрительного файла 🦊")
                    color: root.a(root.cFg, 0.6); font.family: "Inter"; font.pixelSize: 14; topPadding: 20; leftPadding: 6
                }
                Repeater {
                    model: root.qlist.slice(0, 6)
                    Rectangle {
                        id: qrow
                        required property int index
                        required property var modelData
                        width: parent.width; height: 58; radius: 15
                        color: root.qsel === index ? root.a(root.cRed, 0.14) : root.a(root.cSurface, 0.35)
                        border.width: root.qsel === index ? 1.5 : 0
                        border.color: root.a(root.cRed, 0.6)
                        Column {
                            x: 16; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 130
                            Text { width: parent.width; elide: Text.ElideMiddle; text: qrow.modelData.name; color: root.cFg; font.family: "Inter"; font.pixelSize: 14; font.weight: Font.DemiBold }
                            Text { width: parent.width; elide: Text.ElideRight; text: qrow.modelData.sig + " · " + root.when(qrow.modelData.time); color: root.a(root.cRed, 0.9); font.family: "Inter"; font.pixelSize: 11 }
                        }
                        Row {
                            anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Repeater {
                                model: [{ icon: "restore", cmd: "restore" }, { icon: "trash", cmd: "delete" }]
                                Rectangle {
                                    required property var modelData
                                    width: 34; height: 34; radius: 17
                                    color: qma.containsMouse ? root.a(root.cAccent, 0.35) : root.a(root.cAccent, 0.16)
                                    Icon { anchors.centerIn: parent; name: modelData.icon; color: root.cAccent; size: 16 }
                                    MouseArea { id: qma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: root.run(["ember-av", modelData.cmd, qrow.modelData.id]) }
                                }
                            }
                        }
                        MouseArea { anchors.fill: parent; z: -1; onClicked: root.qsel = qrow.index }
                    }
                }
                Rectangle {
                    width: parent.width; height: 44; radius: 15
                    color: bma.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent"
                    Row { x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                        Icon { name: "back"; color: root.cAccent; size: 17; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: root.tr("Назад", "Back", "Назад"); color: root.cFg; font.family: "Inter"; font.pixelSize: 15; font.weight: Font.DemiBold } }
                    MouseArea { id: bma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.page = "main" }
                }
            }

            // підказки
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width; height: 44
                color: root.a(root.cSurface, 0.3)
                Text {
                    anchors.centerIn: parent
                    textFormat: Text.StyledText
                    readonly property string k: "<font color='" + root.cAccent + "'><b>"
                    text: root.page === "main"
                        ? k + "↑↓</b></font> " + root.tr("вибір", "select", "выбор") + "   " + k + "Enter</b></font> " + root.tr("відкрити", "open", "открыть") + "   " + k + "Esc</b></font> " + root.tr("закрити", "close", "закрыть")
                        : k + "R</b></font> " + root.tr("повернути", "restore", "вернуть") + "   " + k + "Del</b></font> " + root.tr("видалити", "delete", "удалить") + "   " + k + "Esc</b></font> " + root.tr("назад", "back", "назад")
                    color: root.a(root.cFg, 0.55); font.family: "Inter"; font.pixelSize: 12
                }
            }
        }
    }
}
