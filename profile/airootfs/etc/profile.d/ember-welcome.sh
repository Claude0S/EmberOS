# Ember OS: show fastfetch once per interactive login shell.
case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

if [ -z "${EMBER_FETCHED:-}" ] && command -v fastfetch >/dev/null 2>&1; then
  EMBER_FETCHED=1
  export EMBER_FETCHED
  fastfetch
fi
