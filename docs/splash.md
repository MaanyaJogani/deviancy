# Plasma splash guide

[Back to the README](../README.md) · [SDDM guide](sddm.md) · [Customization](customization.md)

Install Deviancy's matching session-loading splash. Run commands from the
repository root after cloning the repository.

## Requirements and compatibility

- KDE Plasma 6 with `ksplashqml`.
- Qt 6 `QtQuick` and `Qt5Compat.GraphicalEffects`.
- `kwriteconfig6` for the optional command-line activation method.

The splash package currently contains legacy `metadata.desktop` metadata.
Package discovery and real session behavior should be checked on the target
Plasma release before claiming compatibility with that release.

## Appearance and stage behavior

A matching splash screen lives in `splash/`. It continues the greeter's visual
style after login with **SIGNATURE ACCEPTED / RESTORING PRESENCE**, a
restoration checklist, a sweeping band, and a glowing **WELCOME HOME** greeting.
This is a Plasma session-loading splash, not a boot splash or lock screen.

The checklist responds to the stage value supplied by KSplash. Its labels are
decorative narrative, not individual system checks. The 20-cell progress bar
maps the stage to a percentage using `stage / 7`, with animated transitions;
it does not measure elapsed time or completed work. WELCOME HOME starts at
stage 5, and the code targets 100% at stage 7. Stage sequences and splash
lifetime depend on Plasma; the full greeting animation and 100% display are
not guaranteed before the splash closes.

## Install and activate

From the repository root:

```bash
mkdir -p "$HOME/.local/share/plasma/look-and-feel/deviancy-splash"
cp -a splash/. "$HOME/.local/share/plasma/look-and-feel/deviancy-splash/"
```

The same copy command updates an existing installation without creating a
nested `splash/` directory.

Select **Deviancy Splash** in System Settings by searching for **Splash Screen**,
or configure KSplash directly:

```bash
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML
kwriteconfig6 --file ksplashrc --group KSplash --key Theme deviancy-splash
```

The splash applies at the next Plasma session login. The greeter and splash
are installed separately.

## Preview without installing

From the repository root, without installing:

```bash
ksplashqml --test --window "$PWD/splash"
```

KSplash test mode supplies preview stages; it does not reproduce real login
timing. The [README gallery](../README.md#preview) shows the SDDM greeter.

## Troubleshooting and reverting

If the splash does not appear, check that
`~/.local/share/plasma/look-and-feel/deviancy-splash/` contains
`metadata.desktop` and `contents/splash/Splash.qml` directly. Run the preview
command and inspect its output for missing QML modules or package-loading errors.
Changing the SDDM theme does not activate the splash.

To revert, select your previous splash in System Settings. The current package
uses `metadata.desktop`; if your Plasma release cannot discover it, package
metadata compatibility needs investigation before assuming the QML is at fault.
