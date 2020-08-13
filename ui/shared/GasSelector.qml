import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../imports"
import "./"

Item {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    height: gasSlider.height + Style.current.smallPadding * 3 + txtNetworkFee.height + buttonAdvanced.height
    property double slowestGasPrice: 0
    property double fastestGasPrice: 100
    property string gasLimit: ""
    property double stepSize: ((root.fastestGasPrice - root.slowestGasPrice) / 10).toFixed(1)
    property alias value: gasSlider.value
    property var getGasEthValue: function () {}
    property string defaultCurrency: "USD"
    property string selectedGasPrice: ""
    property string selectedGasLimit: ""

    function resetGasSlider() {
        return ((50 * (root.fastestGasPrice - root.slowestGasPrice) / 100) + root.slowestGasPrice)
    }

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
        anchors.right: labelEth.left
        text: "0.0"
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }

    StyledText {
        id: labelEth
        anchors.top: parent.top
        anchors.right: parent.right
        text: " ETH"
        font.weight: Font.Medium
        font.pixelSize: 13
        color: Style.current.secondaryText
    }


    Item {
        id: sliderWrapper
        anchors.topMargin: Style.current.smallPadding
        anchors.top: labelGasPriceSummary.bottom
        height: sliderWrapper.visible ? gasSlider.height + labelSlow.height + Style.current.padding : 0
        width: parent.width
        visible: root.selectedGasPrice == "" && root.selectedGasLimit == ""

        StatusSlider {
            id: gasSlider
            from: root.slowestGasPrice
            to: root.fastestGasPrice
            stepSize: root.stepSize
            value: root.resetGasSlider()
            onValueChanged: {
                if (!isNaN(gasSlider.value)) {
                    console.log("A")
                    labelGasPriceSummary.text = root.getGasEthValue(gasSlider.value, root.gasLimit)
                    console.log(labelGasPriceSummary.text)
                }
            }
            visible: root.selectedGasPrice == "" && root.selectedGasLimit == ""
        }

        StyledText {
            id: labelSlow
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.left: parent.left
            text: qsTr("Slow")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: root.selectedGasPrice == "" && root.selectedGasLimit == ""
        }

        StyledText {
            id: labelOptimal
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: gasSlider.horizontalCenter
            text: qsTr("Optimal")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: root.selectedGasPrice == "" && root.selectedGasLimit == ""
        }

        StyledText {
            id: labelFast
            anchors.top: gasSlider.bottom
            anchors.topMargin: Style.current.padding
            anchors.right: parent.right
            text: qsTr("Fast")
            font.pixelSize: 15
            color: Style.current.textColor
            visible: root.selectedGasPrice == "" && root.selectedGasLimit == ""
        }
    }

    StyledButton {
        id: buttonReset
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWraper.visible ? Style.current.smallPadding : 0
        anchors.right: buttonAdvanced.left
        anchors.rightMargin: -Style.current.padding
        label: qsTr("Reset")
        btnColor: "transparent"
        labelFontSize: 13
        visible: root.selectedGasPrice != "" && root.selctedGasLimit != ""
        onClicked: {
            gasSlider.value = root.resetGasSlider()
            root.selectedGasPrice = ""
            root.selectedGasLimit = ""
        }
    }

    StyledButton {
        id: buttonAdvanced
        anchors.top: sliderWrapper.bottom
        anchors.topMargin: sliderWraper.visible ? Style.current.smallPadding : 0
        anchors.right: parent.right
        anchors.rightMargin: -Style.current.padding
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
        height: 286

        Input {
          id: inputGasLimit
          label: qsTr("Gas limit")
          width: 222
          anchors.top: parent.top
          text: root.gasLimit
        }

        Input {
          id: inputGasPrice
          label: qsTr("Gas price")
          width: 130
          anchors.top: inputGasLimit.bottom
          anchors.topMargin: Style.current.smallPadding
          anchors.left: parent.left
          text: gasSlider.value
        }

        footer: StyledButton {
            id: applyButton
            anchors.right: parent.right
            anchors.rightMargin: Style.current.smallPadding
            label: qsTr("Apply")
            anchors.bottom: parent.bottom
            onClicked: {
              gasSlider.value = parseFloat(inputGasPrice.text)
              root.selectedGasLimit = inputGasLimit.text
              root.selectedGasPrice = inputGasPrice.text
              customNetworkFeeDialog.close()
            }
        }
    }
}
