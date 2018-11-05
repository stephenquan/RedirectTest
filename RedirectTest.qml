import QtQuick 2.9
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import SQ 1.0

Item {
    property NetworkAccessManager manager: NetworkAccessManager
    property string redirectionTarget: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Text {
            text: qsTr("Url:")
        }

        TextField {
            id: urlTextField

            Layout.fillWidth: true

            text: "https://www.arcgis.com/sharing/rest/content/items/37e9d4a26cd64544939f56ae23a27847/data"
            wrapMode: TextField.WrapAtWordBoundaryOrAnywhere
        }

        Flow {
            Layout.fillWidth: true
            spacing: 10

            Button {
                text: qsTr("Get")

                onClicked: {
                    textArea.log("NetworkAccessManager.get(%1)".arg(urlTextField.text));
                    manager.get(urlTextField.text)
                }
            }

            Button {
                text: qsTr("Redirect")
                enabled: redirectionTarget !== ""

                onClicked: {
                    textArea.log("NetworkAccessManager.get(%1)".arg(redirectionTarget));
                    manager.get(redirectionTarget);
                }
            }

            Button {
                text: qsTr("ClearAccessCache")

                onClicked: {
                    textArea.log("NetworkAccessManager.clearAccessCache");
                    manager.clearAccessCache();
                }
            }

            Button {
                text: qsTr("Clear")

                onClicked: textArea.text = ""
            }

        }

        Flickable {
            id: flickable

            Layout.fillWidth: true
            Layout.fillHeight: true

            contentWidth: textArea.width
            contentHeight: textArea.height
            clip: true

            TextArea {
                id: textArea

                readOnly: true

                function log(txt) {
                    console.log(txt);
                    text = text + txt + "\n";
                }
            }
        }
    }

    Connections {
        target: manager

        onFinished: {
            redirectionTarget = "";
            textArea.log("onFinished %1".arg(reply.url));
            textArea.log("error: %1".arg(reply.error));
            if (reply.error !== 0) {
                textArea.log("errorString: %1".arg(reply.errorString));
                return;
            }
            var httpStatusCode = reply.attribute(NetworkReply.NetworkReplyAttributeHttpStatusCode);
            textArea.log("HttpStatusCode: %1".arg(httpStatusCode));
            redirectionTarget = reply.attribute(NetworkReply.NetworkReplyAttributeRedirectionTarget) || "";
            textArea.log("RedirectionTarget: %1".arg(JSON.stringify(redirectionTarget)));
            textArea.log("ResponseText:");
            textArea.log(reply.readAll());
        }

        onSslErrors: {
            textArea.log("onSslErrors %1".arg(reply.url));
            textArea.log(JSON.stringify(errors, undefined, 2));
        }
    }

    Component.onCompleted: {
        textArea.log("supportedSchemes: %1".arg(NetworkAccessManager.supportedSchemes));
        textArea.log("supportsSsl: %1".arg(SslSocket.supportsSsl));
        textArea.log("sslLibraryBuildVersionNumber: %1".arg(SslSocket.sslLibraryBuildVersionNumber));
        textArea.log("sslLibraryBuildVersionString: %1".arg(SslSocket.sslLibraryBuildVersionString));
        textArea.log("sslLibraryVersionNumber: %1".arg(SslSocket.sslLibraryVersionNumber));
        textArea.log("sslLibraryVersionString: %1".arg(SslSocket.sslLibraryVersionString));
    }

}
