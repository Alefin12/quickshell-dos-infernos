import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Loader {
    id: central
    property bool menuOpen: item ? item.menuOpen : false   // read back through `item`
    

    active: true

    sourceComponent: RowLayout {
        id: modules
        property bool menuOpen: sysTray.isMenuOpen   // valid here, same component scope

        RowLayout {
            Layout.alignment: Qt.AlignLeft

            Workspacesbak {
                id: workL
            }

            Workspaces {
                id: workR
            }

        }

        RowLayout {
            id: expandedModules
            
            Volume {
                id: volumeIcon
                Layout.alignment: Qt.AlignLeft
                Layout.leftMargin: 25
            }

            Item {
                Layout.fillWidth: true
            }

            SystemTray {
                id: sysTray
                
                bar: root
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 5
            }

        }

        Item {
            Layout.preferredWidth: expandedModules.visible? 20 : 50
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            Clock {
                id: clock
            }

        }

    }

}
