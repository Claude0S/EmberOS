# Ember OS: выбор языка для скриптов.  Использование:  . /usr/share/ember/i18n.sh;  msg "Українською" "In English"
ember_lang() {
    local l=""
    [ -n "${HOME:-}" ] && l=$(cat "$HOME/.config/ember/lang" 2>/dev/null)
    if [ -z "$l" ]; then
        case "${LANG:-}" in en*) l=en ;; *) l=uk ;; esac
    fi
    echo "$l"
}
msg() { if [ "$(ember_lang)" = en ]; then echo "$2"; else echo "$1"; fi; }
