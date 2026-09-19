import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Loader {
    active: true

    sourceComponent: Item {
        id: root

        implicitWidth: r.childrenRect.width
        implicitHeight: 20
            MouseArea {

                id: mouseScroll
                property int animationCount: 0
                width: root.width
                height: root.height
                anchors.centerIn: parent
                hoverEnabled: true
                    onWheel: (wheel) => {
                if (wheelCooldown.running) {
                    wheel.accepted = true;
                    return ;
                }

                // support both vertical wheel and horizontal touchpad scroll
                const delta = Math.abs(wheel.angleDelta.y) > Math.abs(wheel.angleDelta.x)
                                ? wheel.angleDelta.y
                                : wheel.angleDelta.x;

                if (delta < 0 && mediaName.currentIndex < rep.count - 1)
                    mediaName.currentIndex += 1;
                else if (delta > 0 && mediaName.currentIndex > 0)
                    mediaName.currentIndex -= 1;
                
                wheelCooldown.restart();
                wheel.accepted = true;
            }
        }
        Item {
            id: r
            anchors.verticalCenter: parent.verticalCenter

        ColumnLayout{
            id: mediaName
            spacing: 10
            y: currentIndex * -30
            property int currentIndex: 0
            Behavior on y{
                NumberAnimation{
                    duration: 300
                }
            }
            Repeater {
                id: rep

                model: Mpris.players

                        Rectangle{
                            Layout.preferredWidth: label.paintedWidth
                            Layout.preferredHeight: 20
                            color:"transparent"
                            Text{
                                id: label
                                text: modelData.identity + ": " +modelData.trackTitle
                            }
                        }

                }


            }

        }

    }

}
