#!/usr/bin/env bash
# Instala el efecto "Ventanas inactivas" para KWin (KDE Plasma 6).
set -euo pipefail

ID=ventanas-inactivas
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

if ! command -v kwriteconfig6 >/dev/null; then
    echo "No se encontró kwriteconfig6. Este efecto necesita KDE Plasma 6." >&2
    exit 1
fi

# Plasma 6.4+ busca en kwin-wayland / kwin-x11; versiones anteriores en kwin.
for dir in kwin-wayland kwin-x11 kwin; do
    dest="$DATA/$dir/effects/$ID"
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -r "$SRC/." "$dest/"
done
echo "Efecto copiado en $DATA/kwin*/effects/$ID"

# Los efectos de KDE que hacen lo mismo se desactivan para no duplicar.
kwriteconfig6 --file kwinrc --group Plugins --key diminactiveEnabled false
for g in Effect-translucency Effect-Translucency; do
    kwriteconfig6 --file kwinrc --group "$g" --key Inactive 100
done
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true
echo "Activado. Se desactivó \"Oscurecer inactivas\" y la opción de ventanas inactivas de \"Translucidez\"."

# Recargar sin cerrar sesión, si KWin está en marcha.
kwin() {
    dbus-send --session --print-reply --dest=org.kde.KWin /Effects \
        "org.kde.kwin.Effects.$1" "string:$2" >/dev/null 2>&1 || true
}
kwin unloadEffect diminactive
kwin unloadEffect translucency
kwin unloadEffect "$ID"
kwin loadEffect "$ID"
dbus-send --session --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1 || true

echo "Listo. Ajusta los valores en Preferencias del sistema → Efectos del escritorio → Ventanas inactivas."
