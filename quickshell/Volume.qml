import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick.Effects

Item{
    id: root
    Layout.preferredWidth: volumeControl.width
    Layout.preferredHeight: volumeControl.height
    visible: island.expanded || volumeControl.volumeChanged_
RectangularShadow {
    anchors.fill: volumeControl
    offset.x: 0
    offset.y: 2
    radius: volumeControl.radius
    blur: 3
    spread: 2
    color: Qt.darker(volumeControl.color, 1.6)
}
Rectangle{
        id: volumeControl
        implicitWidth: childrenRect.width
        implicitHeight: 20
    color: Colors.md3.on_primary_container
    border.color: Colors.md3.primary_fixed_dim
    border.width: 1
        radius: 6
        property var sink: Pipewire.defaultAudioSink
        readonly property bool ready: sink && sink.ready
        readonly property bool muted: ready && sink.audio.muted
        readonly property int vol: ready ? Math.round(sink.audio.volume * 100) : 0

        property bool volumeChanged_: false
        

        Timer {
            id: occult
            interval: 1000
            onTriggered: volumeControl.volumeChanged_ = false
        }

        onVolChanged: {
            volumeChanged_ = true
            occult.restart()
        }

    RowLayout {
        anchors.centerIn: parent

        Text {
            Layout.leftMargin: 10

            text: {
                if (!volumeControl.ready)
                    return "-";

                if (volumeControl.muted)
                    return "Muted";

                return volumeControl.vol + "%";
            }
            font {
                pixelSize: 12
            }
            color: Colors.md3.primary_fixed_dim
        }



        Rectangle {
            Layout.preferredHeight: 2
            Layout.preferredWidth: volumeControl.vol / 1
            color: Colors.md3.primary_fixed_dim
            Layout.rightMargin: 10
            Behavior on Layout.preferredWidth {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCurve
                }

            }

        }

        PwObjectTracker {
            objects: [volumeControl.sink]
        }

    }
}
}