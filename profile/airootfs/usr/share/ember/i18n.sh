# Ember OS: язык для скриптов.  msg "Українською" "In English" "По-русски"
ember_lang() {
    local l=""
    [ -n "${HOME:-}" ] && l=$(cat "$HOME/.config/ember/lang" 2>/dev/null)
    if [ -z "$l" ]; then
        case "${LANG:-}" in en*) l=en ;; ru*) l=ru ;; *) l=uk ;; esac
    fi
    echo "$l"
}
msg() {
    case "$(ember_lang)" in
        en) echo "$2" ;;
        ru) echo "${3:-$1}" ;;
        *)  echo "$1" ;;
    esac
}
