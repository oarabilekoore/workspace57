import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    PanelWindow {
        id: root

        anchors { right: true; top: true; bottom: true }
        margins { left: 2; right: 0; top: 3; bottom: 3 }
        width: 460
        
        // FIX: Close the window when it loses focus (newly added for Waybar integration)
        Connections {
            target: root 
            function onActiveChanged() {
                if (!root.active) {
                    root.close()
                }
            }
        }

        // Define all properties at the top level to ensure they're accessible
        property int cpuUsageValue: 0
        property int diskUsageValue: 0
        property int volumeValue: 50
        property int brightnessValue: 50
        property bool bluetoothEnabled: false
        property bool wifiEnabled: true
        property bool vpnEnabled: false
        property int notificationCount: 0
        property int cpuLastTotal: 0
        property int cpuLastIdle: 0
        
        // Removed: Media properties

        Rectangle {
            anchors.fill: parent
            color: "#1a1a1a"
        }

        Flickable {
            id: flickable
            anchors.fill: parent
            contentWidth: parent.width
            contentHeight: column.height + 30  // Account for margins
            flickableDirection: Flickable.VerticalFlick
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: column
                anchors.fill: parent
                anchors.margins: 15
                spacing: 30 // FIX: Increased spacing to push CPU/DISK down

                // Calendar Section
                Rectangle {
                    width: parent.width
                    height: 260
                    color: "#202020"

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 12

                        Text {
                            text: Qt.formatDate(new Date(), "MMMM yyyy")
                            font.pixelSize: 18
                            font.family: "JetBrains Mono"
                            font.bold: true
                            color: "#ffffff"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Grid {
                            columns: 7
                            columnSpacing: 4
                            rowSpacing: 4
                            anchors.horizontalCenter: parent.horizontalCenter

                            Repeater {
                                model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                                Text {
                                    text: modelData
                                    font.pixelSize: 11
                                    font.family: "JetBrains Mono"
                                    color: "#888888"
                                    width: 52
                                    height: 24
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Repeater {
                                id: calendarDays
                                model: 42

                                Rectangle {
                                    width: 52
                                    height: 32
                                    color: {
                                        var today = new Date()
                                        var firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
                                        var dayOfWeek = (firstDay.getDay() + 6) % 7
                                        var dayNum = index - dayOfWeek + 1
                                        var lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
                                        
                                        if (dayNum === today.getDate() && dayNum > 0 && dayNum <= lastDay) {
                                            return "#ffffff"
                                        }
                                        return "transparent"
                                    }

                                    Text {
                                        text: {
                                            var today = new Date()
                                            var firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
                                            var dayOfWeek = (firstDay.getDay() + 6) % 7
                                            var dayNum = index - dayOfWeek + 1
                                            var lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0).getDate()
                                            
                                            if (dayNum > 0 && dayNum <= lastDay) {
                                                return dayNum
                                            }
                                            return ""
                                        }
                                        font.pixelSize: 13
                                        font.family: "JetBrains Mono"
                                        color: {
                                            var today = new Date()
                                            var firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
                                            var dayOfWeek = (firstDay.getDay() + 6) % 7
                                            var dayNum = index - dayOfWeek + 1
                                            
                                            if (dayNum === today.getDate()) {
                                                return "#000000"
                                            }
                                            return "#ffffff"
                                        }
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }
                }

                
                // Control Grid
                Grid {
                    columns: 3
                    spacing: 10
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: root.bluetoothEnabled ? "#666666" : "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: function(mouse) {
                                if (mouse.button === Qt.LeftButton) {
                                    root.toggleBluetooth()
                                } else if (mouse.button === Qt.RightButton) {
                                    root.launchBluetuiInTerminal()
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "BLE"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: root.wifiEnabled ? "#666666" : "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: function(mouse) {
                                if (mouse.button === Qt.LeftButton) {
                                    root.toggleWifi()
                                } else if (mouse.button === Qt.RightButton) {
                                    root.launchNetworkManager()
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "WiFi"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: root.vpnEnabled ? "#666666" : "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: function(mouse) {
                                if (mouse.button === Qt.LeftButton) {
                                    root.toggleVPN()
                                } else if (mouse.button === Qt.RightButton) {
                                    root.launchVPNManager()
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "VPN"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.lockScreen()
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "Lock"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.rebootSystem()
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "Reboot"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }

                    Rectangle {
                        width: (parent.width - 20) / 3
                        height: 70
                        color: "#333333"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.shutdownSystem()
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: "Shutdown"
                                font.pixelSize: 12
                                font.family: "JetBrains Mono"
                                color: "#ffffff"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                
                // Modern Volume Slider
                Rectangle {
                    width: parent.width
                    height: 80
                    color: "#202020"
                    radius: 8

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "Volume: " + root.volumeValue + "%"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono"
                            color: "#ffffff"
                        }

                        Item {
                            width: parent.width
                            height: 30

                            // Track background
                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#444444"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Track fill
                            Rectangle {
                                width: parent.width * (Math.min(100, root.volumeValue) / 100)
                                height: 6
                                radius: 3
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Handle
                            Rectangle {
                                x: parent.width * (Math.min(100, root.volumeValue) / 100) - width/2
                                y: (parent.height - height) / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                border.color: "#1a1a1a"
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.minimumX: 0
                                    drag.maximumX: parent.width - parent.width

                                    onPositionChanged: {
                                        var relativeX = parent.x + parent.width/2
                                        var newValue = Math.round((relativeX / parent.width) * 100)
                                        root.volumeValue = newValue
                                        root.setVolume(newValue)
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var newValue = Math.round((mouse.x / parent.width) * 100)
                                    root.volumeValue = newValue
                                    root.setVolume(newValue)
                                }
                            }
                        }
                    }
                }

                // Modern Brightness Slider
                Rectangle {
                    width: parent.width
                    height: 80
                    color: "#202020"
                    radius: 8

                    Column {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: "Brightness: " + root.brightnessValue + "%"
                            font.pixelSize: 14
                            font.family: "JetBrains Mono"
                            color: "#ffffff"
                        }

                        Item {
                            width: parent.width
                            height: 30

                            // Track background
                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: "#444444"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Track fill
                            Rectangle {
                                width: parent.width * (root.brightnessValue / 100)
                                height: 6
                                radius: 3
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // Handle
                            Rectangle {
                                x: parent.width * (root.brightnessValue / 100) - width/2
                                y: (parent.height - height) / 2
                                width: 20
                                height: 20
                                radius: 10
                                color: "#ffffff"
                                border.color: "#1a1a1a"
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    drag.target: parent
                                    drag.axis: Drag.XAxis
                                    drag.minimumX: 0
                                    drag.maximumX: parent.width - parent.width

                                    onPositionChanged: {
                                        var relativeX = parent.x + parent.width/2
                                        var newValue = Math.round((relativeX / parent.width) * 100)
                                        root.brightnessValue = newValue
                                        root.setBrightness(newValue)
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var newValue = Math.round((mouse.x / parent.width) * 100)
                                    root.brightnessValue = newValue
                                    root.setBrightness(newValue)
                                }
                            }
                        }
                    }
                }

                // Removed: Media Controls Section

                // System Monitors at bottom
                Column {
                    width: parent.width
                    spacing: 14

                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "CPU"
                            font.pixelSize: 17
                            font.family: "JetBrains Mono"
                            color: "#ffffff"
                        }

                        Rectangle {
                            width: parent.width
                            height: 24
                            color: "#222222"
                            radius: 4

                            Rectangle {
                                id: cpuFill
                                height: parent.height
                                width: parent.width * (root.cpuUsageValue / 100)
                                radius: 4
                                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                                color: "#ffffff"
                            }

                            Text {
                                text: root.cpuUsageValue + "%"
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 13
                                font.family: "JetBrains Mono"
                                color: root.cpuUsageValue > 0 ? "#ffffff" : "#666666"
                                anchors.rightMargin: 8
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 6

                        Text {
                            text: "DISK"
                            font.pixelSize: 17
                            font.family: "JetBrains Mono"
                            color: "#ffffff"
                        }

                        Rectangle {
                            width: parent.width
                            height: 24
                            color: "#222222"
                            radius: 4

                            Rectangle {
                                id: diskFill
                                height: parent.height
                                width: parent.width * (root.diskUsageValue / 100)
                                radius: 4
                                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                                color: "#ffffff"
                            }

                            Text {
                                text: root.diskUsageValue + "%"
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 13
                                font.family: "JetBrains Mono"
                                color: root.diskUsageValue > 0 ? "#ffffff" : "#666666"
                                anchors.rightMargin: 8
                            }
                        }
                    }
                }
            }
        }

        // Removed: Helper function to format time

        // --- Processes ---

        Process {
            id: cpuReader
            command: ["cat", "/proc/stat"]
    
            stdout: SplitParser {
                onRead: data => {
                    var lines = data.split("\n")
                    for (var i = 0; i < lines.length; i++) {
                        if (lines[i].startsWith("cpu ")) {
                            var parts = lines[i].trim().split(/\s+/)
                            var user = parseInt(parts[1]) || 0
                            var nice = parseInt(parts[2]) || 0
                            var system = parseInt(parts[3]) || 0
                            var idle = parseInt(parts[4]) || 0
                            var total = user + nice + system + idle
                            
                            if (root.cpuLastTotal > 0) {
                                var diff = total - root.cpuLastTotal
                                var idleDiff = idle - root.cpuLastIdle
                             
                                if (diff > 0) {
                                    root.cpuUsageValue = Math.round(((diff - idleDiff) / diff) * 100)
                                }
                            }
                            root.cpuLastTotal = total
                            root.cpuLastIdle = idle
                            break
                        }
                    }
                }
            }
        }

        Process {
            id: diskReader
            command: ["sh", "-c", "df -h / | tail -1 | awk '{print $5}' | tr -d %"]
            stdout: SplitParser {
                onRead: data => {
                    var disk = parseInt(data.trim())
                    if (!isNaN(disk)) {
                        root.diskUsageValue = disk
                    }
                }
            }
        }

        Process {
            id: btChecker
            command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && echo on || echo off"]
            stdout: SplitParser {
                onRead: data => {
                    root.bluetoothEnabled = (data.trim() === "on")
                }
            }
        }

        Process {
            id: wifiChecker
            command: ["nmcli", "radio", "wifi"]
            stdout: SplitParser {
                onRead: data => {
                    root.wifiEnabled = (data.trim() === "enabled")
                }
            }
        }

        Process {
            id: vpnChecker
            command: ["sh", "-c", "nmcli connection show --active | grep -q vpn && echo on || echo off"]
            stdout: SplitParser {
                onRead: data => {
                    root.vpnEnabled = (data.trim() === "on")
                }
            }
        }

        Process {
            id: volumeGetter
            command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | head -1 | awk '{print $5}' | tr -d %"]
            stdout: SplitParser {
                onRead: data => {
                    var vol = parseInt(data.trim())
                    if (!isNaN(vol)) {
                        root.volumeValue = vol
                    }
                }
            }
        }

        Process {
            id: brightnessGetter
            command: ["sh", "-c", "brightnessctl g"]
            stdout: SplitParser {
                onRead: data => {
                    var current = parseInt(data.trim())
                    if (!isNaN(current)) {
                        // Get max brightness
                        brightnessMaxGetter.running = true
                    }
                }
            }
        }

        Process {
            id: brightnessMaxGetter
            command: ["sh", "-c", "brightnessctl m"]
            stdout: SplitParser {
                onRead: data => {
                    var max = parseInt(data.trim())
                    if (!isNaN(max) && max > 0) {
                        var current = parseInt(brightnessGetter.stdout)
                        if (!isNaN(current)) {
                            // Correctly calculate the brightness percentage
                            root.brightnessValue = Math.round((current / max) * 100)
                        }
                    }
                }
            }
        }

        // Removed: Media control processes

        // --- Functions ---

        function toggleBluetooth() {
            var command = root.bluetoothEnabled ? "off" : "on"
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['bluetoothctl','power','" + command + "']; running: true }", root)
            Qt.createQmlObject("import QtQuick; Timer { interval: 1000; running: true; repeat: false; onTriggered: btChecker.running = true }", root)
        }

        function launchBluetuiInTerminal() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['kitty','bluetui']; running: true }", root)
        }

        function toggleWifi() {
            var command = root.wifiEnabled ? "off" : "on"
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['nmcli','radio','wifi','" + command + "']; running: true }", root)
            Qt.createQmlObject("import QtQuick; Timer { interval: 1000; running: true; repeat: false; onTriggered: wifiChecker.running = true }", root)
        }

        function launchNetworkManager() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['nm-connection-editor']; running: true }", root)
        }

        function toggleVPN() {
            if (root.vpnEnabled) {
                Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','nmcli connection show --active | grep vpn | awk \\\"{print $1}\\\" | xargs -I {} nmcli connection down {}']; running: true }", root)
            } else {
                Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['sh','-c','nmcli connection show | grep vpn | head -1 | awk \\\"{print $1}\\\" | xargs -I {} nmcli connection up {}']; running: true }", root)
            }
            Qt.createQmlObject("import QtQuick; Timer { interval: 1000; running: true; repeat: false; onTriggered: vpnChecker.running = true }", root)
        }

        function launchVPNManager() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['nm-connection-editor']; running: true }", root)
        }

        function lockScreen() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['hyprlock']; running: true }", root)
        }

        function rebootSystem() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['systemctl','reboot']; running: true }", root)
        }

        function shutdownSystem() {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['systemctl','poweroff']; running: true }", root)
        }

        function setVolume(vol) {
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['pactl','set-sink-volume','@DEFAULT_SINK@','" + vol + "%']; running: true }", root)
        }

        function setBrightness(val) {
            var percent = Math.round(val)
            Qt.createQmlObject("import Quickshell.Io; import QtQuick; Process { command: ['brightnessctl','s','" + percent + "%']; running: true }", root)
        }

        // Removed: Media control functions

        // --- Timers ---

        Timer {
            interval: 2000
            repeat: true
            running: true
            onTriggered: {
                cpuReader.running = true
                diskReader.running = true
            }
            Component.onCompleted: triggered()
        }

        Timer {
            interval: 5000
            repeat: true
            running: true
            onTriggered: {
                btChecker.running = true
                wifiChecker.running = true
                vpnChecker.running = true
            }
            Component.onCompleted: triggered()
        }

        Timer {
            // FIX: Faster interval (500ms) for responsiveness
            interval: 500 
            repeat: true
            running: true
            onTriggered: {
                volumeGetter.running = true
                brightnessGetter.running = true
            }
            Component.onCompleted: triggered() 
        }

        // Removed: Media info update timers

        Timer {
            interval: 60000
            repeat: true
            running: true
            onTriggered: {
                calendarDays.model = 0
                calendarDays.model = 42
            }
        }
    }
}
