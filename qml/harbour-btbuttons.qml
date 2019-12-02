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
import Launcher 1.0
import "pages"

ApplicationWindow
{
    id:app
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
    Launcher {
        id: launcher
    }

    property bool proxyRunning: false
    property bool applying: false
    onProxyRunningChanged: {
        console.log('Proxy is running:', proxyRunning);
        applying = false
    }

    function checkProxyRunning() {
        var checkOutput = launcher.launch('ps -C mpris-proxy');
        proxyRunning = checkOutput.indexOf('mpris-proxy') > -1
    }
    function toggleProxy() {
        if(applying) {
            return;
        }
        if(proxyRunning) {
            launcher.launch('killall mpris-proxy');
        } else {
            launcher.launchAndForget('bash', ['-c', 'mpris-proxy &']);
        }
        applying = true;
        checkTimer.interval = 100;
        checkTimer.restart();
    }
    Timer {
        id: checkTimer
        interval: 100
        repeat: true
        running: true
        onTriggered: {
            interval = 1000
            checkProxyRunning();
        }
    }
//    Component.onCompleted: {
//        checkProxyRunning();
//    }
}
