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
import Nemo.DBus 2.0
import Nemo.Configuration 1.0

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
    property alias configAutoManage: configAutoManage
    property alias configDoOfonoWatchDog: configDoOfonoWatchDog
    property alias client: client
    property string devicesString
    onProxyRunningChanged: {
        console.log('Proxy is running:', proxyRunning);
        applying = false
    }
    ConfigurationValue {
        id: configAutoManage;
        key: "/apps/btbuttons/automanage";
        defaultValue: false;
        onValueChanged: {
            if(!value) {
//                app.connectedDevices.clear()
//                app.audioDevices.clear()
            }
            manageBackgroundProcess();
        }
        Component.onCompleted: {
            verbose && console.log('config value on start', value);
//            manageBackgroundProcess();
        }
        function manageBackgroundProcess(){
            if(value && client.status < 2) {
                verbose && console.log('I may start the background process');
                launcher.launchAndForget(executablePath, ['-b']);
            } else if(!value) {
                client.typedCall('close',[], function () {
                    // This will be called when the result is available
                    console.log('process should close');
                });
            }
        }
    }
    ConfigurationValue {
        id: configDoOfonoWatchDog
        key: "/apps/btbuttons/ofonowatchdog";
        defaultValue: false
        onValueChanged: {
            sync();
        }
    }

    function checkProxyRunning() {
        var checkOutput = launcher.launch('ps -C mpris-proxy');
        proxyRunning = checkOutput.indexOf('mpris-proxy') > -1
    }
    function toggleProxy(manual) {
        if(applying) {
            return;
        }
        if(proxyRunning) {
            launcher.launch('killall mpris-proxy');
        } else {
            launcher.launchAndForget('bash', ['-c', 'mpris-proxy &']);
        }
        applying = true;
        if(manual) {
            app.configAutoManage.value = false
            app.configAutoManage.sync()
        }
        checkTimer.interval = 100;
        checkTimer.restart();
    }
    Timer {
        id: checkTimer
        interval: 100
        repeat: true
        running: true
        onTriggered: {
            interval = 5000
            checkProxyRunning();
        }
    }
    Component.onCompleted: {
        console.log('running this', executablePath)

        console.log('fg verbose', verbose);
    }


    DBusInterface {
        id: client
        service: 'de.gibbon.bgqml'
        path: '/'
        iface: 'de.gibbon.bgqml'
        onStatusChanged: {
            // 0: unknown
            // 1: disconnected
            // 2: available
            console.log('status changed', status);
            configAutoManage.manageBackgroundProcess();
        }
        watchServiceStatus: true
        onWatchServiceStatusChanged: {
            console.log('watch changed', watchServiceStatus);
        }

        propertiesEnabled: true
        signalsEnabled: true

        onPropertiesChanged: {
            console.log('CLIENT dbus properties changed, though', isRunning)
        }

        function connectedDevicesChanged(devicesString) {
            verbose && console.log('connected devices:', devicesString);
            app.devicesString = devicesString;
        }

        function isRunningChanged(running) {
            console.log('signal running', running);
            app.proxyRunning = running;
        }
        Component.onCompleted: {
            // 0 false
            console.log('status', status, watchServiceStatus);
            client.typedCall('getRunning',[], function (result) {
                // This will be called when the result is available
                console.log('Got running: ' + result);
            });
            client.typedCall('getConnectedDevices',[], function (devicesString) {
                // This will be called when the result is available
                app.devicesString = devicesString;
            });
        }
    }
    Timer {
        interval: 300
        running: true
        onTriggered: {
            configAutoManage.manageBackgroundProcess()
        }
    }

}
