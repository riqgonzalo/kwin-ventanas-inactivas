# Inactive Windows (Ventanas inactivas) — KWin effect for KDE Plasma 6

🇬🇧 English · [🇪🇸 Español](README.md)

**Makes only the windows you're not using transparent and darker.** The window you're working in always stays solid.

🌐 Project page: https://riqgonzalo.github.io/kwin-ventanas-inactivas/

**🙏 Using it? [Tell us your setup](https://github.com/riqgonzalo/kwin-ventanas-inactivas/issues/new?template=reporte.yml)** (Plasma version, Wayland/X11, distro).

## Why not KDE's built-in effects?

With *Translucency* and *Dim Inactive*, the focused window sometimes turns transparent or dark. That's because KDE briefly gives focus to windows you can't see: the screen-recording bridge (`xwaylandvideobridge`), a panel, a menu or a notification. Those effects then think your window is inactive.

**Inactive Windows** avoids this:

- Ignores panels, menus, notifications, the desktop and invisible helper windows (opacity 0 or tiny size). If focus jumps to one of them, your last focused window stays solid.
- Dialogs of the focused window, and the window that owns a dialog, also stay solid.
- Fullscreen windows are never touched.
- Recomputes every window from scratch on each focus change, so it never gets stuck in a wrong state.
- Does transparency and dimming in a single effect.

## Install

```bash
git clone https://github.com/riqgonzalo/kwin-ventanas-inactivas.git
cd kwin-ventanas-inactivas
./install.sh
```

The installer:

1. Checks you have KDE Plasma 6.
2. Copies the effect to the right folder for your version (`~/.local/share/kwin-wayland/effects/` and `kwin-x11` on Plasma 6.4+, `kwin` on older versions).
3. Backs up your config to `~/.config/kwinrc.antes-de-ventanas-inactivas`.
4. Disables *Dim Inactive* and *Translucency*'s inactive-window option so they don't stack, remembering how you had them.
5. Enables the effect and loads it immediately, no logout needed.

No root needed. Also works on immutable distros (Fedora Kinoite, Bazzite, Aurora, etc.).

## Settings

*System Settings → Desktop Effects → Ventanas inactivas* (configure button):

| Option | Default | What it does |
|---|---|---|
| Inactive opacity | 40 % | 100 % = no transparency |
| Dim inactive | 40 % | 0 % = no dimming |

From the terminal:

```bash
kwriteconfig6 --file kwinrc --group Effect-ventanas-inactivas --key Inactive 60
kwriteconfig6 --file kwinrc --group Effect-ventanas-inactivas --key Dim 25
dbus-send --session --dest=org.kde.KWin /Effects org.kde.kwin.Effects.reconfigureEffect string:ventanas-inactivas
```

## Update

```bash
cd kwin-ventanas-inactivas && git pull && ./install.sh
```

## Uninstall

```bash
cd kwin-ventanas-inactivas && ./uninstall.sh
```

Restores *Dim Inactive* and *Translucency* to how you had them before.

## Blur behind windows

This effect only does transparency and dimming. For a frosted-glass look, combine it with [Better Blur DX](https://github.com/xarblu/kwin-effects-better-blur-dx) and enable blur for all windows there.

## Compatibility

- KDE Plasma 6, tested on Plasma 6.7.5 with Wayland (Fedora 44 Kinoite).
- Should work on X11, but untested.

## License

[GPL-3.0-or-later](LICENSE)
