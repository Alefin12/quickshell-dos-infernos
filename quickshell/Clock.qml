import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects

Item{
    id:root
Layout.preferredWidth: myRectangle.width
Layout.preferredHeight: myRectangle.height
RectangularShadow {
    anchors.fill: myRectangle
    offset.x: 0
    offset.y: 2
    radius: myRectangle.radius
    blur: 3
    spread: 2
    color: Qt.darker(myRectangle.color, 1.6)
}
Rectangle {
    id: myRectangle
    implicitWidth: 60
    implicitHeight: 20
    color: Colors.md3.on_primary_container
    border.color: Colors.md3.primary_fixed_dim
    border.width: 1
    radius: 6

    RowLayout {
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignCenter
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Colors.md3.primary_fixed_dim
                font {
            pixelSize: 12
        }

            SystemClock {
                id: clock

                precision: SystemClock.Minutes
            }

        }

    }

}
}