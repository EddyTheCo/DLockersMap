import QtLocation
import QtPositioning
import QtQuick
import QtQuick.Controls
MapQuickItem {
            id: control
            required property real latitude;
            required property real longitude;
            required property string account;
            required property string score;
            required property string occupied;
            signal selected(string account)
            signal showDirections(var coords)

            coordinate: QtPositioning.coordinate(latitude, longitude)
            autoFadeIn:false
            sourceItem: Rectangle {
                id: image
                width:24
                height:24
                radius:24
                color:"red"
            }
            MouseArea
            {
                anchors.fill: parent
                onClicked: objpop.open()
            }

           ObjPopUp
           {
               id:objpop
               visible:false
               closePolicy:Popup.CloseOnPressOutside
               focus:true
               modal:true
               anchors.centerIn: Overlay.overlay
               score:control.score
               occupied:control.occupied

               onSelected: control.selected(control.account);
               onShowDirections: control.showDirections(QtPositioning.coordinate(latitude, longitude));
           }
        }
