# SDDM greeter guide

[Back to the README](../README.md) · [Splash guide](splash.md) · [Customization](customization.md)

Install and preview the Deviancy login theme, and understand how it uses SDDM
for account selection and authentication. Run commands from the repository root.

## Requirements

- An SDDM installation capable of running Qt 6 themes. The theme metadata
  declares `QtVersion=6` and `Theme-API=2.0`.
- Qt 6 QML modules: `QtQuick`, `QtQuick.Controls`, and
  `Qt5Compat.GraphicalEffects` from Qt 6's Qt5Compat module.
- A physical keyboard. The theme hides the virtual keyboard.
- Plasma is optional for the greeter.

The committed theme targets Qt 6; the `2.15` import versions in some QML files
do not imply Qt 5 compatibility. Distribution package names vary.

## Install and activate

Preview the theme first. Keep a record of your current SDDM theme so you can
switch back if needed.

```bash
# Install or update without creating a nested sddm/ directory
sudo mkdir -p /usr/share/sddm/themes/deviancy
sudo cp -a sddm/. /usr/share/sddm/themes/deviancy/

# Create the configuration directory if needed
sudo mkdir -p /etc/sddm.conf.d

# Activate it
sudo tee /etc/sddm.conf.d/theme.conf << 'EOF'
[Theme]
Current=deviancy
EOF

# (Optional) disable the Qt virtual keyboard globally
sudo tee /etc/sddm.conf.d/10-no-virtual-keyboard.conf << 'EOF'
[General]
InputMethod=
EOF
```

Save your work before restarting SDDM; this ends the current graphical session.
Alternatively, reboot when convenient. Check for conflicting `Current=` entries
in other SDDM configuration files if the theme does not change.

To restart:

```bash
sudo systemctl restart sddm
```

## Preview without installing

```bash
sddm-greeter --test-mode --theme "$PWD/sddm"
```

Use your distribution's Qt 6 greeter executable. It may be named
`sddm-greeter-qt6` instead of `sddm-greeter`.

Test mode previews the interface without a real authentication exchange.
`debugSimulateAuth` in `sddm/Main.qml` defaults to `false`, so clicking
AUTHENTICATE can remain in verification during a preview. For animation
development only, a disposable local copy can set it to `true`: the included
simulator returns failure for the username `aarjav` and success for other
selected users. Keep it disabled in any installed theme.

## Greeter behavior

- Accounts come from SDDM's user model. The carousel initially selects the last
  user when available; displayed model and serial codes are cosmetic.
- Login uses `sessionModel.lastIndex`, falling back to index `0`. There is
  currently no session picker, manual username field, or power menu.
- Press Enter in the password field or click AUTHENTICATE to submit.
  A failed login clears the password and returns to idle after one second.
- Password cells show input length up to 22 visible cells. This is a display
  cap, not a configured 22-character password limit.
- Verification messages and progress are scripted visuals. With simulation
  disabled, final success or failure comes from SDDM's authentication signals.
  The theme does not hold the session open until its success animation ends.
- The theme always hides `Qt.inputMethod`; enabling SDDM's virtual keyboard
  alone does not provide an on-screen keyboard in this theme.

## Troubleshooting and reverting

- **Missing QML module:** check that the greeter uses Qt 6 and that the Qt 6
  modules listed above are installed. Qt 5 GraphicalEffects is a different module.
- **Preview stays on verification:** with the simulator disabled, test mode
  has no real authentication result. See the preview instructions above.
- **Theme does not change:** check the installed directory contains `Main.qml`
  directly, rather than a nested `sddm/` folder, and inspect conflicting
  `[Theme]` / `Current=` settings in SDDM configuration files.
- **Need another session or an on-screen keyboard:** the current theme provides
  neither a session picker nor a virtual keyboard. Use a suitable alternate
  greeter when those controls are needed.

To revert, restore your previous SDDM theme configuration. If you created
`/etc/sddm.conf.d/theme.conf` only for Deviancy, remove that file or change its
`Current=` value to your previous installed theme. Restore any existing file
that you replaced during installation. Restart SDDM only after saving your work,
or reboot when convenient.
