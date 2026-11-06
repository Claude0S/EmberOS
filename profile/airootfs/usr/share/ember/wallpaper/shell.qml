// Ember OS — обої (окремий легкий екземпляр Quickshell, працює і в режимі /little)
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root
    property string path: "/usr/share/backgrounds/ember/lake.png"
    FileView {
        id: wf
        path: Quickshell.env("HOME") + "/.config/ember/wallpaper"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { var p = text().trim(); if (p !== "") root.path = p }
    }
    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            color: "#1a1320"
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "ember-wallpaper"
            anchors { top: true; bottom: true; left: true; right: true }
            Image {
                anchors.fill: parent
                source: "file://" + root.path
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
            }
        }
    }
}
