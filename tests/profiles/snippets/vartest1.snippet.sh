# shellcheck shell=bash
SNIPPET_NAME="vartest1"
case "$1" in
load)
    export check_var_test1="test1 variable"
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    unset check_var_test1
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    true
    ;;
esac

return 0
