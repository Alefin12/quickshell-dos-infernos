import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import QtQuick.Effects

Item {
    id: root
    property int shadowPadding: 10

    Layout.preferredWidth: pill.volumeChanged_ && !island.expanded ? pill.width + shadowPadding * 2 : 0
    Layout.preferredHeight: pill.height + shadowPadding * 2
    clip: true
    visible: Layout.preferredWidth > 10 && modulesChanger.currentIndex === 0

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: 200;}
    }

    RectangularShadow {
        anchors.fill: pill
        offset.x: 0
        offset.y: 2
        radius: pill.radius
        blur: 3
        spread: 2
        color: Qt.darker(pill.color, 1.6)
    }

    Rectangle {
        id: pill
        anchors.centerIn: root
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
            id: hideTimer
            interval: 1000
            onTriggered: pill.volumeChanged_ = false
        }

        onVolChanged: {
            volumeChanged_ = true
            hideTimer.restart()
        }

        RowLayout {
            anchors.centerIn: parent

            Text {
                Layout.leftMargin: 10
                text: {
                    if (!pill.ready)
                        return "-";
                    if (pill.muted)
                        return "Muted";
                    return pill.vol + "%";
                }
                font.pixelSize: 12
                color: Colors.md3.primary_fixed_dim
            }

            Rectangle {
                Layout.preferredHeight: 2
                Layout.preferredWidth: pill.vol / 1
                color: Colors.md3.primary_fixed_dim
                Layout.rightMargin: 10
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 200; easing.type: Easing.OutCurve }
                }
            }

            PwObjectTracker {
                objects: [pill.sink]
            }
        }
    }
}