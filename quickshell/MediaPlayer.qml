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

        Item {
            id: r
            Repeater {
                id: rep

                model: Mpris.players
                visible: {
                    for (var i = 0; i < count; i++) {
                        if (itemAt(i).isPlaying && track.text === ""){
                            return true;}
                        else{return false;}

                    }
                }

                Rectangle {
                    id: textBox

                    implicitWidth: track.contentWidth
                    implicitHeight: 20

                    Text {
                        id: track

                        anchors.centerIn: parent
                        text: modelData.playbackState === MprisPlaybackState.Playing ? modelData.trackTitle || modelData.identity: ""
                    }

                }

            }

        }

    }

}
