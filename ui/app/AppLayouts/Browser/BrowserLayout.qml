import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtWebEngine 1.10
import QtWebChannel 1.13

Item {
    id: browserView
    Layout.fillHeight: true
    Layout.fillWidth: true

    // TODO: example qml webbrowser available here:
    // https://doc.qt.io/qt-5/qtwebengine-webengine-quicknanobrowser-example.html

    WebEngineProfile {
        id: webProfile
        offTheRecord: true // Private Mode on
        persistentCookiesPolicy:  WebEngineProfile.NoPersistentCookies
        userScripts: [
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                sourceUrl:  Qt.resolvedUrl("provider.js")
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            },
            WebEngineScript {
                injectionPoint: WebEngineScript.DocumentCreation
                name: "QWebChannel"
                sourceUrl: "qrc:///qtwebchannel/qwebchannel.js"
                worldId: WebEngineScript.MainWorld // TODO: check https://doc.qt.io/qt-5/qml-qtwebengine-webenginescript.html#worldId-prop 
            }
        ]
    }

    QtObject {
        id: provider
        WebChannel.id: "backend"

        signal web3Response(string data);

        function postMessage(data){
            console.log("Calling nim web3provider with: ", data);
            var result = web3Provider.postMessage(data);
            web3Response(result);
        }
    }

    WebChannel {
        id: channel
        registeredObjects: [provider]
    }

    WebEngineView {
        id: browserContainer
        anchors.fill: parent
        profile: webProfile
        url: "https://status-im.github.io/dapp/"
        webChannel: channel
        onNewViewRequested: function(request) {
            // TODO: rramos: tabs can be handled here. see: https://doc.qt.io/qt-5/qml-qtwebengine-webengineview.html#newViewRequested-signal
            // In the meantime, I'm opening the content in the same webengineview
            request.openIn(browserContainer)
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
