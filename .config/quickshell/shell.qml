import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens

PanelWindow {
    id: root
    mask: Region { item:{ root, island} }
    required property var modelData
    screen: modelData
    width: 500
    implicitHeight: 100          // was 60 — extra ~40px gives the blur room
    color: "transparent"
    exclusiveZone: 50            // keep this at the ORIGINAL bar height so
                                  // other windows/bars still reserve space
                                  // as if nothing changed
    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 0
    }

    CenterIsland {
        id: island
    }
}

    }

}
