import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

// Password entry rendered as small glowing cyan cell blocks rather than an
// ordinary text field, with a brightened, subtly-pulsing underline while
// focused. The real TextField underneath is fully functional but invisible;
// everything here is a visual readout of its length/focus state.
Item {
    id: pwField

    height: 46

    property alias text: input.text
    readonly property alias fieldFocused: input.activeFocus
    property color accentColor: "#5dd8ff"
    property color line: "#24414f"

    // Exposed so Main.qml's failure glitch animation can target it directly
    property alias underline: passwordUnderline

    signal accepted()

    function clear() {
        input.text = ""
    }

    function forceActiveFocus() {
        input.forceActiveFocus()
    }

    property int maxCells: 22
    property int cellCount: Math.min(input.text.length + 1, maxCells)

    // Slow, steady glow pulse shared by the "next" (cursor) cell
    property real cursorBlink: 1.0

    SequentialAnimation on cursorBlink {
        loops: Animation.Infinite

        NumberAnimation {
            from: 1.0
            to: 0.15
            duration: 500
        }

        NumberAnimation {
            from: 0.15
            to: 1.0
            duration: 500
        }
    }

    // Actual input handling — kept fully functional but invisible; the cell
    // row below is a purely visual readout of its length.
    TextField {
        id: input
        anchors.fill: parent

        echoMode: TextInput.Password
        passwordMaskDelay: 0
        cursorVisible: false

        color: "transparent"
        selectionColor: "transparent"
        selectedTextColor: "transparent"

        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        background: Item {}

        Keys.onReturnPressed: pwField.accepted()
        Keys.onEnterPressed: pwField.accepted()
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: pwField.cellCount

            Rectangle {
                width: 14
                height: 30
                radius: 2

                property bool filled: index < input.text.length
                property bool isCursor: index === input.text.length && input.activeFocus

                color: filled ? "#173042" : "transparent"
                border.width: 1
                border.color: filled || isCursor ? pwField.accentColor : pwField.line
                opacity: isCursor ? pwField.cursorBlink : 1.0

                layer.enabled: filled || isCursor
                layer.effect: Glow {
                    radius: 6
                    samples: 12
                    color: pwField.accentColor
                    spread: isCursor ? 0.3 : 0.2
                    opacity: isCursor ? 0.6 : 0.5
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    Rectangle {
        id: passwordUnderline
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true

        height: input.activeFocus ? 2 : 1
        color: input.activeFocus ? pwField.accentColor : pwField.line

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        Behavior on height {
            NumberAnimation { duration: 150 }
        }

        // Subtle traveling highlight while focused, in addition to the
        // brightened base line above
        Rectangle {
            id: underlineScan
            visible: input.activeFocus
            width: 60
            height: parent.height
            x: -width
            opacity: 0.55

            gradient: Gradient {
                orientation: Gradient.Horizontal

                GradientStop { position: 0.0; color: "#00c8f5ff" }
                GradientStop { position: 0.5; color: pwField.accentColor }
                GradientStop { position: 1.0; color: "#00c8f5ff" }
            }

            SequentialAnimation {
                running: input.activeFocus
                loops: Animation.Infinite

                NumberAnimation {
                    target: underlineScan
                    property: "x"
                    from: -60
                    to: pwField.width + 60
                    duration: 1700
                    easing.type: Easing.InOutSine
                }

                PauseAnimation {
                    duration: 450
                }
            }
        }
    }
}
