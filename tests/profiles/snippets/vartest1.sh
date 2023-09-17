# shellcheck shell=bash
SNIPPET_NAME="vartest1"
case "$1" in
load)
    export check_var_test1="test1 variable"
    export common_value="test1 common"
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    unset check_var_test1
    unset common_value
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
