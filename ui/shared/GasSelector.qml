import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: gasSlider.height + Style.current.smallPadding * 3 + txtNetworkFee.height + buttonAdvanced.height
    property double slowestValue: 0
    property double fastestValue: 100
    property double stepSize: ((root.fastestValue - root.slowestValue) / 10).toFixed(1)
    property alias value: gasSlider.value
    property var getGasFiatValue: function () {}
    property string defaultCurrency: "USD"

    StyledText {
        id: txtNetworkFee
        anchors.top: parent.top
        anchors.left: parent.left
        text: qsTr("Network fee")
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.textColor
    }

    StyledText {
        id: labelGasPriceSummary
        anchors.top: parent.top
        anchors.right: parent.right
        text: "0.001159 ETH ~ 0.24 USD"
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StatusSlider {
        id: gasSlider
        anchors.top: labelGasPriceSummary.bottom
        anchors.topMargin: Style.current.smallPadding
        minimumValue: root.slowestValue
        maximumValue: root.fastestValue
        stepSize: root.stepSize
        value: ((50 * (root.fastestValue - root.slowestValue) / 100) + root.slowestValue)
        onValueChanged: {
            if (!isNaN(gasSlider.value)) {
                // labelGasPriceSummary.text = root.getGasFiatValue(gasSlider.value, root.defaultCurrency))
            }
        }
    }

    StyledText {
        id: labelSlow
        anchors.top: gasSlider.bottom
        anchors.topMargin: Style.current.padding
        anchors.left: parent.left
        text: qsTr("Slow")
        font.pixelSize: 15
        color: Style.current.textColor
    }

    StyledText {
        id: labelOptimal
        anchors.top: gasSlider.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: gasSlider.horizontalCenter
        text: qsTr("Optimal")
        font.pixelSize: 15
        color: Style.current.textColor
    }

    StyledText {
        id: labelFast
        anchors.top: gasSlider.bottom
        anchors.topMargin: Style.current.padding
        anchors.right: parent.right
        text: qsTr("Fast")
        font.pixelSize: 15
        color: Style.current.textColor
    }

    StyledButton {
        id: buttonAdvanced
        anchors.top: labelFast.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.right: parent.right
        label: qsTr("Advanced")
        btnColor: "transparent"
        labelFontSize: 13
        onClicked: {
            customNetworkFeeDialog.open()
        }
    }

    ModalPopup {
        id: customNetworkFeeDialog
        title: qsTr("Custom Network Fee")

        footer: StyledButton {
            id: applyButton
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            label: qsTr("Apply")
            anchors.bottom: parent.bottom
            onClicked: {
              customNetworkFeeDialog.close()
            }
        }
    }
}
