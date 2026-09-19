// SystemTray.qml
// A complete, drop-in system tray (StatusNotifierItem) widget for Quickshell.
// Features:
//   - Renders every item published on the SNI/tray protocol via IconImage
//   - Left click  -> activate()          (or opens the menu if the item is menu-only)
//   - Middle click-> secondaryActivate()
//   - Right click -> opens the item's context menu (if it has one)
//   - Scroll      -> forwarded to the tray item (volume mixers, etc.)
//   - Hover tooltip showing tooltipTitle / tooltipDescription (falls back to title)
//   - NeedsAttention items get a small pulsing indicator dot
//   - Optional passive-item hiding
//   - Themed context menu (QsMenuOpener-based, matches bar's Colors.md3 palette),
//     with single-level submenu flyout support

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: root

    Layout.preferredWidth: row2.implicitWidth 
    Layout.preferredHeight: row2.implicitHeight
    visible: trayRepeater.count > 0
    property var bar: null
    property bool isMenuOpen: false
    property int iconSize: 15
    property int itemSpacing: 8
    property int itemPadding: 5
    property bool hidePassiveItems: false
    property color hoverColor: Qt.rgba(1, 1, 1, 0.12)
    property color attentionColor: "#f38ba8"
    property color tooltipBackground: "#1e1e2e"
    property color tooltipTextColor: "#cdd6f4"
    property color tooltipBorderColor: "#313244"
    // Menu-specific theming - defaults reuse the tooltip palette so you
    // only need to override these if you want the menu to diverge.
    property color menuBackground: tooltipBackground
    property color menuTextColor: tooltipTextColor
    property color menuBorderColor: tooltipBorderColor
    property color menuHoverColor: Colors.md3.primary
    property int menuItemHeight: 28
    property int menuWidth: 200
    readonly property bool anyMenuOpen: openMenuCount > 0
    property int openMenuCount: 0


RectangularShadow {
    anchors.fill: row2
    offset.x: 0
    offset.y: 2
    radius: row2.radius
    blur: 3
    spread: 2
    color: Qt.darker(row2.color, 1.6)
}
    Rectangle{
        id: row2
        implicitHeight: 20
        implicitWidth: row.width + 25
        radius: 6
        color: Colors.md3.on_primary

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: root.itemSpacing
        layoutDirection: Qt.LeftToRight
        Repeater {
            // ---- Themed context menu -------------------------------
            id: trayRepeater
            model: SystemTray.items
            delegate: Item {
                id: trayEntry

                required property SystemTrayItem modelData

                visible: !(root.hidePassiveItems && modelData.status === Status.Passive)
                Layout.preferredWidth: visible ? root.iconSize + root.itemPadding * 0.8 : 0
                Layout.preferredHeight: root.iconSize + root.itemPadding * 1

                Rectangle {
                    anchors.fill: parent
                    radius: 3
                    color: "transparent"

                    border {
                        width: 0
                        color: mouseArea.containsMouse ? Colors.md3.primary : root.hoverColor
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                IconImage {
                    id: icon

                    anchors.centerIn: parent
                    implicitSize: root.iconSize
                    asynchronous: false
                    source: trayEntry.modelData.icon
                }

                MultiEffect {
                    anchors.fill: icon
                    source: icon.backer
                    colorization: 1
                    colorizationColor: !mouseArea.containsMouse ? Colors.md3.primary : Colors.md3.on_secondary_fixed_variant
                }

                Rectangle {
                    visible: trayEntry.modelData.status === Status.NeedsAttention
                    width: 6
                    height: 6
                    radius: 0
                    color: root.attentionColor
                    anchors.right: icon.right
                    anchors.bottom: icon.bottom
                    anchors.rightMargin: -1
                    anchors.bottomMargin: -1

                    SequentialAnimation on opacity {
                        running: trayEntry.modelData.status === Status.NeedsAttention
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1
                            to: 0.3
                            duration: 600
                        }

                        NumberAnimation {
                            from: 0.3
                            to: 1
                            duration: 600
                        }

                    }

                }

                QsMenuOpener {
                    id: menuOpener

                    menu: trayEntry.modelData.menu
                }

                Loader {
                    id: menuLoader

                    active: false
                    sourceComponent: trayMenuComponent
                    onLoaded: item.rootAnchorItem = trayEntry

                    Component {
                        id: trayMenuComponent

                        PopupWindow {
                            // ---- Single-level submenu flyout -------------------

                            id: menuPopup

                            // The tray icon this menu belongs to, used for positioning.
                            property var rootAnchorItem: null
                            property var opener: menuOpener

                            visible: menuLoader.active
                            color: "transparent"
                            anchor.window: root.bar
                            anchor.rect.x: rootAnchorItem ? rootAnchorItem.mapToItem(root.bar.contentItem, 0, 0).x : 0
                            anchor.rect.y: rootAnchorItem ? rootAnchorItem.mapToItem(root.bar.contentItem, 0, rootAnchorItem.height + 6).y : 0
                            implicitWidth: root.menuWidth
                            implicitHeight: menuColumn.implicitHeight + 8

                            HyprlandFocusGrab {
                                id: focusGrab

                                windows: [menuPopup]
                                active: menuPopup.visible
                                onCleared: {
                                    menuLoader.active = false;
                                    root.isMenuOpen = false;
                                    island.state = "";
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 15
                                color: Colors.md3.primary
                                border.width: 2
                                border.color: Colors.md3.on_primary

                                ColumnLayout {
                                    id: menuColumn

                                    anchors.fill: parent
                                    anchors.leftMargin: 3
                                    anchors.rightMargin: 3
                                    anchors.topMargin: 3
                                    anchors.bottomMargin: 3 
                                    spacing: 0

                                    Repeater {
                                        model: menuPopup.opener.children

                                        delegate: Item {
                                            id: entryDelegate

                                            required property QsMenuEntry modelData

                                            Layout.fillWidth: true
                                            implicitHeight: modelData.isSeparator ? 9 : root.menuItemHeight

                                            Rectangle {
                                                visible: entryDelegate.modelData.isSeparator
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                height: 2
                                                color: Colors.md3.on_secondary_fixed_variant
                                            }

                                            Rectangle {
                                                id: entryBg
                                                visible: !entryDelegate.modelData.isSeparator
                                                anchors.fill: parent
                                                radius: 10
                                                color: entryMouseArea.containsMouse ? Colors.md3.primary_fixed_dim : Colors.md3.on_secondary_fixed_variant

                                                border {
                                                    width: 2
                                                    color: entryMouseArea.containsMouse ? Colors.md3.on_secondary_fixed_variant : Colors.md3.primary_fixed_dim
                                                }

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 8
                                                    anchors.rightMargin: 8
                                                    spacing: 0

                                                    // Checkable / radio indicator
                                                    Text {
                                                        visible: entryDelegate.modelData.checkable
                                                        text: entryDelegate.modelData.checked ? "✓" : ""
                                                        color: entryMouseArea.containsMouse ? Colors.md3.on_secondary_fixed_variant : Colors.md3.primary_fixed_dim
                                                        font.pixelSize: 12
                                                        Layout.preferredWidth: 12
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: entryDelegate.modelData.text
                                                        color: entryMouseArea.containsMouse ? Colors.md3.on_secondary_fixed_variant : Colors.md3.primary_fixed_dim
                                                        font.pixelSize: 12
                                                        opacity: entryDelegate.modelData.enabled ? 1 : root.menuDisabledOpacity
                                                        elide: Text.ElideRight
                                                    }

                                                    // Submenu caret
                                                    Text {
                                                        visible: entryDelegate.modelData.hasChildren
                                                        text: "\u203A"
                                                        color: entryMouseArea.containsMouse ? Colors.md3.on_secondary_fixed_variant : Colors.md3.primary_fixed_dim
                                                        font.pixelSize: 12
                                                    }

                                                }

                                                MouseArea {
                                                    id: entryMouseArea

                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    enabled: entryDelegate.modelData.enabled
                                                    onEntered: {
                                                        if (entryDelegate.modelData.hasChildren) {
                                                            submenuLoader.parentEntry = entryDelegate;
                                                            submenuLoader.menu = entryDelegate.modelData;
                                                            submenuLoader.active = true;
                                                        } else {
                                                            submenuLoader.active = false;
                                                        }
                                                    }
                                                    onClicked: {
                                                        if (!entryDelegate.modelData.hasChildren) {
                                                            entryDelegate.modelData.triggered();
                                                            menuLoader.active = false;
                                                            root.isMenuOpen = false;
                                                        }

                                                    }
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                            QsMenuOpener {
                                id: submenuOpener

                                menu: submenuLoader.menu
                            }

                            Loader {
                                id: submenuLoader

                                property var parentEntry: null
                                property var menu: null

                                active: false

                                sourceComponent: PopupWindow {
                                    id: submenuPopup

                                    function entryDelegateWidth() {
                                        return submenuLoader.parentEntry ? submenuLoader.parentEntry.width : 0;
                                    }

                                    visible: true
                                    color: "transparent"
                                    anchor.window: root.bar
                                    anchor.rect.x: submenuLoader.parentEntry ? submenuLoader.parentEntry.mapToItem(root.bar.contentItem, entryDelegateWidth(), 0).x : 0
                                    anchor.rect.y: submenuLoader.parentEntry ? submenuLoader.parentEntry.mapToItem(root.bar.contentItem, 0, 0).y : 0
                                    implicitWidth: root.menuWidth
                                    implicitHeight: submenuColumn.implicitHeight + 8

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: Colors.md3.on_secondary_fixed_variant
                                        border.width: 1
                                        border.color: root.menuBorderColor

                                        ColumnLayout {
                                            id: submenuColumn

                                            anchors.fill: parent
                                            anchors.margins: 4
                                            spacing: 1

                                            Repeater {
                                                model: submenuOpener.children

                                                delegate: Item {
                                                    id: subEntryDelegate

                                                    required property QsMenuEntry modelData

                                                    Layout.fillWidth: true
                                                    implicitHeight: modelData.isSeparator ? 9 : root.menuItemHeight

                                                    Rectangle {
                                                        visible: subEntryDelegate.modelData.isSeparator
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: parent.left
                                                        anchors.right: parent.right
                                                        anchors.leftMargin: 4
                                                        anchors.rightMargin: 4
                                                        height: 1
                                                        color: root.menuBorderColor
                                                    }

                                                    Rectangle {
                                                        visible: !subEntryDelegate.modelData.isSeparator
                                                        anchors.fill: parent
                                                        radius: 0
                                                        color: subEntryMouseArea.containsMouse ? root.menuHoverColor : "transparent"

                                                        Text {
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 8
                                                            anchors.verticalCenter: parent.verticalCenter
                                                            text: subEntryDelegate.modelData.text
                                                            color: Colors.md3.primary_fixed_dim
                                                            font.pixelSize: 12
                                                            opacity: subEntryDelegate.modelData.enabled ? 1 : root.menuDisabledOpacity
                                                        }

                                                        MouseArea {
                                                            id: subEntryMouseArea

                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            enabled: subEntryDelegate.modelData.enabled
                                                            onClicked: {
                                                                subEntryDelegate.modelData.triggered();
                                                                menuLoader.active = false;
                                                            }
                                                        }

                                                    }

                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

                MouseArea {
                    id: mouseArea

                    property var item: trayEntry.modelData

                    function openMenu(item) {
                        tooltipLoader.active = false;
                        root.isMenuOpen = true;
                        menuLoader.active = true;
                    }

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            if (item.onlyMenu)
                                openMenu(item);
                            else
                                item.activate();
                        } else if (mouse.button === Qt.MiddleButton) {
                            item.secondaryActivate();
                        } else if (mouse.button === Qt.RightButton) {
                            if (item.hasMenu)
                                openMenu(item);

                        }
                    }
                    onExited: {
                        tooltipLoader.active = false;
                    }
                    onWheel: (wheel) => {
                        trayEntry.modelData.scroll(wheel.angleDelta.y, false);
                        wheel.accepted = true;
                    }
                    onEntered: tooltipLoader.active = true
                }

                // Lazily-loaded tooltip popup, anchored below the icon.
                Loader {
                    id: tooltipLoader

                    active: false

                    sourceComponent: PopupWindow {
                        id: tooltipWindow

                        readonly property string ttTitle: {
                            const t = trayEntry.modelData.tooltipTitle;
                            return t && t.length > 0 ? t : trayEntry.modelData.title;
                        }
                        readonly property string ttDesc: trayEntry.modelData.tooltipDescription

                        visible: root.bar !== null
                        color: "transparent"
                        anchor.window: root.bar
                        anchor.rect.x: root.bar ? trayEntry.mapToItem(root.bar.contentItem, 0, trayEntry.height + 4).x : 0
                        anchor.rect.y: root.bar ? trayEntry.mapToItem(root.bar.contentItem, 0, trayEntry.height + 4).y : 0
                        implicitWidth: tooltipContent.implicitWidth + 20
                        implicitHeight: tooltipContent.implicitHeight + 14

                        Rectangle {
                            anchors.fill: parent
                            radius: 30
                            color: Colors.md3.on_secondary_fixed_variant
                            border.width: 0
                            border.color: Colors.md3.primary_fixed_dim

                            ColumnLayout {
                                id: tooltipContent

                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    text: tooltipWindow.ttTitle
                                    color: Colors.md3.primary_fixed_dim
                                    font.pixelSize: 12
                                    font.bold: false
                                    visible: text.length > 0
                                }

                                Text {
                                    text: tooltipWindow.ttDesc
                                    color: Colors.md3.primary_fixed_dim
                                    font.pixelSize: 11
                                    opacity: 0.8
                                    visible: text.length > 0
                                    wrapMode: Text.WordWrap
                                    Layout.maximumWidth: 260
                                }

                            }

                        }

                    }

                }

            }

        }

    }
}

}
