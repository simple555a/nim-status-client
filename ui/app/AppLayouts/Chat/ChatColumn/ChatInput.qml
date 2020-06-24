import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../components"
import "../../../../shared"
import "../../../../imports"

Rectangle {
    border.width: 0

    RowLayout {
        spacing: 0
        anchors.fill: parent

        TextField {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width - sendBtns.width

            id: txtData
            text: ""
            leftPadding: 12
            rightPadding: Theme.padding
            font.pixelSize: 14
            placeholderText: qsTr("Type a message...")
            Keys.onEnterPressed: {
                chatsModel.sendMessage(txtData.text)
                txtData.text = ""
            }
            Keys.onReturnPressed: {
                chatsModel.sendMessage(txtData.text)
                txtData.text = ""
            }
            background: Rectangle {
                color: "#00000000"
            }
        }

        ChatButtons {
            id: sendBtns
            Layout.topMargin: 1
            Layout.fillHeight: true
            Layout.preferredWidth: 30 + Theme.padding
            Layout.minimumWidth: 30 + Theme.padding
            Layout.maximumWidth: 200
        }
    }

    MouseArea {
        id: mouseArea1
        anchors.rightMargin: 50
        anchors.fill: parent
        onClicked: {
            txtData.forceActiveFocus(Qt.MouseFocusReason)
        }
    }
}
/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:100;width:600}
}
##^##*/
