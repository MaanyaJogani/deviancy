import QtQuick 2.15
import QtGraphicalEffects 1.15

// Self-contained clock block: LOCAL TIME label, glowing LED-style clock with
// its own periodic random flicker, and the weekday/date readout. Call
// flicker() to trigger one extra flash on demand (e.g. on successful login).
Column {
    id: clockPanel

    property color textMain: "#edf6fb"
    property color textMuted: "#93aab5"
    property color cyan: "#5dd8ff"
    property color cyanSoft: "#7ab8c9"
    property color line: "#24414f"

    spacing: 0

    function flicker() {
        clockFlicker.start()
    }

    Row {
        spacing: 8

        Rectangle {
            width: 5
            height: 5
            radius: 2.5
            color: clockPanel.cyan
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: "LOCAL TIME"

            color: clockPanel.textMuted
            font.pixelSize: 9
            font.letterSpacing: 3
        }
    }

    Item {
        width: 1
        height: 10
    }

    Row {
        spacing: 12

        Text {
            id: clock
            text: Qt.formatTime(new Date(), "hh:mm")

            color: clockPanel.textMain
            font.pixelSize: 92
            font.weight: Font.Light
            font.letterSpacing: 1

            layer.enabled: true
            layer.effect: Glow {
                radius: 16
                samples: 24
                color: clockPanel.cyan
                spread: 0.25
                opacity: 0.35
            }

            SequentialAnimation {
                id: clockFlicker

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 0.05
                    duration: 40
                }

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 1.0
                    duration: 50
                }

                PauseAnimation {
                    duration: 70
                }

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 0.1
                    duration: 30
                }

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 1.0
                    duration: 40
                }

                PauseAnimation {
                    duration: 60
                }

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 0.15
                    duration: 25
                }

                NumberAnimation {
                    target: clock
                    property: "opacity"
                    to: 1.0
                    duration: 90
                }
            }
        }

        Text {
            id: seconds
            text: Qt.formatTime(new Date(), "ss")

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15

            color: clockPanel.cyanSoft
            font.pixelSize: 20
            font.letterSpacing: 2
        }
    }

    Item {
        width: 1
        height: 16
    }

    Row {
        spacing: 0

        Rectangle {
            width: 6
            height: 40
            color: clockPanel.cyan
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: 12
            height: 1
        }

        Column {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: weekdayText
                text: Qt.formatDate(new Date(), "dddd").toUpperCase()

                color: clockPanel.textMuted
                font.pixelSize: 13
                font.weight: Font.Medium
                font.letterSpacing: 3
            }

            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "dd MMMM yyyy").toUpperCase()

                color: "#8edff5"
                font.pixelSize: 17
                font.weight: Font.Medium
                font.letterSpacing: 3
            }
        }
    }

    Item {
        width: 1
        height: 15
    }

    Rectangle {
        width: parent.width
        height: 1
        color: clockPanel.line
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "hh:mm")
            seconds.text = Qt.formatTime(new Date(), "ss")
            weekdayText.text = Qt.formatDate(new Date(), "dddd").toUpperCase()
            dateText.text = Qt.formatDate(new Date(), "dd MMMM yyyy").toUpperCase()
        }
    }

    // Occasional tube-light style flicker, simulating a slightly faulty LED
    Timer {
        interval: 5000 + Math.random() * 5000
        running: true
        repeat: true

        onTriggered: {
            clockFlicker.start()
            interval = 5000 + Math.random() * 5000
        }
    }
}
