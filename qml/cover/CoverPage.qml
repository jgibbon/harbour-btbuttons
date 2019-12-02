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
import QtQuick 2.6
import Sailfish.Silica 1.0

CoverBackground {
    Image {
        width: parent.width / 2
        height: width
        sourceSize.width: width
        sourceSize.height: height
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: label.top
            bottomMargin: Theme.paddingLarge
        }
        opacity: app.proxyRunning ? 1.0 : 0.4
        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
        }
        source: '../bttns-icon.svg'
    }
    Label {
        id: label
        anchors.centerIn: parent
        width: parent.width - Theme.horizontalPageMargin * 2
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: app.proxyRunning
              ? qsTr("Mpris proxy is running.")
              : qsTr("Mpris proxy isn't running.")
    }
    BusyIndicator {
        id: indicator
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        running: app.applying
        RotationAnimator on rotation {
            from: 0; to: 360
            duration: 2000
            running: (indicator.running || opacity > 0) && indicator.visible && !Qt.application.active
            loops: Animation.Infinite
        }
    }
    CoverActionList {
        id: coverAction
        CoverAction {
            iconSource: app.proxyRunning
                        ? "image://theme/icon-cover-cancel"
                        : "image://theme/icon-cover-play"
            onTriggered: app.toggleProxy()
        }
    }
}
