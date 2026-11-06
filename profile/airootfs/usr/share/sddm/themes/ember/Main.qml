// Ember OS — экран входа (SDDM, Qt 6)
import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#1a1320"

    readonly property color cream: "#fbeee0"
    readonly property color ember: "#e8875a"
    readonly property color amber: "#f3a46c"
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0

    function doLogin() {
        errorText.text = ""
        sddm.login(userField.text, passField.text, root.sessionIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            passField.text = ""
            errorText.text = "Невірний пароль · Wrong password · Неверный пароль"
            shake.start()
            passField.forceActiveFocus()
        }
    }

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // ─── Часы ───
    Column {
        id: clockBox
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.12
        spacing: 4
        property date now: new Date()
        Timer { interval: 1000; running: true; repeat: true; onTriggered: clockBox.now = new Date() }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatTime(clockBox.now, "HH:mm")
            color: root.cream
            font.family: "Inter"; font.pixelSize: 110; font.weight: Font.Bold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: clockBox.now.toLocaleDateString(Qt.locale(), "dddd, d MMMM")
            color: root.amber
            font.family: "Inter"; font.pixelSize: 24
        }
    }

    // ─── Карточка входа ───
    Rectangle {
        id: card
        width: 380
        height: 400
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.42
        radius: 28
        color: Qt.rgba(0.10, 0.07, 0.12, 0.55)
        border.color: Qt.rgba(0.94, 0.63, 0.44, 0.35)
        border.width: 1

        SequentialAnimation {
            id: shake
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -14; duration: 50 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 14; duration: 70 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: -8; duration: 60 }
            NumberAnimation { target: card; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
        }

        Column {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 60

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 110; height: 110; radius: 30
                color: "#2a1c3d"
                border.color: root.ember; border.width: 3
                clip: true
                Image {
                    anchors.fill: parent
                    anchors.margins: 12
                    source: "fox.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: false
                }
            }

            TextField {
                id: userField
                width: parent.width; height: 46
                text: userModel.lastUser
                placeholderText: "Імʼя користувача · Username"
                horizontalAlignment: Text.AlignHCenter
                color: root.cream
                placeholderTextColor: Qt.rgba(0.98, 0.93, 0.88, 0.5)
                font.family: "Inter"; font.pixelSize: 17
                background: Rectangle { radius: 14; color: Qt.rgba(1, 1, 1, 0.06) }
                onAccepted: passField.forceActiveFocus()
            }

            TextField {
                id: passField
                width: parent.width; height: 50
                echoMode: TextInput.Password
                placeholderText: "Пароль · Password"
                horizontalAlignment: Text.AlignHCenter
                color: root.cream
                placeholderTextColor: Qt.rgba(0.98, 0.93, 0.88, 0.5)
                font.family: "Inter"; font.pixelSize: 17
                focus: true
                background: Rectangle {
                    radius: 14
                    color: Qt.rgba(0.10, 0.07, 0.12, 0.7)
                    border.color: passField.activeFocus ? root.ember : Qt.rgba(0.94, 0.63, 0.44, 0.35)
                    border.width: 2
                }
                onAccepted: root.doLogin()
                Component.onCompleted: forceActiveFocus()
            }

            Rectangle {
                width: parent.width; height: 48; radius: 14
                color: loginMa.pressed ? "#c96f45" : (loginMa.containsMouse ? "#f09a6c" : root.ember)
                Behavior on color { ColorAnimation { duration: 150 } }
                Text {
                    anchors.centerIn: parent
                    text: "Увійти · Log in  →"
                    color: "#1a1320"
                    font.family: "Inter"; font.pixelSize: 17; font.weight: Font.Bold
                }
                MouseArea { id: loginMa; anchors.fill: parent; hoverEnabled: true; onClicked: root.doLogin() }
            }

            Text {
                id: errorText
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                color: "#ff9b8a"
                font.family: "Inter"; font.pixelSize: 14
            }
        }
    }

    // ─── Нижняя панель: сессия и питание ───
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 36
        spacing: 14

        ComboBox {
            id: sessionBox
            width: 220; height: 40
            model: sessionModel
            textRole: "name"
            currentIndex: root.sessionIndex
            onActivated: (i) => root.sessionIndex = i
            font.family: "Inter"
            contentItem: Text {
                leftPadding: 14
                text: sessionBox.displayText
                color: root.cream
                font.family: "Inter"; font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 12; color: Qt.rgba(0.10, 0.07, 0.12, 0.6); border.color: Qt.rgba(0.94, 0.63, 0.44, 0.3) }
        }

        Repeater {
            model: [
                { label: "Сон · Sleep",                act: "suspend",  ok: sddm.canSuspend },
                { label: "Перезавантажити · Restart", act: "reboot",   ok: sddm.canReboot },
                { label: "Вимкнути · Shut down",      act: "poweroff", ok: sddm.canPowerOff }
            ]
            Rectangle {
                required property var modelData
                visible: modelData.ok
                width: lbl.implicitWidth + 32; height: 40; radius: 12
                color: pma.containsMouse ? Qt.rgba(0.91, 0.53, 0.35, 0.35) : Qt.rgba(0.10, 0.07, 0.12, 0.6)
                border.color: Qt.rgba(0.94, 0.63, 0.44, 0.3)
                Text { id: lbl; anchors.centerIn: parent; text: modelData.label; color: root.cream; font.family: "Inter"; font.pixelSize: 14 }
                MouseArea {
                    id: pma; anchors.fill: parent; hoverEnabled: true
                    onClicked: {
                        if (modelData.act === "suspend") sddm.suspend()
                        else if (modelData.act === "reboot") sddm.reboot()
                        else sddm.powerOff()
                    }
                }
            }
        }
    }

    Text {
        anchors.left: parent.left; anchors.bottom: parent.bottom
        anchors.margins: 28
        text: "Ember OS"
        color: Qt.rgba(0.98, 0.93, 0.88, 0.5)
        font.family: "Inter"; font.pixelSize: 14
    }
}
