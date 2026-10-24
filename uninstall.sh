#!/usr/bin/env bash
# Desinstala el efecto "Ventanas inactivas".
set -euo pipefail

ID=ventanas-inactivas
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

dbus-send --session --print-reply --dest=org.kde.KWin /Effects \
    org.kde.kwin.Effects.unloadEffect "string:$ID" >/dev/null 2>&1 || true
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" false
for dir in kwin-wayland kwin-x11 kwin; do
    rm -rf "$DATA/$dir/effects/$ID"
done
dbus-send --session --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

echo "Desinstalado. Si quieres, vuelve a activar \"Translucidez\" u \"Oscurecer inactivas\" en Efectos del escritorio."
