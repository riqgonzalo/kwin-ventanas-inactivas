#!/usr/bin/env bash
# Desinstala el efecto "Ventanas inactivas" y devuelve los ajustes que tenías antes.
set -euo pipefail

ID=ventanas-inactivas
GROUP="Effect-$ID"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

kwin() {
    dbus-send --session --print-reply --reply-timeout=3000 --dest=org.kde.KWin /Effects \
        "org.kde.kwin.Effects.$1" "string:$2" >/dev/null 2>&1 || true
}

kwin unloadEffect "$ID"
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" false
for dir in kwin-wayland kwin-x11 kwin; do
    rm -rf "$DATA/$dir/effects/$ID"
done

# Devolver los ajustes que había antes de instalar.
if [[ "$(kreadconfig6 --file kwinrc --group "$GROUP" --key Saved)" == "true" ]]; then
    dim="$(kreadconfig6 --file kwinrc --group "$GROUP" --key PrevDimInactive --default false)"
    tr="$(kreadconfig6 --file kwinrc --group "$GROUP" --key PrevTranslucencyInactive --default 100)"
    kwriteconfig6 --file kwinrc --group Plugins --key diminactiveEnabled "$dim"
    for g in Effect-translucency Effect-Translucency; do
        kwriteconfig6 --file kwinrc --group "$g" --key Inactive "$tr"
    done
    for k in Saved PrevDimInactive PrevTranslucencyInactive; do
        kwriteconfig6 --file kwinrc --group "$GROUP" --key "$k" --delete
    done
    [[ "$dim" == "true" ]] && kwin loadEffect diminactive
    kwin reconfigureEffect translucency
    echo "Se devolvieron tus ajustes anteriores de \"Oscurecer inactivas\" y \"Translucidez\"."
fi

echo "Desinstalado."
