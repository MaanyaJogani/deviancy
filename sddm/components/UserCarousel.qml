import QtQuick 2.15
import Qt5Compat.GraphicalEffects

// Last-signed-in user centered and lit up, other accounts dimmed on either
// side. Chevrons (or the side names themselves) request prev/next; Main.qml
// owns the actual currentIndex and the userModel-backed name lookups, passed
// in as plain function references so this component stays data-agnostic.
Row {
    id: carousel

    spacing: 40

    property int currentIndex: 0
    property int userCount: 0
    property int lastIndex: 0
    property string modelText: ""

    property var displayNameAt: function (i) { return "" }
    property var firstNameAt: function (i) { return "" }
    property var lastNameAt: function (i) { return "" }

    property string authState: "idle"
    property color accentColor: "#5dd8ff"
    property color cyan: "#5dd8ff"
    property color cyanSoft: "#7ab8c9"
    property color textMain: "#edf6fb"
    property color textMuted: "#93aab5"

    // Exposes the current-user text item so Main.qml can compute an
    // on-screen point for scanline convergence during verification.
    property alias currentUserAnchor: currentUserFirstName

    signal prevRequested()
    signal nextRequested()

    Text {
        text: "‹"
        visible: carousel.userCount > 1
        color: carousel.cyanSoft
        font.pixelSize: 22
        anchors.verticalCenter: parent.verticalCenter
        opacity: prevMouse.containsMouse ? 1.0 : 0.5

        MouseArea {
            id: prevMouse
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: carousel.prevRequested()
        }
    }

    Item {
        width: Math.max(prevFirstName.width, prevLastName.width)
        height: prevFirstName.height + prevLastName.height + 2
        visible: carousel.userCount > 2
        opacity: 0.55
        anchors.verticalCenter: parent.verticalCenter

        property int userIndex: (carousel.currentIndex - 1 + carousel.userCount) % carousel.userCount

        Text {
            id: prevFirstName
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.firstNameAt(parent.userIndex).toUpperCase()
            color: carousel.textMuted
            font.pixelSize: 14
            font.weight: Font.Medium
            font.letterSpacing: 3
        }

        Text {
            id: prevLastName
            anchors.top: prevFirstName.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.lastNameAt(parent.userIndex) !== ""
                  ? carousel.lastNameAt(parent.userIndex).toUpperCase()
                  : "\u00A0"
            color: carousel.textMuted
            font.pixelSize: 14
            font.weight: Font.Medium
            font.letterSpacing: 3
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: carousel.prevRequested()
        }
    }

    Item {
        width: Math.max(currentUserFirstName.width, currentUserLastName.width,
                         lastSignedInRow.width, currentUserModelText.width)
        height: currentUserFirstName.height + currentUserLastName.height
                + 6 + lastSignedInRow.height + 4 + currentUserModelText.height
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: currentUserFirstName
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.displayNameAt(carousel.currentIndex) !== ""
                  ? carousel.firstNameAt(carousel.currentIndex).toUpperCase()
                  : "USER"

            color: carousel.textMain
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.letterSpacing: 6

            layer.enabled: true
            layer.effect: Glow {
                radius: 12
                samples: 18
                color: carousel.accentColor
                spread: 0.3
                opacity: carousel.authState === "authenticating" ? 0.75
                         : (carousel.authState === "success" ? 1.0 : 0.4)

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }
            }
        }

        Text {
            id: currentUserLastName
            anchors.top: currentUserFirstName.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.lastNameAt(carousel.currentIndex) !== ""
                  ? carousel.lastNameAt(carousel.currentIndex).toUpperCase()
                  : "\u00A0"

            color: carousel.textMain
            font.pixelSize: 27
            font.weight: Font.DemiBold
            font.letterSpacing: 6

            layer.enabled: true
            layer.effect: Glow {
                radius: 12
                samples: 18
                color: carousel.accentColor
                spread: 0.3
                opacity: carousel.authState === "authenticating" ? 0.75
                         : (carousel.authState === "success" ? 1.0 : 0.4)

                Behavior on opacity {
                    NumberAnimation { duration: 250 }
                }
            }
        }

        Row {
            id: lastSignedInRow
            anchors.top: currentUserLastName.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            opacity: carousel.currentIndex === carousel.lastIndex ? 1.0 : 0.0

            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: carousel.cyan
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "LAST SIGNED IN"

                color: carousel.textMuted
                font.pixelSize: 9
                font.letterSpacing: 2.4
            }
        }

        Text {
            id: currentUserModelText
            anchors.top: lastSignedInRow.bottom
            anchors.topMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.modelText

            color: carousel.textMuted
            font.pixelSize: 9
            font.letterSpacing: 1.6
            opacity: 0.8
        }
    }

    Item {
        width: Math.max(nextFirstName.width, nextLastName.width)
        height: nextFirstName.height + nextLastName.height + 2
        visible: carousel.userCount > 2
        opacity: 0.55
        anchors.verticalCenter: parent.verticalCenter

        property int userIndex: (carousel.currentIndex + 1) % carousel.userCount

        Text {
            id: nextFirstName
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.firstNameAt(parent.userIndex).toUpperCase()
            color: carousel.textMuted
            font.pixelSize: 14
            font.weight: Font.Medium
            font.letterSpacing: 3
        }

        Text {
            id: nextLastName
            anchors.top: nextFirstName.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: parent.horizontalCenter
            text: carousel.lastNameAt(parent.userIndex) !== ""
                  ? carousel.lastNameAt(parent.userIndex).toUpperCase()
                  : "\u00A0"
            color: carousel.textMuted
            font.pixelSize: 14
            font.weight: Font.Medium
            font.letterSpacing: 3
        }

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: carousel.nextRequested()
        }
    }

    Text {
        text: "›"
        visible: carousel.userCount > 1
        color: carousel.cyanSoft
        font.pixelSize: 22
        anchors.verticalCenter: parent.verticalCenter
        opacity: nextMouse.containsMouse ? 1.0 : 0.5

        MouseArea {
            id: nextMouse
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: carousel.nextRequested()
        }
    }
}
