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
mv "$PROFILE/packages.tmp" "$PROFILE/packages.x86_64"

# Extra pacman repos / options (multilib for Steam & Wine)
if [[ -f "$REPO/profile/pacman.extra.conf" ]]; then
  cat "$REPO/profile/pacman.extra.conf" >> "$PROFILE/pacman.conf"
fi

# ISO identity
sed -i \
  -e 's|^iso_name=.*|iso_name="emberos"|' \
  -e 's|^iso_label=.*|iso_label="EMBER_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"|' \
  -e 's|^iso_publisher=.*|iso_publisher="Ember OS <https://github.com/Claude0S/EmberOS>"|' \
  -e 's|^iso_application=.*|iso_application="Ember OS Live/Install"|' \
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

log "Profile ready:"
grep -E '^(iso_name|iso_label|iso_publisher)=' "$PROFILE/profiledef.sh"
echo "packages: $(wc -l < "$PROFILE/packages.x86_64")"

log "Building ISO (this takes a while)"
mkdir -p "$OUT"
mkarchiso -v -w "$WORK" -o "$OUT" "$PROFILE"

cd "$OUT"
for iso in *.iso; do sha256sum "$iso" > "$iso.sha256"; done
log "Done:"
ls -lh "$OUT"
