"""Спільне для графічних програм Ember (калькулятор, Ember Office):
кольори поточної теми, мова, живе оновлення при /theme."""
import json
import os

HOME = os.path.expanduser("~")
THEME = os.path.join(HOME, ".config/ember/theme.json")
DEFAULT = {"name": "Ember", "accent": "#e8875a", "accent2": "#f3a46c", "accent3": "#f7c59a",
           "fg": "#fbeee0", "bg": "#1a1320", "surface": "#523049"}


def lang():
    try:
        l = open(os.path.join(HOME, ".config/ember/lang")).read().strip()
        if l in ("uk", "en", "ru"):
            return l
    except OSError:
        pass
    env = os.environ.get("LANG", "")
    return "en" if env.startswith("en") else "ru" if env.startswith("ru") else "uk"


def tr(uk, en, ru):
    return {"uk": uk, "en": en, "ru": ru}[lang()]


def theme():
    t = dict(DEFAULT)
    try:
        with open(THEME) as f:
            data = json.load(f)
        for k in DEFAULT:
            v = data.get(k)
            if isinstance(v, str) and v:
                t[k] = v if (k == "name" or v.startswith("#")) else "#" + v
        if isinstance(data.get("fox"), str):
            t["fox"] = data["fox"]
    except (OSError, ValueError):
        pass
    if not os.path.exists(t.get("fox", "")):
        t["fox"] = "/usr/share/ember/icons/fox-small.png"
    return t


def rgba(hexcol, a):
    h = hexcol.lstrip("#")
    return f"rgba({int(h[0:2], 16)},{int(h[2:4], 16)},{int(h[4:6], 16)},{a})"


class ThemedCss:
    """Підключає CSS, побудований з кольорів теми, і перебудовує його при /theme."""

    def __init__(self, builder, on_change=None):
        import gi
        gi.require_version("Gtk", "4.0")
        from gi.repository import Gdk, Gio, GLib, Gtk
        self._GLib, self._Gtk = GLib, Gtk
        self.builder = builder
        self.on_change = on_change
        self.provider = Gtk.CssProvider()
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), self.provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1)
        self.apply()
        try:
            self.mon = Gio.File.new_for_path(THEME).monitor_file(Gio.FileMonitorFlags.NONE, None)
            self.mon.connect("changed", lambda *a: self._GLib.timeout_add(250, self._reload))
        except GLib.Error:
            self.mon = None

    def _reload(self):
        self.apply()
        if self.on_change:
            self.on_change(self.t)
        return False

    def apply(self):
        self.t = theme()
        css = self.builder(self.t)
        try:
            self.provider.load_from_string(css)
        except AttributeError:          # GTK < 4.12
            self.provider.load_from_data(css.encode())
