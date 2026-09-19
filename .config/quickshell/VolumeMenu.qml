import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

PopupWindow {
    id: menu

    property var anchorItem: null
    property var bar: null

    visible: false
    color: "transparent"

    anchor.window: bar
    anchor.rect.x: anchorItem ? anchorItem.mapToItem(bar.contentItem, 0, anchorItem.height + 6).x : 0
    anchor.rect.y: anchorItem ? anchorItem.mapToItem(bar.contentItem, 0, anchorItem.height + 6).y : 0

    implicitWidth: 260
    implicitHeight: content.implicitHeight + 20

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource
    // NOTE: verify isSink/isSource/isStream against your Quickshell version's Pipewire docs.
    // If input/output lists come up empty, console.log Pipewire.nodes.values to see the
    // actual property names available on PwNode in your install.
    readonly property var outputNodes: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    readonly property var inputNodes: Pipewire.nodes.values.filter(n => !n.isSink && n.audio)
    readonly property var appStreams: Pipewire.nodes.values.filter(n => n.isStream)

    PwObjectTracker {
        objects: menu.outputNodes
            .concat(menu.inputNodes)
            .concat(menu.appStreams)
            .concat(menu.sink ? [menu.sink] : [])
            .concat(menu.source ? [menu.source] : [])
    }

    HyprlandFocusGrab {
        id: grab
        windows: [menu]
        active: menu.visible
        onCleared: menu.visible = false
    }

    // Reusable volume slider component: drag or scroll to change `target.audio.volume`
    component VolumeSlider: Rectangle {
        id: track
        property var target: null
        Layout.fillWidth: true
        Layout.preferredHeight: 8
        radius: 0
        
        color: Colors.md3.on_secondary_fixed_variant

        Rectangle {
            width: track.width * (track.target && track.target.audio ? track.target.audio.volume : 0)
            height: parent.height
            radius: 0
            border{width: 1}
            color: Colors.md3.on_primary_container
        }

        MouseArea {
            anchors.fill: parent
            function setVol(x) {
                if (!track.target || !track.target.audio) return;
                track.target.audio.volume = Math.max(0, Math.min(1, x / track.width));
            }
            onPressed: (mouse) => setVol(mouse.x)
            onPositionChanged: (mouse) => { if (pressed) setVol(mouse.x) }
            onWheel: (wheel) => {
                if (!track.target || !track.target.audio) return;
                const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                track.target.audio.volume = Math.max(0, Math.min(1, track.target.audio.volume + step));
                wheel.accepted = true;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 15
        color: Colors.md3.primary
        border.width: 2
        border.color: Colors.md3.on_primary

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            // ---- Master output volume ----

            Text { Layout.alignment: Qt.AlignHCenter;text: "Output Device"; color: Colors.md3.on_primary_container; font.pixelSize: 11; font.bold: true }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: menu.sink && menu.sink.audio.muted ? "󰸈" : "󱄠"
                    color: Colors.md3.on_primary_container
                    font.pixelSize: 20
                    style: Text.Outline
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: if (menu.sink) menu.sink.audio.muted = !menu.sink.audio.muted
                    }
                }

                VolumeSlider { target: menu.sink }

                Text {
                    text: menu.sink ? Math.round(menu.sink.audio.volume * 100) + "%" : "-"
                    color: Colors.md3.on_primary_container
                    font.pixelSize: 11
                    Layout.preferredWidth: 34
                }
            }

            Repeater {
                model: menu.outputNodes
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: modelData === menu.sink ? Colors.md3.on_primary_container : "transparent"
                        border.width: 1
                        border.color: Colors.md3.on_primary_container
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.description || modelData.nickname || modelData.name
                        color: Colors.md3.on_primary_container
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Pipewire.defaultAudioSink = modelData
                    }
                }
            }

            // ---- Master input (mic) volume ----
            Rectangle { Layout.fillWidth: true; height: 5; color: Colors.md3.on_secondary_fixed_variant }
            Text {Layout.alignment: Qt.AlignHCenter; text: "Input Device"; color: Colors.md3.on_primary_container; font.pixelSize: 11; font.bold: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: menu.source && menu.source.audio.muted ? "󰍮" : "󰍬"
                    font.pixelSize: 20
                    color: Colors.md3.on_primary_container
                    style: Text.Outline
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: if (menu.source) menu.source.audio.muted = !menu.source.audio.muted
                    }
                }

                VolumeSlider { target: menu.source }

                Text {
                    text: menu.source ? Math.round(menu.source.audio.volume * 100) + "%" : "-"
                    color: Colors.md3.on_primary_container
                    font.pixelSize: 11
                    Layout.preferredWidth: 34
                }
            }

            Repeater {
                model: menu.inputNodes
                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: modelData === menu.source ? Colors.md3.on_primary_container : "transparent"
                        border.width: 1
                        border.color: Colors.md3.on_primary_container
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.description || modelData.nickname || modelData.name
                        color: Colors.md3.on_primary_container
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Pipewire.defaultAudioSource = modelData
                    }
                }
            }

            // ---- Per-application volume ----
            Rectangle {
                Layout.fillWidth: true; height: 1
                color: Colors.md3.on_secondary_fixed_variant
                visible: menu.appStreams.length > 0
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: menu.appStreams.length > 0
                text: "Applications"
                color: Colors.md3.on_primary_container
                font.pixelSize: 11
                font.bold: true
            }

            Repeater {
                model: menu.appStreams
                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: modelData.properties["application.name"] +" | "+ modelData.properties["media.name"] 
                        color: Colors.md3.on_primary_container
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    VolumeSlider {
                        target: modelData
                        Layout.preferredHeight: 6
                    }
                }
            }
        }
    }
}
