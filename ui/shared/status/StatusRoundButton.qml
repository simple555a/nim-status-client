import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import QtQml 2.14
import "../../imports"
import "../../shared"

RoundButton {
    property string type: "primary"
    property string state: "default"
    property string size: "large"

    id: control

    font.pixelSize: 15
    font.weight: Font.Medium

    implicitWidth: size === "medium" ? 40 : 44
    implicitHeight: size === "medium" ? 40 : 44

    enabled: state === "default"

    icon.source: "../../app/img/" + icon.name + ".svg"
    icon.height: size === "medium" ? 14 : 20
    icon.width: size === "medium" ? 14 : 20
    icon.color: type === "secondary" ? 
        !enabled ? 
          Style.current.roundedButtonSecondaryDisabledForegroundColor :
          Style.current.roundedButtonSecondaryForegroundColor
        :
        !enabled ?
          Style.current.roundedButtonDisabledForegroundColor : 
          Style.current.roundedButtonForegroundColor

    background: Rectangle {
        anchors.fill: parent
        color: {
            if (type === "secondary") {
                return !enabled ? Style.current.roundedButtonSecondaryDisabledBackgroundColor :
                  hovered ? Style.current.roundedButtonSecondaryHoveredBackgroundColor : 
                  Style.current.roundedButtonSecondaryBackgroundColor
            }
            return !enabled ?
              Style.current.roundedButtonDisabledBackgroundColor : 
              Style.current.roundedButtonBackgroundColor
        }
        radius: parent.width / 2
    }

    LoadingImage {
        id: loadingIndicator
        visible: false
        height: 18
        width: loadingIndicator.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    ColorOverlay {
        id: colorOverlay
        anchors.fill: loadingIndicator
        visible: control.state === "pending"
        source: loadingIndicator
        color: control.type === "secondary" ?
          Style.current.roundedButtonSecondaryDisabledForegroundColor :
          Style.current.roundedButtonDisabledForegroundColor
        antialiasing: true
        RotationAnimator {
            target: colorOverlay
            from: 0
            to: 360
            duration: 1200
            running: true
            loops: Animation.Infinite
        }
    }

    MouseArea {
        cursorShape: Qt.PointingHandCursor
        anchors.fill: parent
        onPressed: mouse.accepted = false
    }
}