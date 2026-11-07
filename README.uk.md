<p align="center">
  <img src="assets/fox-avatar.png" width="180" alt="Ember OS fox">
</p>

<h1 align="center">Ember OS</h1>

<p align="center">
  Тепла, гарна й легка система на базі Arch Linux.<br>
  A warm, good-looking and lightweight Arch-based system.
</p>

<p align="center">
  <img src="assets/wallpaper.png" width="720" alt="Ember OS wallpaper">
</p>

<p align="center"><a href="README.md">English</a> · <b>Українська</b> · <a href="README.ru.md">Русский</a></p>

## Завантажити

Готовий ISO — на сторінці **[Releases](../../releases/latest)** (файл `emberos-….iso`).
Кожна збірка автоматично запускається у віртуальній машині, скриншоти — в релізі.

## Що всередині

- **Робочий стіл** Hyprland: напівпрозорі вікна, плавні анімації, панель, док, обої з озером
- **Віджети**: музика (Spotify, YouTube у Firefox, будь-який плеєр), годинник, погода, процесор/памʼять/батарея — перетягуються мишкою
- **Win + Enter** — командний рядок Ember на весь екран, `/desktop` — назад
- **Програми**: Firefox, Claude в окремому вікні, Steam, Hydra Launcher, файли `.exe` подвійним кліком
- **Драйвери** — автоматично під будь-яке залізо (Intel, AMD, NVIDIA, Wi-Fi, звук, ноутбуки)
- **Встановлювач** з Wi-Fi: стерти диск / поруч з Windows / замінити розділ / вручну
- **Красиве завантаження**: меню, заставка з лисеням, екран входу й блокування
- **Мови**: українська, English, русский

## Команди (Win + Enter)

| Команда | Що робить |
|---|---|
| `/search котики` | Firefox з пошуком |
| `/desktop` | повернутися на робочий стіл |
| `/download steam` | встановити програму (`/apps` — список) |
| `/little` · `/full` | легкий режим для старих компʼютерів · повний режим |
| `/widgets` | віджети: `on`/`off`/`opacity`/`scale`/`reset` |
| `/theme night` | тема: `ember`, `night`, `ocean`, `forest`, `sakura`, `mono`, `aurora`, `cyber`, `autumn`, `desert`, `winter`, `cosmos` (кольори, лисеня й обої разом) |
| `/mascot ember` | лисеня від іншої теми (`auto` — як у теми) |
| `/wallpaper ocean` | обої від іншої теми або свій файл: `/wallpaper ~/Pictures/фото.jpg` (`auto` — як у теми) |
| `/status` | процесор, памʼять, диск, батарея |
| `/drivers` | перевірити драйвери |
| `/wifi` · `/update` · `/files` | Wi-Fi · оновлення · провідник |
| `/antivirus` | Ember Антивірус: швидка/повна перевірка, папка, карантин, файрвол (ClamAV + ufw) |
| `/office` · `/calc` | Ember Office (Write · Slides · Sheets — відкриває/зберігає .docx .pptx .xlsx, шаблони в кольорах теми) · калькулятор у кольорах теми |
| `Super+Space` | Ember Launcher: програми, ігри з обкладинками, недавні, команди — під тему |
| `/lang uk` · `/lang en` · `/lang ru` | мова |

Усе інше, що ти напишеш без `/`, виконується як звичайна команда терміналу.

## Гарячі клавіші

`Win+Enter` командний рядок · `Win+D` програми · `Win+T` термінал · `Win+E` файли · `Win+B` браузер · `Win+L` блокування · `Win+Q` закрити вікно · `Win+F` на весь екран · `Win+1…9` робочі столи · `Print` скриншот · `Alt+Shift` мова клавіатури (EN · UA · RU)

## Як спробувати

**VirtualBox:** нова ВМ → тип *Linux / Arch Linux (64-bit)*, 4 ГБ памʼяті, 2+ ядра, диск 30 ГБ.
Display → Graphics Controller **VMSVGA**, увімкни **3D Acceleration**, Video Memory 128 МБ. Підключи ISO і запусти.

**Флешка:** запиши ISO через [Ventoy](https://www.ventoy.net), Rufus (режим DD) або balenaEtcher.
Перед запуском вимкни **Secure Boot** у BIOS (ThinkPad: F1 → Security → Secure Boot → Disabled).

## Збірка вручну / Manual build

```bash
docker run --rm --privileged -v "$PWD:/repo" archlinux:latest bash /repo/build.sh
# ISO зʼявиться в ./out
```

---

Ember OS is an independent hobby project. It is not affiliated with Arch Linux, Anthropic, Valve, or any other company.
