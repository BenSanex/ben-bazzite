//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1
//@ pragma AppId dev.benbazzite.greeter

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Greetd
import Quickshell.Wayland

ShellRoot {
    id: entry

    property string pendingPassword: ""
    property string statusText: ""
    property bool busy: false
    property date now: new Date()

    signal clearPasswordRequested

    function signIn(username, password) {
        const cleanUsername = username.trim();
        if (!cleanUsername || !password || busy)
            return;

        if (!Greetd.available) {
            statusText = "The login service is unavailable";
            return;
        }

        if (Greetd.state !== GreetdState.Inactive) {
            statusText = "Please wait for the current attempt";
            return;
        }

        pendingPassword = password;
        statusText = "Authenticating…";
        busy = true;
        Greetd.createSession(cleanUsername);
    }

    function resetAfterFailure(message) {
        pendingPassword = "";
        busy = false;
        statusText = message;
        clearPasswordRequested();
        if (Greetd.state !== GreetdState.Inactive)
            Greetd.cancelSession();
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: entry.now = new Date()
    }

    Process {
        id: poweroffProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired) {
                Greetd.respond(entry.pendingPassword);
                entry.pendingPassword = "";
            } else {
                entry.statusText = message || "Authenticating…";
                Greetd.respond("");
            }
        }

        function onReadyToLaunch() {
            entry.statusText = "Welcome";
            Greetd.launch(
                ["/usr/bin/ben-bazzite-hyprland-session"],
                ["XDG_SESSION_TYPE=wayland", "XDG_CURRENT_DESKTOP=Hyprland", "XDG_SESSION_DESKTOP=Hyprland"]
            );
        }

        function onAuthFailure(message) {
            entry.resetAfterFailure("Username or password was not accepted");
        }

        function onError(error) {
            entry.resetAfterFailure("Unable to sign in. Please try again");
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window

            required property var modelData
            readonly property bool isPrimary: modelData === Quickshell.screens[0]

            screen: modelData
            color: "#070b18"
            exclusionMode: ExclusionMode.Normal
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: isPrimary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            Component.onCompleted: {
                if (isPrimary)
                    Qt.callLater(() => usernameField.forceActiveFocus());
            }

            Image {
                anchors.fill: parent
                source: "file:///usr/share/backgrounds/ben-bazzite/aurora-glass-gdm.png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }

            Rectangle {
                anchors.fill: parent
                color: "#52050713"
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#18070b18" }
                    GradientStop { position: 0.58; color: "#42070b18" }
                    GradientStop { position: 1.0; color: "#b8070b18" }
                }
            }

            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 44
                }
                spacing: 2

                Text {
                    text: Qt.formatDateTime(entry.now, "h:mm AP")
                    color: "#f5f8ff"
                    font.family: "Roboto"
                    font.pixelSize: 34
                    font.weight: Font.Light
                }

                Text {
                    text: Qt.formatDateTime(entry.now, "dddd, MMMM d")
                    color: "#b8c7e8"
                    font.family: "Roboto"
                    font.pixelSize: 15
                }
            }

            Row {
                visible: window.isPrimary
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: 32
                }
                spacing: 10

                Button {
                    text: "Restart"
                    onClicked: rebootProcess.running = true
                    contentItem: Text {
                        text: parent.text
                        color: "#e6edf7"
                        font.family: "Roboto"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#80263353" : "#54111930"
                        border.color: "#53657fa0"
                        radius: 12
                    }
                }

                Button {
                    text: "Shut down"
                    onClicked: poweroffProcess.running = true
                    contentItem: Text {
                        text: parent.text
                        color: "#e6edf7"
                        font.family: "Roboto"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.hovered ? "#80263353" : "#54111930"
                        border.color: "#53657fa0"
                        radius: 12
                    }
                }
            }

            Rectangle {
                id: card
                visible: window.isPrimary
                width: Math.min(440, parent.width - 48)
                height: 520
                anchors.centerIn: parent
                radius: 28
                color: "#d90b1020"
                border.width: 1
                border.color: "#596ee7fa"

                Column {
                    anchors {
                        fill: parent
                        margins: 40
                    }
                    spacing: 18

                    Image {
                        width: 216
                        height: 72
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "file:///etc/ben-bazzite/ben-os-gdm-logo.png"
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Text {
                        width: parent.width
                        text: "Welcome back"
                        color: "#f5f8ff"
                        font.family: "Roboto"
                        font.pixelSize: 25
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        width: parent.width
                        text: "Sign in to Ben Bazzite"
                        color: "#aeb9d6"
                        font.family: "Roboto"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                    }

                    TextField {
                        id: usernameField
                        width: parent.width
                        height: 54
                        enabled: !entry.busy
                        placeholderText: "Username"
                        color: "#e6edf7"
                        placeholderTextColor: "#8794b5"
                        font.family: "Roboto"
                        font.pixelSize: 16
                        leftPadding: 18
                        rightPadding: 18
                        selectByMouse: true
                        background: Rectangle {
                            color: "#c4111930"
                            radius: 14
                            border.width: usernameField.activeFocus ? 2 : 1
                            border.color: usernameField.activeFocus ? "#6ee7fa" : "#53657394"
                        }
                        onAccepted: passwordField.forceActiveFocus()
                    }

                    TextField {
                        id: passwordField
                        width: parent.width
                        height: 54
                        enabled: !entry.busy
                        placeholderText: "Password"
                        color: "#e6edf7"
                        placeholderTextColor: "#8794b5"
                        font.family: "Roboto"
                        font.pixelSize: 16
                        leftPadding: 18
                        rightPadding: 18
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        selectByMouse: true
                        background: Rectangle {
                            color: "#c4111930"
                            radius: 14
                            border.width: passwordField.activeFocus ? 2 : 1
                            border.color: passwordField.activeFocus ? "#6ee7fa" : "#53657394"
                        }
                        onAccepted: entry.signIn(usernameField.text, passwordField.text)
                    }

                    Text {
                        width: parent.width
                        height: 22
                        text: entry.statusText
                        color: entry.busy ? "#6ee7fa" : "#ff9daf"
                        font.family: "Roboto"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Button {
                        id: signInButton
                        width: parent.width
                        height: 54
                        enabled: !entry.busy && usernameField.text.trim() !== "" && passwordField.text !== ""
                        text: entry.busy ? "Signing in…" : "Sign in"
                        onClicked: entry.signIn(usernameField.text, passwordField.text)
                        contentItem: Text {
                            text: parent.text
                            color: parent.enabled ? "#070b18" : "#72809f"
                            font.family: "Roboto"
                            font.pixelSize: 16
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: signInButton.enabled ? (signInButton.hovered ? "#9cf0ff" : "#6ee7fa") : "#263353"
                            radius: 14
                        }
                    }

                    Text {
                        width: parent.width
                        text: "Hyprland session"
                        color: "#7180a2"
                        font.family: "Roboto"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            Connections {
                target: entry
                function onClearPasswordRequested() {
                    passwordField.clear();
                    if (window.isPrimary)
                        passwordField.forceActiveFocus();
                }
            }
        }
    }
}
