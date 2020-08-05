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
                text: mainButton.text
                onClicked: app.toggleProxy(true)
            }
        }
        PushUpMenu {
            busy: app.applying
            quickSelect: true
            MenuItem {
                text: mainButton.text
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
            TextSwitch {
                id: manageSwitch
                text: qsTr("Start with active bluetooth connection")
                checked: app.configAutoManage.value
                onClicked: {
                    app.configAutoManage.value = checked
                    app.configAutoManage.sync()
                    checked = Qt.binding(function() { return app.configAutoManage.value })
                }
            }
            HighlightImage {
                id: image
                x: (parent.width - width) / 2
                source: '../bttns-icon.svg'
                color: Theme.highlightColor
                width: parent.width //Theme.itemSizeHuge
                height: Theme.itemSizeHuge
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
            ButtonLayout {
                id: buttonLayout
                width: parent.width
                visible: !app.configAutoManage.value
                Button {
                    id: mainButton
                    enabled: !app.applying
                    text: app.proxyRunning
                          ? qsTr("Close Proxy")
                          : qsTr("Start Proxy")
                    onClicked: app.toggleProxy()
                }
                BusyIndicator {
                    size: BusyIndicatorSize.Large
                    anchors.centerIn: buttonLayout
                    running: app.applying
                }
            }
            ListView {
                width: parent.width - Theme.horizontalPageMargin * 2
                x: Theme.horizontalPageMargin
                height: app.connectedDevices.count * Theme.itemSizeExtraSmall
                model: app.connectedDevices
                visible: app.configAutoManage.value
                delegate: Label {
                    width: parent.width

                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    height: Theme.itemSizeExtraSmall
                    text: model.name
                    color: Theme.highlightColor
                }
            }
        }
    }
}
