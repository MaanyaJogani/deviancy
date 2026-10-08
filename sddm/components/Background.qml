import QtQuick 2.15

// Full-bleed cityscape background with a dark left-side gradient panel.
// Drop your background image at assets/background.png
Item {
    property color bg: "#05090f"

    Rectangle {
        anchors.fill: parent
        color: bg
    }

    Image {
        id: cityscape

        anchors.fill: parent

        source: "../assets/background.png"
        fillMode: Image.PreserveAspectCrop
        clip: true
    }

    // Overall darkening so text stays readable over the photo
    Rectangle {
        anchors.fill: cityscape
        color: "#000000"
        opacity: 0.18
    }

    // Fade the left ~60% of the screen into the dark UI panel
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.62

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0.0
                color: bg
            }

            GradientStop {
                position: 0.55
                color: bg
            }

            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
    }
}
