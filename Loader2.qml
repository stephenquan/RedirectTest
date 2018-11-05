import QtQuick 2.9
import QtQuick.Window 2.2

Item {
    id: loader2

    property string source: ""
    property string onlineSource: ""
    property var xhr: new XMLHttpRequest()
    property var newObject: null

    onSourceChanged: {
        load(source);
    }

    function onReadyStateChanged(o) {
        console.log("onReadyStateChanged: ", xhr.readyState);
        if (xhr.readyState !== 4) return;
        console.log(xhr.responseText);
        newObject = Qt.createQmlObject(xhr.responseText, container);
        newObject.width = Qt.binding(function() { return container.width; } );
        newObject.height = Qt.binding(function() { return container.height; } );
    }

    function load(source) {
        if (newObject) {
            newObject.destroy();
            newObject= null;
        }

        if (source && (source + "").match(/^https?:/)) {
            xhr.onreadystatechange = onReadyStateChanged;
            xhr.open('GET', source, true);
            xhr.send();
            return;
        }

        var component = Qt.createComponent(source);
        newObject = component.createObject(container);
        newObject.width = Qt.binding(function() { return container.width; } );
        newObject.height = Qt.binding(function() { return container.height; } );
    }

    Item {
        id: container

        anchors.fill: parent
    }

    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        text: "\u03c0"
        color: "blue"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            onClicked: loadOnlineSource()
        }
    }

    function loadOnlineSource() {
        console.log("loadOnlineSource");
        load(onlineSource);
    }

}
