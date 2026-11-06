// Музика: будь-який плеєр (Spotify, YouTube у Firefox, mpv…) через MPRIS
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

Widget {
    id: root
    cardWidth: 420
    cardHeight: 190

    readonly property bool en: Qt.locale().name.startsWith("en")
    readonly property bool ru: Qt.locale().name.startsWith("ru")
    property var player: {
        var ps = Mpris.players.values
        for (var i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
        return ps.length > 0 ? ps[0] : null
    }
    function fmt(sec) {
        if (!(sec > 0)) return "0:00"
        var m = Math.floor(sec / 60), s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    Timer {
        interval: 1000; repeat: true
        running: root.player !== null && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    Row {
        anchors.fill: parent
        spacing: 22

        ClippingRectangle {
            width: 146; height: 146; radius: 20
            color: "#2a1c26"
            Image {
                anchors.fill: parent
                source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : "file://" + root.foxAvatar
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
            }
        }

        Column {
            width: parent.width - 168
            spacing: 6
            topPadding: 12

            Text {
                width: parent.width
                text: root.player ? (root.player.trackTitle || (root.en ? "Untitled" : root.ru ? "Без названия" : "Без назви"))
                                  : (root.en ? "Silence…" : root.ru ? "Тишина…" : "Тиша…")
                color: root.cFg; font.family: "Inter"; font.pixelSize: 22; font.weight: Font.Bold
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                text: root.player ? ((root.player.trackArtist || "") + (root.player.identity ? "  ·  " + root.player.identity : ""))
                                  : (root.en ? "Play music anywhere" : root.ru ? "Включи музыку где угодно" : "Увімкни музику будь-де")
                color: root.cAccent2; font.family: "Inter"; font.pixelSize: 15; font.weight: Font.Medium
                elide: Text.ElideRight
            }

            // Перемотка з часом
            Item {
                width: parent.width; height: 34
                visible: root.player !== null && root.player.length > 0
                readonly property real frac: root.player && root.player.length > 0 ? Math.min(1, root.player.position / root.player.length) : 0
                Rectangle {
                    id: track
                    y: 10; width: parent.width; height: 5; radius: 2.5
                    color: Qt.rgba(1, 1, 1, 0.15)
                    Rectangle {
                        height: parent.height; radius: 2.5
                        width: parent.width * parent.parent.frac
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: root.cAccent }
                            GradientStop { position: 1; color: root.cAccent3 }
                        }
                    }
                    Rectangle {
                        width: 14; height: 14; radius: 7; color: root.cFg
                        x: parent.width * parent.parent.frac - 7; y: -4.5
                    }
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (m) => { if (root.player && root.player.canSeek) root.player.position = root.player.length * Math.max(0, Math.min(1, m.x / track.width)) }
                    }
                }
                Text { y: 20; text: root.fmt(root.player ? root.player.position : 0); color: root.cFg; opacity: 0.6; font.family: "Inter"; font.pixelSize: 12 }
                Text { y: 20; anchors.right: parent.right; text: root.fmt(root.player ? root.player.length : 0); color: root.cFg; opacity: 0.6; font.family: "Inter"; font.pixelSize: 12 }
            }

            // Кнопки
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 26
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰒮"; color: prevMa.containsMouse ? root.cAccent3 : root.cFg
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 24
                    MouseArea { id: prevMa; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (root.player) root.player.previous() }
                }
                Rectangle {
                    width: 46; height: 46; radius: 23
                    scale: playMa.pressed ? 0.92 : (playMa.containsMouse ? 1.06 : 1)
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: root.cAccent }
                        GradientStop { position: 1; color: root.cAccent3 }
                    }
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: root.player && root.player.isPlaying ? 0 : 2
                        text: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                        color: root.cBg; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 24
                    }
                    MouseArea { id: playMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (root.player) root.player.togglePlaying() }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰒭"; color: nextMa.containsMouse ? root.cAccent3 : root.cFg
                    font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 24
                    MouseArea { id: nextMa; anchors.fill: parent; anchors.margins: -8; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (root.player) root.player.next() }
                }
            }
        }
    }
}
