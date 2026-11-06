// Музыка: работает с любым плеером (Spotify, Firefox/YouTube, mpv, …) через MPRIS
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Widget {
    id: root
    cardWidth: 360
    cardHeight: 150

    readonly property bool en: Qt.locale().name.startsWith("en")
    readonly property bool ru: Qt.locale().name.startsWith("ru")
    property var player: {
        var ps = Mpris.players.values
        for (var i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }

    Timer {
        interval: 1000; repeat: true
        running: root.player !== null && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    Row {
        anchors.fill: parent
        spacing: 16

        Rectangle {
            width: 114; height: 114; radius: 16
            color: "#2a1c26"
            clip: true
            Image {
                anchors.fill: parent
                source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : "file:///usr/share/ember/icons/fox-avatar.png"
                fillMode: Image.PreserveAspectCrop
                smooth: true
            }
        }

        Column {
            width: parent.width - 130
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Text {
                width: parent.width
                text: root.player ? (root.player.trackTitle || (root.en ? "Untitled" : root.ru ? "Без названия" : "Без назви")) : (root.en ? "Silence…" : root.ru ? "Тишина…" : "Тиша…")
                color: "#fbeee0"; font.family: "Inter"; font.pixelSize: 17; font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: root.player ? (root.player.trackArtist || root.player.identity || "") : (root.en ? "Play music anywhere" : root.ru ? "Включи музыку где угодно" : "Увімкни музику будь-де")
                color: "#f3a46c"; font.family: "Inter"; font.pixelSize: 14
                elide: Text.ElideRight
            }

            // Прогресс
            Rectangle {
                width: parent.width; height: 4; radius: 2
                color: Qt.rgba(1, 1, 1, 0.12)
                visible: root.player !== null && root.player.length > 0
                Rectangle {
                    height: parent.height; radius: 2; color: "#e8875a"
                    width: root.player && root.player.length > 0
                           ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
                }
            }

            Row {
                spacing: 22
                topPadding: 6
                Repeater {
                    model: [
                        { icon: "󰒮", act: "prev" },
                        { icon: root.player && root.player.isPlaying ? "󰏤" : "󰐊", act: "toggle" },
                        { icon: "󰒭", act: "next" }
                    ]
                    Text {
                        required property var modelData
                        text: modelData.icon
                        color: ma.containsMouse ? "#f2c37a" : "#fbeee0"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: modelData.act === "toggle" ? 28 : 22
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            id: ma
                            anchors.fill: parent; anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.player) return
                                if (modelData.act === "prev") root.player.previous()
                                else if (modelData.act === "next") root.player.next()
                                else root.player.togglePlaying()
                            }
                        }
                    }
                }
            }
        }
    }
}
