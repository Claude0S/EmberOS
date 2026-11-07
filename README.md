<p align="center">
  <img src="assets/fox-avatar.png" width="180" alt="Ember OS fox">
</p>

<h1 align="center">Ember OS</h1>

<p align="center">
  A warm, good-looking and lightweight Arch-based system.
</p>

<p align="center"><b>English</b> · <a href="README.uk.md">Українська</a> · <a href="README.ru.md">Русский</a></p>

<p align="center">
  <img src="assets/wallpaper.png" width="720" alt="Ember OS wallpaper">
</p>

## Download

Get the ISO from the **[Releases](../../releases/latest)** page (the `emberos-….iso` file, about 1.8 GB).

Every build is tested automatically before it is published:
- the live system boots to the desktop in a virtual machine;
- the installer configuration is checked against the official Calamares schemas;
- Ember OS is installed to a virtual disk, rebooted, and must reach the desktop.

Screenshots from these tests are attached to each release.

## What's inside

- **Desktop**: Hyprland with translucent windows, smooth animations, a top bar, a dock and a lake-at-sunset wallpaper
- **Widgets**: music (Spotify, YouTube in Firefox, any player), clock, weather, CPU / memory / battery. Drag them with the mouse
- **Win + Enter** opens the Ember command line full-screen; `/desktop` takes you back
- **Apps**: Firefox, Claude in its own window, Steam, Hydra Launcher, and `.exe` files that open with a double click
- **Drivers** are installed automatically for any hardware (Intel, AMD, NVIDIA, Wi-Fi, audio, laptops)
- **Installer** with Wi-Fi setup: erase disk / install alongside Windows / replace a partition / manual
- **A polished boot**: themed boot menu, a fox splash screen, and themed login and lock screens
- **Languages**: Ukrainian, English, Russian

## Commands (Win + Enter)

| Command | What it does |
|---|---|
| `/search cats` | open Firefox with a search |
| `/desktop` | back to the desktop |
| `/download steam` | install an app (`/apps` shows the list) |
| `/little` · `/full` | light mode for older computers · full mode |
| `/widgets` | widgets: `on` / `off` / `opacity` / `scale` / `reset` |
| `/theme night` | theme: `ember`, `night`, `ocean`, `forest`, `sakura`, `mono`, `aurora`, `cyber`, `autumn`, `desert`, `winter`, `cosmos` (colours, fox and wallpaper together) |
| `/mascot ember` | fox from another theme (`auto` = follow the theme) |
| `/wallpaper ocean` | wallpaper from another theme, or your own file: `/wallpaper ~/Pictures/photo.jpg` (`auto` = follow the theme) |
| `/status` | CPU, memory, disk, battery |
| `/drivers` | check and install drivers |
| `/wifi` · `/update` · `/files` | Wi-Fi · system update · file manager |
| `/antivirus` | Ember Antivirus: quick/full/folder scan, quarantine, firewall (ClamAV + ufw) |
| `Super+Space` | Ember Launcher: apps, games with covers, recent, Ember commands — follows the theme |
| `/lang uk` · `/lang en` · `/lang ru` | interface language |

Anything you type without a leading `/` runs as a normal terminal command.

## Keyboard shortcuts

| Keys | Action |
|---|---|
| `Win + Enter` | Ember command line (show / hide) |
| `Win + D` | app launcher |
| `Win + T` · `Win + E` · `Win + B` | terminal · files · browser |
| `Win + Q` | close the window |
| `Win + F` | full screen on / off |
| `Win + V` | make the window free-floating (move and resize it like in Windows) |
| `Win` + left mouse drag | move a window |
| `Win` + right mouse drag | resize a window |
| `Win + 1…9` | switch to desktop 1…9 |
| `Win + Shift + 1…9` | send the window to desktop 1…9 (a way to "hide" it without closing) |
| `Win + L` | lock the screen |
| `Print` · `Shift + Print` | screenshot of an area (copied) · full screenshot (saved to Pictures) |
| `Alt + Shift` | keyboard layout EN → UA → RU |

## How to try it

**VirtualBox:** create a new VM with type *Linux / Arch Linux (64-bit)*, 4 GB RAM, 2+ CPUs and a 30 GB disk.
Under Display, set Graphics Controller to **VMSVGA**, enable **3D Acceleration** and set Video Memory to 128 MB. Attach the ISO and start the VM.

**USB stick:** write the ISO with [Ventoy](https://www.ventoy.net), balenaEtcher or Rufus. In Rufus, choose **DD Image mode** when asked.
Turn off **Secure Boot** in the BIOS first. On a ThinkPad: F1 → Security → Secure Boot → Disabled. Then boot from the USB stick (F12 on ThinkPads).

**Installing:** in the welcome window, connect to Wi-Fi and click **Install Ember OS**. On the *Partitions* step, choose **Erase disk** (or **Install alongside** to keep Windows).
After the first boot, Steam, Wine and Hydra Launcher download in the background, and a notification tells you when they are ready.

## Tips

- Lost a widget off-screen? Run `/widgets reset` in the command line.
- An app is missing? Try `/download <name>`, or `/apps` for the list of known apps.
- Old or slow computer? `/little` turns off blur, shadows, heavy animations and widgets.

## Building it yourself

```bash
docker run --rm --privileged -v "$PWD:/repo" archlinux:latest bash /repo/build.sh
# the ISO appears in ./out
```

---

Ember OS is an independent hobby project. It is not affiliated with Arch Linux, Anthropic, Valve, the Hydra project, or any other company.
