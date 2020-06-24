import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import "../../../../shared"
import "../../../../imports"

AddButton {
    id: btnAdd
    onClicked: {
        let x = btnAdd.icon.x + btnAdd.icon.width / 2 - newAccountMenu.width / 2
        newAccountMenu.popup(x, btnAdd.icon.height + 10)
    }

    GenerateAccountModal {
        id: generateAccountModal
    }
    AddAccountWithSeed {
        id: addAccountWithSeedModal
    }
    AddAccountWithPrivateKey {
        id: addAccountWithPrivateKeydModal
    }
    AddWatchOnlyAccount {
        id: addWatchOnlyAccountModal
    }

    PopupMenu {
        id: newAccountMenu
        width: 280
        QQC2.Action {
            text: qsTr("Generate an account")
            icon.source: "../../../img/generate_account.svg"
            onTriggered: {
                generateAccountModal.open()
            }
        }
        QQC2.Action {
            text: qsTr("Add a watch-only address")
            icon.source: "../../../img/add_watch_only.svg"
            onTriggered: {
                addWatchOnlyAccountModal.open()
            }
        }
        QQC2.Action {
            text: qsTr("Enter a seed phrase")
            icon.source: "../../../img/enter_seed_phrase.svg"
            onTriggered: {
                addAccountWithSeedModal.open()
            }
        }
        QQC2.Action {
            text: qsTr("Enter a private key")
            icon.source: "../../../img/enter_private_key.svg"
            onTriggered: {
                addAccountWithPrivateKeydModal.open()
            }
        }
        onAboutToHide: {
            btnAdd.icon.state = "default"
        }
    }
}

/*##^##
Designer {
    D{i:0;height:36;width:36}
}
##^##*/
