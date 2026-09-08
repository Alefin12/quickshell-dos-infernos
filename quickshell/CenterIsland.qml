import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import QtQuick.Effects

MouseArea {

    id: island
    property bool expanded: containsMouse || central.menuOpen
    property int animationCount: 0
    width: modulesChanger.width
    height: modulesChanger.height
    anchors.centerIn:parent
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
    blur: 30
    spread: 0
    color: Qt.darker(myRect.color, 1.6)
}
Rectangle {
    id: myRect
    anchors.fill: parent
    radius: 30
    color: Colors.md3.primary_fixed_dim
    
    
Item {
    id: modulesChanger
    anchors.centerIn: parent
    clip: true
    implicitWidth: currentItem ? currentItem.implicitWidth + leftPadding + rightPadding : 0
    implicitHeight: root.height - 20

    property int currentIndex: 0
    property int count: 2
    readonly property var pages: [central, media]
    readonly property var currentItem: pages[currentIndex]

    property int leftPadding: 20
    property int rightPadding: 20

    Behavior on implicitWidth {
        NumberAnimation {

            duration: 300 
            easing.type: Easing.OutQuart
        }
    }


    CentralModules {
        id: central
        anchors.verticalCenter: parent.verticalCenter
        x: modulesChanger.leftPadding + (0 - modulesChanger.currentIndex) * modulesChanger.width
        visible: modulesChanger.currentIndex === 0
        PopUpCenterMain{id: windawn}
        Behavior on x {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack }
        }
    }
    MediaPlayer {
        id: media
        anchors.verticalCenter: parent.verticalCenter
        x: modulesChanger.leftPadding + (1 - modulesChanger.currentIndex) * modulesChanger.width
        visible: modulesChanger.currentIndex === 1

        Behavior on x {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack }
        }
    }
}
}

}