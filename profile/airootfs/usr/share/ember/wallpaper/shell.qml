// Ember OS — обої (окремий легкий екземпляр Quickshell, працює і в режимі /little)
import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
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
                source: "file:///usr/share/backgrounds/ember/lake.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
            }
        }
    }
}
