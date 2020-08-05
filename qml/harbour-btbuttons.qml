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
                app.connectedDevices.clear()
                app.audioDevices.clear()
            }
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
    property ListModel connectedDevices: ListModel {
        onCountChanged: {
            console.log('connected devices:', count);

            if(app.configAutoManage.value && (count > 0) !== app.proxyRunning) {
                app.toggleProxy();
            }
        }
    }
    property ListModel audioDevices: ListModel {}
    Repeater {
        model: audioDevices
        delegate: Item {
            id: audioDeviceItem
            property bool hasConnection
            DBusInterface {
                id: audioDevice
                bus: DBus.SystemBus
                signalsEnabled: true
                service: 'org.bluez'
                iface: 'org.bluez.Device1'
                path: model.key
                property bool connected
                onPropertiesChanged: {
                    audioDeviceProperties.getConnectionState()
                }
            }
            DBusInterface {
                id: audioDeviceProperties
                bus: DBus.SystemBus
                service: 'org.bluez'
                iface: 'org.freedesktop.DBus.Properties'
                path: model.key
                function getConnectionState() {
                    typedCall('Get', [{type:'s',value:'org.bluez.Device1'},{type:'s',value:'Connected'}],
                        function(result){
                            console.log('deviceConnected…', model.name, result)
                            if(result) {
                                app.addDeviceToModel(app.audioDevices.get(index), app.connectedDevices);
                            } else {
                                app.removeDeviceFromModel(model.key, app.connectedDevices);
                            }
                        },
                        function(err){console.log('connected query error', err)});
                }

                onPropertiesChanged: {
                    getConnectionState();
                }
                Component.onCompleted: getConnectionState()
            }
        }
    }
    Loader {
        id: scanLoader
        active: app.configAutoManage.value
        sourceComponent: btdevicescanner
    }
    function addDeviceToModel(device, model) {
        var alreadyThere = false;
        for(var i = 0; i < model.count; i++) {
            if(model.get(i).key === device.key) {
                alreadyThere = true;
                continue;
            }
        }
        if(!alreadyThere) {
            model.append(device);
        }
    }
    function removeDeviceFromModel(key, model) {
        for(var i = 0; i < model.count; i++) {
            var entry = model.get(i);
            if(entry.key === key) {
                model.remove(i);
                continue;
            }
        }
    }
    Component {
        id: btdevicescanner
        Item {
            id: scannerItem
            DBusInterface {
                id: deviceQuery
                bus: DBus.SystemBus
                signalsEnabled: true
                service: 'org.bluez'
                iface: 'org.freedesktop.DBus.ObjectManager'
                path: '/'
                // start signals
                function interfacesAdded(key, obj) {
                    if(obj && obj['org.bluez.Device1'] && obj['org.bluez.Device1'].Icon === 'audio-card') {
                        app.addDeviceToModel({key: key, name: obj['org.bluez.Device1'].Name}, app.audioDevices)
                    } else {
//                        console.log('Added ----------------------------', JSON.stringify(obj), JSON.stringify(arr))
                    }
                }
                function interfacesRemoved(key, arr) {
                    if(arr[2] === 'org.bluez.Device1') {
                        app.removeDeviceFromModel(key, app.connectedDevices);
                        app.removeDeviceFromModel(key, app.audioDevices);
                    }
                }
                // end signals
                function getConnectedAudioDevices(cb) {
                    deviceQuery.typedCall('GetManagedObjects', undefined, replyFactory(cb), function(err){console.log('error query', err)})
                }
                function replyFactory(cb) {
                    return function filterDbusServices(dbusReply) {
                        app.audioDevices.clear()
                        console.log('does this work even')
                        for (var key in dbusReply) {
                            if('org.bluez.Device1' in dbusReply[key]) {
                                if(dbusReply[key]['org.bluez.Device1'].Icon === 'audio-card') {
                                    var entry = {
                                        name: dbusReply[key]['org.bluez.Device1'].Name,
                                        key: key
                                    }
                                    app.addDeviceToModel(entry, app.audioDevices);
                                } else {
//                                    console.log('device not matched:', JSON.stringify(dbusReply[key]['org.bluez.Device1']));
                                }
                            }
                        }
                        if(cb) {
                            cb();
                        }
                    }
                }
                Component.onCompleted: {
                    getConnectedAudioDevices(function(){});
                }
            }
        }
    }
}
