import QtQuick 2.0
import Nemo.DBus 2.0


Item {
    id: scannerItem
    property string connectedStr: connectedArr.join('<br />')
    property int connectedCount: connectedDevices.count
    property var connectedArr:([])
    property ListModel connectedDevices: ListModel {
        onCountChanged: {
            verbose && console.log('connected devices:', count);
//            if(scannerItem.configAutoManage.value && (count > 0) !== scannerItem.proxyRunning) {
//                scannerItem.toggleProxy();
//            }
            var arr = [];
            for(var i = 0; i< count; i++) {
                arr.push(get(i).name)
            }
            scannerItem.connectedArr = arr;
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
                            verbose && console.log('deviceConnected…', model.name, result)
                            if(result) {
                                scannerItem.addDeviceToModel(scannerItem.audioDevices.get(index), scannerItem.connectedDevices);
                            } else {
                                scannerItem.removeDeviceFromModel(model.key, scannerItem.connectedDevices);
                            }
                        },
                        function(err){verbose && console.log('connected query error', err)});
                }

                onPropertiesChanged: {
                    getConnectionState();
                }
                Component.onCompleted: getConnectionState()
            }
        }
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
                scannerItem.addDeviceToModel({key: key, name: obj['org.bluez.Device1'].Name}, scannerItem.audioDevices)
            } else {
//                        verbose && console.log('Added ----------------------------', JSON.stringify(obj), JSON.stringify(arr))
            }
        }
        function interfacesRemoved(key, arr) {
            if(arr[2] === 'org.bluez.Device1') {
                scannerItem.removeDeviceFromModel(key, scannerItem.connectedDevices);
                scannerItem.removeDeviceFromModel(key, scannerItem.audioDevices);
            }
        }
        // end signals
        function getConnectedAudioDevices(cb) {
            deviceQuery.typedCall('GetManagedObjects', undefined, replyFactory(cb), function(err){verbose && console.log('error query', err)})
        }
        function replyFactory(cb) {
            return function filterDbusServices(dbusReply) {
                scannerItem.audioDevices.clear()
                verbose && console.log('does this work even')
                for (var key in dbusReply) {
                    if('org.bluez.Device1' in dbusReply[key]) {
                        if(dbusReply[key]['org.bluez.Device1'].Icon === 'audio-card') {
                            var entry = {
                                name: dbusReply[key]['org.bluez.Device1'].Name,
                                key: key
                            }
                            scannerItem.addDeviceToModel(entry, scannerItem.audioDevices);
                        } else {
//                                    verbose && console.log('device not matched:', JSON.stringify(dbusReply[key]['org.bluez.Device1']));
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
