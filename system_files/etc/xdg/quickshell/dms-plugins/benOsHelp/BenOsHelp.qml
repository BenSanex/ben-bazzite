import QtQuick
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    pillClickAction: () => helpProcess.running = true

    Process {
        id: helpProcess
        command: ["/usr/libexec/ben-bazzite/keybinds"]
        running: false
    }

    horizontalBarPill: Component {
        StyledText {
            text: "?"
            color: Theme.secondary
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Bold
        }
    }

    verticalBarPill: Component {
        StyledText {
            text: "?"
            color: Theme.secondary
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Bold
        }
    }
}
