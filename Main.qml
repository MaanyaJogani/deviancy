import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import "components"

Item {
    id: root

    width: 1600
    height: 900

    property color bg: "#05090f"
    property color panel: "#0a1119"
    property color cyan: "#5dd8ff"
    property color cyanSoft: "#7ab8c9"
    property color textMain: "#edf6fb"
    property color textMuted: "#93aab5"
    property color line: "#24414f"
    property color amber: "#6fdcff"

    property string statusMessage: "SYSTEM READY"
    property int currentUserIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    property var userDisplayNames: []
    property var userLoginNames: []
    property string selectedUser: userLoginNames.length > currentUserIndex
                                   ? userLoginNames[currentUserIndex]
                                   : userModel.lastUser

    // --- Authentication state machine -------------------------------
    // "idle" | "authenticating" | "success" | "failed"
    property string authState: "idle"
    property string authOverlayText: ""
    property real authProgress: 0.0
    property string pendingResult: ""
    property real chromeOpacity: 1.0
    property real scanTargetX: width / 2
    property real scanTargetY: height / 2
    property real statusPulseOpacity: 1.0
    property real verifyStartTime: 0
    readonly property int verifyMinDuration: 650
    readonly property int verifyScriptedDuration: 1100

    // Desaturated warning red used in place of cyan while authState is
    // "failed"; everything reverts to cyan automatically once idle again.
    property color accentColor: authState === "failed" ? "#c98a7a" : root.cyan

    function displayNameAt(i) {
        return i >= 0 && i < userDisplayNames.length ? userDisplayNames[i] : ""
    }

    function firstNameAt(i) {
        var full = displayNameAt(i)
        return full === "" ? "" : full.split(" ")[0]
    }

    function lastNameAt(i) {
        var full = displayNameAt(i)
        var parts = full.split(" ")
        return parts.length > 1 ? parts.slice(1).join(" ") : ""
    }

    // Deterministic pseudo-random android model/serial per account, purely
    // cosmetic. Same user always gets the same code within a session.
    function hashString(s) {
        var h = 0
        for (var i = 0; i < s.length; i++) {
            h = (h * 31 + s.charCodeAt(i)) >>> 0
        }
        return h
    }

    function modelInfoFor(loginName) {
        if (loginName === "") return ""

        var models = ["RK800", "RK900", "ST200", "WR400", "PL600", "YK500", "AX400", "HK400"]
        var h = hashString(loginName)

        var model = models[h % models.length]
        var s1 = 100 + (h % 900)
        var s2 = 100 + (Math.floor(h / 7) % 900)
        var s3 = 100 + (Math.floor(h / 53) % 900)
        var s4 = 10 + (Math.floor(h / 131) % 90)

        return "MODEL " + model + " · #" + s1 + " " + s2 + " " + s3 + "-" + s4
    }

    function prevUser() {
        if (userModel.count <= 1) return
        currentUserIndex = (currentUserIndex - 1 + userModel.count) % userModel.count
    }

    function nextUser() {
        if (userModel.count <= 1) return
        currentUserIndex = (currentUserIndex + 1) % userModel.count
    }

    // Off-screen collector: reads role data from userModel via a Repeater
    // (roles are only exposed to delegates), and stores it into plain JS
    // arrays so the carousel below can index into it freely.
    Repeater {
        model: userModel

        Item {
            visible: false

            Component.onCompleted: {
                var names = root.userDisplayNames.slice()
                names[index] = (realName && realName.length > 0) ? realName : name
                root.userDisplayNames = names

                var logins = root.userLoginNames.slice()
                logins[index] = name
                root.userLoginNames = logins
            }
        }
    }

    Background {
        anchors.fill: parent
        bg: root.bg
    }

    // Foreground UI chrome, grouped so it can fade out as one unit on
    // successful login while the background photo stays visible a moment
    // longer (see beginFadeOut()).
    Item {
        id: uiChrome
        anchors.fill: parent
        opacity: root.chromeOpacity

    HudDecor {
        anchors.fill: parent
        cyan: root.cyan
        textMuted: root.textMuted
    }

    ScanlineOverlay {
        id: scanOverlay
        anchors.fill: parent
        color: root.accentColor
        converge: root.authState === "authenticating"
        targetX: root.scanTargetX
        targetY: root.scanTargetY
    }

    Column {
        id: loginColumn

        x: parent.width * 0.12
        y: parent.height * 0.15
        width: Math.min(parent.width * 0.38, 560)
        spacing: 0

        ClockPanel {
            id: clockPanel
            width: parent.width

            textMain: root.textMain
            textMuted: root.textMuted
            cyan: root.cyan
            cyanSoft: root.cyanSoft
            line: root.line
        }

        Item {
            width: 1
            height: 55
        }

        UserCarousel {
            id: userCarousel
            anchors.horizontalCenter: userModel.count > 1 ? parent.horizontalCenter : undefined

            currentIndex: root.currentUserIndex
            userCount: userModel.count
            lastIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            modelText: root.modelInfoFor(
                           root.userLoginNames.length > root.currentUserIndex
                           ? root.userLoginNames[root.currentUserIndex]
                           : ""
                       )

            displayNameAt: root.displayNameAt
            firstNameAt: root.firstNameAt
            lastNameAt: root.lastNameAt

            authState: root.authState
            accentColor: root.accentColor
            cyan: root.cyan
            cyanSoft: root.cyanSoft
            textMain: root.textMain
            textMuted: root.textMuted

            onPrevRequested: root.prevUser()
            onNextRequested: root.nextUser()
        }

        Item {
            width: 1
            height: 20
        }

        Row {
            spacing: 9

            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: root.accentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.authState === "authenticating" ? "IDENTITY VERIFICATION IN PROGRESS"
                      : root.authState === "success" ? "IDENTITY CONFIRMED"
                      : root.authState === "failed" ? "ACCESS DENIED"
                      : "IDENTIFICATION REQUIRED"

                color: root.authState === "failed" ? root.accentColor : root.textMuted
                font.pixelSize: 10
                font.letterSpacing: 2.4
            }
        }

        Item {
            width: 1
            height: 42
        }

        Text {
            text: !passwordField.fieldFocused
                  ? "ACCESS KEY"
                  : (passwordField.text.length === 0
                     ? "ACCESS KEY // AWAITING INPUT"
                     : "ACCESS KEY // RECEIVING")

            color: root.textMuted
            font.pixelSize: 10
            font.letterSpacing: 2.5
        }

        Item {
            width: 1
            height: 10
        }

        PasswordField {
            id: passwordField
            width: parent.width

            accentColor: root.accentColor
            line: root.line

            onAccepted: login()
        }

        Item {
            width: 1
            height: 30
        }

        AuthenticateButton {
            id: loginButton

            authState: root.authState
            authProgress: root.authProgress
            accentColor: root.accentColor
            cyan: root.cyan
            cyanSoft: root.cyanSoft

            onClicked: login()
        }

        Item {
            width: 1
            height: 18
        }

        Row {
            spacing: 10

            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: root.authState === "failed" ? root.accentColor : root.cyan

                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: statusText
                text: root.authOverlayText !== "" ? root.authOverlayText : statusMessage
                opacity: root.statusPulseOpacity

                color: root.textMuted
                font.pixelSize: 9
                font.letterSpacing: 2.4
            }
        }
    }

    } // end uiChrome

    // Occasional brief glitch on the idle status line
    Timer {
        interval: 9000 + Math.random() * 6000
        running: true
        repeat: true

        onTriggered: {
            if (root.authState === "idle" && statusMessage === "SYSTEM READY") {
                root.authOverlayText = "SOFTWARE INSTABILITY ///"
                glitchRevert.start()
            }

            interval = 9000 + Math.random() * 6000
        }
    }

    Timer {
        id: glitchRevert
        interval: 180

        onTriggered: root.authOverlayText = ""
    }

    function login() {
        if (root.authState === "authenticating") return

        var username = root.selectedUser

        if (username === "") {
            statusMessage = "NO USER SELECTED"
            return
        }

        startAuthSequence()

        var sessionIndex = sessionModel.lastIndex >= 0
                           ? sessionModel.lastIndex
                           : 0

        sddm.login(username, passwordField.text, sessionIndex)

        // TEMPORARY, TEST-MODE ONLY: sddm-greeter --test-mode has no real
        // daemon to respond, so onLoginSucceeded/onLoginFailed never fire.
        // This simulates a response so the animation branches can be
        // reviewed. REMOVE this block (and debugSimulateAuth) before
        // installing the theme for real use — the real greeter fires the
        // actual signals below on its own.
        if (root.debugSimulateAuth) {
            debugAuthSimTimer.restart()
        }
    }

    property bool debugSimulateAuth: false

    Timer {
        id: debugAuthSimTimer
        interval: 500
        repeat: false

        onTriggered: {
            root.pendingResult = (root.selectedUser === "aarjav") ? "failed" : "success"
            if (root.minDurationElapsed) {
                root.finishVerification()
            }
        }
    }

    // --- Verification sequence --------------------------------------
    // Always calls the real sddm.login() first; this scripted sequence
    // only ever narrates "verification in progress." The final
    // success/failure state is gated on pendingResult, which is only set
    // once the real onLoginSucceeded/onLoginFailed signal arrives.
    property bool minDurationElapsed: false

    function startAuthSequence() {
        pendingResult = ""
        minDurationElapsed = false
        authProgress = 0
        authOverlayText = "PROFILE SIGNATURE ........ MATCHED"
        statusPulseOpacity = 1.0

        // Compute the scanline convergence target *before* flipping
        // authState, since the ScanlineOverlay's "converge" binding reacts
        // to authState immediately and needs the target already in place.
        var anchor = userCarousel.currentUserAnchor
        var target = anchor.mapToItem(root, anchor.width / 2, anchor.height / 2)
        scanTargetX = target.x
        scanTargetY = target.y

        authState = "authenticating"

        verifyMinTimer.restart()
        verifyProgressAnim.restart()
        verifyMessages.restart()
    }

    // Fires once the minimum "felt responsive" duration has elapsed; if a
    // real result already arrived by then, resolve immediately instead of
    // forcing the full scripted duration to play out.
    Timer {
        id: verifyMinTimer
        interval: root.verifyMinDuration
        repeat: false

        onTriggered: {
            root.minDurationElapsed = true
            if (root.pendingResult !== "") {
                root.finishVerification()
            }
        }
    }

    NumberAnimation {
        id: verifyProgressAnim
        target: root
        property: "authProgress"
        from: 0
        to: 0.9
        duration: root.verifyScriptedDuration
        easing.type: Easing.Linear
    }

    SequentialAnimation {
        id: verifyMessages

        ScriptAction { script: root.authOverlayText = "PROFILE SIGNATURE ........ MATCHED" }
        PauseAnimation { duration: 220 }
        ScriptAction { script: root.authOverlayText = "ACCESS KEY ............... VERIFIED" }
        PauseAnimation { duration: 220 }
        ScriptAction { script: root.authOverlayText = "SESSION INTEGRITY ........ STABLE" }
        PauseAnimation { duration: 220 }
        ScriptAction { script: root.authOverlayText = "ANDROID STATUS ........... NOMINAL" }
        PauseAnimation { duration: 220 }
        ScriptAction { script: root.verifyScriptedDone() }
    }

    // Gentle breathing pulse used only while waiting for a slower-than-usual
    // real response, so the "hold" never looks frozen.
    SequentialAnimation {
        id: verifyHoldPulse
        loops: Animation.Infinite

        NumberAnimation {
            target: root
            property: "statusPulseOpacity"
            to: 0.45
            duration: 550
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: root
            property: "statusPulseOpacity"
            to: 1.0
            duration: 550
            easing.type: Easing.InOutSine
        }
    }

    function verifyScriptedDone() {
        if (minDurationElapsed && pendingResult !== "") {
            finishVerification()
        } else {
            authOverlayText = "VERIFYING ..."
            verifyHoldPulse.start()
        }
    }

    function finishVerification() {
        verifyMessages.stop()
        verifyProgressAnim.stop()
        verifyHoldPulse.stop()
        statusPulseOpacity = 1.0

        if (pendingResult === "success") {
            playSuccess()
        } else if (pendingResult === "failed") {
            playFailure()
        }
    }

    function playSuccess() {
        authState = "success"
        authProgress = 1.0
        clockPanel.flicker()
        successSequence.restart()
    }

    SequentialAnimation {
        id: successSequence

        ScriptAction { script: root.authOverlayText = "IDENTITY CONFIRMED" }
        PauseAnimation { duration: 260 }
        ScriptAction {
            script: root.authOverlayText = "WELCOME BACK, "
                    + root.firstNameAt(root.currentUserIndex).toUpperCase()
        }
        PauseAnimation { duration: 380 }
        ScriptAction { script: root.authOverlayText = "SESSION 01 // AUTHORIZED" }
        PauseAnimation { duration: 300 }
        ScriptAction { script: root.beginFadeOut() }
    }

    function beginFadeOut() {
        fadeOutAnim.start()
    }

    NumberAnimation {
        id: fadeOutAnim
        target: root
        property: "chromeOpacity"
        to: 0.0
        duration: 500
        easing.type: Easing.OutQuad
    }

    function playFailure() {
        authState = "failed"
        authProgress = 0
        authOverlayText = "ACCESS DENIED // INVALID KEY"
        passwordField.text = ""
        failureGlitch.restart()
        failureRevertTimer.restart()
    }

    // Small, localized signal-disruption jitter on the underline — not a
    // full-screen shake
    SequentialAnimation {
        id: failureGlitch

        NumberAnimation { target: passwordField.underline; property: "opacity"; to: 0.2; duration: 40 }
        NumberAnimation { target: passwordField.underline; property: "opacity"; to: 1.0; duration: 40 }
        NumberAnimation { target: passwordField.underline; property: "opacity"; to: 0.3; duration: 40 }
        NumberAnimation { target: passwordField.underline; property: "opacity"; to: 1.0; duration: 60 }
    }

    Timer {
        id: failureRevertTimer
        interval: 1000
        repeat: false
        onTriggered: root.revertToIdle()
    }

    function revertToIdle() {
        authState = "idle"
        authOverlayText = ""
        authProgress = 0
        pendingResult = ""
        minDurationElapsed = false

        passwordField.forceActiveFocus()
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.pendingResult = "failed"
            if (root.minDurationElapsed) {
                root.finishVerification()
            }
        }

        function onLoginSucceeded() {
            root.pendingResult = "success"
            if (root.minDurationElapsed) {
                root.finishVerification()
            }
        }
    }

    // Defense in depth: force-hide the virtual keyboard input panel if
    // anything ever tries to auto-show it (e.g. InputMethod=qtvirtualkeyboard
    // being enabled at the SDDM level). This theme has no on-screen keyboard
    // UI, so the panel should never be visible.
    Connections {
        target: Qt.inputMethod

        function onVisibleChanged() {
            if (Qt.inputMethod.visible) {
                Qt.inputMethod.hide()
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}