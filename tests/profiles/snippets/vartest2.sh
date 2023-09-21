# shellcheck shell=bash
SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    export check_var_test2="test2 variable"
    export common_value="test2 common"
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    unset check_var_test2
    unset common_value
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
