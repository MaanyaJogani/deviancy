import QtQuick 2.15
import Qt5Compat.GraphicalEffects

// Two faint scanlines that roam the screen independently at all times.
// Set `converge: true` (with a `targetX`/`targetY`) to have them stop
// roaming, sweep onto a point of interest, and hover there with a small
// "sampling" oscillation until `converge` is set back to false, at which
// point normal roaming resumes automatically.
Item {
    id: overlay

    property color color: "#5dd8ff"
    property bool converge: false
    property real targetX: width / 2
    property real targetY: height / 2

    Rectangle {
        id: scanline
        anchors.left: parent.left
        anchors.right: parent.right
        height: 2
        color: overlay.color
        opacity: 0.06

        SequentialAnimation {
            id: scanlineRoam
            loops: Animation.Infinite
            running: true

            NumberAnimation {
                target: scanline
                property: "y"
                from: 0
                to: overlay.height
                duration: 6400
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                target: scanline
                property: "y"
                from: overlay.height
                to: 0
                duration: 6400
                easing.type: Easing.InOutSine
            }
        }

        NumberAnimation {
            id: convergeY
            target: scanline
            property: "y"
            duration: 420
            easing.type: Easing.InOutQuad
        }

        // Tiny "sampling" hover once converged, instead of sitting dead still
        SequentialAnimation {
            id: holdY
            loops: Animation.Infinite

            NumberAnimation {
                target: scanline
                property: "y"
                to: overlay.targetY - 5
                duration: 500
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                target: scanline
                property: "y"
                to: overlay.targetY + 5
                duration: 500
                easing.type: Easing.InOutSine
            }
        }
    }

    Rectangle {
        id: scanlineVertical
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 2
        color: overlay.color
        opacity: 0.06

        SequentialAnimation {
            id: scanlineVerticalRoam
            loops: Animation.Infinite
            running: true

            NumberAnimation {
                target: scanlineVertical
                property: "x"
                from: 0
                to: overlay.width
                duration: 9100
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                target: scanlineVertical
                property: "x"
                from: overlay.width
                to: 0
                duration: 9100
                easing.type: Easing.InOutSine
            }
        }

        NumberAnimation {
            id: convergeX
            target: scanlineVertical
            property: "x"
            duration: 420
            easing.type: Easing.InOutQuad
        }

        SequentialAnimation {
            id: holdX
            loops: Animation.Infinite

            NumberAnimation {
                target: scanlineVertical
                property: "x"
                to: overlay.targetX - 5
                duration: 620
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                target: scanlineVertical
                property: "x"
                to: overlay.targetX + 5
                duration: 620
                easing.type: Easing.InOutSine
            }
        }
    }

    // Faint "sampling" point where the two scanlines cross, tracking their
    // intersection continuously as they sweep at different speeds.
    // Intensifies briefly while converged.
    Rectangle {
        width: overlay.converge ? 7 : 4
        height: overlay.converge ? 7 : 4
        radius: width / 2
        color: overlay.color
        opacity: overlay.converge ? 0.85 : 0.5

        Behavior on width { NumberAnimation { duration: 200 } }
        Behavior on height { NumberAnimation { duration: 200 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        x: scanlineVertical.x + scanlineVertical.width / 2 - width / 2
        y: scanline.y + scanline.height / 2 - height / 2

        layer.enabled: true
        layer.effect: Glow {
            radius: 8
            samples: 12
            color: overlay.color
            spread: 0.35
            opacity: 0.5
        }
    }

    onConvergeChanged: {
        if (converge) {
            scanlineRoam.stop()
            scanlineVerticalRoam.stop()

            convergeY.from = scanline.y
            convergeY.to = targetY
            convergeX.from = scanlineVertical.x
            convergeX.to = targetX
            convergeY.start()
            convergeX.start()

            holdY.start()
            holdX.start()
        } else {
            holdY.stop()
            holdX.stop()

            scanlineRoam.start()
            scanlineVerticalRoam.start()
        }
    }
}
