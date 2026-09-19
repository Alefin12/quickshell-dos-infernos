import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Loader {
    id: central
    property bool menuOpen: item ? item.menuOpen : false   // read back through `item`
    

    active: true

// CentralModules.qml
sourceComponent: RowLayout {
    id: modules
    property bool menuOpen: sysTray.isMenuOpen || volumeIcon.isMenuOpen
    
    RowLayout {
        Layout.alignment: Qt.AlignRight

        Workspacesbak { id: workL }
        Workspaces { id: workR }
        Layout.rightMargin: 5
        
    }
    SimpleVerticalSeparator{width: 5; Layout.rightMargin: 0}
    VolumeIndicator{id: volumePopup}
    RowLayout {
        id: expandedModules
        clip: true
        visible: Layout.preferredWidth > 0
        property int shadowPadding: 10
        readonly property real naturalWidth: volumeIcon.width + sysTray.width
        Layout.alignment: Qt.AlignCenter
        Layout.leftMargin: 0
        Layout.preferredWidth: island.expanded ? naturalWidth + 30 : (modulesChanger.currentIndex === 1 ? naturalWidth + 30  : 0 )
        Layout.preferredHeight: Math.max(volumeIcon.implicitHeight, sysTray.implicitHeight) + shadowPadding * 2

        Behavior on Layout.preferredWidth {
            NumberAnimation { duration: 300;}
        }
        Item{Layout.fillWidth: true}
        Volume {
            id: volumeIcon
            Layout.alignment: Qt.AlignCenter

            Layout.minimumWidth: implicitWidth
            bar: root
        }
        SimpleVerticalSeparator{width: 2; height: 15;Layout.rightMargin: 5; Layout.leftMargin: 5; }
        SystemTray {
            id: sysTray
            bar: root
            Layout.alignment: Qt.AlignCenter
            Layout.minimumWidth: implicitWidth
        }
        Item{Layout.fillWidth: true}
    }
        SimpleVerticalSeparator{width: 5; Layout.leftMargin: 0; visible: expandedModules.Layout.preferredWidth > 0 || volumePopup.visible}
    RowLayout {
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: 5
        Clock { id: clock }
    }
}

}
