import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import QtQuick.Effects
Item{
    Layout.preferredWidth: work2.width
    Layout.preferredHeight: work2.height
RectangularShadow {
    anchors.fill: work2
    offset.x: 0
    offset.y: 2
    radius: work2.radius
    blur: 3
    spread: 2
    color: Qt.darker(work2.color, 1.6)
}
Rectangle {
    id: work2

    // NOTE: requires `follow_mouse` enabled in your Hyprland config for
    // Hyprland.focusedMonitor to update in real time as the cursor moves
    // between monitors (rather than only on window focus changes).
    readonly property bool isFocusedMonitor: Hyprland.focusedMonitor && Hyprland.focusedMonitor.name === "DP-2"

    readonly property int targetContentWidth: {
        let w = 0;
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            const ws = Hyprland.workspaces.values[i];
            if (ws.monitor.name !== "DP-2" || ws.name === "special:magic")
                continue;
 // match your state widths
            w += ws.focused ? 35 : 19;
        }
        return w;
    }

    implicitWidth: targetContentWidth + 20
    implicitHeight: 20
    radius: 10
    color: !work2.isFocusedMonitor ? Colors.md3.on_primary: Colors.md3.on_primary_container

    border.color: !work2.isFocusedMonitor ? Qt.darker(Colors.md3.on_primary, 0.7): Colors.md3.primary_fixed_dim
    border.width: 1

    Behavior on color {
        ColorAnimation {
            duration: 0
        }
    }

    RowLayout {
        id: workspaces_area

        anchors.centerIn: parent
        spacing: -4

        Repeater {
            model: Hyprland.workspaces

            Shape {
                id: workspaces

                required property var modelData
                property bool hovered
                Layout.preferredHeight: 7
                Layout.alignment: Qt.AlignBaseline
                visible: modelData.monitor.name === "DP-2" && modelData.name !== "special:magic"
                state: modelData.focused ? "focused" : (modelData.activeWorkspace ? "" : ((workspaces.hovered ? "hovered" : "active")))
                antialiasing: true
                smooth: true
                states: [
                    State {
                        name: "focused"

                        PropertyChanges {
                            target: workspaces
                            Layout.preferredWidth: 35
                        }

                    },
                    State {
                        name: "active"

                        PropertyChanges {
                            target: workspaces
                            Layout.preferredWidth: 19
                        }

                    },
                    State {
                        name: "hovered"

                        PropertyChanges {
                            target: workspaces
                            Layout.preferredWidth: 26
                        }

                    }
                ]
                transitions: [
                    Transition {
                        NumberAnimation {
                            properties: "Layout.preferredWidth"
                            duration: 400
                            easing.type: Easing.OutBack
                        }

                    }
                ]

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: workspaces.hovered = true
                    onExited: workspaces.hovered = false
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (modelData.id) + "})")
                }

                ShapePath {
                    fillColor: !modelData.focused ? Colors.md3.primary_container : Colors.md3.primary_fixed_dim
                    strokeColor: Colors.md3.primary_fixed_dim
                    strokeWidth: 0
                    startX: 8
                    startY: 0

                    PathLine {
                        x: 15 + workspaces.width - 17
                        y: 0
                    }

                    PathLine {
                        x: 7 + workspaces.width - 17
                        y: 8
                    }

                    PathLine {
                        x: 0
                        y: 8
                    }

                    PathLine {
                        x: 8
                        y: 0
                    }

                }

                Behavior on Layout.minimumWidth {
                    NumberAnimation {
                        duration: 200
                    }

                }

            }

        }

    }

    Behavior on Layout.preferredWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCirc
        }

    }

}
}