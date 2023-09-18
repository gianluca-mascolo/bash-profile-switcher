# shellcheck shell=bash
SNIPPET_NAME="$(basename "${BASH_SOURCE[0]}" .sh)"
case "$1" in
load)
    # load your settings here >>>
    export var1="test1 variable"
    # <<<
    _snippet push "$SNIPPET_NAME" 2>/dev/null
    ;;
unload)
    # unload your settings here >>>
    export var1="test1 variable"
    # <<<
    _snippet pop "$SNIPPET_NAME" 2>/dev/null
    ;;
*)
    true
    ;;
esac

return 0
