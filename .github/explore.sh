pacman -S --noconfirm --needed git curl >/dev/null 2>&1
cd /tmp && git clone -q https://aur.archlinux.org/calamares.git aur-cal && . aur-cal/PKGBUILD
curl -fsSL -o cal.tar.gz "${source[0]#*::}" && mkdir cal && tar -xzf cal.tar.gz -C cal --strip-components=1
for m in fstab mount umount; do echo "######## $m.conf"; grep -vE '^\s*#|^\s*$' cal/src/modules/$m/$m.conf; echo "######## $m.schema"; cat cal/src/modules/$m/$m.schema.yaml; done
echo "######## users passwordRequirements"; grep -n -A12 "passwordRequirements" cal/src/modules/users/users.conf | grep -v "^\S*-\s*#" | head -30
echo "######## partition swap keys"; grep -nE "swap|Swap" cal/src/modules/partition/partition.schema.yaml
