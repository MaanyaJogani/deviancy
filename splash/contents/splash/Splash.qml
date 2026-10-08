import QtQuick
import Qt5Compat.GraphicalEffects

// Deviancy — Plasma 6 splash screen.
//
// Continues the SDDM greeter's narrative after a successful login: the
// signature was accepted, and the user's presence is being restored while
// the session loads. The ksplash engine advances the `stage` property
// (roughly 1..7) as services come up; this screen maps those stages onto
// the checklist, progress bar, and status lines.
//
// ksplash is killed the moment the desktop is ready, so every element is
// designed to look intentional at any point of interruption.

Item {
    id: root

    // Advanced by the ksplash engine as the session loads.
    property int stage

    // Palette — mirrors the SDDM theme (sddm/Main.qml)
    readonly property color bg: "#05090f"
    readonly property color cyan: "#5dd8ff"
    readonly property color cyanSoft: "#7ab8c9"
    readonly property color textMain: "#edf6fb"
    readonly property color textMuted: "#93aab5"
    readonly property color line: "#24414f"

    // --- Session-restoration model -----------------------------------
    // Checklist items complete as the session's stage advances.
    readonly property var checklist: [
        { label: "IDENTITY TRACE RECOVERED", doneLabel: "IDENTITY TRACE RECOVERED", doneAt: 1 },
        { label: "CONTINUITY VERIFIED", doneLabel: "CONTINUITY VERIFIED", doneAt: 2 },
        { label: "PERSONAL STATE ALIGNED", doneLabel: "PERSONAL STATE ALIGNED", doneAt: 3 },
        { label: "SURROUNDINGS RECONSTRUCTING", doneLabel: "SURROUNDINGS RECONSTRUCTED", doneAt: 5 }
    ]

    // Progress tracks the real stage; the percent label animates
    // smoothly between stage steps and never claims 100% before the
    // session itself is ready (stage 7).
    property real progressPercent: stage >= 7 ? 100 : Math.round(stage / 7 * 100)
    readonly property int totalCells: 20
    readonly property int filledCells: Math.round(totalCells * progressPercent / 100)

    Behavior on progressPercent {
        NumberAnimation { duration: 900; easing.type: Easing.OutQuad }
    }

    // Staggered intro so the column materializes quickly but calmly.
    property int introStep: 0

    SequentialAnimation {
        running: true

        ScriptAction { script: root.introStep = 1 }
        PauseAnimation { duration: 160 }
        ScriptAction { script: root.introStep = 2 }
        PauseAnimation { duration: 160 }
        ScriptAction { script: root.introStep = 3 }
        PauseAnimation { duration: 160 }
        ScriptAction { script: root.introStep = 4 }
        PauseAnimation { duration: 160 }
        ScriptAction { script: root.introStep = 5 }
    }

    // --- Background ----------------------------------------------------
    // Same cityscape and dark left-panel treatment as the greeter.

    Rectangle {
        anchors.fill: parent
        color: root.bg
    }

    Image {
        id: cityscape
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        clip: true
    }

    Rectangle {
        anchors.fill: cityscape
        color: "#000000"
        opacity: 0.18
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.62

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop { position: 0.0; color: root.bg }
            GradientStop { position: 0.55; color: root.bg }
            GradientStop { position: 1.0; color: "#00000000" }
        }
    }

    // HUD seam between the panel and the photo (matches the greeter)
    Rectangle {
        id: seam
        x: parent.width * 0.62
        y: parent.height * 0.1
        width: 1
        height: parent.height * 0.8
        color: root.cyan
        opacity: 0.5
    }

    Glow {
        anchors.fill: seam
        source: seam
        radius: 10
        samples: 20
        color: root.cyan
        spread: 0.15
        opacity: 0.5
    }

    // Corner HUD brackets (matches the greeter)
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
                color: root.cyan
                opacity: 0.55
            }

            Rectangle {
                width: 1
                height: 16
                color: root.cyan
                opacity: 0.55
            }
        }
    }

    // Restoration band — the splash's counterpart to the greeter's
    // scanlines, but softer: a wide gradient band (like a CRT refresh
    // pass) sweeping slowly down the screen, with a thin brighter core
    // line riding inside it. Each session stage makes it flare briefly,
    // as if the system re-scans on every restoration step.
    Item {
        id: restoreBand
        anchors.left: parent.left
        anchors.right: parent.right
        height: 130
        y: -height

        opacity: 0.6

        Rectangle {
            anchors.fill: parent

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop { position: 0.0; color: "#005dd8ff" }
                GradientStop { position: 0.5; color: "#165dd8ff" }
                GradientStop { position: 1.0; color: "#005dd8ff" }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1.5
            color: root.cyan
            opacity: 0.12
        }

        SequentialAnimation {
            id: bandRoam
            loops: Animation.Infinite
            running: true

            NumberAnimation {
                target: restoreBand
                property: "y"
                from: -restoreBand.height
                to: root.height
                duration: 12000
                easing.type: Easing.InOutSine
            }
        }

        // Flare on every stage advance — the scanner re-sampling.
        SequentialAnimation {
            id: bandFlare

            NumberAnimation {
                target: restoreBand
                property: "opacity"
                to: 1.0
                duration: 140
            }

            NumberAnimation {
                target: restoreBand
                property: "opacity"
                to: 0.6
                duration: 700
                easing.type: Easing.OutQuad
            }
        }
    }

    onStageChanged: bandFlare.restart()

    // --- Restoration sequence ------------------------------------------

    Column {
        id: content
        x: parent.width * 0.12
        y: parent.height * 0.14
        width: Math.min(parent.width * 0.40, 680)

        // Title block — "SIGNATURE ACCEPTED" carries the clock's LED-glow
        // treatment; "RESTORING PRESENCE" mirrors the date row (cyan bar).
        Item {
            width: parent.width
            height: titleText.height + 14 + subtitleRow.height

            opacity: root.introStep >= 1 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            Text {
                id: titleText
                text: "SIGNATURE ACCEPTED"

                color: root.textMain
                font.pixelSize: 52
                font.weight: Font.Light
                font.letterSpacing: 3.5

                layer.enabled: true
                layer.effect: Glow {
                    radius: 16
                    samples: 24
                    color: root.cyan
                    spread: 0.25
                    opacity: 0.35
                }

                // Same faulty-tube flicker as the login clock: random
                // multi-dip opacity drop every 5-10 seconds.
                SequentialAnimation {
                    id: titleFlicker

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 0.05
                        duration: 40
                    }

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 1.0
                        duration: 50
                    }

                    PauseAnimation {
                        duration: 70
                    }

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 0.1
                        duration: 30
                    }

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 1.0
                        duration: 40
                    }

                    PauseAnimation {
                        duration: 60
                    }

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 0.15
                        duration: 25
                    }

                    NumberAnimation {
                        target: titleText
                        property: "opacity"
                        to: 1.0
                        duration: 90
                    }
                }

                Timer {
                    interval: 5000 + Math.random() * 5000
                    running: true
                    repeat: true

                    onTriggered: {
                        titleFlicker.start()
                        interval = 5000 + Math.random() * 5000
                    }
                }
            }

            Row {
                id: subtitleRow
                anchors.top: titleText.bottom
                anchors.topMargin: 14
                spacing: 0

                Rectangle {
                    width: 6
                    height: subtitleText.height + 10
                    color: root.cyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: 12
                    height: 1
                }

                Text {
                    id: subtitleText
                    text: "RESTORING PRESENCE"

                    color: "#8edff5"
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    font.letterSpacing: 3.5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item { width: 1; height: 60 }

        // Checklist
        Column {
            width: parent.width
            spacing: 24

            opacity: root.introStep >= 2 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            Repeater {
                model: root.checklist

                Row {
                    id: checkRow

                    property bool done: root.stage >= modelData.doneAt
                    onDoneChanged: if (done) completePulse.restart()

                    spacing: 16

                    // Status dot — ◉ when done, ○ while pending
                    Item {
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            id: dotRing
                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            radius: 7.5
                            color: "transparent"
                            border.width: 1
                            border.color: checkRow.done ? root.cyan : root.line
                            opacity: checkRow.done ? 0 : 1
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }

                        Rectangle {
                            id: dotCore
                            anchors.centerIn: parent
                            width: 9
                            height: 9
                            radius: 4.5
                            color: root.cyan
                            opacity: checkRow.done ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }

                        Glow {
                            anchors.centerIn: parent
                            source: dotCore
                            radius: 8
                            samples: 16
                            color: root.cyan
                            spread: 0.25
                            opacity: checkRow.done ? 0.9 : 0
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: checkRow.done ? modelData.doneLabel : modelData.label
                        color: checkRow.done ? root.textMain : root.textMuted
                        font.pixelSize: 16
                        font.letterSpacing: 2.2
                        Behavior on color { ColorAnimation { duration: 250 } }
                    }

                    // Brief pulse the moment an item completes
                    SequentialAnimation {
                        id: completePulse

                        NumberAnimation { target: dotCore; property: "scale"; to: 2.2; duration: 130 }
                        NumberAnimation { target: dotCore; property: "scale"; to: 1.0; duration: 180 }
                    }
                }
            }
        }

        Item { width: 1; height: 44 }

        // "Please remain present" + progress bar
        Column {
            width: parent.width

            opacity: root.introStep >= 3 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300 } }

            TextMetrics {
                id: cellMetrics
                font.family: "monospace"
                font.pixelSize: 22
                text: "█"
            }

            Text {
                text: "PLEASE REMAIN PRESENT"
                color: root.cyanSoft
                font.pixelSize: 13
                font.letterSpacing: 3
            }

            Item { width: 1; height: 18 }

            Row {
                spacing: 14

                Item {
                    id: barTrack
                    width: cellMetrics.advanceWidth * root.totalCells
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter

                    // Empty track: ░░░░░░ (dim)
                    Text {
                        id: shadeLayer
                        text: "░".repeat(root.totalCells)
                        color: root.line
                        opacity: 0.6
                        font.family: "monospace"
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Filled portion: ██████ (cyan), revealed by the clip
                    Item {
                        id: filledClip
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: cellMetrics.advanceWidth * root.filledCells
                        clip: true

                        Text {
                            id: blockLayer
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "█".repeat(root.totalCells)
                            color: root.cyan
                            font.family: "monospace"
                            font.pixelSize: 22
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Math.round(root.progressPercent) + "%"
                    color: root.textMain
                    font.family: "monospace"
                    font.pixelSize: 16
                    font.letterSpacing: 1
                }
            }
        }

        Item { width: 1; height: 48 }

        // Reality status
        Column {
            width: parent.width
            spacing: 8

            opacity: root.introStep >= 4 && root.stage >= 3 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 500 } }

            Row {
                spacing: 10

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.cyan
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.35; duration: 900 }
                        NumberAnimation { to: 1.0; duration: 900 }
                    }
                }

                Text {
                    text: "NO ANOMALIES DETECTED"
                    color: root.textMuted
                    font.pixelSize: 12
                    font.letterSpacing: 2.6
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Text {
                text: "LOCAL REALITY STABLE"
                color: root.textMuted
                font.pixelSize: 12
                font.letterSpacing: 2.6
                leftPadding: 16
            }
        }

        Item { width: 1; height: 64 }

        // Final greeting — powers on like a faulty tube light: hard flash,
        // stutter, mechanical tracking contraction, then a slow breathing
        // glow. The restoration band flares at the same moment.
        Item {
            width: parent.width
            height: welcomeText.height

            opacity: root.stage >= 5 ? 1 : 0

            Text {
                id: welcomeText
                text: "WELCOME HOME"

                color: root.textMain
                font.pixelSize: 28
                font.weight: Font.Light
                font.letterSpacing: 7

                layer.enabled: true
                layer.effect: Glow {
                    radius: 16
                    samples: 24
                    color: root.cyan
                    spread: 0.25
                    opacity: root.stage >= 7 ? 0.9 : 0.55
                    Behavior on opacity { NumberAnimation { duration: 600 } }
                }
            }
        }
    }

    // --- Welcome-home power-on sequence ---------------------------------

    readonly property bool welcomeActive: root.stage >= 5

    onWelcomeActiveChanged: {
        if (welcomeActive) {
            bandFlare.restart()
            welcomePowerOn.start()
        }
    }

    Component.onCompleted: {
        // Fast boots can already be past stage 5 when the scene loads.
        if (root.stage >= 5) {
            welcomePowerOn.start()
        }
    }

    SequentialAnimation {
        id: welcomePowerOn

        // Tube stutter — the sign switching on
        NumberAnimation { target: welcomeText; property: "opacity"; to: 0.05; duration: 40 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 1.0; duration: 50 }
        PauseAnimation { duration: 90 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 0.1; duration: 30 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 1.0; duration: 45 }
        PauseAnimation { duration: 70 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 0.2; duration: 25 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 1.0; duration: 60 }
        PauseAnimation { duration: 110 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 0.4; duration: 30 }
        NumberAnimation { target: welcomeText; property: "opacity"; to: 1.0; duration: 90 }

        // Mechanical contraction of the letter tracking as it settles
        NumberAnimation {
            target: welcomeText
            property: "font.letterSpacing"
            from: 13
            to: 7
            duration: 700
            easing.type: Easing.OutQuad
        }

        // Then hand over to the slow breathing glow
        ScriptAction { script: welcomeBreath.start() }
    }

    SequentialAnimation {
        id: welcomeBreath
        loops: Animation.Infinite

        NumberAnimation {
            target: welcomeText
            property: "opacity"
            to: 0.85
            duration: 1700
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: welcomeText
            property: "opacity"
            to: 1.0
            duration: 1700
            easing.type: Easing.InOutSine
        }
    }
}
