pragma ComponentBehavior: Bound
import QtQuick
import QtQml
import QtPositioning
import QtLocation
import QtQuick.Controls
import Esterv.CustomControls.CoordToMap

MapView {

    id:control

    property alias objModel:objView.model;
    signal selected(string account)

    MapItemView {
        id: objView
        delegate: ObjDelegate
        {
            onShowDirections: (coords) => {
                routequery.clearWaypoints();
                routequery.addWaypoint(client.position.coordinate);
                routequery.addWaypoint(coords);
                routemodel.update();

            }
            onSelected: (account) => control.selected(account);
        }
    }

    RouteQuery {
        id: routequery
    }

    RouteModel {
        id: routemodel
        plugin: plugin
        query: routequery
        autoUpdate: false
        onErrorChanged: console.log("error:",routemodel.error)
        onErrorStringChanged:  console.log("errorString:",routemodel.errorString)
        onStatusChanged: { console.log("route:", routemodel.status); }
        onCountChanged: { console.log("count:", routemodel.count); }


    }
    MapItemView {
        id:routeview
        model:  routemodel

        delegate: MapRoute {
            required property var routeData
            route: routeData
            line.color: "blue"
            line.width: 5
            smooth: true
            opacity: 0.8
        }
    }


    onVisibleChanged: {
        if(control.visible)
        {
            LocationPermisioner.checkPermission();
        }
    }

    Component.onCompleted: {
        control.map.addMapItem(marker);
        control.map.addMapItemView(objView);
        control.map.addMapItemView(routeview);
        LocationPermisioner.getPermissions();
        //centeranimation.enabled=true;
        client.positionChanged.connect(centerMap);

    }
    function centerMap(){
        control.map.center = client.position.coordinate;
        client.positionChanged.disconnect(centerMap);
    }

    //Behavior on map.center  { id: centeranimation ; enabled:false;
    //  CoordinateAnimation { duration: 400 ; easing.type: Easing.InOutQuad} }

    map.copyrightsVisible: false
    map.zoomLevel:12
    map.minimumZoomLevel:8


    map.plugin: Plugin {
        id: plugin
        name: "osm"
    }

    PositionSource {
        id:client
        active: control.visible&&LocationPermisioner.isGranted
        updateInterval: 1000
    }

    MapQuickItem {
        id: marker
        visible: LocationPermisioner.isGranted
        coordinate: client.position.coordinate
        autoFadeIn:false
        sourceItem: Rectangle {
            id: image
            width:24
            height:24
            radius:24
            color:"blue"
        }
    }

    RoundButton {
        id: recenter
        width:56
        height:56
        radius: 56
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 10
        visible: LocationPermisioner.isGranted
        ToolTip.text: qsTr("Recenter")
        ToolTip.visible: hovered
        onClicked: control.map.center = client.position.coordinate
        background: Rectangle
        {
            width:50
            height:50
            radius:50
            color:"blue"

            Rectangle
            {
                width:42
                height:42
                radius:42
                color:"white"
                anchors.centerIn: parent
                Rectangle
                {
                    width:32
                    height:32
                    radius:32
                    color:"blue"
                    anchors.centerIn: parent
                }
            }
        }
    }
}
