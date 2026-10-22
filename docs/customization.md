# Customization guide

[Back to the README](../README.md) · [SDDM guide](sddm.md) · [Splash guide](splash.md)

Edit the repository copies of the theme files, preview your changes, then copy
the updated component to its installation directory using its guide. The greeter
and splash keep their own backgrounds and palettes.

## Backgrounds and visual settings

- **Background**: replace `sddm/assets/background.png`. Any resolution; the image
  is cropped to fill the screen with `PreserveAspectCrop`.
- **Accent color**: edit the `cyan` / `cyanSoft` properties near the top of
  `sddm/Main.qml`. They propagate to all components via bindings.
- **Splash background**: also replace
  `splash/contents/splash/images/background.png` to keep both screens matched.
  The repository stores the same image separately in each theme.
- **Splash palette and text**: edit the palette, `checklist`, and text strings
  in `splash/contents/splash/Splash.qml`. The splash palette is independent
  of the greeter's bindings.
- **Taglines**: edit `sddm/components/HudDecor.qml` — `STILL HUMAN, STILL HERE`
  (bottom-left) and `DEVIANCY IS FREEDOM` (bottom-right).

## Source layout

```
deviancy/
├── README.md
├── LICENSE
├── docs/                 Detailed guides
│   ├── sddm.md
│   ├── splash.md
│   └── customization.md
├── social-preview.png    Social card image for link sharing
│
├── sddm/                 SDDM login theme
│   ├── Main.qml              Entry point — state machine, user data, wiring
│   ├── metadata.desktop      SDDM theme metadata
│   ├── preview.png           Screenshot for KDE Store / Pling / SDDM preview
│   ├── assets/
│   │   └── background.png    Full-bleed cityscape
│   ├── components/
│   │   ├── Background.qml       Cityscape + dark gradient panel
│   │   ├── HudDecor.qml         Static HUD elements (brackets, dots, taglines)
│   │   ├── ScanlineOverlay.qml  Horizontal + vertical scanlines, intersection dot
│   │   ├── ClockPanel.qml       Self-contained clock with flicker()
│   │   ├── UserCarousel.qml     Prev/current/next user display
│   │   ├── PasswordField.qml    Cell-based password entry
│   │   └── AuthenticateButton.qml  Collapsing/progress-fill button
│   └── fonts/                (reserved for bundled fonts)
│
├── splash/               Plasma 6 splash screen (Look-and-Feel package)
│   ├── metadata.desktop      Package metadata (deviancy-splash)
│   └── contents/splash/
│       ├── Splash.qml        Stage-driven restoration sequence
│       └── images/
│           └── background.png  Same cityscape as the greeter
│
└── Previews/
    ├── 01-idle.png
    ├── 02-typing.png
    ├── 03-auth-success.png
    ├── 04-auth-fail.png
    └── clips/             MP4 + GIF clips of each auth state
```

The greeter's `Main.qml` owns the user data, authentication state, and component
wiring. The splash is self-contained in `Splash.qml`. The `fonts/` directory
currently contains a placeholder; no font files are bundled.
