<p align="center">
  <img src="assets/fox-avatar.png" width="180" alt="Ember OS fox">
</p>

<h1 align="center">Ember OS</h1>

<p align="center">
  Тёплая, красивая и лёгкая система на базе Arch Linux.<br>
  A warm, good-looking and lightweight Arch-based system.
</p>

<p align="center">
  <img src="assets/wallpaper.png" width="720" alt="Ember OS wallpaper">
</p>

## Скачать / Download

Готовый ISO — на странице **[Releases](../../releases/latest)**.
Каждая сборка автоматически запускается в виртуальной машине, скриншоты прикреплены к релизу.

## Что внутри (план)

- [x] **Часть 1** — основа, брендинг, fastfetch с лисёнком, автосборка ISO
- [x] **Часть 2** — внешний вид: меню загрузки, заставка, экран входа и блокировки, Hyprland, панель, док, виджеты (музыка, часы, погода, система)
- [x] **Часть 3** — `ember-shell`: Win+Enter, `/search`, `/desktop`, `/download`, `/little`, `/full`, `/status`, `/lang`, `/help`
- [x] **Часть 4** — программы: Firefox, Claude, Steam, Hydra Launcher, запуск `.exe`
- [ ] **Часть 5** — автоматические драйверы под любое железо
- [ ] **Часть 6** — графический установщик (Wi-Fi, разметка, установка рядом с Windows)
- [ ] **Часть 7** — українська / English

## Сборка вручную / Manual build

```bash
docker run --rm --privileged -v "$PWD:/repo" archlinux:latest bash /repo/build.sh
# ISO появится в ./out
```

---

Ember OS is an independent hobby project and is not affiliated with Arch Linux or any other company.
