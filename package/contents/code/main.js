/*
 * Ventanas inactivas — efecto de KWin para KDE Plasma 6.
 * SPDX-FileCopyrightText: 2026 Gonzalo Riquelme <riqgonzalo@gmail.com>
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * La ventana seleccionada (y sus diálogos) queda sólida; el resto se vuelve
 * transparente y más oscura. Si el foco pasa a algo que no es una ventana
 * normal (panel, menú, notificación, escritorio, pasarela de grabación...)
 * se mantiene la última ventana seleccionada. Todo se recalcula desde cero
 * en cada cambio, así que el estado nunca se queda "confundido".
 */
/*global effect, effects, animate, cancel, set, animationTime, Effect */
"use strict";

var vi = {
    opacity: 0.4,
    brightness: 0.6,
    duration: animationTime(200),
    focus: null,

    loadConfig: function () {
        vi.opacity = effect.readConfig("Inactive", 40) / 100;
        vi.brightness = 1 - effect.readConfig("Dim", 40) / 100;
        effects.stackingOrder.forEach(vi.clear);
        vi.refresh(true);
    },

    // Ventanas que el usuario selecciona de verdad.
    isUserWindow: function (w) {
        return !!w && w.deleted !== true && w.managed !== false &&
            (w.normalWindow === true || w.dialog === true) &&
            w.skipTaskbar !== true && w.desktopWindow !== true &&
            w.dock !== true && w.popupWindow !== true && w.splash !== true &&
            String(w.windowClass).indexOf("xwaylandvideobridge") === -1;
    },

    mains: function (w) {
        try { return w.mainWindows() || []; } catch (e) { return []; }
    },

    isBright: function (w) {
        var f = vi.focus;
        if (!f || w === f || w.fullScreen === true) {
            return true;
        }
        // Ventana principal del diálogo seleccionado, o diálogo de la seleccionada.
        if (vi.mains(f).indexOf(w) !== -1 || vi.mains(w).indexOf(f) !== -1) {
            return true;
        }
        return false;
    },

    updateFocus: function () {
        var a = effects.activeWindow;
        if (vi.isUserWindow(a)) {
            vi.focus = a;
        } else if (vi.focus && (vi.focus.deleted === true || vi.focus.minimized === true)) {
            vi.focus = null;
        }
    },

    clear: function (w) {
        if (w && w.viAnim !== undefined) {
            cancel(w.viAnim);
            w.viAnim = undefined;
        }
    },

    apply: function (w, instant) {
        var dim = vi.isUserWindow(w) && w.minimized !== true && !vi.isBright(w);
        if (dim && w.viAnim === undefined) {
            w.viAnim = set({
                window: w,
                duration: instant ? 1 : vi.duration,
                animations: [
                    { type: Effect.Opacity, to: vi.opacity },
                    { type: Effect.Brightness, to: vi.brightness }
                ]
            });
        } else if (!dim && w.viAnim !== undefined) {
            vi.clear(w);
            if (!instant && w.visible !== false && w.deleted !== true) {
                animate({
                    window: w,
                    duration: vi.duration,
                    animations: [
                        { type: Effect.Opacity, from: vi.opacity },
                        { type: Effect.Brightness, from: vi.brightness }
                    ]
                });
            }
        }
    },

    refresh: function (instant) {
        vi.updateFocus();
        effects.stackingOrder.forEach(function (w) { vi.apply(w, instant === true); });
    },

    manage: function (w) {
        w.minimizedChanged.connect(function () { vi.clear(w); vi.refresh(true); });
        w.windowFullScreenChanged.connect(function () { vi.refresh(false); });
    },

    init: function () {
        effect.configChanged.connect(vi.loadConfig);
        effects.windowAdded.connect(function (w) { vi.manage(w); vi.refresh(false); });
        effects.windowClosed.connect(function (w) {
            vi.clear(w);
            if (w === vi.focus) { vi.focus = null; }
            vi.refresh(false);
        });
        effects.windowActivated.connect(function () { vi.refresh(false); });
        effects.desktopChanged.connect(function () { vi.refresh(true); });
        effects.stackingOrder.forEach(vi.manage);
        vi.loadConfig();
    }
};

vi.init();
