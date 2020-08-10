import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../shared"
import "../../../imports"
import "./components"
import "./ChatColumn"
import "./data"

StackLayout {
    id: chatColumnLayout
    property int chatGroupsListViewCount: 0
    
    property bool isReply: false
    property bool isImage: false

    property bool isExtendedInput: isReply || isImage

    property var appSettings
    property bool isConnected: false
    Layout.fillHeight: true
    Layout.fillWidth: true
    Layout.minimumWidth: 300

    currentIndex:  chatsModel.activeChannelIndex > -1 && chatGroupsListViewCount > 0 ? 0 : 1

    function showReplyArea(){
        isReply = true;
        isImage = false;
        replyAreaContainer.setup()
    }

    function showImageArea(imagePath){
        isImage = true;
        isReply = false;
        sendImageArea.image = imagePath[0];
    }

    function hideExtendedArea(){
        isImage = false;
        isReply = false;
        replyAreaContainer.setup();
        sendImageArea.image = "";
    }
    
    ColumnLayout {
        spacing: 0

        RowLayout {
            id: chatTopBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            z: 60
            spacing: 0
            TopBar {
                id: topBar
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            z: 60
            Rectangle {
                Component.onCompleted: {
                    isConnected = chatsModel.isOnline
                    if(!isConnected){
                        connectedStatusRect.visible = true 
                    }
                }

                id: connectedStatusRect
                Layout.fillWidth: true
                height: 40;
                color: isConnected ? Style.current.green : Style.current.darkGrey
                visible: false
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    color: Style.current.white
                    id: connectedStatusLbl
                    text: isConnected ? 
                        qsTr("Connected") :
                        qsTr("Disconnected")
                }
            }

            Timer {
                id: timer
            }

            Connections {
                target: chatsModel
                onOnlineStatusChanged: {
                    if (connected == isConnected) return;
                    isConnected = connected;
                    if(isConnected){
                        timer.setTimeout(function(){ 
                            connectedStatusRect.visible = false;
                        }, 5000);
                    } else {
                        connectedStatusRect.visible = true;
                    }
                }
            }
        }

        RowLayout {
            id: chatContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
            spacing: 0
            ChatMessages {
                id: chatMessages
                messageList: chatsModel.messageList
                appSettings: chatColumnLayout.appSettings
            }
       }


        ProfilePopup {
            id: profilePopup
            onBlockButtonClicked: {
                blockContactConfirmationDialog.contactName = name
                blockContactConfirmationDialog.contactAddress = address
                blockContactConfirmationDialog.open()
            }
        }

        BlockContactConfirmationDialog {
            id: blockContactConfirmationDialog
            onBlockButtonClicked: {
                chatsModel.blockContact(blockContactConfirmationDialog.contactAddress)
                blockContactConfirmationDialog.close()
                profilePopup.close()
            }
        }

        EmojiReactions {
            id: reactionModel
        }

        MessageContextMenu {
            id: messageContextMenu
        }
 
        ListModel {
            id: suggestions
        }

        Connections {
            target: chatsModel
            onActiveChannelChanged: {
                suggestions.clear()
                for (let i = 0; i < chatsModel.suggestionList.rowCount(); i++) {
                  suggestions.append({
                      alias: chatsModel.suggestionList.rowData(i, "alias"),
                      ensName: chatsModel.suggestionList.rowData(i, "ensName"),
                      address: chatsModel.suggestionList.rowData(i, "address"),
                      identicon: chatsModel.suggestionList.rowData(i, "identicon"),
                      ensVerified: chatsModel.suggestionList.rowData(i, "ensVerified")
                  });
                }
            }
        }

        Rectangle {
            id: inputArea
            color: Style.current.background
            border.width: 1
            border.color: Style.current.border
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: !isExtendedInput ? 70 : 140
            Layout.preferredHeight: height

            SuggestionBox {
                id: suggestionsBox
                model: suggestions
                width: chatContainer.width
                anchors.bottom: inputArea.top
                anchors.left: inputArea.left
                filter: chatInput.textInput.text
                cursorPosition: chatInput.textInput.cursorPosition
                property: "ensName, alias"
                onItemSelected: function (item, lastAtPosition, lastCursorPosition) {
                    let currentText = chatsModel.plainText(Emoji.deparse(chatInput.textInput.text))
                    let lastAt = currentText.lastIndexOf("@")
                    let aliasName = item[suggestionsBox.property.split(",").map(p => p.trim()).find(p => !!item[p])]
                    let nameLen = aliasName.length + 2 // We're doing a +2 here because of the `@` and the trailing whitespace
                    let position = 0;
                    let text = ""

                    if (currentText === "@") {
                        position = nameLen
                        text = "@" + aliasName + " "
                    } else {
                        let left = currentText.substring(0, lastAt)
                        let right = currentText.substring(lastAt + 1)
                        text = `${left} @${aliasName} ${right}`
                    }

                    chatInput.textInput.text = Emoji.parse(text, "26x26")
                    chatInput.textInput.cursorPosition = lastCursorPosition + aliasName.length
                    suggestionsBox.suggestionsModel.clear()
                }
            }
            
            ReplyArea {
                id: replyAreaContainer
                visible: isReply
            }

            SendImageArea {
                id: sendImageArea
                visible: isImage
            }

            ChatInput {
                id: chatInput
                height: 40
                anchors.top: {
                    if(!isExtendedInput){
                        return inputArea.top;
                    }

                    if(isReply){
                        return replyAreaContainer.bottom;
                    }

                    if(isImage){
                        return sendImageArea.bottom;
                    }
                }
                anchors.topMargin: 4
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }

    EmptyChat {}
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:800}
}
##^##*/
