/*

BTtons (harbour-btbuttons)
Copyright (C) 2019  John Gibbon

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/
import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: Orientation.All
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height
        PullDownMenu {
            busy: app.applying
            quickSelect: true
            MenuItem {
                id: toggleMenuItem
                text: app.proxyRunning
                      ? qsTr("Stop Proxy")
                      : qsTr("Start Proxy")
                onClicked: app.toggleProxy(true)
            }
        }
        PushUpMenu {
            busy: app.applying
            quickSelect: true
            MenuItem {
                text: toggleMenuItem.text
                onClicked: app.toggleProxy(true)
            }
        }
        Column {
            id: mainColumn
            width: parent.width
            PageHeader {
                id: pageHeader
                title: qsTr("BTtons")
            }
            HighlightImage {
                id: image
                x: (parent.width - width) / 2
                source: '../bttns-icon.svg'
                color: Theme.highlightColor
                width: parent.width //Theme.itemSizeHuge
                height: Theme.itemSizeExtraLarge
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                sourceSize {
                    width: Theme.itemSizeHuge
                    height: Theme.itemSizeHuge
                }
                opacity: app.proxyRunning ? 1.0 : 0.4
                Behavior on opacity {
                    NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
                }
            }
            Label {
                id: label
                width: parent.width - Theme.horizontalPageMargin * 2
                x: Theme.horizontalPageMargin
                text: app.proxyRunning
                      ? qsTr("Mpris proxy is running.")
                      : qsTr("Mpris proxy isn't running.")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Label {
                width: parent.width - Theme.horizontalPageMargin * 2
                x: Theme.horizontalPageMargin
                visible: app.configAutoManage.value
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                text: app.devicesString
                color: Theme.highlightColor
            }
            TextSwitch {
                id: manageSwitch
                text: qsTr("Automatically manage Proxy")
                description: qsTr("Manager stays active after closing BTtons application.")
                checked: app.configAutoManage.value
                busy: app.configAutoManage.value && app.client.status !== 2
                onClicked: {
                    app.configAutoManage.value = checked
                    app.configAutoManage.sync()
                    checked = Qt.binding(function() { return app.configAutoManage.value })
                }
            }

            TextSwitch {
                id: manualSwitch
                text: qsTr("Proxy started")
                description: qsTr("Start/Stop Proxy manually")
                checked: app.proxyRunning
                enabled: !app.applying
                busy: app.applying
                onClicked: {
                    if(!app.applying) {
                        app.toggleProxy(true)
                    }
                    checked = Qt.binding(function() { return app.proxyRunning })
                }
            }

//            ListView {
//                width: parent.width - Theme.horizontalPageMargin * 2
//                x: Theme.horizontalPageMargin
//                height: app.connectedDevices.count * Theme.itemSizeExtraSmall
//                model: app.connectedDevices
//                visible: app.configAutoManage.value
//                delegate: Label {
//                    width: parent.width

//                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
//                    horizontalAlignment: Text.AlignHCenter
//                    height: Theme.itemSizeExtraSmall
//                    text: model.name
//                    color: Theme.highlightColor
//                }
//            }
        }
    }
}
