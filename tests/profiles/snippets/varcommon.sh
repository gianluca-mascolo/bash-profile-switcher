# shellcheck shell=bash
SNIPPET_NAME="varcommon"
case "$1" in
load)
    export check_var_common="${common_value:-}"
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    unset check_var_common
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
