import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import "../../../../shared"

AddButton {
    id: btnAdd
    width: 36
    height: 36

    onClicked: {
        let x = btnAdd.icon.x + btnAdd.icon.width / 2 - newChatMenu.width / 2
        newChatMenu.popup(x, btnAdd.icon.height + 10)
    }
    
    PopupMenu {
        id: newChatMenu
        QQC2.Action {
            text: qsTr("Start new chat")
            icon.source: "../../../img/new_chat.svg"
            onTriggered: privateChatPopup.open()
        }
        QQC2.Action {
            text: qsTr("Start group chat")
            icon.source: "../../../img/group_chat.svg"
            onTriggered: {
                console.log("TODO: Start group chat")
            }
        }
        QQC2.Action {
            text: qsTr("Join public chat")
            icon.source: "../../../img/public_chat.svg"
            onTriggered: publicChatPopup.open()
        }
        onAboutToHide: {
            btnAdd.icon.state = "default"
        }
    }
}