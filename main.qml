import QtQuick 2.9
import QtQuick.Window 2.2
import SQ 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Redirect Test")

    Loader2 {
        anchors.fill: parent
        source: "RedirectTest.qml"
        onlineSource: "https://www.arcgis.com/sharing/rest/content/items/e10c6d9e3d8a40b9879416e3e242df04/data"
    }

}
