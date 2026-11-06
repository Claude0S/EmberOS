#!/usr/bin/env bash
# Ember OS — ISO build script.
# Runs inside an Arch Linux container (see .github/workflows/build.yml):
#   docker run --rm --privileged -v "$PWD:/repo" archlinux:latest bash /repo/build.sh
#
# How it works: we take the official archiso "releng" profile as a base
# (so boot loaders stay compatible with the current archiso version)
# and lay the Ember OS overlay, packages and branding on top of it.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
OUT="${OUT:-$REPO/out}"
WORK="${WORK:-/tmp/ember-work}"
PROFILE="${PROFILE:-/tmp/ember-profile}"

log() { printf '\033[38;2;232;135;90m==> %s\033[0m\n' "$*"; }

log "Installing build tools"
pacman -Syu --noconfirm --needed archiso

log "Assembling profile from releng + Ember overlay"
rm -rf "$PROFILE" "$WORK"
cp -r /usr/share/archiso/configs/releng "$PROFILE"
cp -rT "$REPO/profile/airootfs" "$PROFILE/airootfs"

# Packages: releng list + ours, without duplicates
{
  cat "$PROFILE/packages.x86_64"
  grep -vE '^[[:space:]]*(#|$)' "$REPO/profile/packages.x86_64"
} | sort -u > "$PROFILE/packages.tmp"
# ...minus what we don't need from releng (keeps the ISO under 2 GiB)
if [[ -f "$REPO/profile/packages.remove" ]]; then
  grep -vxFf <(grep -vE '^[[:space:]]*(#|$)' "$REPO/profile/packages.remove") \
    "$PROFILE/packages.tmp" > "$PROFILE/packages.tmp2" || true
  mv "$PROFILE/packages.tmp2" "$PROFILE/packages.tmp"
fi
mv "$PROFILE/packages.tmp" "$PROFILE/packages.x86_64"

# Extra pacman repos / options (multilib for Steam & Wine)
if [[ -f "$REPO/profile/pacman.extra.conf" ]]; then
  cat "$REPO/profile/pacman.extra.conf" >> "$PROFILE/pacman.conf"
fi
# The live system / installed system get the same pacman.conf (with multilib)
mkdir -p "$PROFILE/airootfs/etc"
cp "$PROFILE/pacman.conf" "$PROFILE/airootfs/etc/pacman.conf"

# --- AUR packages (Calamares) -> local repo used only while building ---
if [[ -f "$REPO/profile/aur.txt" ]]; then
  log "Building AUR packages"
  pacman -S --noconfirm --needed base-devel git sudo >/dev/null
  id builder >/dev/null 2>&1 || useradd -m builder
  echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder
  AURREPO=/tmp/ember-aur
  rm -rf "$AURREPO"; mkdir -p "$AURREPO"; chown builder: "$AURREPO"
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    CACHE="$REPO/aur-cache"; mkdir -p "$CACHE"
    if compgen -G "$CACHE/$pkg-[0-9]*.pkg.tar.zst" >/dev/null; then
      log "  $pkg: from cache"
      cp "$CACHE/$pkg"-[0-9]*.pkg.tar.zst "$AURREPO/"
      continue
    fi
    log "  makepkg $pkg"
    sudo -u builder bash -c "set -e; cd /tmp; rm -rf aur-$pkg; git clone -q https://aur.archlinux.org/$pkg.git aur-$pkg; cd aur-$pkg; makepkg -s --noconfirm --needed --nocheck; cp ./*.pkg.tar.zst $AURREPO/"
    cp "$AURREPO/$pkg"-[0-9]*.pkg.tar.zst "$CACHE/"
  done < "$REPO/profile/aur.txt"
  repo-add -q "$AURREPO/ember-aur.db.tar.gz" "$AURREPO"/*.pkg.tar.zst
  # Only the build-time pacman.conf knows this repo (not the live/installed system)
  printf '\n[ember-aur]\nSigLevel = Optional TrustAll\nServer = file://%s\n' "$AURREPO" >> "$PROFILE/pacman.conf"
fi

# --- GRUB theme fonts (for the installed system's boot menu) ---
pacman -S --noconfirm --needed grub ttf-dejavu freetype2 >/dev/null
GT="$PROFILE/airootfs/usr/share/grub/themes/ember"
if [[ -d "$GT" ]]; then
  grub-mkfont -s 16 -o "$GT/dejavu_16.pf2" /usr/share/fonts/TTF/DejaVuSans.ttf
  grub-mkfont -s 22 -o "$GT/dejavu_22.pf2" /usr/share/fonts/TTF/DejaVuSans.ttf
  grub-mkfont -s 22 -o "$GT/dejavu_bold_22.pf2" /usr/share/fonts/TTF/DejaVuSans-Bold.ttf
  grub-mkfont -s 32 -o "$GT/dejavu_bold_32.pf2" /usr/share/fonts/TTF/DejaVuSans-Bold.ttf
fi

# ISO identity
sed -i \
  -e 's|^iso_name=.*|iso_name="emberos"|' \
  -e 's|^iso_label=.*|iso_label="EMBER_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"|' \
  -e 's|^iso_publisher=.*|iso_publisher="Ember OS <https://github.com/Claude0S/EmberOS>"|' \
  -e 's|^iso_application=.*|iso_application="Ember OS Live/Install"|' \
  -e "s|^airootfs_image_tool_options=.*|airootfs_image_tool_options=('-comp' 'xz' '-b' '1M')|" \
  "$PROFILE/profiledef.sh"

# Executable permissions for our scripts (appended to the associative array)
{
  echo ""
  echo "# --- Ember OS ---"
  while IFS= read -r -d '' f; do
    rel="/${f#"$PROFILE/airootfs/"}"
    echo "file_permissions[\"$rel\"]=\"0:0:755\""
  done < <(find "$PROFILE/airootfs/usr/local/bin" "$PROFILE/airootfs/usr/lib/ember" \
             -type f -print0 2>/dev/null)
} >> "$PROFILE/profiledef.sh"

# Boot menu names: "Arch Linux" -> "Ember OS"
grep -rlI "Arch Linux" "$PROFILE/grub" "$PROFILE/syslinux" "$PROFILE/efiboot" 2>/dev/null \
  | xargs -r sed -i 's/Arch Linux install medium/Ember OS/g; s/Arch Linux/Ember OS/g' || true

# --- Part 2: graphical live session ---
# Boot splash picture for BIOS (syslinux) menu
cp "$REPO/profile/airootfs/usr/share/ember/syslinux/splash.png" "$PROFILE/syslinux/splash.png"
# No text-console autologin: SDDM takes over
rm -f "$PROFILE/airootfs/etc/systemd/system/getty@tty1.service.d/autologin.conf"
# NetworkManager instead of systemd-networkd / iwd
rm -f "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/systemd-networkd.service" \
      "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service" \
      "$PROFILE/airootfs/etc/systemd/system/sockets.target.wants/systemd-networkd.socket" \
      "$PROFILE/airootfs/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service" \
      "$PROFILE/airootfs/etc/systemd/system/systemd-networkd-wait-online.service.wants/"* 2>/dev/null || true
# Plymouth in the live initramfs (after kms)
for f in "$PROFILE"/airootfs/etc/mkinitcpio.conf.d/*.conf "$PROFILE/airootfs/etc/mkinitcpio.conf"; do
  [[ -f "$f" ]] && grep -q '^HOOKS=' "$f" && grep -qw kms "$f" && ! grep -qw plymouth "$f" \
    && sed -i '/^HOOKS=/ s/\bkms\b/kms plymouth/' "$f" && echo "plymouth hook -> $f"
done
# quiet boot + splash on every boot entry
grep -rlI 'archisobasedir=' "$PROFILE/grub" "$PROFILE/syslinux" "$PROFILE/efiboot" 2>/dev/null \
  | xargs -r sed -i '/archisobasedir=/ { /splash/! s/archisobasedir=/quiet splash loglevel=3 vt.global_cursor_default=0 copytoram=n archisobasedir=/ }' || true

log "Profile ready:"
grep -E '^(iso_name|iso_label|iso_publisher)=' "$PROFILE/profiledef.sh"
echo "packages: $(wc -l < "$PROFILE/packages.x86_64")"

log "Building ISO (this takes a while)"
mkdir -p "$OUT"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"

# --- Check: every app in the menu/dock has an icon ---
ROOTFS="$WORK/x86_64/airootfs"
if [[ -d "$ROOTFS/usr/share/applications" ]]; then
  log "Icon check"
  missing=0
  for d in "$ROOTFS"/usr/share/applications/*.desktop; do
    grep -q '^NoDisplay=true' "$d" && continue
    icon=$(grep -m1 '^Icon=' "$d" | cut -d= -f2-)
    [[ -z "$icon" ]] && continue
    if [[ "$icon" == /* ]]; then
      [[ -e "$ROOTFS$icon" ]] && continue
    elif find "$ROOTFS/usr/share/icons/Papirus-Dark" "$ROOTFS/usr/share/icons/Papirus" \
              "$ROOTFS/usr/share/icons/hicolor" "$ROOTFS/usr/share/icons/Adwaita" "$ROOTFS/usr/share/pixmaps" \
              -name "$icon.*" -print -quit 2>/dev/null | grep -q .; then
      continue
    fi
    echo "  MISSING ICON: $(basename "$d") -> $icon"; missing=$((missing+1))
  done
  echo "  icons missing: $missing"
fi

cd "$OUT"
for iso in *.iso; do sha256sum "$iso" > "$iso.sha256"; done
log "Done:"
ls -lh "$OUT"
