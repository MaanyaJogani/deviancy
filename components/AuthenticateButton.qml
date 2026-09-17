import QtQuick 2.15
import QtQuick.Controls 2.15

// The AUTHENTICATE button. While authState is "authenticating" or
// "success", its border visually collapses into a thin cyan line, which
// doubles as the verification progress fill (driven by authProgress) — no
// separate progress widget.
Button {
    id: loginButton

    width: 190
    height: 46

    property string authState: "idle"
    property real authProgress: 0.0
    property color accentColor: "#5dd8ff"
    property color cyan: "#5dd8ff"
    property color cyanSoft: "#7ab8c9"

    enabled: authState === "idle" || authState === "failed"

    text: authState === "authenticating" ? "VERIFYING IDENTITY"
          : authState === "success" ? "IDENTITY CONFIRMED"
          : authState === "failed" ? "ACCESS DENIED"
          : "AUTHENTICATE"

    // Collapses vertically into a thin line while verifying; the label
    // fades out well before the geometry finishes shrinking so it never
    // renders squashed.
    transform: Scale {
        id: buttonCollapseScale
        origin.x: loginButton.width / 2
        origin.y: loginButton.height / 2
        yScale: (loginButton.authState === "authenticating" || loginButton.authState === "success") ? 0.08 : 1.0

        Behavior on yScale {
            NumberAnimation {
                duration: 280
                easing.type: Easing.InOutQuad
            }
        }
    }

    contentItem: Text {
        text: loginButton.text

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        color: loginButton.hovered ? "#05090f" : loginButton.cyanSoft
        font.pixelSize: 11
        font.weight: Font.DemiBold
        font.letterSpacing: 3

        opacity: (loginButton.authState === "authenticating" || loginButton.authState === "success") ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 110
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    background: Rectangle {
        id: loginButtonBg
        clip: true

        color: loginButton.down
               ? "#3fb8d9"
               : (loginButton.hovered ? loginButton.cyan : "transparent")

        border.width: 1
        border.color: loginButton.authState === "failed" ? loginButton.accentColor
                      : (loginButton.hovered ? loginButton.cyan : "#315565")

        radius: 1

        // Doubles as the authentication progress indicator: once the button
        // has collapsed into a thin bar, this is what fills left-to-right.
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * loginButton.authProgress
            color: loginButton.accentColor
            opacity: (loginButton.authState === "authenticating" || loginButton.authState === "success") ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }

        // Diagonal light sweep, plays once each time hover begins
        Rectangle {
            id: sweep
            width: 26
            height: parent.height * 2.4
            rotation: 28
            x: -60
            y: -parent.height * 0.7

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop { position: 0.0; color: "#00ffffff" }
                GradientStop { position: 0.5; color: "#552e4a52" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
        }

        SequentialAnimation {
            id: sweepAnim

            NumberAnimation {
                target: sweep
                property: "x"
                from: -60
                to: loginButtonBg.width + 40
                duration: 420
                easing.type: Easing.InOutQuad
            }
        }

        Connections {
            target: loginButton
            function onHoveredChanged() {
                if (loginButton.hovered) {
                    sweep.x = -60
                    sweepAnim.start()
                }
            }
        }

        // Corner brackets fade in on hover, echoing the HUD styling used
        // elsewhere in the theme
        Repeater {
            model: [
                { x: -1, y: -1, rot: 0 },
                { x: parent.width - 9, y: -1, rot: 90 },
                { x: parent.width - 9, y: parent.height - 9, rot: 180 },
                { x: -1, y: parent.height - 9, rot: 270 }
            ]

            Item {
                x: modelData.x
                y: modelData.y
                width: 10
                height: 10
                rotation: modelData.rot
                opacity: loginButton.hovered ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Rectangle {
                    width: 10
                    height: 1
                    color: "#05090f"
                }

                Rectangle {
                    width: 1
                    height: 10
                    color: "#05090f"
                }
            }
        }
    }
}
