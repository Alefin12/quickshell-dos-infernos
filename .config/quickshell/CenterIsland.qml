import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import QtQuick.Effects
import Quickshell.Widgets

MouseArea {

    id: island
    property bool expanded: containsMouse || central.menuOpen
    property int animationCount: 0
    width: modulesChanger.width
    height: modulesChanger.height
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 10 
    hoverEnabled: true
        onWheel: (wheel) => {
    if (!island.expanded || wheelCooldown.running) {
        wheel.accepted = true;
        return ;
    }

    // support both vertical wheel and horizontal touchpad scroll
    const delta = Math.abs(wheel.angleDelta.y) > Math.abs(wheel.angleDelta.x)
                    ? wheel.angleDelta.y
                    : wheel.angleDelta.x;

    if (delta < 0 && modulesChanger.currentIndex < modulesChanger.count - 1)
        modulesChanger.currentIndex += 1;
    else if (delta > 0 && modulesChanger.currentIndex > 0)
        modulesChanger.currentIndex -= 1;
    
    wheelCooldown.restart();
    wheel.accepted = true;
}

Timer {
    id: wheelCooldown
    interval: 350
}
RectangularShadow {
    anchors.fill: myRect
    offset.x: 0
    offset.y: 2
    radius: myRect.radius
    blur: 3
    spread: 2
    color: Qt.darker(myRect.color, 1.6)
}
ClippingRectangle {
    id: myRect
    anchors.fill: parent
    radius: 30
    color: Colors.md3.primary_fixed_dim
    
    
    
Item {
    id: modulesChanger
    anchors.centerIn: parent

    implicitWidth: currentItem ? currentItem.implicitWidth + leftPadding + rightPadding : 0
    implicitHeight: 33
    property int currentIndex: 0
    property int count: 2
    readonly property var pages: [central, media]
    readonly property var currentItem: pages[currentIndex]

    property int leftPadding: 20
    property int rightPadding: 20

    // true only for the width change caused by a page switch
    property bool pageChanging: false
    onCurrentIndexChanged: pageChanging = true

    Behavior on implicitWidth {
        SequentialAnimation {
            // wait before resizing, but only on a page switch
            PauseAnimation { duration: modulesChanger.pageChanging ? 0 : 0 }
            NumberAnimation { duration: modulesChanger.pageChanging ? 300 : 0 } // or give this a real duration if you want the resize itself animated
            ScriptAction { script: modulesChanger.pageChanging = false }
        }
    }

    Row {
        id: pagesRow
        anchors.verticalCenter: parent.verticalCenter
        x: modulesChanger.leftPadding - (modulesChanger.currentItem ? modulesChanger.currentItem.x : 0)
        spacing: 30

        Behavior on x {
            NumberAnimation { duration: 300 }
        }

        CentralModules { id: central }
        MediaPlayer { id: media }
    }
}
}

}