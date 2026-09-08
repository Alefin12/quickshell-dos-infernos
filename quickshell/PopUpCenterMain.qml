import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id:guia
    anchor.window: root
    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: parentWindow.height + 10
    width: 500
    height: 200
    visible: false
    HyprlandFocusGrab{
        active: true
        id: grab
        windows: [guia]
        onCleared: {guia.visible = false; island.state = ""}
    }
    MouseArea{
        id:guia_area
        anchors.fill:parent
        hoverEnabled:true
        onExited: guia.visible = false
    }
    GridLayout{
        anchors.fill:parent
        Repeater{
            model: 9
            Rectangle{
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                color: "red"
                Text{
                    text: index
                }
            }
        }
    }
}