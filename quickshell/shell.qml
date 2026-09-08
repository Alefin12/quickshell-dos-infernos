import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            
            required property var modelData
            screen: modelData
            width: 500
            implicitHeight: 60
            color: "transparent"
            exclusiveZone: 40
            
            anchors {
                top: true

            }

            margins {
                top: 5
            }

            CenterIsland {
                id: island
            }

        }

    }

}
