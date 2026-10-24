#!/usr/bin/env bash
# Instala el efecto "Ventanas inactivas" para KWin (KDE Plasma 6).
set -euo pipefail

ID=ventanas-inactivas
GROUP="Effect-$ID"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/package"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"

error() { echo "Error: $*" >&2; exit 1; }

command -v kwriteconfig6 >/dev/null && command -v kreadconfig6 >/dev/null ||
    error "no se encontró kwriteconfig6. Este efecto necesita KDE Plasma 6."

# --- Versión de Plasma -------------------------------------------------------
version=""
for bin in kwin_wayland kwin_x11 plasmashell; do
    if command -v "$bin" >/dev/null; then
        version="$("$bin" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || true)"
        [[ -n "$version" ]] && break
    fi
done
[[ -n "$version" ]] || error "no se pudo saber qué versión de KDE Plasma tienes."
major=${version%%.*}; minor=${version#*.}
(( major == 6 )) || error "necesitas KDE Plasma 6 (tienes $version)."

# Plasma 6.4+ separa los efectos por sesión (kwin-wayland / kwin-x11).
if (( minor >= 4 )); then dirs=(kwin-wayland kwin-x11); else dirs=(kwin); fi

# --- Copiar el efecto --------------------------------------------------------
for dir in kwin-wayland kwin-x11 kwin; do rm -rf "$DATA/$dir/effects/$ID"; done
for dir in "${dirs[@]}"; do
    mkdir -p "$DATA/$dir/effects/$ID"
    cp -r "$SRC/." "$DATA/$dir/effects/$ID/"
done
echo "Efecto copiado (Plasma $version) en: ${dirs[*]/#/$DATA/}"

# --- Copia de seguridad y ajustes -------------------------------------------
if [[ -f "$CONF/kwinrc" && ! -f "$CONF/kwinrc.antes-de-$ID" ]]; then
    cp "$CONF/kwinrc" "$CONF/kwinrc.antes-de-$ID"
    echo "Copia de seguridad de tu configuración: $CONF/kwinrc.antes-de-$ID"
fi

# Guardar los valores actuales para que uninstall.sh pueda devolverlos.
if [[ "$(kreadconfig6 --file kwinrc --group "$GROUP" --key Saved)" != "true" ]]; then
    kwriteconfig6 --file kwinrc --group "$GROUP" --key PrevDimInactive \
        "$(kreadconfig6 --file kwinrc --group Plugins --key diminactiveEnabled --default false)"
    kwriteconfig6 --file kwinrc --group "$GROUP" --key PrevTranslucencyInactive \
        "$(kreadconfig6 --file kwinrc --group Effect-translucency --key Inactive --default 100)"
    kwriteconfig6 --file kwinrc --group "$GROUP" --key Saved true
fi

# Los efectos de KDE que hacen lo mismo se desactivan para no duplicar.
kwriteconfig6 --file kwinrc --group Plugins --key diminactiveEnabled false
for g in Effect-translucency Effect-Translucency; do
    kwriteconfig6 --file kwinrc --group "$g" --key Inactive 100
done
kwriteconfig6 --file kwinrc --group Plugins --key "${ID}Enabled" true
echo "Activado. Se desactivó \"Oscurecer inactivas\" y la opción de ventanas inactivas de \"Translucidez\"."

# --- Recargar sin cerrar sesión ---------------------------------------------
kwin() {
    dbus-send --session --print-reply --reply-timeout=3000 --dest=org.kde.KWin /Effects \
        "org.kde.kwin.Effects.$1" "string:$2" >/dev/null 2>&1 || true
}
kwin unloadEffect diminactive
kwin unloadEffect "$ID"
kwin loadEffect "$ID"
kwin reconfigureEffect translucency

echo "Listo. Ajusta los valores en Preferencias del sistema → Efectos del escritorio → Ventanas inactivas."
