import QtQuick 2.15
import Qt5Compat.GraphicalEffects

// Purely decorative HUD elements: the panel/photo seam, corner brackets,
// dotted edge accents, and the small system-label taglines. None of this
// reacts to authentication state.
Item {
    property color cyan: "#5dd8ff"
    property color textMuted: "#93aab5"

    // HUD seam between the panel and the photo, with a soft glow
    Rectangle {
        id: seam
        x: parent.width * 0.62
        y: parent.height * 0.1
        width: 1
        height: parent.height * 0.8
        color: cyan
        opacity: 0.5
    }

    Glow {
        anchors.fill: seam
        source: seam
        radius: 10
        samples: 20
        color: cyan
        spread: 0.15
        opacity: 0.5
    }

    // Corner HUD brackets
    Repeater {
        model: [
            { x: parent.width * 0.66, y: parent.height * 0.08, rot: 0 },
            { x: parent.width * 0.97, y: parent.height * 0.92, rot: 180 },
            { x: 20, y: 16, rot: 0 },
            { x: parent.width * 0.02, y: parent.height * 0.95, rot: 270 }
        ]

        Item {
            x: modelData.x
            y: modelData.y
            width: 16
            height: 16
            rotation: modelData.rot

            Rectangle {
                width: 16
                height: 1
                color: cyan
                opacity: 0.55
            }

            Rectangle {
                width: 1
                height: 16
                color: cyan
                opacity: 0.55
            }
        }
    }

    // Dotted vertical accents along the left edge
    Column {
        x: 26
        y: 40
        spacing: 8

        Repeater {
            model: 4

            Rectangle {
                width: 2
                height: 2
                radius: 1
                color: cyan
                opacity: 0.5
            }
        }
    }

    Column {
        x: 22
        y: parent.height * 0.28
        spacing: 10

        Repeater {
            model: 6

            Rectangle {
                width: 2
                height: 2
                radius: 1
                color: cyan
                opacity: 0.35
            }
        }
    }

    Column {
        x: 26
        y: parent.height * 0.85
        spacing: 8

        Repeater {
            model: 4

            Rectangle {
                width: 3
                height: 4
                radius: 1
                color: cyan
                opacity: 0.5
            }
        }
    }

    Column {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 28
        anchors.topMargin: 30

        spacing: 6

        Text {
            text: "ANDROID INTERFACE // LOCAL"

            horizontalAlignment: Text.AlignRight
            color: textMuted
            font.pixelSize: 9
            font.letterSpacing: 1.6
        }

        Text {
            text: "SECURE SESSION // ACTIVE"

            horizontalAlignment: Text.AlignRight
            color: textMuted
            font.pixelSize: 9
            font.letterSpacing: 1.6
        }
    }

    // Bottom-left tagline
    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: parent.width * 0.03
        anchors.bottomMargin: 26

        spacing: 14

        Text {
            text: "STILL HUMAN, STILL HERE"

            color: textMuted
            font.pixelSize: 9
            font.letterSpacing: 2.4
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 34
            height: 1
            color: cyan
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Bottom-right tagline over the photo, mirroring the bottom-left one
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: parent.width * 0.03
        anchors.bottomMargin: 26

        spacing: 14

        Rectangle {
            width: 34
            height: 1
            color: cyan
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "DEVIANCY IS FREEDOM"

            color: cyan
            font.pixelSize: 9
            font.letterSpacing: 2.4
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
