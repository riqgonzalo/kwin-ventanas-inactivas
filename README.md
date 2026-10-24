# Ventanas inactivas — efecto para KWin (KDE Plasma 6)

Hace **transparentes y más oscuras solo las ventanas que no tienes seleccionadas**.
La ventana en la que trabajas queda siempre sólida.

🌐 Página del proyecto: https://riqgonzalo.github.io/kwin-ventanas-inactivas/

## ¿Por qué no usar los efectos que ya trae KDE?

Con *Translucidez* y *Oscurecer inactivas*, la ventana seleccionada a veces se vuelve
transparente u oscura. Pasa porque KDE da el foco por un momento a ventanas que no ves:
la pasarela de grabación de pantalla (`xwaylandvideobridge`), un panel, un menú
o una notificación. Esos efectos creen entonces que tu ventana está inactiva.

**Ventanas inactivas** lo evita así:

- Ignora paneles, menús, notificaciones, el escritorio y las ventanas ocultas. Si el foco
  pasa a una de ellas, tu última ventana seleccionada sigue sólida.
- Los diálogos de la ventana seleccionada, y la ventana dueña de un diálogo, también se ven sólidos.
- Las ventanas a pantalla completa nunca se tocan.
- Cada vez que cambias de ventana recalcula todas desde cero, así que nunca se queda en un estado equivocado.
- Hace la transparencia y el oscurecido en un solo efecto.

## Instalación

```bash
git clone https://github.com/riqgonzalo/kwin-ventanas-inactivas.git
cd kwin-ventanas-inactivas
./install.sh
```

El instalador:

1. Copia el efecto a `~/.local/share/kwin-wayland/effects/` (y a las carpetas `kwin-x11` y `kwin` para otras versiones de Plasma).
2. Lo activa.
3. Desactiva *Oscurecer inactivas* y la opción de ventanas inactivas de *Translucidez* para que no se dupliquen.
4. Lo carga al momento, sin cerrar sesión.

No necesita permisos de administrador. Funciona también en sistemas inmutables
(Fedora Kinoite, Bazzite, Aurora, etc.).

## Configuración

*Preferencias del sistema → Efectos del escritorio → Ventanas inactivas* (botón de configurar):

| Opción | Por defecto | Qué hace |
|---|---|---|
| Opacidad de las inactivas | 40 % | 100 % = sin transparencia |
| Oscurecer las inactivas | 40 % | 0 % = sin oscurecer |

También desde la terminal:

```bash
kwriteconfig6 --file kwinrc --group Effect-ventanas-inactivas --key Inactive 60
kwriteconfig6 --file kwinrc --group Effect-ventanas-inactivas --key Dim 25
dbus-send --session --dest=org.kde.KWin /Effects org.kde.kwin.Effects.reconfigureEffect string:ventanas-inactivas
```

## Actualizar

```bash
cd kwin-ventanas-inactivas
git pull
./install.sh
```

## Desinstalar

```bash
cd kwin-ventanas-inactivas
./uninstall.sh
```

## Desenfoque detrás de las ventanas

Este efecto solo hace transparencia y oscurecido. Para el aspecto de cristal esmerilado,
combínalo con [Better Blur DX](https://github.com/xarblu/kwin-effects-better-blur-dx)
y activa en él el desenfoque de todas las ventanas.

## Compatibilidad

- KDE Plasma 6, probado en Plasma 6.7.5 con Wayland (Fedora 44 Kinoite).
- Debería funcionar en X11, pero no está probado.

## Licencia

[GPL-3.0-or-later](LICENSE)
