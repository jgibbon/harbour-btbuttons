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
        contentHeight: page.height
        PullDownMenu {
            busy: app.applying
            quickSelect: true
            MenuItem {
                text: mainButton.text
                onClicked: app.toggleProxy()
            }
        }
        PushUpMenu {
            busy: app.applying
            quickSelect: true
            MenuItem {
                text: mainButton.text
                onClicked: app.toggleProxy()
            }
        }
        PageHeader {
            id: pageHeader
            title: qsTr("BTtons")
        }

        HighlightImage {
            id: image
            x: (parent.width - width) / 2
            source: '../bttns-icon.svg'
            color: Theme.highlightColor
            width: Theme.itemSizeHuge
            height: Theme.itemSizeHuge
            sourceSize {
                width: Theme.itemSizeHuge
                height: Theme.itemSizeHuge
            }

            opacity: app.proxyRunning ? 1.0 : 0.4
            Behavior on opacity {
                NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
            }
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: label.top
                bottomMargin: Theme.paddingLarge
            }
        }
        Label {
            id: label
            width: parent.width - Theme.horizontalPageMargin * 2
            height: (parent.height - pageHeader.height) / 2
            anchors.centerIn: parent
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
            anchors {
                top: label.bottom
                topMargin: Theme.paddingLarge * 2
            }

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

    }
}
