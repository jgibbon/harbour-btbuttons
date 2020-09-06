import QtQuick 2.6
import Nemo.DBus 2.0
import Launcher 1.0
import Nemo.Configuration 1.0
import 'bg'

Item {

    ConfigurationValue {
        id: configDoOfonoWatchDog
        key: "/apps/btbuttons/ofonowatchdog";
        defaultValue: false
    }
    DBusAdaptor {
        id: service
        property bool needUpdate: true
        property bool isRunning: true
        property string connectedDevices: scanner.connectedStr
        onConnectedDevicesChanged: {
            emitSignal('connectedDevicesChanged', connectedDevices)
        }

        onIsRunningChanged: {
            emitSignal('isRunningChanged', isRunning)
        }
        service: 'de.gibbon.bgqml'
        iface: 'de.gibbon.bgqml'
        path: '/'

        xml: '  <interface name="de.gibbon.bgqml">\n' +
             '    <method name="close" />\n' +
             '    <method name="getRunning" >\n' +
             '      <arg name="isRunning" direction="out" type="b"/>' +
             '    </method>' +
             '    <method name="getConnectedDevices" >\n' +
             '      <arg name="connectedDevices" direction="out" type="s"/>' +
             '    </method>' +
             '    <signal name="isRunningChanged" >\n' +
             '      <arg type="b" name="isRunning" direction="out"/>\n' +
             '    </signal>\n' +
             '    <signal name="connectedDevicesChanged" >\n' +
             '      <arg type="s" name="connectedDevices" direction="out"/>\n' +
             '    </signal>\n' +
             '    <property name="isRunning" type="b" access="readwrite" />\n' +
             '  </interface>\n'
        function getRunning() {
            return isRunning;
        }
        function getConnectedDevices() {
            return connectedDevices;
        }

        function close() {
            verbose && console.log("close called")
            launcher.exitProxy()
            Qt.quit()
        }
    }

    Timer {
        running: false
        interval: 4000
        repeat: true
        onTriggered: {
            service.isRunning = !service.isRunning
            verbose && console.log('running?', service.isRunning)
        }
    }
    Scanner {
        id: scanner
        onConnectedCountChanged: {
            if(scanner.connectedCount > 0) {
                launcher.launchProxy();
            } else {
                launcher.exitProxy();
            }
        }
    }
    Launcher {
        id: launcher

        function checkProxyRunning() {
            var checkOutput = launcher.launch('ps -C mpris-proxy');
            return checkOutput.indexOf('mpris-proxy') > -1
        }
        function launchProxy() {
            if(!checkProxyRunning()) {
                console.log('launch proxy')
                launcher.launchAndForget('bash', ['-c', 'mpris-proxy &']);
                service.isRunning = true
            }
        }
        function exitProxy() {
            if(checkProxyRunning()) {

                console.log('kill proxy')
                launcher.launch('killall mpris-proxy');
                service.isRunning = false
                ofonoWatchdog()
            }

        }
        function ofonoWatchdog() {
            //watchdog test:
            configDoOfonoWatchDog.sync();
            if(configDoOfonoWatchDog.value) {
                var helperloc = '/usr/share/harbour-nofono/helper/nofonohelper';
                if(launcher.fileExists(helperloc)) {
                   ofonoWatchTimer.start()
                } else {
                    console.log('nofono not installed');
                }
            } else {
                console.log('watchdog not enabled');
            }
        }
    }
    Timer {
        id: ofonoWatchTimer
        interval: 4000
        property int watchNum:0
        property int highCPUNum:0
        onTriggered: {
            if(watchNum < 4) {

                //watchdog test:
                var ofonocpuusage = launcher.launch('ps -C ofonod -o %cpu').split(' ');
                var usage = parseFloat(ofonocpuusage[1])
                console.log('ofono cpu', usage);
                if(usage > 80) {
                    highCPUNum = highCPUNum + 1;
                    console.log('high cpu')
                } else {
                    console.log('normal cpu')
                }

                watchNum = watchNum + 1;
                interval = 1000;
                ofonoWatchTimer.restart();
            } else {
                if(highCPUNum > 2) {
                    launcher.launch('/usr/share/harbour-nofono/helper/nofonohelper');
                }
                watchNum = 0;
                highCPUNum = 0;
                interval = 4000;
            }
        }
    }

    Component.onCompleted: {
        console.log('bg verbose', verbose);
    }
}
